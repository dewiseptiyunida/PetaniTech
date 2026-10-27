import React from 'react';
import {
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  StyleProp,
  ViewStyle,
  TextStyle,
  Platform,
} from 'react-native';
import { ArrowLeft } from 'lucide-react-native';
import { useNavigation } from '@react-navigation/native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme/ThemeContext';

export interface ScreenHeaderProps {
  title: string;
  subtitle?: string;
  showBack?: boolean;
  onBackPress?: () => void;
  rightAction?: React.ReactNode;
  variant?: 'clean' | 'glass' | 'subtleMint';
  style?: StyleProp<ViewStyle>;
  titleStyle?: StyleProp<TextStyle>;
  subtitleStyle?: StyleProp<TextStyle>;
  withSafeArea?: boolean;
}

export const ScreenHeader: React.FC<ScreenHeaderProps> = ({
  title,
  subtitle,
  showBack = false,
  onBackPress,
  rightAction,
  variant = 'clean',
  style,
  titleStyle,
  subtitleStyle,
  withSafeArea = true,
}) => {
  const navigation = useNavigation();
  const { colors, isDark } = useTheme();
  const insets = useSafeAreaInsets();

  const handleBack = () => {
    if (onBackPress) {
      onBackPress();
    } else if (navigation.canGoBack()) {
      navigation.goBack();
    }
  };

  const getBackgroundColor = () => {
    if (variant === 'glass') {
      return isDark ? 'rgba(16, 43, 28, 0.88)' : 'rgba(255, 255, 255, 0.92)';
    }
    if (variant === 'subtleMint') {
      return isDark ? 'rgba(22, 58, 38, 0.70)' : '#F2FBF5';
    }
    return isDark ? colors.surface : '#FFFFFF';
  };

  const topPadding = withSafeArea ? Math.max(insets.top, Platform.OS === 'ios' ? 20 : 12) : 12;

  return (
    <View
      style={[
        styles.container,
        {
          paddingTop: topPadding,
          backgroundColor: getBackgroundColor(),
          borderBottomColor: isDark ? 'rgba(209, 245, 232, 0.14)' : '#DDE8E0',
        },
        style,
      ]}
    >
      {/* Top Hairline Sheen */}
      <View
        style={[
          styles.sheenLine,
          {
            backgroundColor: isDark
              ? 'rgba(255, 255, 255, 0.16)'
              : 'rgba(255, 255, 255, 0.95)',
          },
        ]}
      />

      <View style={styles.headerRow}>
        {showBack ? (
          <TouchableOpacity
            onPress={handleBack}
            style={[
              styles.backButton,
              {
                backgroundColor: isDark
                  ? 'rgba(255, 255, 255, 0.10)'
                  : '#F2FBF5',
                borderColor: isDark
                  ? 'rgba(209, 245, 232, 0.22)'
                  : '#DDE8E0',
              },
            ]}
            hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
            activeOpacity={0.72}
            accessibilityLabel="Kembali"
          >
            <ArrowLeft size={18} color={isDark ? '#D1F5E8' : '#183326'} />
          </TouchableOpacity>
        ) : null}

        <View style={styles.textContainer}>
          <Text
            style={[
              styles.title,
              { color: isDark ? '#FFFFFF' : '#183326' },
              titleStyle,
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
                subtitleStyle,
              ]}
              numberOfLines={1}
            >
              {subtitle}
            </Text>
          ) : null}
        </View>

        {rightAction ? (
          <View style={styles.rightActionContainer}>{rightAction}</View>
        ) : null}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'relative',
    paddingHorizontal: 16,
    paddingBottom: 14,
    borderBottomWidth: 1,
    zIndex: 10,
  },
  sheenLine: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 1.2,
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  backButton: {
    width: 38,
    height: 38,
    borderRadius: 12,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  textContainer: {
    flex: 1,
    justifyContent: 'center',
  },
  title: {
    fontSize: 18,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    letterSpacing: -0.2,
  },
  subtitle: {
    fontSize: 12,
    fontFamily: typography.fontFamily.regular,
    marginTop: 2,
    lineHeight: 16,
  },
  rightActionContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
});
