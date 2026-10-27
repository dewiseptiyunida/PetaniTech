import React from 'react';
import {
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  StyleProp,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { useTheme } from '@/theme/ThemeContext';
import { typography } from '@/theme/typography';

export interface FilterChipProps {
  label: string;
  selected?: boolean;
  count?: number | string;
  icon?: React.ReactNode;
  onPress: () => void;
  disabled?: boolean;
  style?: StyleProp<ViewStyle>;
  textStyle?: StyleProp<TextStyle>;
  size?: 'sm' | 'md';
}

export const FilterChip: React.FC<FilterChipProps> = ({
  label,
  selected = false,
  count,
  icon,
  onPress,
  disabled = false,
  style,
  textStyle,
  size = 'md',
}) => {
  const { isDark } = useTheme();

  const getContainerStyle = (): ViewStyle => {
    if (selected) {
      return {
        backgroundColor: isDark ? 'rgba(64, 145, 108, 0.35)' : '#D1F5E8',
        borderColor: isDark ? 'rgba(209, 245, 232, 0.45)' : '#40916C',
        borderWidth: 1.5,
      };
    }
    return {
      backgroundColor: isDark ? 'rgba(22, 58, 38, 0.60)' : '#FFFFFF',
      borderColor: isDark ? 'rgba(209, 245, 232, 0.18)' : '#DDE8E0',
      borderWidth: 1,
    };
  };

  const getTextColor = (): string => {
    if (selected) {
      return isDark ? '#FFFFFF' : '#183326';
    }
    return isDark ? '#D1F5E8' : '#64746A';
  };

  const getCountBg = (): string => {
    if (selected) {
      return isDark ? 'rgba(209, 245, 232, 0.25)' : '#40916C';
    }
    return isDark ? 'rgba(255, 255, 255, 0.12)' : '#F2FBF5';
  };

  const getCountTextColor = (): string => {
    if (selected) {
      return isDark ? '#FFFFFF' : '#FFFFFF';
    }
    return isDark ? '#D1F5E8' : '#64746A';
  };

  return (
    <TouchableOpacity
      onPress={onPress}
      disabled={disabled}
      activeOpacity={0.75}
      style={[
        styles.chip,
        size === 'sm' ? styles.chipSm : styles.chipMd,
        getContainerStyle(),
        disabled && styles.disabled,
        style,
      ]}
    >
      {icon ? <View style={styles.iconContainer}>{icon}</View> : null}
      <Text
        style={[
          styles.label,
          size === 'sm' ? styles.labelSm : styles.labelMd,
          { color: getTextColor() },
          selected && styles.labelSelected,
          textStyle,
        ]}
      >
        {label}
      </Text>
      {count !== undefined && count !== null ? (
        <View style={[styles.countBadge, { backgroundColor: getCountBg() }]}>
          <Text
            style={[
              styles.countText,
              { color: getCountTextColor() },
              selected && styles.countTextSelected,
            ]}
          >
            {count}
          </Text>
        </View>
      ) : null}
    </TouchableOpacity>
  );
};

export interface FilterChipGroupProps {
  children: React.ReactNode;
  contentContainerStyle?: StyleProp<ViewStyle>;
  style?: StyleProp<ViewStyle>;
}

export const FilterChipGroup: React.FC<FilterChipGroupProps> = ({
  children,
  contentContainerStyle,
  style,
}) => (
  <ScrollView
    horizontal
    showsHorizontalScrollIndicator={false}
    style={[styles.scrollGroup, style]}
    contentContainerStyle={[styles.scrollGroupContent, contentContainerStyle]}
  >
    {children}
  </ScrollView>
);

const styles = StyleSheet.create({
  chip: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 9999,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.04,
    shadowRadius: 3,
    elevation: 1,
  },
  chipSm: {
    paddingHorizontal: 10,
    paddingVertical: 5,
    gap: 6,
  },
  chipMd: {
    paddingHorizontal: 14,
    paddingVertical: 7,
    gap: 7,
  },
  disabled: {
    opacity: 0.45,
  },
  iconContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  label: {
    fontFamily: typography.fontFamily.medium,
  },
  labelSm: {
    fontSize: 11.5,
  },
  labelMd: {
    fontSize: 12.5,
  },
  labelSelected: {
    fontFamily: typography.fontFamily.bold,
  },
  countBadge: {
    minWidth: 18,
    height: 18,
    borderRadius: 9,
    paddingHorizontal: 5,
    alignItems: 'center',
    justifyContent: 'center',
  },
  countText: {
    fontSize: 10,
    fontFamily: typography.fontFamily.semibold,
    lineHeight: 13,
  },
  countTextSelected: {
    fontFamily: typography.fontFamily.bold,
  },
  scrollGroup: {
    flexGrow: 0,
  },
  scrollGroupContent: {
    paddingHorizontal: 16,
    gap: 8,
    alignItems: 'center',
  },
});
