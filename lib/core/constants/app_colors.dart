import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Cores de Identidade Visual Pastoral & Teológica (Profundidade & Autoridade)
  static const Color primaryRoyalNavy = Color(0xFF0F172A); // Slate 900
  static const Color primaryBlue = Color(0xFF1E3A8A);      // Blue 900
  static const Color primaryElectricBlue = Color(0xFF2563EB); // Blue 600
  static const Color accentGold = Color(0xFFD97706);       // Amber 600
  static const Color goldLight = Color(0xFFFBBF24);        // Amber 400
  static const Color goldDark = Color(0xFFB45309);         // Amber 700
  static const Color sacredGoldLuminous = Color(0xFFF59E0B); // Amber 500

  // Tons Neutros Claros (Alto contraste para cards brancos 3D)
  static const Color backgroundLight = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Tons Neutros Escuros (Dark Mode Moderno & Profundo)
  static const Color backgroundDark = Color(0xFF090D16); // Obsidian Navy
  static const Color surfaceDark = Color(0xFF0F172A);    // Slate 900
  static const Color surfaceVariantDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Modo Púlpito (Alto Contraste Oled & Anti-Reflexo)
  static const Color pulpitBackground = Color(0xFF000000);
  static const Color pulpitSurface = Color(0xFF121212);
  static const Color pulpitTextHighContrast = Color(0xFFFFFFFF);
  static const Color pulpitTextAmber = Color(0xFFFDE68A); // Modo Leitura Noturna Quente
  static const Color pulpitAccent = Color(0xFFF59E0B);

  // Cores Semânticas de Homilética
  static const Color homileticIntro = Color(0xFF3B82F6);        // Azul Expositivo
  static const Color homileticPoint = Color(0xFF10B981);        // Esmeralda da Vida
  static const Color homileticIllustration = Color(0xFF8B5CF6); // Roxo Hermenêutico
  static const Color homileticApplication = Color(0xFFF59E0B);  // Âmbar Pastoral
  static const Color homileticConclusion = Color(0xFFEF4444);   // Vermelho Redentor
  static const Color homileticAppeal = Color(0xFFEC4899);       // Rosa da Graça

  // Status
  static const Color statusDraft = Color(0xFF64748B);
  static const Color statusReady = Color(0xFF10B981);
  static const Color statusArchived = Color(0xFF94A3B8);

  // GRADIENTES 3D PROFISSIONAIS (PALETA EXECUTIVA)
  static const LinearGradient heroNavyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF090D16), Color(0xFF0F172A), Color(0xFF1E3A8A)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB45309), Color(0xFFF59E0B)],
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF047857), Color(0xFF10B981)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
  );

  static const LinearGradient cardGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );

  // SOMBRAS 3D EM CAMADAS (AMBIENTE + ELEVAÇÃO + GLOW)
  static List<BoxShadow> cardShadow3D({bool isDark = false, Color? accentColor}) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
        if (accentColor != null)
          BoxShadow(
            color: accentColor.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
      ];
    }
    return [
      BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.08),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
      if (accentColor != null)
        BoxShadow(
          color: accentColor.withValues(alpha: 0.12),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
    ];
  }

  static List<BoxShadow> buttonShadow3D(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.35),
        blurRadius: 14,
        offset: const Offset(0, 5),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }
}
