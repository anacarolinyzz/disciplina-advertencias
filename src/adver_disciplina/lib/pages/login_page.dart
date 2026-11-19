
import 'package:flutter/material.dart';
import 'package:adver/services/dados_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageEstado();
}

class LoginPageEstado extends State<LoginPage> {
  // Controle e chave do formulário
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _obscureText = true;
  bool _carregando = false;

  // Realizar login pela API
  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      await DadosService.instancia.fazerLogin(
        _emailController.text.trim(),
        _senhaController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home');
    } catch (erro) {
      if (!mounted) return;

      final mensagem = erro.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo do Adver
                  Image.asset(
                    'assets/images/logo.png',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Acesse o sistema',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Campo E-mail / Usuário
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: 'E-mail ou Usuário',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, informe seu usuário ou e-mail';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo Senha
                  TextFormField(
                    controller: _senhaController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, informe a senha';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botão de Entrar
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _carregando ? null : _fazerLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8C8C8C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _carregando
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'ENTRAR',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
