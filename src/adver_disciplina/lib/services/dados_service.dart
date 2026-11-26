
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/aluno.dart';
import '../models/advertencia.dart';

class DadosService {
  DadosService._();

  static final DadosService instancia = DadosService._();

  static const String _urlApi = 'http://localhost:3000';
  static const String _chaveAlunos = 'adver_alunos';
  static const String _chaveAdvertencias = 'adver_advertencias';

  Future<void>? _inicializacao;


  // INICIALIZAÇÃO DOS DADOS LOCAIS
 

  Future<void> inicializar() {
    return _inicializacao ??= _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    final prefs = await SharedPreferences.getInstance();

    final alunosExistem = prefs.containsKey(_chaveAlunos);
    final advertenciasExistem = prefs.containsKey(_chaveAdvertencias);

    if (alunosExistem && advertenciasExistem) {
      return;
    }

    final conteudo = await rootBundle.loadString(
      'assets/data/dados_temporario.json',
    );

    final Map<String, dynamic> dados = jsonDecode(conteudo);

    final alunos = dados['alunos'] ?? [];
    final advertencias = dados['advertencias'] ?? [];

    await prefs.setString(_chaveAlunos, jsonEncode(alunos));
    await prefs.setString(
      _chaveAdvertencias,
      jsonEncode(advertencias),
    );
  }


  // AUTENTICAÇÃO E SESSÃO


  Future<Map<String, dynamic>> fazerLogin(
    String login,
    String senha,
  ) async {
    final resposta = await http.post(
      Uri.parse('$_urlApi/usuarios/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'login': login,
        'senha': senha,
      }),
    );

    final Map<String, dynamic> dados = jsonDecode(resposta.body);

    if (resposta.statusCode == 200) {
      await salvarSessao(
        token: dados['token'],
        usuario: Map<String, dynamic>.from(dados['usuario']),
      );

      return dados;
    }

