import '../../models/sermon_block.dart';
import '../../models/sermon_model.dart';

class GeneratedOutlineResult {
  final String title;
  final String biblicalReference;
  final String sermonType;
  final String introduction;
  final List<HomileticBlock> blocks;
  final String conclusion;
  final String appeal;
  final List<String> crossReferences; // Referências de Ponte (AT e NT)
  final String historicalContext;     // Contexto Histórico e Autoria

  const GeneratedOutlineResult({
    required this.title,
    required this.biblicalReference,
    required this.sermonType,
    required this.introduction,
    required this.blocks,
    required this.conclusion,
    required this.appeal,
    this.crossReferences = const [],
    this.historicalContext = '',
  });

  /// Converte o esboço gerado pela IA em um objeto Sermon completo pronto para salvar ou editar
  Sermon toSermon({String? category}) {
    final now = DateTime.now();
    return Sermon(
      id: 'sermon-ai-${now.millisecondsSinceEpoch}',
      userId: 'pastor-local-01',
      title: title,
      biblicalReference: biblicalReference,
      category: category ?? (crossReferences.isNotEmpty ? 'Graça & Redenção' : 'Expositivo'),
      sermonType: sermonType,
      introduction: introduction,
      blocks: blocks,
      conclusion: conclusion,
      appeal: appeal,
      status: 'ready',
      isFavorite: false,
      preachCount: 0,
      estimatedDurationMinutes: 42,
      createdAt: now,
      updatedAt: now,
    );
  }
}

class GreekHebrewInsight {
  final String word;
  final String transliteration;
  final String language; // Grego ou Hebraico
  final String strongNumber;
  final String meaning;
  final String theologicalInsight;

  const GreekHebrewInsight({
    required this.word,
    required this.transliteration,
    required this.language,
    required this.strongNumber,
    required this.meaning,
    required this.theologicalInsight,
  });
}

