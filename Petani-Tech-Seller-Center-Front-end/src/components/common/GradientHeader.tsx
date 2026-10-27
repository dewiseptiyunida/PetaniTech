import React from 'react';
import {
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  StyleProp,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { ArrowLeft } from 'lucide-react-native';
import { useNavigation } from '@react-navigation/native';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme/ThemeContext';

export interface GradientHeaderProps {
  title: string;
  subtitle?: string;
  showBack?: boolean;
  onBackPress?: () => void;
  rightAction?: React.ReactNode;
  gradientColors?: readonly [string, string, ...string[]];
  style?: StyleProp<ViewStyle>;
  titleStyle?: StyleProp<TextStyle>;
  subtitleStyle?: StyleProp<TextStyle>;
}

export const GradientHeader: React.FC<GradientHeaderProps> = ({
  title,
  subtitle,
  showBack = false,
  onBackPress,
  rightAction,
  gradientColors,
  style,
  titleStyle,
  subtitleStyle,
}) => {
  const navigation = useNavigation();
  const { isDark } = useTheme();

  const handleBack = () => {
    if (onBackPress) {
      onBackPress();
    } else if (navigation.canGoBack()) {
      navigation.goBack();
    }
  };

  const defaultGradients: readonly [string, string] = isDark
    ? ['rgba(22, 58, 38, 0.90)', 'rgba(11, 32, 20, 0.95)']
    : ['#D1F5E8', '#FFFFFF'];

  const activeColors = gradientColors || defaultGradients;

  return (
    <View style={[styles.container, style]}>
      <LinearGradient
        colors={activeColors as [string, string, ...string[]]}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={StyleSheet.absoluteFill}
      />
      {/* Top Glossy Sheen Line */}
      <View
        style={[
          styles.sheenLine,
          {
            backgroundColor: isDark
              ? 'rgba(255, 255, 255, 0.18)'
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
                  ? 'rgba(255, 255, 255, 0.12)'
                  : '#FFFFFF',
                borderColor: isDark
                  ? 'rgba(209, 245, 232, 0.25)'
                  : '#DDE8E0',
              },
            ]}
            hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
            activeOpacity={0.75}
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
    overflow: 'hidden',
    paddingHorizontal: 16,
    paddingTop: 14,
    paddingBottom: 14,
    borderBottomWidth: 1,
    borderBottomColor: '#DDE8E0',
  },
  sheenLine: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 1.5,
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  backButton: {
    width: 38,
    height: 38,
    borderRadius: 19,
    borderWidth: 1.2,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  textContainer: {
    flex: 1,
    justifyContent: 'center',
  },
  title: {
    fontSize: 18,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    letterSpacing: -0.3,
  },
  subtitle: {
    fontSize: 12,
    fontFamily: typography.fontFamily.regular,
    marginTop: 2,
  },
  rightActionContainer: {
    marginLeft: 'auto',
  },
});
