import React from 'react';
import {
  ActivityIndicator,
  StyleSheet,
  TouchableOpacity,
  View,
  Text,
  StyleProp,
  ViewStyle,
} from 'react-native';
import { useTheme } from '@/theme/ThemeContext';
import { typography } from '@/theme/typography';

export interface IconButtonProps {
  icon: React.ReactNode;
  onPress?: () => void;
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'glass' | 'softMint' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  isLoading?: boolean;
  badge?: number | string;
  badgeDot?: boolean;
  style?: StyleProp<ViewStyle>;
  accessibilityLabel: string;
}

export const IconButton: React.FC<IconButtonProps> = ({
  icon,
  onPress,
  variant = 'secondary',
  size = 'md',
  disabled = false,
  isLoading = false,
  badge,
  badgeDot = false,
  style,
  accessibilityLabel,
}) => {
  const { colors, isDark } = useTheme();
  const isDisabled = disabled || isLoading;

  const sizeStyles = {
    sm: styles.sizeSm,
    md: styles.sizeMd,
    lg: styles.sizeLg,
  }[size];

  const getVariantStyles = (): ViewStyle => {
    switch (variant) {
      case 'primary':
        return {
          backgroundColor: colors.primary,
          borderColor: colors.primaryDark,
          borderWidth: 1,
        };
      case 'outline':
        return {
          backgroundColor: 'transparent',
          borderColor: isDark ? 'rgba(209, 245, 232, 0.25)' : '#DDE8E0',
          borderWidth: 1.2,
        };
      case 'ghost':
        return {
          backgroundColor: 'transparent',
          borderWidth: 0,
        };
      case 'glass':
        return {
          backgroundColor: isDark
            ? 'rgba(255, 255, 255, 0.12)'
            : 'rgba(255, 255, 255, 0.90)',
          borderColor: isDark
            ? 'rgba(209, 245, 232, 0.22)'
            : '#DDE8E0',
          borderWidth: 1,
        };
      case 'softMint':
        return {
          backgroundColor: isDark
            ? 'rgba(64, 145, 108, 0.22)'
            : '#D1F5E8',
          borderColor: isDark
            ? 'rgba(209, 245, 232, 0.30)'
            : '#BCE8D5',
          borderWidth: 1,
        };
      case 'danger':
        return {
          backgroundColor: isDark
            ? 'rgba(239, 68, 68, 0.20)'
            : '#FEE2E2',
          borderColor: isDark
            ? 'rgba(239, 68, 68, 0.35)'
            : '#FECACA',
          borderWidth: 1,
        };
      case 'secondary':
      default:
        return {
          backgroundColor: isDark ? 'rgba(22, 58, 38, 0.65)' : '#F2FBF5',
          borderColor: isDark ? 'rgba(209, 245, 232, 0.18)' : '#DDE8E0',
          borderWidth: 1,
        };
    }
  };

  const hitSlopValue = size === 'sm' ? 8 : 4;

  return (
    <TouchableOpacity
      onPress={onPress}
      disabled={isDisabled}
      activeOpacity={0.72}
      accessibilityRole="button"
      accessibilityLabel={accessibilityLabel}
      hitSlop={{
        top: hitSlopValue,
        bottom: hitSlopValue,
        left: hitSlopValue,
        right: hitSlopValue,
      }}
      style={[
        styles.base,
        sizeStyles,
        getVariantStyles(),
        isDisabled && styles.disabled,
        style,
      ]}
    >
      {isLoading ? (
        <ActivityIndicator
          size="small"
          color={variant === 'primary' ? '#FFFFFF' : colors.primary}
        />
      ) : (
        icon
      )}

      {/* Badge or Dot */}
      {badgeDot ? (
        <View style={styles.badgeDot} />
      ) : badge !== undefined && badge !== null ? (
        <View style={styles.badgeContainer}>
          <Text style={styles.badgeText} numberOfLines={1}>
            {badge}
          </Text>
        </View>
      ) : null}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  base: {
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
    overflow: 'visible',
  },
  sizeSm: {
    width: 34,
    height: 34,
    borderRadius: 10,
  },
  sizeMd: {
    width: 42,
    height: 42,
    borderRadius: 14,
  },
  sizeLg: {
    width: 48,
    height: 48,
    borderRadius: 16,
  },
  disabled: {
    opacity: 0.45,
  },
  badgeContainer: {
    position: 'absolute',
    top: -4,
    right: -4,
    minWidth: 18,
    height: 18,
    borderRadius: 9,
    backgroundColor: '#EF4444',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 4,
    borderWidth: 1.5,
    borderColor: '#FFFFFF',
  },
  badgeText: {
    color: '#FFFFFF',
    fontSize: 9.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    lineHeight: 12,
  },
  badgeDot: {
    position: 'absolute',
    top: -1,
    right: -1,
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#EF4444',
    borderWidth: 1.5,
    borderColor: '#FFFFFF',
  },
});
