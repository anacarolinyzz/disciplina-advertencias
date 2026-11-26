class JustificativaLegal {
  final String inciso;
  final String alinea;
  final String descricao;

  const JustificativaLegal({
    required this.inciso,
    required this.alinea,
    required this.descricao,
  });

  String get textoCompleto =>
      'Organização Didática do IFPI, Art. 160, inciso $inciso, '
      'alínea $alinea) $descricao';
}

class JustificativasLegais {
  static const String advertenciaOral = 'Advertência oral';
  static const String advertenciaEscrita = 'Advertência por escrito';
  static const String suspensao = 'Suspensão';

  static const List<String> tipos = [
    advertenciaOral,
    advertenciaEscrita,
    suspensao,
  ];

  static const Map<String, List<JustificativaLegal>> justificativas = {
    advertenciaOral: [
      JustificativaLegal(
        inciso: 'I',
        alinea: 'a',
        descricao:
            'entrar e permanecer nas dependências da Instituição sem estar devidamente uniformizado, se estudante dos cursos do ensino médio integrado, exceto se expressamente autorizado pela Direção do campus;',
      ),
      JustificativaLegal(
        inciso: 'I',
        alinea: 'b',
        descricao: 'ausentar-se da sala de aula sem autorização do docente;',
      ),
      JustificativaLegal(
        inciso: 'I',
        alinea: 'c',
        descricao:
            'alimentar-se em sala de aula, sala de multimeios, sala de projeções, auditórios, laboratórios, oficinas e demais espaços equivalentes;',
      ),
      JustificativaLegal(
        inciso: 'I',
        alinea: 'd',
        descricao:
            'permanecer, sem autorização, nas salas de aula, sala de multimeios, sala de projeções, auditórios, laboratórios, oficinas e demais espaços equivalentes, após o término das atividades escolares;',
      ),
      JustificativaLegal(
        inciso: 'I',
        alinea: 'e',
        descricao:
            'permanecer, nas quadras esportivas, fora das atividades de Educação Física quando não autorizado pela Direção de Ensino ou coordenação de área/curso;',
      ),
      JustificativaLegal(
        inciso: 'I',
        alinea: 'f',
        descricao:
            'provocar e/ou participar de atividades que comprometam a disciplina, nas dependências da Instituição, especialmente nos locais destinados às aulas e a outras atividades curriculares;',
      ),
      JustificativaLegal(
        inciso: 'I',
        alinea: 'g',
        descricao:
            'manter-se fora da sala no período em que estiver sendo ministrada aula;',
      ),
      JustificativaLegal(
        inciso: 'I',
        alinea: 'h',
        descricao: 'namorar, em quaisquer das dependências da escola; e',
      ),
      JustificativaLegal(
        inciso: 'I',
        alinea: 'i',
        descricao:
            'descumprimento dos deveres de que tratam os incisos I ao XVI, XIX e XXI ao XXIII do Art. 156, bem como as condutas que configurem a prática das vedações de que tratam os incisos III ao V, VII ao X, XIV, XVII, XVIII do Art. 157.',
      ),
    ],

    advertenciaEscrita: [
      JustificativaLegal(
        inciso: 'II',
        alinea: 'a',
        descricao: 'frequentar bares e casas de diversões, quando uniformizados;',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'b',
        descricao:
            'praticar agiotagem, jogos de azar, fazer apostas, propor ou aceitar transação pecuniária de qualquer natureza, nas dependências do campus;',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'c',
        descricao:
            'desrespeitar, ofender, provocar com palavras, atos ou gestos colegas, educadores, demais servidores ou qualquer outra pessoa, nas dependências da Instituição;',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'd',
        descricao:
            'proferir palavras de baixo calão, gesticular, escrever ou fazer desenhos pornográficos nas dependências do campus ou quando em missão de representação;',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'e',
        descricao:
            'participar de atos de indisciplina ou perigosos, nas dependências da Instituição ou em sua proximidade;',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'f',
        descricao:
            'danificar ou lançar mão de objetos pertencentes a outrem ou à Instituição, sem autorização;',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'g',
        descricao:
            'organizar qualquer forma de arrecadação pecuniária, distribuir impressos, divulgar folhetos, fazer publicações em imprensa falada, escrita ou televisada em nome da Instituição, sem autorização expressa da Direção-Geral do campus;',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'h',
        descricao:
            'utilizar-se de meios fraudulentos para obter resultados favoráveis nas avaliações ou vantagem de qualquer natureza;',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'i',
        descricao:
            'impedir a entrada de colegas às aulas ou incitá-los a faltas coletivas;',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'j',
        descricao:
            'participar de eventos que ensejem subversão da ordem na Instituição ou incitar outrem a fazê-lo;',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'k',
        descricao:
            'fumar nas dependências da Instituição (Lei nº 9.294, de 15 de julho de 1996), incluindo os cigarros eletrônicos;',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'l',
        descricao:
            'utilizar telefone celular ou outros aparelhos eletrônicos similares durante as atividades curriculares, exceto se autorizados pelo professor;',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'm',
        descricao: 'reincidir em qualquer uma das infrações sujeitas a advertência oral;',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'n',
        descricao:
            'alterar, inutilizar ou destruir avisos ou documentos afixados pela Administração do campus ou entidades a ele ligadas;',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'o',
        descricao:
            'utilizar laboratórios e oficinas para atividades não relacionadas ao processo de ensino-aprendizagem;',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'p',
        descricao:
            'distribuir ou divulgar publicações e impressos no recinto, bem como qualquer conteúdo físico ou digital, que promova, incite ou reproduza práticas discriminatórias, tais como racismo, misoginia, etarismo, xenofobia, LGBTfobia, capacitismo, discurso de ódio ou qualquer outra forma de violência simbólica ou atentatória à dignidade humana;',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'q',
        descricao: 'aplicar trote, sob qualquer pretexto; e',
      ),
      JustificativaLegal(
        inciso: 'II',
        alinea: 'r',
        descricao:
            'descumprir os deveres de que tratam os incisos III e XXI do Art. 156, bem como as condutas que configurem a prática das vedações de que tratam os incisos V, XX, XXI do Art. 157.',
      ),
    ],

    suspensao: [
      JustificativaLegal(
        inciso: 'III',
        alinea: 'a',
        descricao:
            'praticar qualquer ação que implique constrangimento recorrente a outros alunos, que configure bullying ou cyberbullying, nos termos da legislação vigente;',
      ),
      JustificativaLegal(
        inciso: 'III',
        alinea: 'b',
        descricao:
            'desrespeitar, ofender, provocar com palavras, atos ou gestos colegas, educadores, demais servidores ou qualquer outra pessoa, nas dependências da Instituição;',
      ),
      JustificativaLegal(
        inciso: 'III',
        alinea: 'c',
        descricao:
            'reincidir em qualquer uma das infrações sujeitas a advertência escrita; e',
      ),
      JustificativaLegal(
        inciso: 'III',
        alinea: 'd',
        descricao:
            'descumprir os deveres de que tratam os incisos XVII e XX do Art. 156, bem como as condutas que configurem a prática das vedações de que tratam os incisos I, II, XI, XII, XVI do Art. 157.',
      ),
    ],
  };

  static List<JustificativaLegal> obter(String? tipo) {
    if (tipo == null) return [];
    return justificativas[tipo] ?? [];
  }

  static List<String> obterTextos(String? tipo) {
    return obter(tipo)
        .map((justificativa) => justificativa.textoCompleto)
        .toList();
  }
}