import { useEffect, useState } from 'react';
import { AccessibilityInfo, Easing } from 'react-native';

// ============================================================================
// Petani Tech Seller Center — Motion Design System Tokens
// ============================================================================

export const motion = {
  duration: {
    instant: 0,
    fast: 150,
    normal: 250,
    smooth: 350,
    entrance: 400,
    staggerDelay: 45,
  },
  distance: {
    subtle: 8,
    standard: 12,
    prominent: 20,
  },
  scale: {
    pressedButton: 0.975,
    pressedCard: 0.985,
    normal: 1,
  },
  easing: {
    easeOutCubic: Easing.out(Easing.cubic),
    easeInOutCubic: Easing.inOut(Easing.cubic),
    spring: {
      friction: 7,
      tension: 45,
    },
  },
} as const;

// ============================================================================
// Hook: Detect System Reduced Motion Preference
// ============================================================================

export function useReducedMotion(): boolean {
  const [reduceMotion, setReduceMotion] = useState(false);

  useEffect(() => {
    let isMounted = true;
    AccessibilityInfo.isReduceMotionEnabled()
      .then((enabled) => {
        if (isMounted) setReduceMotion(enabled);
      })
      .catch(() => {});

    const subscription = AccessibilityInfo.addEventListener(
      'reduceMotionChanged',
      (enabled) => {
        if (isMounted) setReduceMotion(enabled);
      }
    );

    return () => {
      isMounted = false;
      subscription?.remove();
    };
  }, []);

  return reduceMotion;
}