    throw Exception(
      dados['erro'] ?? 'Não foi possível realizar o login.',
    );
  }

  Future<void> salvarSessao({
    required String token,
    required Map<String, dynamic> usuario,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('adver_token', token);
    await prefs.setString('adver_usuario', jsonEncode(usuario));
  }

  Future<String?> obterToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('adver_token');
  }

  Future<Map<String, dynamic>?> obterUsuarioConectado() async {
    final prefs = await SharedPreferences.getInstance();

    final dados = prefs.getString('adver_usuario');

    if (dados == null) {
      return null;
    }

    return Map<String, dynamic>.from(jsonDecode(dados));
  }

  Future<void> encerrarSessao() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('adver_token');
    await prefs.remove('adver_usuario');
  }

  Future<Map<String, String>> _cabecalhoAutenticado() async {
    final token = await obterToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sessão não encontrada. Faça login novamente.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }


  // ALUNOS


  Future<List<Aluno>> listarAlunos() async {
    final resposta = await http.get(
      Uri.parse('$_urlApi/alunos'),
      headers: await _cabecalhoAutenticado(),
    );

    if (resposta.statusCode == 200) {
      final List<dynamic> lista = jsonDecode(resposta.body);

      return lista
          .map((item) => Aluno.fromJson(item))
          .toList();
    }

    if (resposta.statusCode == 401) {
      throw Exception('Sua sessão expirou. Faça login novamente.');
    }

    throw Exception(
      'Erro ao buscar alunos: ${resposta.statusCode}',
    );
  }

  Future<Map<String, dynamic>> enviarPlanilhaAlunos(
    Uint8List bytes,
    String nomeArquivo,
  ) async {
    final token = await obterToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sessão não encontrada. Faça login novamente.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_urlApi/importacao/alunos'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes(
        'arquivo',
        bytes,
        filename: nomeArquivo,
      ),
    );

    final resposta = await request.send();
    final corpo = await resposta.stream.bytesToString();

    final Map<String, dynamic> dados = jsonDecode(corpo);

    if (resposta.statusCode >= 200 &&
        resposta.statusCode < 300) {
      return dados;
    }

    if (resposta.statusCode == 401) {
      throw Exception('Sua sessão expirou. Faça login novamente.');
    }

    throw Exception(
      dados['erro'] ??
          dados['mensagem'] ??
          'Falha ao importar a planilha.',
    );
  }

  // Método mantido para compatibilidade com funcionalidades antigas.
  // A importação oficial de alunos é feita pela API.
  Future<Map<String, int>> importarAlunos(
    List<Aluno> novosAlunos,
  ) async {
    await inicializar();

    final prefs = await SharedPreferences.getInstance();
    final alunosExistentes = await listarAlunos();

    final Map<String, Aluno> mapaAlunos = {
      for (final aluno in alunosExistentes)
        aluno.matricula: aluno,
    };

    int novos = 0;
    int atualizados = 0;

    for (final aluno in novosAlunos) {
      if (mapaAlunos.containsKey(aluno.matricula)) {
        atualizados++;
      } else {
        novos++;
      }

      mapaAlunos[aluno.matricula] = aluno;
    }

    final listaJson = mapaAlunos.values
        .map((aluno) => aluno.toJson())
        .toList();

    await prefs.setString(
      _chaveAlunos,
      jsonEncode(listaJson),
    );

    return {
      'novos': novos,
      'atualizados': atualizados,
      'total': novosAlunos.length,
    };
  }

  Future<void> atualizarAlunosDoJson() async {
    final prefs = await SharedPreferences.getInstance();

    final conteudo = await rootBundle.loadString(
      'assets/data/dados_temporario.json',
    );

    final Map<String, dynamic> dados = jsonDecode(conteudo);
    final alunos = dados['alunos'] ?? [];

    await prefs.setString(
      _chaveAlunos,
      jsonEncode(alunos),
    );
  }


  // ADVERTÊNCIAS


  Future<List<Advertencia>> listarAdvertencias() async {
    final resposta = await http.get(
      Uri.parse('$_urlApi/advertencias'),
      headers: await _cabecalhoAutenticado(),
    );

    if (resposta.statusCode == 200) {
      final List<dynamic> lista = jsonDecode(resposta.body);

      return lista
          .map((item) => Advertencia.fromJson(item))
          .toList();
    }

    if (resposta.statusCode == 401) {
      throw Exception('Sua sessão expirou. Faça login novamente.');
    }

    throw Exception(
      'Erro ao buscar advertências: ${resposta.statusCode}',
    );
  }


