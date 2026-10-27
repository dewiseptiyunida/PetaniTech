import React from 'react';
import {
  ActivityIndicator,
  StyleSheet,
  Text,
  View,
  StyleProp,
  ViewStyle,
  TextStyle,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { colors } from '@/theme/colors';
import { typography } from '@/theme/typography';

import { PressableScale } from './Motion';

export interface ButtonProps {
  children?: React.ReactNode;
  variant?: 'primary' | 'gradient' | 'secondary' | 'outline' | 'ghost' | 'danger' | 'softGreen' | 'leaf' | 'glass';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
  disabled?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  onPress?: () => void;
  style?: StyleProp<ViewStyle>;
  textStyle?: StyleProp<TextStyle>;
  type?: 'button' | 'submit' | 'reset';
}

export const Button: React.FC<ButtonProps> = ({
  children,
  variant = 'primary',
  size = 'md',
  isLoading = false,
  disabled = false,
  leftIcon,
  rightIcon,
  onPress,
  style,
  textStyle,
}) => {
  const isDisabled = disabled || isLoading;
  const isGradient = variant === 'primary' || variant === 'gradient';

  const isTextLike =
    typeof children === 'string' ||
    typeof children === 'number' ||
    (Array.isArray(children) && children.every((c) => typeof c === 'string' || typeof c === 'number'));

  const content = (
    <>
      {isLoading ? (
        <ActivityIndicator
          size="small"
          color={
            variant === 'outline' ||
            variant === 'ghost' ||
            variant === 'secondary' ||
            variant === 'softGreen' ||
            variant === 'leaf' ||
            variant === 'glass'
              ? colors.primary.dark
              : '#FFFFFF'
          }
          style={styles.spinner}
        />
      ) : (
        leftIcon && <View style={styles.iconContainer}>{leftIcon}</View>
      )}

      {isTextLike ? (
        <Text
          style={[
            styles.text,
            isGradient ? styles.primaryText : styles[`${variant}Text`],
            styles[`${size}Text`],
            textStyle,
          ]}
        >
          {children}
        </Text>
      ) : (
        children
      )}

      {!isLoading && rightIcon && <View style={styles.iconContainer}>{rightIcon}</View>}
    </>
  );

  const hitSlop = size === 'sm' ? { top: 6, bottom: 6, left: 6, right: 6 } : undefined;

  if (isGradient) {
    return (
      <PressableScale
        disabled={isDisabled}
        onPress={onPress}
        hitSlop={hitSlop}
        accessibilityRole="button"
        style={[styles.touchableWrapper, isDisabled && styles.disabled, style]}
      >
        <LinearGradient
          colors={colors.primary.gradient}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 0.8 }}
          style={[styles.base, styles[size], styles.gradientBase]}
        >
          <View style={styles.btnTopSheen} />
          {content}
        </LinearGradient>
      </PressableScale>
    );
  }

  return (
    <PressableScale
      disabled={isDisabled}
      onPress={onPress}
      hitSlop={hitSlop}
      accessibilityRole="button"
      style={[
        styles.base,
        styles[variant],
        styles[size],
        isDisabled && styles.disabled,
        style,
      ]}
    >
      {content}
    </PressableScale>
  );
};

const styles = StyleSheet.create({
  touchableWrapper: {
    borderRadius: 16,
    overflow: 'hidden',
    shadowColor: '#31572C',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.18,
    shadowRadius: 8,
    elevation: 3,
  },
  base: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 16,
    gap: 8,
  },
  gradientBase: {
    width: '100%',
    position: 'relative',
    overflow: 'hidden',
  },
  btnTopSheen: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 1.5,
    backgroundColor: 'rgba(255, 255, 255, 0.22)',
  },
  sm: {
    paddingHorizontal: 12,
    paddingVertical: 7,
    minHeight: 36,
  },
  md: {
    paddingHorizontal: 18,
    paddingVertical: 12,
    minHeight: 46,
  },
  lg: {
    paddingHorizontal: 22,
    paddingVertical: 14,
    minHeight: 52,
  },
  primary: {
    backgroundColor: colors.primary.DEFAULT,
  },
  gradient: {
    backgroundColor: colors.primary.DEFAULT,
  },
  secondary: {
    backgroundColor: '#F2FBF5',
    borderWidth: 1.5,
    borderColor: '#DDE8E0',
  },
  outline: {
    backgroundColor: colors.neutral.white,
    borderWidth: 1.5,
    borderColor: colors.primary.DEFAULT,
  },
  ghost: {
    backgroundColor: 'transparent',
  },
  danger: {
    backgroundColor: colors.semantic.danger.DEFAULT,
  },
  softGreen: {
    backgroundColor: '#EAF4EE',
    borderWidth: 1,
    borderColor: '#C6E2D0',
  },
  leaf: {
    backgroundColor: colors.primary.leaf,
    borderWidth: 1,
    borderColor: colors.primary.moss,
  },
  glass: {
    backgroundColor: 'rgba(255, 255, 255, 0.88)',
    borderWidth: 1.5,
    borderColor: '#DDE8E0',
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 6,
    elevation: 2,
  },
  disabled: {
    opacity: 0.55,
  },
  text: {
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    textAlign: 'center',
    letterSpacing: 0.2,
  },
  smText: {
    fontSize: 12,
  },
  mdText: {
    fontSize: 14,
  },
  lgText: {
    fontSize: 15,
  },
  primaryText: {
    color: '#FFFFFF',
  },
  gradientText: {
    color: '#FFFFFF',
  },
  secondaryText: {
    color: '#31572C',
  },
  outlineText: {
    color: colors.primary.dark,
  },
  ghostText: {
    color: colors.neutral[800],
  },
  dangerText: {
    color: '#FFFFFF',
  },
  softGreenText: {
    color: colors.primary.dark,
  },
  leafText: {
    color: colors.primary.dark,
  },
  glassText: {
    color: '#183326',
  },
  spinner: {
    marginRight: 4,
  },
  iconContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
});
