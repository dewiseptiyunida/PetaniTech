import React from 'react';
import {
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  StyleProp,
  ViewStyle,
} from 'react-native';
import { ChevronRight } from 'lucide-react-native';
import { useTheme } from '@/theme/ThemeContext';
import { typography } from '@/theme/typography';

export interface ListItemProps {
  title: string;
  subtitle?: string;
  detail?: string;
  leftIcon?: React.ReactNode;
  leftIconBg?: string;
  rightElement?: React.ReactNode;
  showChevron?: boolean;
  onPress?: () => void;
  variant?: 'card' | 'flat' | 'glass';
  showDivider?: boolean;
  style?: StyleProp<ViewStyle>;
  disabled?: boolean;
}

export const ListItem: React.FC<ListItemProps> = ({
  title,
  subtitle,
  detail,
  leftIcon,
  leftIconBg,
  rightElement,
  showChevron = false,
  onPress,
  variant = 'card',
  showDivider = false,
  style,
  disabled = false,
}) => {
  const { colors, isDark } = useTheme();

  const getContainerStyle = (): ViewStyle => {
    switch (variant) {
      case 'glass':
        return {
          backgroundColor: isDark
            ? 'rgba(22, 58, 38, 0.65)'
            : 'rgba(255, 255, 255, 0.90)',
          borderColor: isDark
            ? 'rgba(209, 245, 232, 0.20)'
            : '#DDE8E0',
          borderWidth: 1,
          borderRadius: 16,
          padding: 14,
        };
      case 'card':
        return {
          backgroundColor: isDark ? 'rgba(22, 58, 38, 0.72)' : '#FFFFFF',
          borderColor: isDark ? 'rgba(209, 245, 232, 0.16)' : '#DDE8E0',
          borderWidth: 1,
          borderRadius: 16,
          padding: 14,
          shadowColor: '#183326',
          shadowOffset: { width: 0, height: 2 },
          shadowOpacity: 0.04,
          shadowRadius: 6,
          elevation: 2,
        };
      case 'flat':
      default:
        return {
          backgroundColor: 'transparent',
          paddingVertical: 12,
          paddingHorizontal: 4,
        };
    }
  };

  const defaultIconBg = isDark
    ? 'rgba(64, 145, 108, 0.22)'
    : '#F2FBF5';

  const content = (
    <>
      <View style={styles.mainRow}>
        {leftIcon ? (
          <View
            style={[
              styles.iconWrapper,
              { backgroundColor: leftIconBg || defaultIconBg },
            ]}
          >
            {leftIcon}
          </View>
        ) : null}

        <View style={styles.textContainer}>
          <Text
            style={[
              styles.title,
              { color: isDark ? '#FFFFFF' : '#183326' },
            ]}
            numberOfLines={1}
          >
            {title}
          </Text>
          {subtitle ? (
            <Text
              style={[
                styles.subtitle,
                { color: isDark ? '#D1F5E8' : '#64746A' },
              ]}
              numberOfLines={2}
            >
              {subtitle}
            </Text>
          ) : null}
        </View>

        {detail ? (
          <Text
            style={[
              styles.detail,
              { color: isDark ? colors.mint : colors.primary },
            ]}
          >
            {detail}
          </Text>
        ) : null}

        {rightElement}

        {showChevron ? (
          <ChevronRight
            size={18}
            color={isDark ? '#8BA899' : '#A3B4A5'}
            style={styles.chevron}
          />
        ) : null}
      </View>

      {showDivider && variant === 'flat' ? (
        <View
          style={[
            styles.divider,
            { backgroundColor: isDark ? 'rgba(255, 255, 255, 0.08)' : '#EFF4F0' },
          ]}
        />
      ) : null}
    </>
  );

  if (onPress) {
    return (
      <TouchableOpacity
        onPress={onPress}
        disabled={disabled}
        activeOpacity={0.72}
        style={[getContainerStyle(), disabled && styles.disabled, style]}
      >
        {content}
      </TouchableOpacity>
    );
  }

  return (
    <View style={[getContainerStyle(), disabled && styles.disabled, style]}>
      {content}
    </View>
  );
};

const styles = StyleSheet.create({
  mainRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  iconWrapper: {
    width: 42,
    height: 42,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  textContainer: {
    flex: 1,
    gap: 3,
  },
  title: {
    fontSize: 14,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  subtitle: {
    fontSize: 12,
    fontFamily: typography.fontFamily.regular,
    lineHeight: 16,
  },
  detail: {
    fontSize: 13,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  chevron: {
    marginLeft: 2,
  },
  divider: {
    height: 1,
    marginTop: 12,
  },
  disabled: {
    opacity: 0.5,
  },
});
