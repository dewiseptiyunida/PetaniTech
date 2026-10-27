export * from './colors';
export * from './typography';
export * from './spacing';
export * from './types';
export * from './tokens';
export * from './ThemeContext';
export * from './motion';

import { colors, brand } from './colors';
import { typography } from './typography';
import { spacing, borderRadius, shadows, glassSurfaces } from './spacing';
import { motion } from './motion';

export const theme = {
  colors,
  brand,
  typography,
  spacing,
  borderRadius,
  shadows,
  glassSurfaces,
  motion,
} as const;


export type Theme = typeof theme;
