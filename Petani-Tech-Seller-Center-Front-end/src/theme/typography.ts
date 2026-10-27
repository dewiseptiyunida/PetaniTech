// ============================================================================
// Petani Tech Seller Center - Design Tokens: Typography
// Font Utama: Poppins (Regular, Medium, SemiBold, Bold, ExtraBold)
// ============================================================================

import { Platform, TextStyle } from 'react-native';

const webFontFamily = 'Poppins, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';

export const typography = {
  fontFamily: {
    regular: Platform.select({ web: webFontFamily, default: 'Poppins_400Regular' }),
    medium: Platform.select({ web: webFontFamily, default: 'Poppins_500Medium' }),
    semibold: Platform.select({ web: webFontFamily, default: 'Poppins_600SemiBold' }),
    bold: Platform.select({ web: webFontFamily, default: 'Poppins_700Bold' }),
    extrabold: Platform.select({ web: webFontFamily, default: 'Poppins_800ExtraBold' }),
    heading: Platform.select({ web: webFontFamily, default: 'Poppins_700Bold' }),
  },
  fontSize: {
    xs: 10,
    sm: 12,
    base: 14,
    md: 16,
    lg: 18,
    xl: 20,
    '2xl': 24,
    '3xl': 28,
    '4xl': 32,
  },
  fontWeight: {
    regular: '400' as const,
    medium: '500' as const,
    semibold: '600' as const,
    bold: '700' as const,
    extrabold: '800' as const,
  },
  lineHeight: {
    tight: 14,
    snug: 18,
    normal: 20,
    relaxed: 24,
    loose: 28,
    heading: 34,
  },
  presets: {
    h1: {
      fontFamily: Platform.select({ web: webFontFamily, default: 'Poppins_700Bold' }),
      fontSize: 28,
      fontWeight: '700' as TextStyle['fontWeight'],
      lineHeight: 34,
      letterSpacing: -0.5,
    },
    h2: {
      fontFamily: Platform.select({ web: webFontFamily, default: 'Poppins_700Bold' }),
      fontSize: 22,
      fontWeight: '700' as TextStyle['fontWeight'],
      lineHeight: 28,
      letterSpacing: -0.3,
    },
    h3: {
      fontFamily: Platform.select({ web: webFontFamily, default: 'Poppins_600SemiBold' }),
      fontSize: 18,
      fontWeight: '600' as TextStyle['fontWeight'],
      lineHeight: 24,
      letterSpacing: -0.2,
    },
    h4: {
      fontFamily: Platform.select({ web: webFontFamily, default: 'Poppins_600SemiBold' }),
      fontSize: 16,
      fontWeight: '600' as TextStyle['fontWeight'],
      lineHeight: 22,
    },
    body: {
      fontFamily: Platform.select({ web: webFontFamily, default: 'Poppins_400Regular' }),
      fontSize: 14,
      fontWeight: '400' as TextStyle['fontWeight'],
      lineHeight: 20,
    },
    bodyMedium: {
      fontFamily: Platform.select({ web: webFontFamily, default: 'Poppins_500Medium' }),
      fontSize: 14,
      fontWeight: '500' as TextStyle['fontWeight'],
      lineHeight: 20,
    },
    bodySemibold: {
      fontFamily: Platform.select({ web: webFontFamily, default: 'Poppins_600SemiBold' }),
      fontSize: 14,
      fontWeight: '600' as TextStyle['fontWeight'],
      lineHeight: 20,
    },
    label: {
      fontFamily: Platform.select({ web: webFontFamily, default: 'Poppins_600SemiBold' }),
      fontSize: 13,
      fontWeight: '600' as TextStyle['fontWeight'],
      lineHeight: 18,
      letterSpacing: 0.1,
    },
    caption: {
      fontFamily: Platform.select({ web: webFontFamily, default: 'Poppins_400Regular' }),
      fontSize: 12,
      fontWeight: '400' as TextStyle['fontWeight'],
      lineHeight: 16,
    },
    captionMedium: {
      fontFamily: Platform.select({ web: webFontFamily, default: 'Poppins_500Medium' }),
      fontSize: 12,
      fontWeight: '500' as TextStyle['fontWeight'],
      lineHeight: 16,
    },
    badge: {
      fontFamily: Platform.select({ web: webFontFamily, default: 'Poppins_700Bold' }),
      fontSize: 11,
      fontWeight: '700' as TextStyle['fontWeight'],
      lineHeight: 14,
      letterSpacing: 0.3,
    },
    button: {
      fontFamily: Platform.select({ web: webFontFamily, default: 'Poppins_700Bold' }),
      fontSize: 14,
      fontWeight: '700' as TextStyle['fontWeight'],
      lineHeight: 20,
      letterSpacing: 0.2,
    },
  },
} as const;

export type Typography = typeof typography;