class AiHomileticsService {
  /// Gera um esboço completo de homilética de alta riqueza exegética com 5 divisões e pontes bíblicas
  static Future<GeneratedOutlineResult> generateOutline({
    required String theme,
    required String biblicalReference,
    required String sermonType,
  }) async {
    // Simulação com latência realista do motor teológico
    await Future.delayed(const Duration(milliseconds: 1100));

    final cleanTheme = theme.trim().isEmpty ? 'Salvos pelo Mérito de Cristo' : theme.trim();
    final cleanRef = biblicalReference.trim().isEmpty ? 'Efésios 2:1-10' : biblicalReference.trim();
    final lowerRef = cleanRef.toLowerCase();
    final lowerTheme = cleanTheme.toLowerCase();

    // 1. ESPECIALIZAÇÃO EXPOSITIVA: EFÉSIOS 2 (A Obra Soberana da Graça)
    if (lowerRef.contains('efés') || lowerRef.contains('efes') || lowerTheme.contains('mérito') || lowerTheme.contains('graça')) {
      return GeneratedOutlineResult(
        title: cleanTheme.isNotEmpty && cleanTheme != 'Salvos pelo mérito de Cristo' ? cleanTheme : 'Salvos pelo Mérito de Cristo',
        biblicalReference: cleanRef,
        sermonType: sermonType,
        historicalContext:
            'Carta escrita pelo apóstolo Paulo por volta de 60-62 d.C. enquanto prisioneiro em Roma. '
            'Éfeso era uma metrópole gentílica dominada pelo ocultismo e pelo templo de Ártemis. Paulo contrasta '
            'a antiga morte espiritual sob os principados das trevas com a triunfante exaltação dos crentes assentados em Cristo.',
        crossReferences: const [
          'Romanos 5:1-11 (Justificação e Paz)',
          'Gênesis 3:1-15 (A Queda e a Promessa da Redenção)',
          'Colossenses 2:13-15 (O Triunfo da Cruz sobre as Dívidas)',
          'Isaías 57:19 (Paz para os que Estavam Longe e Perto)',
          'Tito 3:4-7 (A Salvação Não por Obras de Justiça Própria)',
        ],
        introduction:
            'O evangelho não é um manual de autoajuda que ensina homens caídos a se reerguerem; é uma declaração '
            'de ressurreição espiritual onde o Deus Todo-Poderoso desce ao abismo da nossa incapacidade. '
            'Em $cleanRef, Paulo desmonta toda pretensão de mérito humano e constrói o monumento supremo da graça soberana. '
            'Nossa esperança eterna não reside no que fizemos para Deus, mas no que Cristo consumou vicariamente em nosso favor.',
        blocks: [
          HomileticBlock(
            id: UniqueKeyString.generate(),
            title: '1. O Diagnóstico Universal: A Falência Total do Homem Sem Deus',
            biblicalReference: 'Efésios 2:1-3 • Pontes: Romanos 5:12; Jeremias 17:9; Colossenses 2:13',
            explanation:
                'Paulo utiliza o termo grego "nekros" (cadáver, morto espiritualmente) para descrever o estado humano. '
                'O homem não estava meramente doente ou desorientado moralmente; estava morto em delitos e pecados, '
                'seguindo voluntariamente o curso deste mundo ("aion"), subjugado pelo príncipe da potestade do ar e pelas paixões da carne.',
            illustration:
                'O náufrago no fundo do oceano: um homem sem oxigênio não precisa de lições de natação ou de uma boia jogada à distância; '
                'ele necessita que um mergulhador desça às trevas profundas, o tome em seus braços e insufle vida em seus pulmões inertes.',
            application:
                'Reconheça a seriedade da sua condição natural. Ninguém pode valorizar a grandeza do remédio da cruz enquanto '
                'minimizar a gravidade mortal do pecado em seu próprio coração.',
            orderIndex: 0,
          ),
          HomileticBlock(
            id: UniqueKeyString.generate(),
            title: '2. A Virada Soberana: "Mas Deus, Sendo Rico em Misericórdia"',
            biblicalReference: 'Efésios 2:4-7 • Pontes: Lamentações 3:22-23; Salmos 103:10-12; Tito 3:4-5',
            explanation:
                'A conjunção adversativa grega "De" ("Mas Deus") introduz a maior intervenção da história cósmica. '
                'Quando a justiça exigia a nossa condenação irrevogável, a misericórdia ("eleos") e o supremo amor sacrificial ("agape") '
                'de Deus irromperam. Ele nos vivificou juntamente com Cristo e nos assentou espiritualmente nos lugares celestiais.',
            illustration:
                'O tribunal onde o réu confesso aguarda a sentença de morte, e o próprio magistrado se despoja de suas vestes judiciais, '
                'desce do estrado supremo, assume a penalidade em seu próprio corpo e estende uma carta irrevogável de adoção familiar.',
            application:
                'Pare de olhar para as suas fraquezas como o limite do que Deus pode fazer. Quando o desespero disser "tudo acabou", '
                'lembre-se do decreto celestial: "Mas Deus!" Ele é rico em misericórdia para com você hoje.',
            orderIndex: 1,
          ),
          HomileticBlock(
            id: UniqueKeyString.generate(),
            title: '3. A Gratuidade Inegociável: Pela Graça Mediante a Fé, Dom de Deus',
            biblicalReference: 'Efésios 2:8-9 • Pontes: Romanos 3:24-28; Gálatas 2:16; Isaías 64:6',
            explanation:
                'A salvação provém exclusivamente da graça ("charis" - favor imerecido e gratuito) através do canal da fé ("pistis"). '
                'Paulo enfatiza enfaticamente: "isto não vem de vós, é dom de Deus; não vem das obras, para que ninguém se glorie" ("kauchomai"). '
                'Qualquer tentativa de somar justiça própria ao sacrifício de Jesus constitui afronta à perfeição do Calvário.',
            illustration:
                'Um banquete real de valor incalculável preparado pelo soberano: se um convidado tentar tirar uma moeda oxidada do bolso '
                'para pagar pelo banquete, ele não demonstra dignidade, mas insulta gravemente a generosidade do rei.',
            application:
                'Abandone de uma vez por todas o legalismo religioso e a culpa paralisante. Receba o abraço da graça com as mãos vazias, '
                'confiando que o sangue vertido na cruz é 100% suficiente para purificar o seu passado e garantir o seu futuro.',
            orderIndex: 2,
          ),
          HomileticBlock(
            id: UniqueKeyString.generate(),
            title: '4. O Propósito da Redenção: Feitura Sua, Criados para as Boas Obras',
            biblicalReference: 'Efésios 2:10 • Pontes: 2 Coríntios 5:17; Tiago 2:17-18; Mateus 5:16',
            explanation:
                'O vocábulo grego "poiema" (de onde deriva "poema" ou "obra-prima artesanal") declara que a igreja é a escultura divina. '
                'Não somos salvos *pelas* obras, mas fomos salvos *para* as boas obras que Deus preparou de antemão ("proetoimazo") '
                'para que andássemos nelas. As obras não são a raiz da salvação, mas o fruto inevitável de uma vida regenerada.',
            illustration:
                'A macieira não produz maçãs doces para provar que é macieira; ela produz maçãs porque a vida e a seiva da árvore '
                'fluem naturalmente em seus ramos podados e cuidados pelo agricultor.',
            application:
                'Seja a expressão visível do poema da graça de Deus no seu trabalho, em sua casa e na sociedade. '
                'Viva de modo que os homens vejam suas boas obras e glorifiquem o Pai que está nos céus.',
            orderIndex: 3,
          ),
          HomileticBlock(
            id: UniqueKeyString.generate(),
            title: '5. A Nova Comunidade de Paz: A Derrubada da Parede de Separação',
            biblicalReference: 'Efésios 2:11-22 • Pontes: Isaías 57:19; Gálatas 3:28; 1 Pedro 2:9-10',
            explanation:
                'Cristo não apenas reconciliou o homem com Deus, mas derrubou a parede intermediária de inimizade ("mesotoichon"). '
                'Gentios e judeus, distantes e próximos, agora formam "um novo homem" ("heis kainos anthropos"), '
                'sendo edificados sobre o fundamento dos apóstolos e profetas, tendo Jesus como a pedra angular ("akrogoniaios").',
            illustration:
                'A demolição de muralhas históricas de divisão: famílias antes separadas por arames farpados se abraçando em pranto, '
                'celebrando uma cidadania comum onde não há mais estrangeiros nem peregrinos, mas concidadãos do Reino.',
            application:
                'Derrube todo muro de rancor, amargura ou preconceito em seus relacionamentos. '
                'Se Cristo nos uniu no mesmo corpo na cruz, vivamos como a verdadeira família dos santos em amor e comunhão.',
            orderIndex: 4,
          ),
        ],
        conclusion:
            'A mensagem de Efésios 2 ecoa através dos séculos: do vale da morte espiritual fomos transportados para os lugares celestiais '
            'não por mérito, barganha ou justiça própria, mas pelo amor imensurável daquele que entregou a Sua vida por nós. '
            'Somos a feitura de Deus, um monumento vivo ao louvor da glória da Sua graça!',
        appeal:
            'Você que tem tentado agradar a Deus pelas suas próprias forças ou que se sente distante do amor celestial, '
            'abandone hoje os seus fardos. Aproxime-se do trono da graça com fé; Jesus já pagou a sua dívida na cruz!',
      );
    }

    // 2. MOTOR HOMILÉTICO DINÂMICO PARA QUALQUER TEXTO OU TEMA INFORMADO PELO PREGADOR
    return GeneratedOutlineResult(
      title: cleanTheme,
      biblicalReference: cleanRef,
      sermonType: sermonType,
      historicalContext:
          'Passagem de profunda revelação das Sagradas Escrituras em $cleanRef. O texto revela princípios eternos '
          'do caráter de Deus, conectando a soberania celestial com o chamado prático para o povo da aliança.',
      crossReferences: [
        'Salmos 119:105 (A Palavra como Lâmpada e Luz)',
        'Romanos 8:31-39 (A Inabalável Certeza do Amor Divino)',
        'Hebreus 11:1-6 (O Fundamento Inabalável da Fé Verdadeira)',
        'Isaías 40:28-31 (O Renovo das Forças no Senhor)',
        '2 Coríntios 12:9-10 (O Poder Aperfeiçoado na Fraqueza)',
      ],
      introduction:
          'Quantas vezes a congregação se vê confrontada pelos dilemas do cotidiano sem uma bússola segura? '
          'Em $cleanRef, as Escrituras sagradas nos convidam a contemplar a soberania e fidelidade de Deus em torno do tema "$cleanTheme". '
          'Não estamos reunidos para ouvir opiniões humanas falíveis, mas para ser impactados pela voz viva do Espírito Santo '
          'que expõe o nosso coração e restaura a nossa caminhada de fé.',
      blocks: [
        HomileticBlock(
          id: UniqueKeyString.generate(),
          title: '1. O Contexto Revelado: A Realidade Humana Sob o Olhar de Deus',
          biblicalReference: '$cleanRef (Parte Inicial) • Pontes: Salmos 139:1-7; Jeremias 29:11',
          explanation:
              'A revelação divina parte da realidade concreta do ser humano. Deus não ignora os desafios, '
              'dores e limitações do Seu povo, mas intervém no cenário histórico com propósitos eternos e redentores.',
          illustration:
              'O arquiteto que analisa o terreno rochoso antes de erguer o alicerce: ele não se assusta com os desníveis, '
              'pois já projetou as colunas capazes de suportar qualquer impacto.',
          application:
              'Apresente suas vulnerabilidades a Deus com honestidade. Ele conhece as suas lutas antes mesmo de serem pronunciadas.',
          orderIndex: 0,
        ),
        HomileticBlock(
          id: UniqueKeyString.generate(),
          title: '2. O Princípio Teológico: A Fidelidade Inabalável da Aliança',
          biblicalReference: '$cleanRef (Desenvolvimento) • Pontes: Lamentações 3:22-23; 2 Timóteo 2:13',
          explanation:
              'O texto revela um princípio que não oscila conforme as eras: a aliança de Deus é sustentada pelo Seu próprio juramento. '
              'A fidelidade do Senhor permanece inalterável mesmo quando o homem tropeça.',
          illustration:
              'Uma rocha milenar no litoral que resiste dia e noite à fúria constante das marés, permanecendo inabalável.',
          application:
              'Ancore as suas decisões nas promessas imutáveis da Palavra de Deus e não na instabilidade passageira dos seus sentimentos.',
          orderIndex: 1,
        ),
        HomileticBlock(
          id: UniqueKeyString.generate(),
          title: '3. A Centralidade em Cristo: A Ponte Eterna da Graça',
          biblicalReference: '$cleanRef (Conexão Messiânica) • Pontes: João 14:6; Hebreus 7:25; Colossenses 1:19-20',
          explanation:
              'Toda a Escritura converge para a pessoa e obra de Jesus Cristo. Não há solução pastoral autêntica sem passar '
              'pela cruz, pela ressurreição e pela mediação viva do Filho de Deus.',
          illustration:
              'A chave-mestra que abre todas as portas trancadas da prisão: Cristo desce ao cativeiro para conduzir os cativos à liberdade.',
          application:
              'Reconheça que você não pode vencer pelos próprios esforços. Deposite sua confiança na suficiência redentora de Jesus.',
          orderIndex: 2,
        ),
        HomileticBlock(
          id: UniqueKeyString.generate(),
          title: '4. A Transformação Interna: O Fruto da Obra do Espírito',
          biblicalReference: '$cleanRef (Aplicação Comunitária) • Pontes: Gálatas 5:22-25; Romanos 12:1-2',
          explanation:
              'O evangelho não produz mera concordância intelectual; ele gera metanoia — transformação profunda de mente, '
              'afeições e conduta moral no poder capacitador do Espírito Santo.',
          illustration:
              'A árvore frutífera que floresce na primavera porque a vida interna da seiva expulsa naturalmente as folhas secas.',
          application:
              'Permita que o Espírito Santo sonde e trate as áreas secretas da sua vida para que você frutifique em justiça.',
          orderIndex: 3,
        ),
        HomileticBlock(
          id: UniqueKeyString.generate(),
          title: '5. O Chamado Prático: Posicionamento e Fruto no Mundo',
          biblicalReference: '$cleanRef (Desafio Prático) • Pontes: Mateus 28:18-20; Tiago 1:22-25',
          explanation:
              'A mensagem que ouvimos exige uma resposta de obediência e serviço. O pregador convoca o povo '
              'a ser sal da terra e luz do mundo, exercendo o ministério da reconciliação no seu dia a dia.',
          illustration:
              'A lâmpada que não é acesa para ser colocada debaixo do alqueire, mas sobre o velador para alumiar a todos que estão na casa.',
          application:
              'Saia deste lugar comprometido a agir: perdoe quem te feriu, testemunhe da sua fé e sirva ao próximo com amor genuíno.',
          orderIndex: 4,
        ),
      ],
      conclusion:
          'À luz de $cleanRef e da mensagem de "$cleanTheme", somos lembrados de que Deus está operando em nós tanto o querer como o realizar. '
          'Ele começou a boa obra e a aperfeiçoará até o dia de Cristo Jesus.',
      appeal:
          'Se você precisa de um renovo espiritual ou deseja entregar a sua vida ao senhorio de Cristo, dê esse passo de fé hoje diante do altar.',
    );
  }

