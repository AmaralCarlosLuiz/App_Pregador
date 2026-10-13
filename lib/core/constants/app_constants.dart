class AppConstants {
  AppConstants._();

  static const String appName = 'Pregador Pro';
  static const String appTagline = 'Plataforma Inteligente de Homilética e Ministração';

  // Categorias de Sermão
  static const List<String> sermonCategories = [
    'Todas',
    'Família',
    'Fé e Esperança',
    'Cura e Milagres',
    'Evangelismo',
    'Oração e Jejum',
    'Avivamento',
    'Batalha Espiritual',
    'Liderança Cristã',
    'Ceia do Senhor',
    'Casamento',
    'Funeral e Consolo',
    'Jovens e Adolescentes',
  ];

  // Tipos de Sermão (Homilética Clássica)
  static const List<String> sermonTypes = [
    'Expositivo',
    'Temático',
    'Textual',
    'Evangelístico',
    'Devocional',
  ];

  // Status do Sermão
  static const List<String> sermonStatuses = [
    'draft',     // Em Rascunho
    'ready',     // Pronto para Ministrar
    'archived',  // Arquivado / Ministrado
  ];

  // Livros da Bíblia (para o Seletor Bíblico Inteligente)
  static const List<String> oldTestamentBooks = [
    'Gênesis', 'Êxodo', 'Levítico', 'Números', 'Deuteronômio',
    'Josué', 'Juízes', 'Rute', '1 Samuel', '2 Samuel',
    '1 Reis', '2 Reis', '1 Crônicas', '2 Crônicas', 'Esdras',
    'Neemias', 'Ester', 'Jó', 'Salmos', 'Provérbios',
    'Eclesiastes', 'Cânticos', 'Isaías', 'Jeremias', 'Lamentações',
    'Ezequiel', 'Daniel', 'Oseias', 'Joel', 'Amós',
    'Obadias', 'Jonas', 'Miqueias', 'Naum', 'Habacuque',
    'Sofonias', 'Ageu', 'Zacarias', 'Malaquias'
  ];

  static const List<String> newTestamentBooks = [
    'Mateus', 'Marcos', 'Lucas', 'João', 'Atos',
    'Romanos', '1 Coríntios', '2 Coríntios', 'Gálatas', 'Efésios',
    'Filipenses', 'Colossenses', '1 Tessalonicenses', '2 Tessalonicenses',
    '1 Timóteo', '2 Timóteo', 'Tito', 'Filemom', 'Hebreus',
    'Tiago', '1 Pedro', '2 Pedro', '1 João', '2 João', '3 João',
    'Judas', 'Apocalipse'
  ];

  static List<String> get allBibleBooks => [...oldTestamentBooks, ...newTestamentBooks];
}
