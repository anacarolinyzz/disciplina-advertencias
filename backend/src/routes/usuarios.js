
const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const autenticar = require('../middleware/autenticar');

const router = express.Router();

// --------------------------------------------------
// VERIFICA SE É O PRIMEIRO ACESSO
// --------------------------------------------------

router.get('/status-inicial', async (req, res) => {
  try {
    const [resultado] = await pool.query(
      'SELECT COUNT(*) AS total FROM usuario'
    );

    res.json({
      primeiroAcesso: resultado[0].total === 0
    });
  } catch (erro) {
    console.error('Erro ao verificar usuários:', erro.message);
    res.status(500).json({
      erro: 'Não foi possível verificar os usuários.'
    });
  }
});

// --------------------------------------------------
// CADASTRA O PRIMEIRO FUNCIONÁRIO
// --------------------------------------------------

router.post('/primeiro-acesso', async (req, res) => {
  try {
    const { nome, login, senha } = req.body;

    if (!nome || !login || !senha) {
      return res.status(400).json({
        erro: 'Preencha todos os campos.'
      });
    }

    if (
      nome.trim().length === 0 ||
      login.trim().length === 0 ||
      senha.length < 4
    ) {
      return res.status(400).json({
        erro: 'Informe nome e login válidos e uma senha com pelo menos 4 caracteres.'
      });
    }

    const [usuarios] = await pool.query(
      'SELECT COUNT(*) AS total FROM usuario'
    );

    if (usuarios[0].total > 0) {
      return res.status(403).json({
        erro: 'O primeiro cadastro já foi realizado.'
      });
    }

    const senhaHash = await bcrypt.hash(senha, 10);

    const [resultado] = await pool.execute(
      `INSERT INTO usuario (nome, login, senhaHash, perfil)
       VALUES (?, ?, ?, ?)`,
      [nome.trim(), login.trim(), senhaHash, 'funcionario']
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

// --------------------------------------------------
// LOGIN
// --------------------------------------------------

router.post('/login', async (req, res) => {
  try {
    const { login, senha } = req.body;

    if (!login || !senha) {
      return res.status(400).json({
        erro: 'Informe o login e a senha.'
      });
    }

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

    const senhaCorreta = await bcrypt.compare(
      senha,
      usuario.senhaHash
    );

    if (!senhaCorreta) {
      return res.status(401).json({
        erro: 'Login ou senha incorretos.'
      });
    }

    const token = jwt.sign(
      {
        idUsuario: usuario.idUsuario,
        nome: usuario.nome,
        perfil: usuario.perfil
      },
      process.env.JWT_SECRET,
      { expiresIn: '8h' }
    );

    res.json({
      mensagem: 'Login realizado com sucesso!',
      token,
      usuario: {
        idUsuario: usuario.idUsuario,
        nome: usuario.nome,
        login: usuario.login,
        perfil: usuario.perfil
      }
    });
  } catch (erro) {
    console.error('Erro ao realizar login:', erro.message);

    res.status(500).json({
      erro: 'Não foi possível realizar o login.'
    });
  }
});

// --------------------------------------------------
// CONSULTA O FUNCIONÁRIO CONECTADO
// --------------------------------------------------

router.get('/me', autenticar, (req, res) => {
  res.json({
    mensagem: 'Funcionário autenticado com sucesso!',
    usuario: req.usuario
  });
});

// --------------------------------------------------
// LISTA TODOS OS FUNCIONÁRIOS
// GET /usuarios
// --------------------------------------------------

router.get('/', autenticar, async (req, res) => {
  try {
    const [usuarios] = await pool.query(
      `SELECT idUsuario, nome, login, perfil
       FROM usuario
       ORDER BY nome ASC`
    );

    res.json(usuarios);
  } catch (erro) {
    console.error('Erro ao listar funcionários:', erro.message);

    res.status(500).json({
      erro: 'Não foi possível listar os funcionários.'
    });
  }
});

// --------------------------------------------------
// CADASTRA UM NOVO FUNCIONÁRIO
// POST /usuarios
// --------------------------------------------------

router.post('/', autenticar, async (req, res) => {
  try {
    const { nome, login, senha } = req.body;

    if (!nome || !login || !senha) {
      return res.status(400).json({
        erro: 'Preencha todos os campos.'
      });
    }

    if (
      nome.trim().length === 0 ||
      login.trim().length === 0 ||
      senha.length < 4
    ) {
      return res.status(400).json({
        erro: 'Informe nome e login válidos e uma senha com pelo menos 4 caracteres.'
      });
    }

    const senhaHash = await bcrypt.hash(senha, 10);

    const [resultado] = await pool.execute(
      `INSERT INTO usuario (nome, login, senhaHash, perfil)
       VALUES (?, ?, ?, ?)`,
      [nome.trim(), login.trim(), senhaHash, 'funcionario']
    );

    res.status(201).json({
      mensagem: 'Funcionário cadastrado com sucesso!',
      usuario: {
        idUsuario: resultado.insertId,
        nome: nome.trim(),
        login: login.trim(),
        perfil: 'funcionario'
      }
    });
  } catch (erro) {
    console.error('Erro ao cadastrar funcionário:', erro.message);

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

// --------------------------------------------------
// EDITA NOME E LOGIN
// PUT /usuarios/:id
// --------------------------------------------------

router.put('/:id', autenticar, async (req, res) => {
  try {
    const id = Number(req.params.id);
    const { nome, login } = req.body;

    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({
        erro: 'Identificador de funcionário inválido.'
      });
    }

    if (
      !nome ||
      !login ||
      nome.trim().length === 0 ||
      login.trim().length === 0
    ) {
      return res.status(400).json({
        erro: 'Informe um nome e um login válidos.'
      });
    }

    const [resultado] = await pool.execute(
      `UPDATE usuario
       SET nome = ?, login = ?
       WHERE idUsuario = ?`,
      [nome.trim(), login.trim(), id]
    );

    if (resultado.affectedRows === 0) {
      return res.status(404).json({
        erro: 'Funcionário não encontrado.'
      });
    }

    res.json({
      mensagem: 'Dados do funcionário atualizados com sucesso!'
    });
  } catch (erro) {
    console.error('Erro ao editar funcionário:', erro.message);

    if (erro.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({
        erro: 'Este login já está sendo utilizado.'
      });
    }

    res.status(500).json({
      erro: 'Não foi possível atualizar o funcionário.'
    });
  }
});

// --------------------------------------------------
// ALTERA A SENHA DO FUNCIONÁRIO CONECTADO
// PUT /usuarios/me/senha
// --------------------------------------------------

router.put('/me/senha', autenticar, async (req, res) => {
  try {
    const { senhaAtual, novaSenha } = req.body;
    const idUsuario = req.usuario.idUsuario;

    if (!senhaAtual || !novaSenha) {
      return res.status(400).json({
        erro: 'Informe a senha atual e a nova senha.'
      });
    }

    if (novaSenha.length < 4) {
      return res.status(400).json({
        erro: 'A nova senha deve ter pelo menos 4 caracteres.'
      });
    }

    const [usuarios] = await pool.execute(
      `SELECT senhaHash
       FROM usuario
       WHERE idUsuario = ?
       LIMIT 1`,
      [idUsuario]
    );

    if (usuarios.length === 0) {
      return res.status(404).json({
        erro: 'Funcionário não encontrado.'
      });
    }

    const senhaCorreta = await bcrypt.compare(
      senhaAtual,
      usuarios[0].senhaHash
    );

    if (!senhaCorreta) {
      return res.status(401).json({
        erro: 'A senha atual está incorreta.'
      });
    }

    const novoHash = await bcrypt.hash(novaSenha, 10);

    await pool.execute(
      `UPDATE usuario
       SET senhaHash = ?
       WHERE idUsuario = ?`,
      [novoHash, idUsuario]
    );

    res.json({
      mensagem: 'Senha alterada com sucesso!'
    });
  } catch (erro) {
    console.error('Erro ao alterar senha:', erro.message);

    res.status(500).json({
      erro: 'Não foi possível alterar a senha.'
    });
  }
});

module.exports = router;
