// ============================================================================
// Petani Tech Seller Center - Design Tokens: Spacing, Radii, Shadows, Glass
// ============================================================================

export const spacing = {
  none: 0,
  xs: 4,
  sm: 8,
  md: 12,
  base: 16,
  lg: 20,
  xl: 24,
  '2xl': 32,
  '3xl': 40,
  '4xl': 48,
  '5xl': 64,
} as const;

export const borderRadius = {
  none: 0,
  xs: 4,
  sm: 6,
  md: 10,
  base: 12,
  lg: 14,
  xl: 16,
  '2xl': 20,
  '3xl': 24,
  card: 20,
  pill: 9999,
  full: 9999,
} as const;

export const shadows = {
  none: {
    shadowColor: 'transparent',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0,
    shadowRadius: 0,
    elevation: 0,
  },
  sm: {
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.04,
    shadowRadius: 3,
    elevation: 1,
  },
  base: {
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 6,
    elevation: 2,
  },
  soft: {
    shadowColor: '#31572C',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 10,
    elevation: 3,
  },
  card: {
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.05,
    shadowRadius: 12,
    elevation: 2,
  },
  md: {
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 4,
  },
  lg: {
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.1,
    shadowRadius: 16,
    elevation: 8,
  },
  xl: {
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 12 },
    shadowOpacity: 0.14,
    shadowRadius: 24,
    elevation: 12,
  },
  glowGreen: {
    shadowColor: '#32CD32',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25,
    shadowRadius: 12,
    elevation: 4,
  },
  glass: {
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.07,
    shadowRadius: 16,
    elevation: 3,
  },
} as const;

export const glassSurfaces = {
  whiteGlass: {
    backgroundColor: '#FFFFFF',
    borderColor: '#DDE8E0',
    borderWidth: 1.5,
    borderRadius: 20,
    sheenColor: 'rgba(255, 255, 255, 0.95)',
    ...shadows.glass,
  },
  greenGlass: {
    backgroundColor: 'rgba(49, 87, 44, 0.88)',
    borderColor: 'rgba(209, 245, 232, 0.35)',
    borderWidth: 1.5,
    borderRadius: 20,
    sheenColor: 'rgba(255, 255, 255, 0.18)',
    ...shadows.soft,
  },
  mintGlass: {
    backgroundColor: '#F2FBF5',
    borderColor: '#D1F5E8',
    borderWidth: 1.5,
    borderRadius: 18,
    sheenColor: 'rgba(255, 255, 255, 0.9)',
    ...shadows.sm,
  },
  inputGlass: {
    backgroundColor: '#FFFFFF',
    borderColor: '#DDE8E0',
    borderWidth: 1.5,
    borderRadius: 16,
    minHeight: 48,
  },
  floatingNav: {
    backgroundColor: 'rgba(255, 255, 255, 0.98)',
    borderColor: '#DDE8E0',
    borderWidth: 1.5,
    borderRadius: 24,
    activeBubble: '#D1F5E8',
    activeText: '#183326',
    inactiveText: '#64746A',
    ...shadows.md,
  },
} as const;

export type Spacing = typeof spacing;
export type BorderRadius = typeof borderRadius;
export type Shadows = typeof shadows;
export type GlassSurfaces = typeof glassSurfaces;
