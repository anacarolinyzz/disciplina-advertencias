
import 'package:flutter/material.dart';

import '../services/dados_service.dart';
import '../widget/navigation_drawer.dart';

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({super.key});

  @override
  State<UsuarioPage> createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  final DadosService _dadosService = DadosService.instancia;

  List<Map<String, dynamic>> _usuarios = [];

  Map<String, dynamic>? _usuarioConectado;

  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }


  // CARREGAR FUNCIONÁRIOS E USUÁRIO CONECTADO


  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final usuario = await _dadosService.obterUsuarioConectado();
      final usuarios = await _dadosService.listarUsuarios();

      if (!mounted) return;

      setState(() {
        _usuarioConectado = usuario;
        _usuarios = usuarios;
        _carregando = false;
      });
    } catch (erro) {
      if (!mounted) return;

      setState(() {
        _erro = erro.toString().replaceFirst('Exception: ', '');
        _carregando = false;
      });
    }
  }

  
  // MENSAGENS


  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  
  // CADASTRAR OU EDITAR FUNCIONÁRIO


  Future<void> _abrirFormularioUsuario({
    Map<String, dynamic>? usuario,
  }) async {
    final editando = usuario != null;

    final nomeController = TextEditingController(
      text: usuario?['nome']?.toString() ?? '',
    );

    final loginController = TextEditingController(
      text: usuario?['login']?.toString() ?? '',
    );

    final senhaController = TextEditingController();
    final confirmarSenhaController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            editando ? 'Editar funcionário' : 'Novo funcionário',
          ),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Informe o nome do funcionário.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: loginController,
                      decoration: const InputDecoration(
                        labelText: 'Login',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_circle_outlined),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Informe um login.';
                        }
                        return null;
                      },
                    ),

                    if (!editando) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: senhaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (valor) {
                          if (valor == null || valor.length < 4) {
                            return 'A senha deve ter pelo menos 4 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmarSenhaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar senha',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (valor) {
                          if (valor != senhaController.text) {
                            return 'As senhas não coincidem.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                Navigator.pop(context, {
                  'nome': nomeController.text.trim(),
                  'login': loginController.text.trim(),
                  'senha': senhaController.text,
                });
              },
              child: Text(editando ? 'Salvar alterações' : 'Cadastrar'),
            ),
          ],
        );
      },
    );

    

    if (resultado == null || !mounted) return;

    try {
      if (editando) {
        final id = int.parse(usuario['idUsuario'].toString());

        await _dadosService.atualizarUsuario(
          id: id,
          nome: resultado['nome']!,
          login: resultado['login']!,
        );

        // Atualiza os dados locais se o funcionário editado
        // for o próprio usuário conectado.
        if (_usuarioConectado?['idUsuario'].toString() == id.toString()) {
          final usuarioAtualizado = Map<String, dynamic>.from(
            _usuarioConectado!,
          );

          usuarioAtualizado['nome'] = resultado['nome'];
          usuarioAtualizado['login'] = resultado['login'];

          final token = await _dadosService.obterToken();

          if (token != null) {
            await _dadosService.salvarSessao(
              token: token,
              usuario: usuarioAtualizado,
            );
          }

          _usuarioConectado = usuarioAtualizado;
        }

        _mostrarMensagem('Funcionário atualizado com sucesso!');
      } else {
        await _dadosService.cadastrarUsuario(
          nome: resultado['nome']!,
          login: resultado['login']!,
          senha: resultado['senha']!,
        );

        _mostrarMensagem('Funcionário cadastrado com sucesso!');
      }

      await _carregarDados();
    } catch (erro) {
      if (!mounted) return;

      _mostrarMensagem(
        erro.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

 
  // ALTERAR SENHA DO FUNCIONÁRIO CONECTADO


  Future<void> _alterarSenha() async {
    final senhaAtualController = TextEditingController();
    final novaSenhaController = TextEditingController();
    final confirmarSenhaController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alterar minha senha'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: senhaAtualController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha atual',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Informe sua senha atual.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: novaSenhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nova senha',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.length < 4) {
                        return 'A senha deve ter pelo menos 4 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmarSenhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar nova senha',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if (valor != novaSenhaController.text) {
                        return 'As senhas não coincidem.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                Navigator.pop(context, {
                  'senhaAtual': senhaAtualController.text,
                  'novaSenha': novaSenhaController.text,
                });
              },
              child: const Text('Alterar senha'),
            ),
          ],
        );
      },
    );

    

    if (resultado == null || !mounted) return;

    try {
      await _dadosService.alterarMinhaSenha(
        senhaAtual: resultado['senhaAtual']!,
        novaSenha: resultado['novaSenha']!,
      );

      if (!mounted) return;

      _mostrarMensagem('Senha alterada com sucesso!');
    } catch (erro) {
      if (!mounted) return;

      _mostrarMensagem(
        erro.toString().replaceFirst('Exception: ', ''),
      );
    }
  }


  // CARTÃO DO FUNCIONÁRIO CONECTADO


  Widget _cartaoMinhaConta() {
    final nome = _usuarioConectado?['nome']?.toString() ?? 'Funcionário';
    final login = _usuarioConectado?['login']?.toString() ?? '';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_outline, size: 22),
                SizedBox(width: 10),
                Text(
                  'Minha conta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(
                    Icons.person,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Login: $login',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Funcionário',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    final usuario = _usuarios.firstWhere(
                      (item) =>
                          item['idUsuario'].toString() ==
                          _usuarioConectado?['idUsuario'].toString(),
                      orElse: () => _usuarioConectado!,
                    );

                    _abrirFormularioUsuario(usuario: usuario);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar meus dados'),
                ),
                OutlinedButton.icon(
                  onPressed: _alterarSenha,
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Alterar senha'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  
  // LISTA DE FUNCIONÁRIOS


  Widget _listaFuncionarios() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Funcionários cadastrados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${_usuarios.length} cadastrados',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Divider(height: 28),

            if (_usuarios.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 25),
                child: Center(
                  child: Text('Nenhum funcionário cadastrado.'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _usuarios.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final usuario = _usuarios[index];

                  final nome = usuario['nome']?.toString() ?? '';
                  final login = usuario['login']?.toString() ?? '';

                  final ehUsuarioAtual =
                      usuario['idUsuario'].toString() ==
                      _usuarioConectado?['idUsuario'].toString();

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 0,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.black,
                      ),
                    ),
                    title: Text(
                      nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text('Login: $login'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (ehUsuarioAtual)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Text(
                              'Você',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        IconButton(
                          tooltip: 'Editar funcionário',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            _abrirFormularioUsuario(
                              usuario: usuario,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adver'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _carregarDados,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: DrawerTest(),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 45,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _erro!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _carregarDados,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregarDados,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 1000,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Funcionários',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Gerencie os dados dos funcionários que utilizam o Adver.',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),

                            _cartaoMinhaConta(),

                            const SizedBox(height: 24),

                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Equipe',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _abrirFormularioUsuario(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Novo funcionário'),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            _listaFuncionarios(),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
