export type ThemeMode = 'light' | 'dark' | 'system';
export type ActiveTheme = 'light' | 'dark';

export interface ThemeColors {
  mode: ActiveTheme;
  isDark: boolean;

  // Backgrounds & Surfaces
  background: string;
  backgroundSecondary: string;
  surface: string;
  card: string;
  cardBorder: string;
  cardSheen: string;

  // Aliases for convenience across screens
  cardBackground: string;
  cardBackgroundSecondary: string;
  modalBackground: string;
  modalBorder: string;

  // Borders & Dividers
  border: string;
  borderSubtle: string;
  borderGlass: string;
  divider: string;

  // Typography
  text: string;
  textPrimary: string;
  textSecondary: string;
  textMuted: string;
  textInverted: string;

  // Brand Green Palette (Petani Tech)
  primary: string;
  primaryDark: string;
  brandGreen: string;
  grass: string;
  forest: string;
  moss: string;
  softMint: string;
  lightMint: string;
  softWhite: string;
  white: string;
  accent: string;
  mint: string;
  leaf: string;

  // Form & Inputs
  inputBg: string;
  inputBorder: string;
  inputText: string;
  inputPlaceholder: string;

  // Navigation (Bottom Tab Bar)
  navBg: string;
  navBorder: string;
  navActive: string;
  navInactive: string;
  navActiveBg: string;

  // Semantics
  semantic: {
    success: {
      DEFAULT: string;
      text: string;
      bg: string;
      border: string;
    };
    warning: {
      DEFAULT: string;
      text: string;
      bg: string;
      border: string;
    };
    danger: {
      DEFAULT: string;
      text: string;
      bg: string;
      border: string;
    };
    info: {
      DEFAULT: string;
      text: string;
      bg: string;
      border: string;
    };
  };

  // Gradients
  gradients: {
    main: readonly [string, string, string, string];
    balance: readonly [string, string, string];
    header: readonly [string, string];
    button: readonly [string, string];
    recommendation: readonly [string, string];
  };
  headerGradient: readonly [string, string];
}

export interface ThemeContextType {
  mode: ThemeMode;
  activeTheme: ActiveTheme;
  isDark: boolean;
  isDarkMode: boolean;
  setMode: (mode: ThemeMode) => void;
  toggleTheme: () => void;
  colors: ThemeColors;
  themeColors: ThemeColors;
}
