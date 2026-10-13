import '../../models/sermon_block.dart';

class GeneratedOutlineResult {
  final String title;
  final String biblicalReference;
  final String sermonType;
  final String introduction;
  final List<HomileticBlock> blocks;
  final String conclusion;
  final String appeal;

  const GeneratedOutlineResult({
    required this.title,
    required this.biblicalReference,
    required this.sermonType,
    required this.introduction,
    required this.blocks,
    required this.conclusion,
    required this.appeal,
  });
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
  /// Gera um esboço completo de homilética baseado nos parâmetros fornecidos
  static Future<GeneratedOutlineResult> generateOutline({
    required String theme,
    required String biblicalReference,
    required String sermonType,
  }) async {
    // Simulação com latência realista (pode ser conectado a endpoint OpenAI/Claude/Supabase Edge Function)
    await Future.delayed(const Duration(milliseconds: 1200));

    final cleanTheme = theme.trim().isEmpty ? 'A Graça Transformadora de Deus' : theme.trim();
    final cleanRef = biblicalReference.trim().isEmpty ? 'Romanos 8:28-39' : biblicalReference.trim();

    return GeneratedOutlineResult(
      title: cleanTheme,
      biblicalReference: cleanRef,
      sermonType: sermonType,
      introduction:
          'Quantas vezes nos sentimos desamparados pelas circunstâncias ao nosso redor? '
          'No texto de $cleanRef, as Escrituras nos revelam o propósito soberano do Criador, '
          'mostrando que mesmo nos momentos de maior pressão, a soberania divina tece '
          'todas as coisas para o bem daqueles que O amam de coração sincero.',
      blocks: [
        HomileticBlock(
          id: UniqueKeyString.generate(),
          title: '1. O Propósito Divino em Meio às Aflições',
          biblicalReference: '$cleanRef (Parte A)',
          explanation:
              'A soberania de Deus não é passiva, mas ativa. Deus não é o causador do mal, '
              'mas possui autoridade para redimir a dor e transformá-la em testemunho e maturidade espiritual.',
          illustration:
              'Como o tear da tapeçaria: do lado de baixo vemos apenas fios emaranhados e sem sentido, '
              'mas visto de cima pelo Mestre, revela-se uma obra de arte perfeita.',
          application:
              'Não meça o amor de Deus pelo tamanho da sua tribulação presente. Olhe para a cruz e descanse na promessa.',
          orderIndex: 0,
        ),
        HomileticBlock(
          id: UniqueKeyString.generate(),
          title: '2. A Inabalável Intercessão de Cristo',
          biblicalReference: '$cleanRef (Parte B)',
          explanation:
              'Nenhum tribunal humano ou acusador espiritual pode condenar aquele a quem Deus já justificou. '
              'Cristo ressuscitou e permanece à destra do Pai advogando a nossa causa.',
          illustration:
              'Um farol em um penhasco marítimo: as ondas violentas colidem com força titânica, '
              'mas a torre permanece imóvel, guiando os navios perdidos para a baía segura.',
          application:
              'Rejeite as vozes de acusação do inimigo. O sangue de Jesus cancelou o escrito de dívida que era contra nós.',
          orderIndex: 1,
        ),
        HomileticBlock(
          id: UniqueKeyString.generate(),
          title: '3. Mais que Vencedores por Aquele que nos Amou',
          biblicalReference: '$cleanRef (Parte C)',
          explanation:
              'A expressão grega hupernikao denota uma vitória esmagadora e definitiva. '
              'Não somos apenas sobreviventes; somos herdeiros coroados pela graça.',
          illustration:
              'A águia não foge da tempestade; ela abre suas asas e usa os próprios ventos contrários '
              'para elevar-se acima das nuvens carregadas.',
          application:
              'Levante a cabeça nesta noite. A batalha pode ser dura, mas o veredito final da sua vitória já foi assinado no Calvário.',
          orderIndex: 2,
        ),
      ],
      conclusion:
          'Nada — nem a morte, nem a vida, nem anjos, nem principados — poderá jamais nos separar do amor de Deus '
          'que está em Cristo Jesus nosso Senhor. Esta é a rocha sobre a qual devemos firmar nossa fé.',
      appeal:
          'Se você tem se sentido esmagado pelas lutas, venha ao altar hoje para renovar suas forças na presença do Espírito Santo.',
    );
  }

  /// Gera sugestões de ilustrações práticas para enriquecer o sermão
  static Future<List<String>> generateIllustrations({
    required String sermonTheme,
    required String pointContext,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

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
    await Future.delayed(const Duration(milliseconds: 700));

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
        word: 'ὑπερνικάω',
        transliteration: 'hupernikao',
        language: 'Grego (Novo Testamento)',
        strongNumber: 'G5245',
        meaning: 'Super-vencedor, triunfar gloriosamente, vencer com abundância de folga.',
        theologicalInsight:
          'Junção de "huper" (além, sobre) com "nikao" (conquistar). Paulo afirma que nossa vitória não é parcial ou acirrada, '
          'mas absoluta e selada pelo sacrifício vicário de Cristo.',
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
      const GreekHebrewInsight(
        word: 'σπλαγχνίζομαι',
        transliteration: 'splagchnizomai',
        language: 'Grego (Novo Testamento)',
        strongNumber: 'G4697',
        meaning: 'Mover-se de íntima compaixão; sentir visceralmente a dor alheia.',
        theologicalInsight:
          'Usado para descrever a reação de Jesus ao ver as multidões famintas e feridas como ovelhas sem pastor. '
          'Uma compaixão que impele à ação salvífica imediata.',
      ),
    ];
  }
}
