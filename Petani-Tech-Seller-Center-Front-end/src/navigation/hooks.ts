import { Platform } from 'react-native';
import { CompositeNavigationProp, useNavigation } from '@react-navigation/native';
import { BottomTabNavigationProp } from '@react-navigation/bottom-tabs';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { MainTabParamList, RootStackParamList } from './types';

export type SellerNavigationProp = CompositeNavigationProp<
  BottomTabNavigationProp<MainTabParamList>,
  NativeStackNavigationProp<RootStackParamList>
>;

export const useSellerNavigation = () => useNavigation<SellerNavigationProp>();

export const BOTTOM_TAB_HEIGHT = 66;

export function useBottomTabSpace(extraPadding = 28): number {
  const insets = useSafeAreaInsets();
  const tabBottom =
    Platform.OS === 'ios'
      ? Math.max(insets.bottom, 14)
      : insets.bottom > 0
      ? insets.bottom + 8
      : 14;
  return BOTTOM_TAB_HEIGHT + tabBottom + extraPadding;
}

