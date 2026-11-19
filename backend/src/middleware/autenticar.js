
const jwt = require('jsonwebtoken');

function autenticar(req, res, next) {
  // Recupera o cabeçalho de autorização
  const cabecalho = req.headers.authorization;

  // Verifica se o token foi enviado
  if (!cabecalho || !cabecalho.startsWith('Bearer ')) {
    return res.status(401).json({
      erro: 'Acesso não autorizado. Faça login novamente.'
    });
  }

  // Separa o token do prefixo Bearer
  const token = cabecalho.split(' ')[1];

  try {
    // Verifica se o token é válido
    const dadosUsuario = jwt.verify(
      token,
      process.env.JWT_SECRET
    );

    // Disponibiliza os dados do funcionário para a rota
    req.usuario = dadosUsuario;

    next();
  } catch (erro) {
    return res.status(401).json({
      erro: 'Token inválido ou expirado. Faça login novamente.'
    });
  }
}

module.exports = autenticar;
