import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/services.dart';
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

  Future<void> inicializar() {
    return _inicializacao ??= _carregarDadosIniciais();
  }
  
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
  Future<void> _carregarDadosIniciais() async {
    final prefs = await SharedPreferences.getInstance();

    // Se os dados já existem no navegador, não carregamos
    // novamente o JSON por cima deles.
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

  
Future<List<Aluno>> listarAlunos() async {
  final resposta = await http.get(
    Uri.parse('$_urlApi/alunos'),
  );

  if (resposta.statusCode == 200) {
    final List<dynamic> lista = jsonDecode(resposta.body);

    return lista
        .map((item) => Aluno.fromJson(item))
        .toList();
  }

  throw Exception(
    'Erro ao buscar alunos: ${resposta.statusCode}',
  );
}


  Future<List<Advertencia>> listarAdvertencias() async {
    await inicializar();

    final prefs = await SharedPreferences.getInstance();

    final conteudo = prefs.getString(_chaveAdvertencias) ?? '[]';
    final List<dynamic> lista = jsonDecode(conteudo);

    return lista
        .map((item) => Advertencia.fromJson(item))
        .toList();
  }

  Future<void> salvarAdvertencia(Advertencia advertencia) async {
    await inicializar();

    final prefs = await SharedPreferences.getInstance();

    final advertencias = await listarAdvertencias();

    advertencias.add(advertencia);

    final listaJson = advertencias
        .map((item) => item.toJson())
        .toList();

    await prefs.setString(
      _chaveAdvertencias,
      jsonEncode(listaJson),
    );
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
  

}