
const express = require('express');
const multer = require('multer');
const ExcelJS = require('exceljs');
const pool = require('../config/database');

const router = express.Router();

// Recebe o arquivo Excel em memória
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024 // máximo de 5 MB
  },
  fileFilter: (req, file, callback) => {
    const nome = file.originalname.toLowerCase();

    if (nome.endsWith('.xlsx')) {
      callback(null, true);
    } else {
      callback(new Error('Envie um arquivo Excel no formato .xlsx'));
    }
  }
});

// Converte valores das células para texto
function lerCelula(valor) {
  if (valor === null || valor === undefined) {
    return '';
  }

  if (typeof valor === 'object') {
    if (valor.text) return String(valor.text).trim();

    if (valor.richText) {
      return valor.richText.map(item => item.text).join('').trim();
    }

    if (valor.result !== undefined) {
      return String(valor.result).trim();
    }
  }

  return String(valor).trim();
}

// POST /importacao/alunos
router.post('/alunos', upload.single('arquivo'), async (req, res) => {
  let conexao;

  try {
    if (!req.file) {
      return res.status(400).json({
        mensagem: 'Nenhum arquivo foi enviado.'
      });
    }

    const workbook = new ExcelJS.Workbook();

    await workbook.xlsx.load(req.file.buffer);

    const planilha = workbook.getWorksheet('Alunos');

    if (!planilha) {
      return res.status(400).json({
        mensagem: 'A planilha precisa ter uma aba chamada Alunos.'
      });
    }

    // Lê os nomes das colunas
    const cabecalho = planilha.getRow(1).values
      .slice(1)
      .map(valor => lerCelula(valor).toLowerCase());

    const colunasObrigatorias = [
      'matricula',
      'nome',
      'curso',
      'turma',
      'anoletivo'
    ];

    const colunasValidas = colunasObrigatorias.every(
      coluna => cabecalho.includes(coluna)
    );

    if (!colunasValidas) {
      return res.status(400).json({
        mensagem: 'As colunas da planilha não correspondem ao modelo do Adver.',
        colunasEsperadas: colunasObrigatorias
      });
    }

    const indice = {};
    cabecalho.forEach((coluna, posicao) => {
      indice[coluna] = posicao + 1;
    });

    const cursosPermitidos = [
      'Administração',
      'Agropecuária',
      'Informática',
      'Mineração'
    ];

    const alunos = [];
    const matriculas = new Set();
    const erros = [];

    // Lê os alunos da planilha
    for (let numero = 2; numero <= planilha.rowCount; numero++) {
      const linha = planilha.getRow(numero);

      const matricula = lerCelula(
        linha.getCell(indice.matricula).value
      );

      const nome = lerCelula(
        linha.getCell(indice.nome).value
      );

      const curso = lerCelula(
        linha.getCell(indice.curso).value
      );

      const turma = lerCelula(
        linha.getCell(indice.turma).value
      );

      const anoLetivo = Number(
        lerCelula(linha.getCell(indice.anoletivo).value)
      );

      // Ignora linhas completamente vazias
      if (!matricula && !nome && !curso && !turma) {
        continue;
      }

      if (!matricula || !nome || !curso || !turma ||
          !Number.isInteger(anoLetivo) ||
          anoLetivo < 2000 || anoLetivo > 2100) {
        erros.push(`Linha ${numero}: existem dados obrigatórios ausentes ou inválidos.`);
        continue;
      }

      if (!cursosPermitidos.includes(curso)) {
        erros.push(`Linha ${numero}: curso "${curso}" não é válido.`);
        continue;
      }

      if (matriculas.has(matricula)) {
        erros.push(`Linha ${numero}: matrícula ${matricula} está repetida na planilha.`);
        continue;
      }

      matriculas.add(matricula);

      alunos.push({
        matricula,
        nome,
        curso,
        turma,
        anoLetivo
      });
    }

    // Não importa parcialmente uma planilha com erros
    if (erros.length > 0) {
      return res.status(400).json({
        mensagem: 'A planilha contém erros. Corrija-os antes de importar.',
        erros
      });
    }

    if (alunos.length === 0) {
      return res.status(400).json({
        mensagem: 'A planilha não contém alunos para importar.'
      });
    }

    conexao = await pool.getConnection();
    await conexao.beginTransaction();

    let novos = 0;
    let atualizados = 0;

    for (const aluno of alunos) {
      // Localiza o curso
      const [cursos] = await conexao.execute(
        'SELECT idCurso FROM curso WHERE nome = ?',
        [aluno.curso]
      );

      let idCurso;

      if (cursos.length > 0) {
        idCurso = cursos[0].idCurso;
      } else {
        const [resultadoCurso] = await conexao.execute(
          'INSERT INTO curso (nome) VALUES (?)',
          [aluno.curso]
        );

        idCurso = resultadoCurso.insertId;
      }

      // Localiza ou cria a turma
      const [turmas] = await conexao.execute(
        `SELECT idTurma FROM turma
         WHERE nome = ? AND anoLetivo = ? AND idCurso = ?`,
        [aluno.turma, aluno.anoLetivo, idCurso]
      );

      let idTurma;

      if (turmas.length > 0) {
        idTurma = turmas[0].idTurma;
      } else {
        const [resultadoTurma] = await conexao.execute(
          `INSERT INTO turma (nome, anoLetivo, idCurso)
           VALUES (?, ?, ?)`,
          [aluno.turma, aluno.anoLetivo, idCurso]
        );

        idTurma = resultadoTurma.insertId;
      }

      // Verifica se o aluno já existe
      const [existentes] = await conexao.execute(
        'SELECT matricula FROM aluno WHERE matricula = ?',
        [aluno.matricula]
      );

      if (existentes.length > 0) {
        // Atualiza os dados sem alterar o status ativo/inativo
        await conexao.execute(
          `UPDATE aluno
           SET nome = ?, idTUrma = ?
           WHERE matricula = ?`,
          [aluno.nome, idTurma, aluno.matricula]
        );

        atualizados++;
      } else {
        // Novos alunos começam ativos
        await conexao.execute(
          `INSERT INTO aluno (matricula, nome, idTUrma, ativo)
           VALUES (?, ?, ?, 1)`,
          [aluno.matricula, aluno.nome, idTurma]
        );

        novos++;
      }
    }

    await conexao.commit();

    res.json({
      mensagem: 'Importação realizada com sucesso!',
      totalLidos: alunos.length,
      novos,
      atualizados
    });

  } catch (erro) {
  console.error('ERRO COMPLETO NA IMPORTAÇÃO:');
  console.error(erro.stack || erro);

  if (conexao) {
    await conexao.rollback();
  }

  res.status(500).json({
    mensagem: 'Não foi possível importar a planilha.',
    erro: erro.message
  });
} finally {
    if (conexao) {
      conexao.release();
    }
  }
});

module.exports = router;
