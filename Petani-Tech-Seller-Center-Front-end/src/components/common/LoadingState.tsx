import React from 'react';
import {
  ActivityIndicator,
  StyleSheet,
  Text,
  View,
  StyleProp,
  ViewStyle,
} from 'react-native';
import { useTheme } from '@/theme/ThemeContext';
import { typography } from '@/theme/typography';

export interface LoadingStateProps {
  message?: string;
  size?: 'small' | 'large';
  fullScreen?: boolean;
  style?: StyleProp<ViewStyle>;
}

export const LoadingState: React.FC<LoadingStateProps> = ({
  message = 'Memuat data...',
  size = 'large',
  fullScreen = false,
  style,
}) => {
  const { colors, isDark } = useTheme();

  return (
    <View
      style={[
        styles.container,
        fullScreen && styles.fullScreen,
        { backgroundColor: fullScreen ? (isDark ? colors.background : '#FAF9F6') : 'transparent' },
        style,
      ]}
    >
      <View
        style={[
          styles.spinnerCard,
          {
            backgroundColor: isDark
              ? 'rgba(22, 58, 38, 0.70)'
              : '#FFFFFF',
            borderColor: isDark
              ? 'rgba(209, 245, 232, 0.18)'
              : '#DDE8E0',
          },
        ]}
      >
        <ActivityIndicator
          size={size}
          color={isDark ? colors.mint : colors.primary}
        />
        {message ? (
          <Text
            style={[
              styles.message,
              { color: isDark ? '#D1F5E8' : '#64746A' },
            ]}
          >
            {message}
          </Text>
        ) : null}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
  },
  fullScreen: {
    flex: 1,
  },
  spinnerCard: {
    paddingVertical: 20,
    paddingHorizontal: 28,
    borderRadius: 20,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 12,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 10,
    elevation: 3,
  },
  message: {
    fontSize: 13,
    fontFamily: typography.fontFamily.medium,
    textAlign: 'center',
  },
});
