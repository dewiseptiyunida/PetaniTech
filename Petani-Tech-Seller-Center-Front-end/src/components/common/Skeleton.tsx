import React from 'react';
import { StyleSheet, View, StyleProp, ViewStyle } from 'react-native';

import { useTheme } from '@/theme/ThemeContext';

export interface SkeletonProps {
  style?: StyleProp<ViewStyle>;
  rounded?: 'sm' | 'md' | 'lg' | 'full';
}

export const Skeleton: React.FC<SkeletonProps> = ({ style, rounded = 'md' }) => {
  const { isDark } = useTheme();
  const roundedStyle = {
    sm: styles.roundedSm,
    md: styles.roundedMd,
    lg: styles.roundedLg,
    full: styles.roundedFull,
  }[rounded];

  return (
    <View
      style={[
        styles.base,
        {
          backgroundColor: isDark
            ? 'rgba(255, 255, 255, 0.08)'
            : '#EAEFE7',
        },
        roundedStyle,
        style,
      ]}
    />
  );
};

export const SkeletonText: React.FC<{ lines?: number; style?: StyleProp<ViewStyle> }> = ({
  lines = 3,
  style,
}) => (
  <View style={[styles.textGroup, style]}>
    {Array.from({ length: lines }).map((_, i) => (
      <Skeleton
        key={i}
        rounded="md"
        style={[styles.textLine, i === lines - 1 && lines > 1 ? styles.textLineShort : null]}
      />
    ))}
  </View>
);

export const StatCardSkeleton: React.FC = () => {
  const { isDark } = useTheme();
  return (
    <View
      style={[
        styles.cardSkeleton,
        {
          backgroundColor: isDark ? 'rgba(22, 58, 38, 0.72)' : '#FFFFFF',
          borderColor: isDark ? 'rgba(209, 245, 232, 0.16)' : '#E8ECE7',
        },
      ]}
    >
      <View style={styles.row}>
        <View style={styles.col}>
          <Skeleton style={{ width: 80, height: 12, marginBottom: 8 }} />
          <Skeleton style={{ width: 120, height: 24 }} />
        </View>
        <Skeleton rounded="md" style={{ width: 44, height: 44 }} />
      </View>
    </View>
  );
};

export const ProductCardSkeleton: React.FC = () => {
  const { isDark } = useTheme();
  return (
    <View
      style={[
        styles.cardSkeleton,
        {
          backgroundColor: isDark ? 'rgba(22, 58, 38, 0.72)' : '#FFFFFF',
          borderColor: isDark ? 'rgba(209, 245, 232, 0.16)' : '#E8ECE7',
        },
      ]}
    >
      <Skeleton rounded="lg" style={{ width: '100%', height: 140, marginBottom: 12 }} />
      <Skeleton style={{ width: 100, height: 12, marginBottom: 6 }} />
      <Skeleton style={{ width: '80%', height: 16, marginBottom: 8 }} />
      <Skeleton style={{ width: 120, height: 20 }} />
    </View>
  );
};

const styles = StyleSheet.create({
  base: {
    backgroundColor: '#EAEFE7',
  },
  roundedSm: {
    borderRadius: 6,
  },
  roundedMd: {
    borderRadius: 10,
  },
  roundedLg: {
    borderRadius: 14,
  },
  roundedFull: {
    borderRadius: 9999,
  },
  textGroup: {
    gap: 8,
  },
  textLine: {
    height: 12,
    width: '100%',
  },
  textLineShort: {
    width: '65%',
  },
  cardSkeleton: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 16,
    borderWidth: 1,
    borderColor: '#E8ECE7',
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  col: {
    flex: 1,
  },
});
