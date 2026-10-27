import { ThemeColors } from './types';

export const darkThemeColors: ThemeColors = {
  mode: 'dark',
  isDark: true,

  // Backgrounds & Surfaces (Forest green, deep green, transparency)
  background: '#0B2014',
  backgroundSecondary: '#102B1C',
  surface: '#163A26',
  card: 'rgba(22, 58, 38, 0.72)',
  cardBorder: 'rgba(209, 245, 232, 0.18)',
  cardSheen: 'rgba(255, 255, 255, 0.22)',

  // Aliases for convenience across screens
  cardBackground: 'rgba(22, 58, 38, 0.72)',
  cardBackgroundSecondary: '#102B1C',
  modalBackground: '#102B1C',
  modalBorder: 'rgba(209, 245, 232, 0.22)',

  // Borders & Dividers
  border: 'rgba(209, 245, 232, 0.16)',
  borderSubtle: 'rgba(255, 255, 255, 0.08)',
  borderGlass: 'rgba(209, 245, 232, 0.25)',
  divider: 'rgba(255, 255, 255, 0.10)',

  // Typography
  text: '#FFFFFF',
  textPrimary: '#FFFFFF',
  textSecondary: '#D1F5E8',
  textMuted: '#8BA899',
  textInverted: '#183326',

  // Brand Green Palette (Petani Tech)
  primary: '#40916C',
  primaryDark: '#31572C',
  brandGreen: '#32CD32',
  grass: '#40916C',
  forest: '#31572C',
  moss: '#90A955',
  softMint: '#D1F5E8',
  lightMint: '#F2FBF5',
  softWhite: '#FAF9F6',
  white: '#FFFFFF',
  accent: '#32CD32',
  mint: '#D1F5E8',
  leaf: '#ECF39E',

  // Form & Inputs
  inputBg: 'rgba(22, 58, 38, 0.75)',
  inputBorder: 'rgba(209, 245, 232, 0.22)',
  inputText: '#FFFFFF',
  inputPlaceholder: '#8BA899',

  // Navigation (Bottom Tab Bar)
  navBg: 'rgba(11, 32, 20, 0.96)',
  navBorder: 'rgba(209, 245, 232, 0.20)',
  navActive: '#D1F5E8',
  navInactive: '#8BA899',
  navActiveBg: 'rgba(64, 145, 108, 0.38)',

  // Semantics
  semantic: {
    success: {
      DEFAULT: '#40916C',
      text: '#D1F5E8',
      bg: 'rgba(64, 145, 108, 0.25)',
      border: 'rgba(209, 245, 232, 0.30)',
    },
    warning: {
      DEFAULT: '#F59E0B',
      text: '#FCD34D',
      bg: 'rgba(245, 158, 11, 0.22)',
      border: 'rgba(245, 158, 11, 0.38)',
    },
    danger: {
      DEFAULT: '#EF4444',
      text: '#FCA5A5',
      bg: 'rgba(239, 68, 68, 0.22)',
      border: 'rgba(239, 68, 68, 0.38)',
    },
    info: {
      DEFAULT: '#3B82F6',
      text: '#93C5FD',
      bg: 'rgba(59, 130, 246, 0.22)',
      border: 'rgba(59, 130, 246, 0.38)',
    },
  },

  // Gradients
  gradients: {
    main: ['#0B2014', '#102B1C', '#163A26', '#1E4A32'] as const,
    balance: ['#31572C', '#40916C', '#225B3E'] as const,
    header: ['rgba(209, 245, 232, 0.15)', 'rgba(22, 58, 38, 0.75)'] as const,
    button: ['#40916C', '#31572C'] as const,
    recommendation: ['rgba(28, 73, 49, 0.90)', 'rgba(22, 58, 38, 0.78)'] as const,
  },
  headerGradient: ['#0B2014', '#102B1C'] as const,
};

export const lightThemeColors: ThemeColors = {
  mode: 'light',
  isDark: false,

  // Backgrounds & Surfaces (Blend: White, Soft White, Light Mint, Accents)
  background: '#FAF9F6',
  backgroundSecondary: '#F2FBF5',
  surface: '#FFFFFF',
  card: '#FFFFFF',
  cardBorder: '#DDE8E0',
  cardSheen: 'rgba(255, 255, 255, 0.95)',

  // Aliases for convenience across screens
  cardBackground: '#FFFFFF',
  cardBackgroundSecondary: '#FAF9F6',
  modalBackground: '#FFFFFF',
  modalBorder: '#DDE8E0',

  // Borders & Dividers
  border: '#DDE8E0',
  borderSubtle: '#EFF4F0',
  borderGlass: '#D1F5E8',
  divider: '#DDE8E0',

  // Typography
  text: '#183326',
  textPrimary: '#183326',
  textSecondary: '#64746A',
  textMuted: '#7E9180',
  textInverted: '#FFFFFF',

  // Brand Green Palette (Petani Tech)
  primary: '#40916C',
  primaryDark: '#31572C',
  brandGreen: '#32CD32',
  grass: '#40916C',
  forest: '#31572C',
  moss: '#90A955',
  softMint: '#D1F5E8',
  lightMint: '#F2FBF5',
  softWhite: '#FAF9F6',
  white: '#FFFFFF',
  accent: '#32CD32',
  mint: '#D1F5E8',
  leaf: '#ECF39E',

  // Form & Inputs
  inputBg: '#FFFFFF',
  inputBorder: '#DDE8E0',
  inputText: '#183326',
  inputPlaceholder: '#A3B4A5',

  // Navigation (Bottom Tab Bar)
  navBg: 'rgba(255, 255, 255, 0.98)',
  navBorder: '#DDE8E0',
  navActive: '#183326',
  navInactive: '#64746A',
  navActiveBg: '#D1F5E8',

  // Semantics
  semantic: {
    success: {
      DEFAULT: '#40916C',
      text: '#1E432E',
      bg: '#EAF4EE',
      border: '#C6E2D0',
    },
    warning: {
      DEFAULT: '#D97706',
      text: '#92400E',
      bg: '#FEF3C7',
      border: '#FDE68A',
    },
    danger: {
      DEFAULT: '#DC2626',
      text: '#991B1B',
      bg: '#FEE2E2',
      border: '#FECACA',
    },
    info: {
      DEFAULT: '#2563EB',
      text: '#1E40AF',
      bg: '#EFF6FF',
      border: '#BFDBFE',
    },
  },

  // Gradients
  gradients: {
    main: ['#F2FBF5', '#FAF9F6', '#FFFFFF', '#FAF9F6'] as const,
    balance: ['#31572C', '#40916C', '#90A955'] as const,
    header: ['#D1F5E8', '#FFFFFF'] as const,
    button: ['#40916C', '#31572C'] as const,
    recommendation: ['#FFFFFF', '#F2FBF5'] as const,
  },
  headerGradient: ['#F2FBF5', '#FAF9F6'] as const,
};
