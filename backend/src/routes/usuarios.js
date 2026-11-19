
const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const autenticar = require('../middleware/autenticar');

const router = express.Router();

// Verifica se já existe algum funcionário cadastrado
router.get('/status-inicial', async (req, res) => {
  try {
    const [resultado] = await pool.query(
      'SELECT COUNT(*) AS total FROM usuario'
    );

    const primeiroAcesso = resultado[0].total === 0;

    res.json({
      primeiroAcesso: primeiroAcesso
    });

  } catch (erro) {
    console.error('Erro ao verificar usuários:', erro.message);

    res.status(500).json({
      erro: 'Não foi possível verificar os usuários.'
    });
  }
});

// Cadastra o primeiro funcionário
router.post('/primeiro-acesso', async (req, res) => {
  try {
    const { nome, login, senha } = req.body;

    // Validação dos campos
    if (!nome || !login || !senha) {
      return res.status(400).json({
        erro: 'Preencha todos os campos.'
      });
    }

    if (nome.trim().length === 0 ||
        login.trim().length === 0 ||
        senha.length < 4) {
      return res.status(400).json({
        erro: 'Informe nome e login válidos e uma senha com pelo menos 4 caracteres.'
      });
    }

    // Verifica se já existe algum usuário
    const [usuarios] = await pool.query(
      'SELECT COUNT(*) AS total FROM usuario'
    );

    if (usuarios[0].total > 0) {
      return res.status(403).json({
        erro: 'O primeiro cadastro já foi realizado.'
      });
    }

    // Protege a senha com bcrypt
    const senhaHash = await bcrypt.hash(senha, 10);

    // Insere o primeiro funcionário
    const [resultado] = await pool.execute(
      `INSERT INTO usuario (nome, login, senhaHash, perfil)
       VALUES (?, ?, ?, ?)`,
      [
        nome.trim(),
        login.trim(),
        senhaHash,
        'funcionario'
      ]
    );

    res.status(201).json({
      mensagem: 'Primeiro funcionário cadastrado com sucesso!',
      usuario: {
        idUsuario: resultado.insertId,
        nome: nome.trim(),
        login: login.trim(),
        perfil: 'funcionario'
      }
    });

  } catch (erro) {
    console.error('Erro ao cadastrar usuário:', erro.message);

    if (erro.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({
        erro: 'Este login já está cadastrado.'
      });
    }

    res.status(500).json({
      erro: 'Não foi possível cadastrar o funcionário.'
    });
  }
});




// Realiza o login do funcionário
router.post('/login', async (req, res) => {
  try {
    const { login, senha } = req.body;

    if (!login || !senha) {
      return res.status(400).json({
        erro: 'Informe o login e a senha.'
      });
    }

    // Procura o funcionário pelo login
    const [usuarios] = await pool.execute(
      `SELECT idUsuario, nome, login, senhaHash, perfil
       FROM usuario
       WHERE login = ?
       LIMIT 1`,
      [login.trim()]
    );

    if (usuarios.length === 0) {
      return res.status(401).json({
        erro: 'Login ou senha incorretos.'
      });
    }

    const usuario = usuarios[0];

    // Compara a senha digitada com o hash do banco
    const senhaCorreta = await bcrypt.compare(
      senha,
      usuario.senhaHash
    );

    if (!senhaCorreta) {
      return res.status(401).json({
        erro: 'Login ou senha incorretos.'
      });
    }

    // Gera o token de autenticação
    const token = jwt.sign(
      {
        idUsuario: usuario.idUsuario,
        nome: usuario.nome,
        perfil: usuario.perfil
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '8h'
      }
    );

    return res.json({
      mensagem: 'Login realizado com sucesso!',
      token: token,
      usuario: {
        idUsuario: usuario.idUsuario,
        nome: usuario.nome,
        login: usuario.login,
        perfil: usuario.perfil
      }
    });

  } catch (erro) {
    console.error('Erro ao realizar login:', erro.message);

    return res.status(500).json({
      erro: 'Não foi possível realizar o login.'
    });
  }
});

// GET /usuarios/me
router.get('/me', autenticar, (req, res) => {
  res.json({
    mensagem: 'Funcionário autenticado com sucesso!',
    usuario: req.usuario
  });
});

module.exports = router;
