
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const pool = require('./config/database');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    mensagem: 'API do Adver funcionando!'
  });
});

app.get('/teste-banco', async (req, res) => {
  try {
    const [resultado] = await pool.query(
      'SELECT DATABASE() AS banco, NOW() AS horario'
    );

    res.json({
      mensagem: 'Conexão com MySQL realizada com sucesso!',
      dados: resultado[0]
    });
  } catch (erro) {
    console.error('Erro ao conectar ao MySQL:', erro.message);

    res.status(500).json({
      mensagem: 'Não foi possível conectar ao banco de dados.'
    });
  }
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Servidor do Adver rodando na porta ${PORT}`);
});
