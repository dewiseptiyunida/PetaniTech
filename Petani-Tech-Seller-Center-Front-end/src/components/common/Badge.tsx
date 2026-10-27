import React from 'react';
import { StyleSheet, Text, View, StyleProp, ViewStyle, TextStyle } from 'react-native';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme/ThemeContext';

export interface BadgeProps {
  children: React.ReactNode;
  variant?: 'success' | 'warning' | 'danger' | 'info' | 'brand' | 'neutral' | 'leaf' | 'glass';
  size?: 'sm' | 'md';
  dot?: boolean;
  style?: StyleProp<ViewStyle>;
  textStyle?: StyleProp<TextStyle>;
}

export const Badge: React.FC<BadgeProps> = ({
  children,
  variant = 'brand',
  size = 'md',
  dot = false,
  style,
  textStyle,
}) => {
  const { isDark } = useTheme();
  const isTextLike =
    typeof children === 'string' ||
    typeof children === 'number' ||
    (Array.isArray(children) && children.every((c) => typeof c === 'string' || typeof c === 'number'));

  const darkVariantStyle = isDark ? darkStyles[variant] : null;
  const darkTextStyle = isDark ? darkStyles[`${variant}Text`] : null;
  const darkDotStyle = isDark ? darkStyles[`${variant}Dot`] : null;

  return (
    <View
      style={[
        styles.base,
        styles[variant],
        darkVariantStyle,
        size === 'sm' ? styles.sizeSm : styles.sizeMd,
        style,
      ]}
    >
      {dot && <View style={[styles.dot, styles[`${variant}Dot`], darkDotStyle]} />}
      {isTextLike ? (
        <Text
          style={[
            styles.text,
            styles[`${variant}Text`],
            darkTextStyle,
            size === 'sm' ? styles.textSm : styles.textMd,
            textStyle,
          ]}
        >
          {children}
        </Text>
      ) : (
        children
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  base: {
    flexDirection: 'row',
    alignItems: 'center',
    alignSelf: 'flex-start',
    borderRadius: 9999,
    borderWidth: 1,
  },
  sizeSm: {
    paddingHorizontal: 8,
    paddingVertical: 2.5,
    gap: 4,
  },
  sizeMd: {
    paddingHorizontal: 10,
    paddingVertical: 4.5,
    gap: 5,
  },
  text: {
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  textSm: {
    fontSize: 10.5,
  },
  textMd: {
    fontSize: 11.5,
  },
  dot: {
    width: 6,
    height: 6,
    borderRadius: 3,
  },
  brand: {
    backgroundColor: '#EAF4EE',
    borderColor: '#C6E2D0',
  },
  brandText: {
    color: '#31572C',
  },
  brandDot: {
    backgroundColor: '#40916C',
  },
  leaf: {
    backgroundColor: '#ECF39E',
    borderColor: '#90A955',
  },
  leafText: {
    color: '#31572C',
  },
  leafDot: {
    backgroundColor: '#40916C',
  },
  success: {
    backgroundColor: '#EAF4EE',
    borderColor: '#C6E2D0',
  },
  successText: {
    color: '#1E432E',
  },
  successDot: {
    backgroundColor: '#40916C',
  },
  warning: {
    backgroundColor: '#FEF9E7',
    borderColor: '#FDE68A',
  },
  warningText: {
    color: '#B45309',
  },
  warningDot: {
    backgroundColor: '#F59E0B',
  },
  danger: {
    backgroundColor: '#FEF2F2',
    borderColor: '#FECDD3',
  },
  dangerText: {
    color: '#B91C1C',
  },
  dangerDot: {
    backgroundColor: '#EF4444',
  },
  info: {
    backgroundColor: '#F0F7FF',
    borderColor: '#BAE6FD',
  },
  infoText: {
    color: '#1D4ED8',
  },
  infoDot: {
    backgroundColor: '#2563EB',
  },
  neutral: {
    backgroundColor: '#F2FBF5',
    borderColor: '#DDE8E0',
  },
  neutralText: {
    color: '#64746A',
  },
  neutralDot: {
    backgroundColor: '#90A955',
  },
  glass: {
    backgroundColor: 'rgba(255, 255, 255, 0.85)',
    borderColor: 'rgba(221, 232, 224, 0.95)',
  },
  glassText: {
    color: '#183326',
  },
  glassDot: {
    backgroundColor: '#32CD32',
  },
});

const darkStyles = StyleSheet.create({
  brand: {
    backgroundColor: 'rgba(64, 145, 108, 0.25)',
    borderColor: 'rgba(209, 245, 232, 0.35)',
  },
  brandText: {
    color: '#D1F5E8',
  },
  brandDot: {
    backgroundColor: '#40916C',
  },
  leaf: {
    backgroundColor: 'rgba(236, 243, 158, 0.18)',
    borderColor: 'rgba(144, 169, 85, 0.35)',
  },
  leafText: {
    color: '#ECF39E',
  },
  leafDot: {
    backgroundColor: '#90A955',
  },
  success: {
    backgroundColor: 'rgba(64, 145, 108, 0.25)',
    borderColor: 'rgba(209, 245, 232, 0.35)',
  },
  successText: {
    color: '#D1F5E8',
  },
  successDot: {
    backgroundColor: '#40916C',
  },
  warning: {
    backgroundColor: 'rgba(245, 158, 11, 0.20)',
    borderColor: 'rgba(245, 158, 11, 0.38)',
  },
  warningText: {
    color: '#FCD34D',
  },
  warningDot: {
    backgroundColor: '#F59E0B',
  },
  danger: {
    backgroundColor: 'rgba(239, 68, 68, 0.20)',
    borderColor: 'rgba(239, 68, 68, 0.38)',
  },
  dangerText: {
    color: '#FCA5A5',
  },
  dangerDot: {
    backgroundColor: '#EF4444',
  },
  info: {
    backgroundColor: 'rgba(59, 130, 246, 0.20)',
    borderColor: 'rgba(59, 130, 246, 0.38)',
  },
  infoText: {
    color: '#93C5FD',
  },
  infoDot: {
    backgroundColor: '#3B82F6',
  },
  neutral: {
    backgroundColor: 'rgba(255, 255, 255, 0.10)',
    borderColor: 'rgba(209, 245, 232, 0.18)',
  },
  neutralText: {
    color: '#D1F5E8',
  },
  neutralDot: {
    backgroundColor: '#8BA899',
  },
  glass: {
    backgroundColor: 'rgba(255, 255, 255, 0.14)',
    borderColor: 'rgba(209, 245, 232, 0.25)',
  },
  glassText: {
    color: '#FFFFFF',
  },
  glassDot: {
    backgroundColor: '#32CD32',
  },
});
