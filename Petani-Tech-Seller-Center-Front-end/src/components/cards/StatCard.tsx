import React from 'react';
import { StyleSheet, Text, View, StyleProp, ViewStyle } from 'react-native';
import { Card } from './Card';
import { colors } from '@/theme/colors';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme';

export interface StatCardProps {
  title: string;
  value: string | number;
  subtitle?: string;
  icon: React.ComponentType<{ size?: number; color?: string }>;
  iconBgColor?: string;
  iconColor?: string;
  trend?: {
    value: string;
    isPositive: boolean;
  };
  onClick?: () => void;
  onPress?: () => void;
  style?: StyleProp<ViewStyle>;
}

export const StatCard: React.FC<StatCardProps> = ({
  title,
  value,
  subtitle,
  icon: Icon,
  iconBgColor,
  iconColor,
  trend,
  onClick,
  onPress,
  style,
}) => {
  const { themeColors, isDarkMode } = useTheme();

  const defaultIconBg = isDarkMode ? 'rgba(64, 145, 108, 0.16)' : '#EAF4EE';
  const defaultIconColor = isDarkMode ? themeColors.accent : colors.primary.DEFAULT;

  return (
    <Card
      onPress={onPress || onClick}
      style={[
        styles.container,
        {
          backgroundColor: themeColors.cardBackground,
          borderColor: themeColors.cardBorder,
        },
        style,
      ]}
    >
      <View style={styles.topRow}>
        <View style={styles.textColumn}>
          <Text style={[styles.title, { color: themeColors.textSecondary }]}>{title}</Text>
          <Text style={[styles.value, { color: themeColors.textPrimary }]}>{value}</Text>
        </View>
        <View style={[styles.iconWrapper, { backgroundColor: iconBgColor || defaultIconBg }]}>
          <Icon size={20} color={iconColor || defaultIconColor} />
        </View>
      </View>

      {(subtitle || trend) && (
        <View style={[styles.bottomRow, { borderTopColor: themeColors.divider }]}>
          {subtitle ? (
            <Text style={[styles.subtitle, { color: themeColors.textMuted }]}>{subtitle}</Text>
          ) : (
            <View />
          )}
          {trend ? (
            <Text
              style={[
                styles.trendText,
                trend.isPositive ? styles.trendPositive : styles.trendNegative,
              ]}
            >
              {trend.isPositive ? '↑' : '↓'} {trend.value}
            </Text>
          ) : null}
        </View>
      )}
    </Card>
  );
};

const styles = StyleSheet.create({
  container: {
    padding: 16,
    gap: 12,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#E6EDE7',
    backgroundColor: '#FFFFFF',
  },
  topRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  textColumn: {
    flex: 1,
    gap: 4,
  },
  title: {
    fontSize: 12,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
    color: colors.neutral[600],
  },
  value: {
    fontSize: 18,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
    color: colors.neutral[900],
  },
  iconWrapper: {
    width: 42,
    height: 42,
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
  },
  bottomRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: '#F0F5F1',
  },
  subtitle: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
    color: colors.neutral[500],
  },
  trendText: {
    fontSize: 11,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  trendPositive: {
    color: colors.primary.DEFAULT,
  },
  trendNegative: {
    color: colors.semantic.danger.DEFAULT,
  },
});