Future<void> excluirAdvertencia(String id) async {
  final resposta = await http.delete(
    Uri.parse('$_urlApi/advertencias/$id'),
    headers: await _cabecalhoAutenticado(),
  );

  final dados = jsonDecode(resposta.body);

  if (resposta.statusCode == 200) {
    return;
  }

  if (resposta.statusCode == 401) {
    throw Exception('Sua sessão expirou. Faça login novamente.');
  }

  throw Exception(
    dados['erro'] ?? 'Não foi possível excluir a advertência.',
  );
}



  Future<void> salvarAdvertencia(
    Advertencia advertencia,
  ) async {
    final resposta = await http.post(
      Uri.parse('$_urlApi/advertencias'),
      headers: await _cabecalhoAutenticado(),
      body: jsonEncode({
        'matriculaAluno': advertencia.matriculaAluno,
        'data': advertencia.data.toIso8601String().split('T').first,
        'justificativaLegal': advertencia.justificativa,
        'descricao': advertencia.descricao,
      }),
    );

    debugPrint('Status da advertência: ${resposta.statusCode}');
    debugPrint('Resposta da API: ${resposta.body}');

    if (resposta.statusCode == 201) {
      return;
    }

    if (resposta.statusCode == 401) {
      throw Exception('Sua sessão expirou. Faça login novamente.');
    }

    final dados = jsonDecode(resposta.body);

    throw Exception(
      dados['erro'] ?? 'Não foi possível registrar a advertência.',
    );
  }

  Future<List<Map<String, dynamic>>> salvarAdvertenciasEmLote({
    required List<String> matriculas,
    required DateTime data,
    required String justificativa,
    required String descricao,
  }) async {
    final resposta = await http.post(
      Uri.parse('$_urlApi/advertencias/lote'),
      headers: await _cabecalhoAutenticado(),
      body: jsonEncode({
        'matriculas': matriculas,
        'data': data.toIso8601String().split('T').first,
        'justificativaLegal': justificativa,
        'descricao': descricao,
      }),
    );

    debugPrint('Status do lote: ${resposta.statusCode}');
    debugPrint('Resposta do lote: ${resposta.body}');

    final dados = jsonDecode(resposta.body);

    if (resposta.statusCode == 201) {
      return List<Map<String, dynamic>>.from(
        dados['advertencias'],
      );
    }

    if (resposta.statusCode == 401) {
      throw Exception('Sua sessão expirou. Faça login novamente.');
    }

    throw Exception(
      dados['erro'] ?? 'Não foi possível registrar as advertências.',
    );
  }

  // FUNCIONÁRIOS / USUÁRIOS


  Future<List<Map<String, dynamic>>> listarUsuarios() async {
    final resposta = await http.get(
      Uri.parse('$_urlApi/usuarios'),
      headers: await _cabecalhoAutenticado(),
    );

    final dados = jsonDecode(resposta.body);

    if (resposta.statusCode == 200) {
      return List<Map<String, dynamic>>.from(dados);
    }

    if (resposta.statusCode == 401) {
      throw Exception('Sua sessão expirou. Faça login novamente.');
    }

    throw Exception(
      dados['erro'] ?? 'Não foi possível listar os funcionários.',
    );
  }

  Future<void> cadastrarUsuario({
    required String nome,
    required String login,
    required String senha,
  }) async {
    final resposta = await http.post(
      Uri.parse('$_urlApi/usuarios'),
      headers: await _cabecalhoAutenticado(),
      body: jsonEncode({
        'nome': nome,
        'login': login,
        'senha': senha,
      }),
    );

    final dados = jsonDecode(resposta.body);

    if (resposta.statusCode == 201) {
      return;
    }

    if (resposta.statusCode == 401) {
      throw Exception('Sua sessão expirou. Faça login novamente.');
    }

    throw Exception(
      dados['erro'] ?? 'Não foi possível cadastrar o funcionário.',
    );
  }

  Future<void> atualizarUsuario({
    required int id,
    required String nome,
    required String login,
  }) async {
    final resposta = await http.put(
      Uri.parse('$_urlApi/usuarios/$id'),
      headers: await _cabecalhoAutenticado(),
      body: jsonEncode({
        'nome': nome,
        'login': login,
      }),
    );

    final dados = jsonDecode(resposta.body);

    if (resposta.statusCode == 200) {
      return;
    }

    if (resposta.statusCode == 401) {
      throw Exception('Sua sessão expirou. Faça login novamente.');
    }

    throw Exception(
      dados['erro'] ?? 'Não foi possível atualizar o funcionário.',
    );
  }

  Future<void> alterarMinhaSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    final resposta = await http.put(
      Uri.parse('$_urlApi/usuarios/me/senha'),
      headers: await _cabecalhoAutenticado(),
      body: jsonEncode({
        'senhaAtual': senhaAtual,
        'novaSenha': novaSenha,
      }),
    );

    final dados = jsonDecode(resposta.body);

    if (resposta.statusCode == 200) {
      return;
    }

    if (resposta.statusCode == 401) {
      throw Exception(
        dados['erro'] ?? 'A senha atual está incorreta.',
      );
    }

    throw Exception(
      dados['erro'] ?? 'Não foi possível alterar a senha.',
    );
  }

Future<List<Map<String, dynamic>>> listarRankingUsuarios() async {
  final resposta = await http.get(
    Uri.parse('$_urlApi/advertencias/ranking/usuarios'),
    headers: await _cabecalhoAutenticado(),
  );

  final dados = jsonDecode(resposta.body);

  if (resposta.statusCode == 200) {
    return List<Map<String, dynamic>>.from(dados);
  }

  if (resposta.statusCode == 401) {
    throw Exception('Sua sessão expirou. Faça login novamente.');
  }

  throw Exception(
    dados['erro'] ?? 'Não foi possível carregar o ranking.',
  );
}


}
