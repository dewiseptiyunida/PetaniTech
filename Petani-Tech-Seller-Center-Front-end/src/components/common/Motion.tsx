import React, { useEffect, useState } from 'react';
import {
  Animated,
  StyleProp,
  ViewStyle,
  TouchableOpacity,
  TouchableOpacityProps,
} from 'react-native';
import { motion, useReducedMotion } from '@/theme/motion';

// ============================================================================
// Component: FadeInUp
// Reusable entrance animation: subtle opacity fade + upward slide
// ============================================================================

export interface FadeInUpProps {
  children: React.ReactNode;
  delay?: number;
  duration?: number;
  distance?: number;
  style?: StyleProp<ViewStyle>;
}

export const FadeInUp: React.FC<FadeInUpProps> = ({
  children,
  delay = 0,
  duration = motion.duration.smooth,
  distance = motion.distance.standard,
  style,
}) => {
  const isReduced = useReducedMotion();
  const [opacity] = useState(() => new Animated.Value(isReduced ? 1 : 0));
  const [translateY] = useState(() => new Animated.Value(isReduced ? 0 : distance));

  useEffect(() => {
    if (isReduced) {
      opacity.setValue(1);
      translateY.setValue(0);
      return;
    }

    const timer = setTimeout(() => {
      Animated.parallel([
        Animated.timing(opacity, {
          toValue: 1,
          duration,
          easing: motion.easing.easeOutCubic,
          useNativeDriver: true,
        }),
        Animated.timing(translateY, {
          toValue: 0,
          duration,
          easing: motion.easing.easeOutCubic,
          useNativeDriver: true,
        }),
      ]).start();
    }, delay);

    return () => clearTimeout(timer);
  }, [delay, duration, distance, isReduced, opacity, translateY]);

  return (
    <Animated.View
      style={[
        style,
        {
          opacity,
          transform: [{ translateY }],
        },
      ]}
    >
      {children}
    </Animated.View>
  );
};

// ============================================================================
// Component: PressableScale
// Button / Card wrapper with subtle tactile spring compression feedback
// ============================================================================

export interface PressableScaleProps extends TouchableOpacityProps {
  pressedScale?: number;
  containerStyle?: StyleProp<ViewStyle>;
  children: React.ReactNode;
}

export const PressableScale: React.FC<PressableScaleProps> = ({
  children,
  pressedScale = motion.scale.pressedButton,
  containerStyle,
  style,
  onPressIn,
  onPressOut,
  disabled,
  ...props
}) => {
  const isReduced = useReducedMotion();
  const [scaleAnim] = useState(() => new Animated.Value(1));

  const handlePressIn = (e: any) => {
    if (!disabled && !isReduced) {
      Animated.spring(scaleAnim, {
        toValue: pressedScale,
        friction: 8,
        tension: 100,
        useNativeDriver: true,
      }).start();
    }
    onPressIn?.(e);
  };

  const handlePressOut = (e: any) => {
    if (!disabled && !isReduced) {
      Animated.spring(scaleAnim, {
        toValue: 1,
        friction: 7,
        tension: 80,
        useNativeDriver: true,
      }).start();
    }
    onPressOut?.(e);
  };

  return (
    <TouchableOpacity
      {...props}
      style={containerStyle}
      disabled={disabled}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      activeOpacity={0.88}
    >
      <Animated.View style={[style, { transform: [{ scale: scaleAnim }] }]}>
        {children}
      </Animated.View>
    </TouchableOpacity>
  );
};
