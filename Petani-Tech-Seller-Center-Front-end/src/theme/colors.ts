// ============================================================================
// Petani Tech Seller Center - Design Tokens: Colors
// Palet Wajib:
// - White: #FAF9F6
// - Grass: #40916C
// - Leaf: #ECF39E
// - Moss: #90A955
// - Forest: #31572C
// ============================================================================

export const brand = {
  // Required Design Foundation Palette
  brandGreen: '#32CD32',   // Brand Green aksen identitas
  grass: '#40916C',        // Grass Green brand utama
  forest: '#31572C',       // Forest Green teks elegan & kontras tinggi
  moss: '#90A955',         // Moss Green aksen alami
  softMint: '#D1F5E8',     // Soft Mint highlight & bubble
  lightMint: '#F2FBF5',    // Light Mint background section lembut
  softWhite: '#FAF9F6',    // Soft White background halaman
  white: '#FFFFFF',        // White card & modal
  pureWhite: '#FFFFFF',
  primaryText: '#183326',  // Primary Text utama gelap
  secondaryText: '#64746A',// Secondary Text pendukung
  border: '#DDE8E0',       // Border standar card & input

  // Backward compatibility & convenience aliases
  mint: '#D1F5E8',
  leaf: '#ECF39E',
  softBorder: '#DDE8E0',
} as const;

export const colors = {
  // Brand Primary (Tema Hijau Alami & Segar)
  primary: {
    DEFAULT: '#40916C', // Grass brand utama
    hover: '#367B5C',
    dark: '#31572C',    // Forest green (kontras tinggi, teks elegan)
    deep: '#31572C',    // Forest
    vibrant: '#32CD32', // Brand Green aksen identitas
    grass: '#40916C',   // Grass
    moss: '#90A955',    // Moss
    leaf: '#ECF39E',    // Leaf
    forest: '#31572C',  // Forest
    mint: '#D1F5E8',    // Mint Green
    light: '#ECF39E',   // Leaf aksen lembut
    border: '#E3EDE6',  // Soft border
    soft: '#F4F7F2',    // Background badge & icon container ultra soft
    tint: '#E5EFE2',    // Tint lembut
    gradient: ['#40916C', '#31572C'] as [string, string], // Grass to Forest
    gradientLight: ['#FAF9F6', '#FFFFFF'] as [string, string],
    gradientHero: ['#40916C', '#90A955'] as [string, string], // Hero dashboard: Grass to Moss
    gradientLeaf: ['#ECF39E', '#90A955'] as [string, string],
    gradientHeader: ['#D1F5E8', '#FFFFFF'] as [string, string], // Header: Mint to White
    gradientMint: ['#FAF9F6', '#D1F5E8'] as [string, string], // Background section: Soft White to Mint
    gradientCard: ['#FFFFFF', '#F9FAF7'] as [string, string],
    gradientButton: ['#40916C', '#31572C'] as [string, string], // Tombol utama: Grass to Forest
    gradientSplash: ['#0A1D10', '#13351C', '#224D2B'] as [string, string, string],
    gradientAuthBg: ['#0B1F11', '#14381D', '#1D4928'] as [string, string, string],
    gradientAuthCard: ['rgba(255, 255, 255, 0.95)', 'rgba(250, 249, 246, 0.88)'] as [string, string],
    gradientBubble: ['rgba(209, 245, 232, 0.35)', 'rgba(255, 255, 255, 0.05)'] as [string, string],
  },

  // Glassmorphism & Translucent Design Tokens (Watery / Liquid / Bubble)
  glass: {
    background: 'rgba(255, 255, 255, 0.90)',
    backgroundSubtle: 'rgba(255, 255, 255, 0.12)',
    backgroundDark: 'rgba(12, 32, 18, 0.65)',
    border: 'rgba(255, 255, 255, 0.65)',
    borderSubtle: 'rgba(255, 255, 255, 0.22)',
    borderGreen: 'rgba(64, 145, 108, 0.35)',
    bubbleMint: 'rgba(209, 245, 232, 0.28)',
    bubbleWhite: 'rgba(255, 255, 255, 0.15)',
    highlight: 'rgba(255, 255, 255, 0.90)',
  },

  // Netral, Surface & Latar Belakang (Dominan Putih/Off-white #FAF9F6 & #F2FBF5)
  neutral: {
    900: '#183326', // Primary Text utama gelap
    800: '#2A382C', // Charcoal Forest
    700: '#3E4D40', // Body Text Utama
    600: '#64746A', // Secondary Text pendukung
    500: '#7E9180', // Subtle Secondary Slate
    400: '#A3B4A5', // Border Slate Gray
    300: '#D2DDD4', // Border Card Lembut & Placeholder
    200: '#DDE8E0', // Border standar card & input (#DDE8E0)
    100: '#F2FBF5', // Light Mint Surface Lembut
    50: '#FAF9F6',  // Background Halaman Utama (Soft White #FAF9F6)
    white: '#FFFFFF',
    card: '#FFFFFF',
    background: '#FAF9F6',
  },

  // Status & Umpan Balik (Semantic)
  semantic: {
    success: {
      DEFAULT: '#40916C',
      text: '#1E432E',
      bg: '#EAF4EE',
      border: '#90A955',
    },
    warning: {
      DEFAULT: '#D97706',
      text: '#92400E',
      bg: '#FEF3C7',
      border: '#FDE68A',
    },
    danger: {
      DEFAULT: '#E11D48',
      text: '#9F1239',
      bg: '#FFF1F2',
      border: '#FECDD3',
    },
    info: {
      DEFAULT: '#2563EB',
      text: '#1E40AF',
      bg: '#EFF6FF',
      border: '#BFDBFE',
    },
  },

  // Aksen Kategori & Quick Menu (Dashboard)
  categories: {
    products: { icon: '#40916C', bg: '#EAF4EE' },
    orders: { icon: '#31572C', bg: '#E5EFE2' },
    finance: { icon: '#90A955', bg: '#F4F7EE' },
    inventory: { icon: '#5F7061', bg: '#F0F5F1' },
    promotions: { icon: '#40916C', bg: '#ECF39E' },
    analytics: { icon: '#31572C', bg: '#FAF9F6' },
  },
} as const;

export type Colors = typeof colors;
