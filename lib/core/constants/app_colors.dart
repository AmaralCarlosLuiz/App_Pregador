import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Cores de Identidade Visual Pastoral & Teológica
  static const Color primaryRoyalNavy = Color(0xFF0F172A); // Slate 900
  static const Color primaryBlue = Color(0xFF1E3A8A);      // Blue 900
  static const Color accentGold = Color(0xFFD97706);       // Amber 600
  static const Color goldLight = Color(0xFFFBBF24);        // Amber 400
  static const Color goldDark = Color(0xFFB45309);         // Amber 700

  // Tons Neutros Claros
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Tons Neutros Escuros (Dark Mode Moderno)
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF131B2E);
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
  static const Color homileticIntro = Color(0xFF3B82F6);      // Azul
  static const Color homileticPoint = Color(0xFF10B981);      // Esmeralda
  static const Color homileticIllustration = Color(0xFF8B5CF6); // Roxo
  static const Color homileticApplication = Color(0xFFF59E0B);  // Âmbar
  static const Color homileticConclusion = Color(0xFFEF4444);  // Vermelho
  static const Color homileticAppeal = Color(0xFFEC4899);      // Rosa

  // Status
  static const Color statusDraft = Color(0xFF64748B);
  static const Color statusReady = Color(0xFF10B981);
  static const Color statusArchived = Color(0xFF94A3B8);
}
