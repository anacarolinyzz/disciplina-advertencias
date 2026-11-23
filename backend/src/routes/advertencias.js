
const express = require('express');
const pool = require('../config/database');
const autenticar = require('../middleware/autenticar');

const router = express.Router();



// POST /advertencias/lote
// Registra uma advertência para vários alunos
router.post('/lote', autenticar, async (req, res) => {
  let conexao;

  try {
    const {
      matriculas,
      data,
      justificativaLegal,
      descricao
    } = req.body;

    // Validação dos dados
    if (
      !Array.isArray(matriculas) ||
      matriculas.length === 0 ||
      !data ||
      !justificativaLegal ||
      !descricao
    ) {
      return res.status(400).json({
        erro: 'Informe os alunos e preencha todos os campos.'
      });
    }

    if (!/^\d{4}-\d{2}-\d{2}$/.test(data)) {
      return res.status(400).json({
        erro: 'A data deve estar no formato AAAA-MM-DD.'
      });
    }

    // Impede matrículas duplicadas
    const matriculasUnicas = [...new Set(matriculas)];

    if (
      matriculasUnicas.length !== matriculas.length ||
      matriculasUnicas.some(
        matricula => typeof matricula !== 'string' || !matricula.trim()
      )
    ) {
      return res.status(400).json({
        erro: 'Existem matrículas inválidas ou duplicadas.'
      });
    }

    const idUsuario = req.usuario.idUsuario;

    conexao = await pool.getConnection();

    await conexao.beginTransaction();

    // Verifica se todos os alunos existem e estão ativos
    const placeholders = matriculas.map(() => '?').join(',');

    const [alunos] = await conexao.execute(
      `SELECT matricula
       FROM aluno
       WHERE matricula IN (${placeholders})
       AND ativo = 1`,
      matriculas
    );

    if (alunos.length !== matriculas.length) {
      await conexao.rollback();

      return res.status(400).json({
        erro: 'Um ou mais alunos não foram encontrados ou estão inativos.'
      });
    }

    const registros = [];

    // Registra uma advertência para cada aluno
    for (const matriculaAluno of matriculas) {
      const [resultado] = await conexao.execute(
        `INSERT INTO advertencia
         (data_advertencia, justificativaLegal, descricao, matriculaAluno, idUsuario)
         VALUES (?, ?, ?, ?, ?)`,
        [
          data,
          justificativaLegal,
          descricao,
          matriculaAluno,
          idUsuario
        ]
      );

      registros.push({
        idAdvertencia: resultado.insertId,
        matriculaAluno
      });
    }

    await conexao.commit();

    return res.status(201).json({
      mensagem: 'Advertências registradas com sucesso!',
      quantidade: registros.length,
      advertencias: registros
    });

  } catch (erro) {
    if (conexao) {
      await conexao.rollback();
    }

    console.error('Erro ao registrar advertências em lote:', erro.message);

    return res.status(500).json({
      erro: 'Não foi possível registrar as advertências em lote.'
    });

  } finally {
    if (conexao) {
      conexao.release();
    }
  }
});

// POST /advertencias
// Registra uma advertência vinculada a um aluno e funcionário
router.post('/', autenticar, async (req, res) => {
  try {
    const {
      matriculaAluno,
      data,
      justificativaLegal,
      descricao
    } = req.body;

    // Validação dos campos
    if (!matriculaAluno || !data || !justificativaLegal || !descricao) {
      return res.status(400).json({
        erro: 'Preencha todos os campos da advertência.'
      });
    }

    // Valida o formato da data
    if (!/^\d{4}-\d{2}-\d{2}$/.test(data)) {
      return res.status(400).json({
        erro: 'A data deve estar no formato AAAA-MM-DD.'
      });
    }

    // Verifica se o aluno existe e está ativo
    const [alunos] = await pool.execute(
      `SELECT matricula
       FROM aluno
       WHERE matricula = ? AND ativo = 1`,
      [matriculaAluno]
    );

    if (alunos.length === 0) {
      return res.status(404).json({
        erro: 'Aluno não encontrado ou está inativo.'
      });
    }

    // Identifica o funcionário pelo token JWT
    const idUsuario = req.usuario.idUsuario;

    // Registra a advertência
    const [resultado] = await pool.execute(
      `INSERT INTO advertencia
       (data_advertencia, justificativaLegal, descricao, matriculaAluno, idUsuario)
       VALUES (?, ?, ?, ?, ?)`,
      [
        data,
        justificativaLegal,
        descricao,
        matriculaAluno,
        idUsuario
      ]
    );

    return res.status(201).json({
      mensagem: 'Advertência registrada com sucesso!',
      advertencia: {
        idAdvertencia: resultado.insertId,
        data_advertencia: data,
        justificativaLegal,
        descricao,
        matriculaAluno,
        idUsuario
      }
    });

  } catch (erro) {
    console.error('Erro ao registrar advertência:', erro.message);

    return res.status(500).json({
      erro: 'Não foi possível registrar a advertência.'
    });
  }
});

// Listar advertências registradas
router.get('/', autenticar, async (req, res) => {
  try {
    const [advertencias] = await pool.query(`
      SELECT
        idAdvertencia,
        data_advertencia,
        justificativaLegal,
        descricao,
        matriculaAluno,
        idUsuario
      FROM advertencia
      ORDER BY data_advertencia DESC, idAdvertencia DESC
    `);

    res.json(advertencias);
  } catch (erro) {
    console.error('Erro ao listar advertências:', erro);
    res.status(500).json({
      erro: 'Não foi possível buscar as advertências.'
    });
  }
});


// GET /advertencias/ranking/usuarios
// Retorna o ranking mensal de funcionários
router.get('/ranking/usuarios', autenticar, async (req, res) => {
  try {
    const [ranking] = await pool.query(`
      SELECT
        u.idUsuario,
        u.nome,
        COUNT(a.idAdvertencia) AS total
      FROM usuario u
      LEFT JOIN advertencia a
        ON a.idUsuario = u.idUsuario
        AND a.data_advertencia >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
        AND a.data_advertencia < DATE_ADD(
          DATE_FORMAT(CURDATE(), '%Y-%m-01'),
          INTERVAL 1 MONTH
        )
      GROUP BY u.idUsuario, u.nome
      ORDER BY total DESC, u.nome ASC
    `);

    return res.json(ranking);
  } catch (erro) {
    console.error('Erro ao buscar ranking de usuários:', erro);

    return res.status(500).json({
      erro: 'Não foi possível carregar o ranking de funcionários.'
    });
  }
});


module.exports = router;
