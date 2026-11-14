
const express = require('express');
const router = express.Router();

const pool = require('../config/database');

// LISTAR ALUNOS
// Permite pesquisar, filtrar e contar advertências.
router.get('/', async (req, res) => {
  try {
    const { busca, curso, turma, status } = req.query;

    let sql = `
      SELECT
        a.matricula,
        a.nome,
        a.ativo,
        t.idTurma,
        t.nome AS turma,
        t.anoLetivo,
        c.idCurso,
        c.nome AS curso,

        (
          SELECT COUNT(*)
          FROM advertencia ad
          WHERE ad.matriculaAluno = a.matricula
        ) AS quantidadeAdvertencias

      FROM aluno a
      INNER JOIN turma t
        ON a.idTUrma = t.idTurma
      INNER JOIN curso c
        ON t.idCurso = c.idCurso
      WHERE 1 = 1
    `;

    const parametros = [];

    // Pesquisa por nome ou matrícula
    if (busca) {
      sql += `
        AND (
          a.nome LIKE ?
          OR a.matricula LIKE ?
        )
      `;

      parametros.push(`%${busca}%`, `%${busca}%`);
    }

    // Filtro por curso
    if (curso) {
      sql += ` AND c.nome = ?`;
      parametros.push(curso);
    }

    // Filtro por turma
    if (turma) {
      sql += ` AND t.nome = ?`;
      parametros.push(turma);
    }

    // Por padrão, mostra somente alunos ativos.
    if (status === 'inativos') {
      sql += ` AND a.ativo = 0`;
    } else if (status === 'todos') {
      // Não adiciona filtro de situação.
    } else {
      sql += ` AND a.ativo = 1`;
    }

    // Ordem alfabética
    sql += ` ORDER BY a.nome ASC`;

    const [alunos] = await pool.query(sql, parametros);

    res.json(alunos);
  } catch (erro) {
    console.error('Erro ao buscar alunos:', erro);

    res.status(500).json({
      mensagem: 'Não foi possível buscar os alunos.'
    });
  }
});

// ATIVAR OU DESATIVAR UM ALUNO
router.patch('/:matricula/status', async (req, res) => {
  try {
    const { matricula } = req.params;
    const { ativo } = req.body;

    if (![true, false, 0, 1].includes(ativo)) {
      return res.status(400).json({
        mensagem: 'O campo ativo deve ser true, false, 0 ou 1.'
      });
    }

    const [resultado] = await pool.query(
      'UPDATE aluno SET ativo = ? WHERE matricula = ?',
      [ativo ? 1 : 0, matricula]
    );

    if (resultado.affectedRows === 0) {
      return res.status(404).json({
        mensagem: 'Aluno não encontrado.'
      });
    }

    res.json({
      mensagem: 'Situação do aluno atualizada com sucesso.'
    });
  } catch (erro) {
    console.error('Erro ao atualizar aluno:', erro);

    res.status(500).json({
      mensagem: 'Não foi possível atualizar a situação do aluno.'
    });
  }
});

module.exports = router;
