import React from 'react';
import {
  StyleSheet,
  TouchableOpacity,
  View,
  StyleProp,
  ViewStyle,
} from 'react-native';
import { useTheme } from '@/theme/ThemeContext';

export interface CardProps {
  children?: React.ReactNode;
  style?: StyleProp<ViewStyle>;
  bordered?: boolean;
  hoverable?: boolean;
  sheen?: boolean;
  variant?: 'default' | 'flat' | 'elevated' | 'softGreen' | 'whiteGlass' | 'greenGlass' | 'mintGlass';
  onClick?: () => void;
  onPress?: () => void;
}

export const Card: React.FC<CardProps> = ({
  children,
  style,
  bordered = true,
  sheen = false,
  variant = 'default',
  onClick,
  onPress,
}) => {
  const { colors, isDark } = useTheme();
  const handlePress = onPress || onClick;

  const getVariantStyles = (): ViewStyle => {
    switch (variant) {
      case 'whiteGlass':
        return {
          backgroundColor: isDark ? 'rgba(22, 58, 38, 0.65)' : '#FFFFFF',
          borderColor: bordered
            ? isDark
              ? 'rgba(209, 245, 232, 0.20)'
              : '#DDE8E0'
            : 'transparent',
          borderWidth: bordered ? 1.5 : 0,
        };
      case 'greenGlass':
        return {
          backgroundColor: isDark ? 'rgba(22, 58, 38, 0.85)' : '#EAF5EE',
          borderColor: bordered
            ? isDark
              ? 'rgba(209, 245, 232, 0.35)'
              : '#C6E2D0'
            : 'transparent',
          borderWidth: bordered ? 1.5 : 0,
        };
      case 'mintGlass':
        return {
          backgroundColor: isDark ? 'rgba(64, 145, 108, 0.25)' : '#F2FBF5',
          borderColor: bordered
            ? isDark
              ? 'rgba(209, 245, 232, 0.25)'
              : '#D1F5E8'
            : 'transparent',
          borderWidth: bordered ? 1.5 : 0,
        };
      case 'softGreen':
        return {
          backgroundColor: isDark ? 'rgba(64, 145, 108, 0.22)' : '#EAF4EE',
          borderColor: bordered
            ? isDark
              ? 'rgba(209, 245, 232, 0.25)'
              : '#DDE8E0'
            : 'transparent',
          borderWidth: bordered ? 1 : 0,
        };
      case 'flat':
        return {
          backgroundColor: colors.card,
          borderColor: bordered ? colors.cardBorder : 'transparent',
          borderWidth: bordered ? 1 : 0,
        };
      default:
        return {
          backgroundColor: colors.card,
          borderColor: bordered ? colors.cardBorder : 'transparent',
          borderWidth: bordered ? 1.5 : 0,
        };
    }
  };

  const hasSheen = sheen || variant === 'whiteGlass' || variant === 'greenGlass';

  const cardStyles = [
    styles.card,
    getVariantStyles(),
    styles[variant],
    style,
  ];

  const content = (
    <>
      {hasSheen ? (
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
      ) : null}
      {children}
    </>
  );

  if (handlePress) {
    return (
      <TouchableOpacity
        activeOpacity={0.78}
        onPress={handlePress}
        style={cardStyles}
      >
        {content}
      </TouchableOpacity>
    );
  }

  return <View style={cardStyles}>{content}</View>;
};

export const WhiteGlassCard: React.FC<CardProps> = (props) => (
  <Card {...props} variant="whiteGlass" sheen={props.sheen ?? true} />
);

export const GreenGlassPanel: React.FC<CardProps> = (props) => (
  <Card {...props} variant="greenGlass" sheen={props.sheen ?? true} />
);

const styles = StyleSheet.create({
  card: {
    borderRadius: 20,
    padding: 16,
    position: 'relative',
    overflow: 'hidden',
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
  },
  sheenLine: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 1.5,
  },
  default: {},
  whiteGlass: {
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 12,
    elevation: 3,
  },
  greenGlass: {
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.08,
    shadowRadius: 12,
    elevation: 3,
  },
  mintGlass: {
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.04,
    shadowRadius: 6,
    elevation: 1,
  },
  flat: {
    shadowOpacity: 0,
    elevation: 0,
  },
  elevated: {
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.10,
    shadowRadius: 16,
    elevation: 4,
  },
  softGreen: {},
  bordered: {},
});
