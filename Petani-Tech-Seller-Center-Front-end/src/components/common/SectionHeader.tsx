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

export interface SectionHeaderProps {
  title: string;
  eyebrow?: string;
  actionLabel?: string;
  onActionPress?: () => void;
  rightElement?: React.ReactNode;
  badge?: React.ReactNode;
  style?: StyleProp<ViewStyle>;
}

export const SectionHeader: React.FC<SectionHeaderProps> = ({
  title,
  eyebrow,
  actionLabel,
  onActionPress,
  rightElement,
  badge,
  style,
}) => {
  const { colors, isDark } = useTheme();

  return (
    <View style={[styles.container, style]}>
      <View style={styles.leftContainer}>
        {eyebrow ? (
          <Text
            style={[
              styles.eyebrow,
              { color: isDark ? colors.mint : colors.primary },
            ]}
          >
            {eyebrow.toUpperCase()}
          </Text>
        ) : null}
        <View style={styles.titleRow}>
          <Text
            style={[
              styles.title,
              { color: isDark ? '#FFFFFF' : '#183326' },
            ]}
          >
            {title}
          </Text>
          {badge}
        </View>
      </View>

      {rightElement ? (
        rightElement
      ) : actionLabel && onActionPress ? (
        <TouchableOpacity
          onPress={onActionPress}
          activeOpacity={0.7}
          hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
          style={styles.actionButton}
        >
          <Text
            style={[
              styles.actionText,
              { color: isDark ? colors.mint : colors.primary },
            ]}
          >
            {actionLabel}
          </Text>
          <ChevronRight
            size={14}
            color={isDark ? colors.mint : colors.primary}
            strokeWidth={2.4}
          />
        </TouchableOpacity>
      ) : null}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    marginBottom: 10,
    marginTop: 6,
  },
  leftContainer: {
    flex: 1,
    gap: 2,
  },
  eyebrow: {
    fontSize: 10.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    letterSpacing: 0.8,
  },
  titleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  title: {
    fontSize: 17,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    letterSpacing: -0.2,
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 2,
    paddingVertical: 2,
  },
  actionText: {
    fontSize: 12.5,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
});