  /// Gera sugestões de ilustrações práticas para enriquecer o sermão
  static Future<List<String>> generateIllustrations({
    required String sermonTheme,
    required String pointContext,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return [
      'O Relógio do Mestre: Uma criança vê o relojoeiro desmontar as engrenagens e acha que ele estragou a máquina; porém, após a limpeza meticulosa, o relógio volta a marcar as horas com absoluta precisão.',
      'O Ouro e o Cadinho de Fogo: O ourives mantém o metal precioso na fornalha ardente até que consiga ver o reflexo nítido do seu próprio rosto no ouro purificado.',
      'A Semente no Solo Escuro: Antes de brotar como árvore frondosa, a semente passa pelo sepultamento na terra e pelo rompimento da casca. O que parecia morte era na verdade o início da colheita.',
    ];
  }

  /// Fornece análise exegética de termos em Grego e Hebraico com contexto histórico
  static Future<List<GreekHebrewInsight>> getLexicalInsights({
    required String biblicalPassage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (biblicalPassage.toLowerCase().contains('filip') ||
        biblicalPassage.toLowerCase().contains('ansied')) {
      return [
        const GreekHebrewInsight(
          word: 'μεριμνάω',
          transliteration: 'merimnao',
          language: 'Grego (Novo Testamento)',
          strongNumber: 'G3309',
          meaning: 'Estar dividido, puxado para direções opostas; sofrer angústia mental.',
          theologicalInsight:
              'Derivado de "merizo" (dividir). A ansiedade rouba nossa capacidade de foco espiritual, '
              'fragmentando o coração entre a confiança em Deus e o pavor das circunstâncias terrenas.',
        ),
        const GreekHebrewInsight(
          word: 'φρουρέω',
          transliteration: 'phroureo',
          language: 'Grego (Novo Testamento)',
          strongNumber: 'G5432',
          meaning: 'Montar guarda militar, proteger como guarnição em fortaleza.',
          theologicalInsight:
              'Termo militar romano muito conhecido pelos filipenses, colônia militar de Roma. '
              'A paz de Deus não é mera calmaria, mas soldados celestiais armados vigiando a porta do nosso coração.',
        ),
      ];
    }

    return [
      const GreekHebrewInsight(
        word: 'χάρις',
        transliteration: 'charis',
        language: 'Grego (Novo Testamento)',
        strongNumber: 'G5485',
        meaning: 'Graça, favor imerecido, benevolência soberana e gratuita de Deus.',
        theologicalInsight:
            'No contexto do Novo Testamento, descreve o amor ativo de Deus conferido a pecadores rebeldes '
            'que mereciam a condenação, capacitando-os a uma vida de comunhão e santidade sem qualquer barganha meritória.',
      ),
      const GreekHebrewInsight(
        word: 'ποίημα',
        transliteration: 'poiema',
        language: 'Grego (Novo Testamento)',
        strongNumber: 'G4161',
        meaning: 'Obra feita, manufatura artística, poema, obra-prima artesanal.',
        theologicalInsight:
            'Usado em Efésios 2:10 para declarar que o crente regenerado é a escultura viva das mãos de Deus, '
            'moldada intencionalmente para refletir o caráter do Criador diante da criação.',
      ),
      const GreekHebrewInsight(
        word: 'חֶסֶד',
        transliteration: 'chesed',
        language: 'Hebraico (Antigo Testamento)',
        strongNumber: 'H2617',
        meaning: 'Amor leal pactual, misericórdia infalível, benignidade perpétua.',
        theologicalInsight:
            'Descreve o compromisso juramentado de Yahweh com Seu povo. Mesmo quando o homem quebra a fidelidade, '
            'o Chesed de Deus permanece inalterável.',
      ),
    ];
  }
}
