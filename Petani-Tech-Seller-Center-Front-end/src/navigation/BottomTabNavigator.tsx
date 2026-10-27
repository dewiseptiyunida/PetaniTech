import React from 'react';
import { Platform, StyleSheet, View } from 'react-native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { LinearGradient } from 'expo-linear-gradient';
import {
  LayoutDashboard,
  Package,
  ShoppingBag,
  UserRound,
  Wallet,
} from 'lucide-react-native';
import { DashboardScreen } from '@/screens/dashboard';
import { ProductsScreen } from '@/screens/products';
import { OrdersScreen } from '@/screens/orders';
import { InventoryScreen, PromotionsScreen } from '@/screens/store';
import { FinanceScreen, AnalyticsScreen } from '@/screens/reports';
import { ProfileScreen } from '@/screens/profile';
import { MainTabParamList } from '@/navigation/types';
import { useOrderStore } from '@/store/useOrderStore';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme/ThemeContext';
import { BOTTOM_TAB_HEIGHT } from './hooks';

const Tab = createBottomTabNavigator<MainTabParamList>();

const hiddenTabOption = {
  tabBarButton: () => null,
  tabBarItemStyle: { display: 'none' as const },
};

export function BottomTabNavigator() {
  const { colors, isDark } = useTheme();
  const insets = useSafeAreaInsets();
  const orders = useOrderStore((state) => state.orders);
  const pendingOrdersCount = orders.filter((o) => o.status === 'Diproses').length;

  const tabBottom =
    Platform.OS === 'ios'
      ? Math.max(insets.bottom, 14)
      : insets.bottom > 0
      ? insets.bottom + 8
      : 14;

  return (
    <Tab.Navigator
      initialRouteName="Dashboard"
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: colors.navActive,
        tabBarInactiveTintColor: colors.navInactive,
        tabBarBackground: () => (
          <View style={StyleSheet.absoluteFill}>
            <LinearGradient
              colors={
                isDark
                  ? ['rgba(16, 43, 28, 0.96)', 'rgba(11, 32, 20, 0.98)']
                  : ['rgba(255, 255, 255, 0.97)', 'rgba(250, 249, 246, 0.95)']
              }
              start={{ x: 0.5, y: 0 }}
              end={{ x: 0.5, y: 1 }}
              style={StyleSheet.absoluteFill}
            />
            <View
              style={[
                styles.tabTopGlassSheen,
                {
                  backgroundColor: isDark
                    ? 'rgba(255, 255, 255, 0.20)'
                    : 'rgba(255, 255, 255, 0.95)',
                },
              ]}
            />
          </View>
        ),
        tabBarStyle: {
          position: 'absolute',
          bottom: tabBottom,
          left: 14,
          right: 14,
          borderRadius: 24,
          height: BOTTOM_TAB_HEIGHT,
          backgroundColor: isDark ? colors.navBg : '#FFFFFF',
          borderWidth: 1.2,
          borderColor: isDark ? 'rgba(209, 245, 232, 0.20)' : '#DDE8E0',
          paddingTop: 6,
          paddingBottom: 6,
          elevation: 10,
          shadowColor: isDark ? '#000000' : '#183326',
          shadowOffset: { width: 0, height: 6 },
          shadowOpacity: isDark ? 0.45 : 0.08,
          shadowRadius: 18,
          overflow: 'hidden',
        },
        tabBarLabelStyle: {
          fontSize: 10.5,
          fontWeight: '700',
          fontFamily: typography.fontFamily.semibold,
          marginTop: -2,
        },
      }}
    >
      <Tab.Screen
        name="Dashboard"
        component={DashboardScreen}
        options={{
          tabBarLabel: 'Beranda',
          tabBarIcon: ({ color, size, focused }) => (
            <View
              style={[
                styles.iconWrapper,
                focused && [
                  styles.iconWrapperActive,
                  {
                    backgroundColor: colors.navActiveBg,
                    borderColor: isDark
                      ? 'rgba(209, 245, 232, 0.3)'
                      : 'rgba(64, 145, 108, 0.3)',
                  },
                ],
              ]}
            >
              <LayoutDashboard
                color={focused ? colors.navActive : color}
                size={focused ? size + 1 : size}
                strokeWidth={focused ? 2.4 : 1.8}
              />
            </View>
          ),
        }}
      />
      <Tab.Screen
        name="Products"
        component={ProductsScreen}
        options={{
          tabBarLabel: 'Produk',
          tabBarIcon: ({ color, size, focused }) => (
            <View
              style={[
                styles.iconWrapper,
                focused && [
                  styles.iconWrapperActive,
                  {
                    backgroundColor: colors.navActiveBg,
                    borderColor: isDark
                      ? 'rgba(209, 245, 232, 0.3)'
                      : 'rgba(64, 145, 108, 0.3)',
                  },
                ],
              ]}
            >
              <Package
                color={focused ? colors.navActive : color}
                size={focused ? size + 1 : size}
                strokeWidth={focused ? 2.4 : 1.8}
              />
            </View>
          ),
        }}
      />
      <Tab.Screen
        name="Orders"
        component={OrdersScreen}
        options={{
          tabBarLabel: 'Pesanan',
          tabBarBadge: pendingOrdersCount > 0 ? pendingOrdersCount : undefined,
          tabBarBadgeStyle: {
            backgroundColor: '#EF4444',
            color: '#FFFFFF',
            fontSize: 10,
            fontWeight: '700',
            fontFamily: typography.fontFamily.bold,
            lineHeight: 14,
          },
          tabBarIcon: ({ color, size, focused }) => (
            <View
              style={[
                styles.iconWrapper,
                focused && [
                  styles.iconWrapperActive,
                  {
                    backgroundColor: colors.navActiveBg,
                    borderColor: isDark
                      ? 'rgba(209, 245, 232, 0.3)'
                      : 'rgba(64, 145, 108, 0.3)',
                  },
                ],
              ]}
            >
              <ShoppingBag
                color={focused ? colors.navActive : color}
                size={focused ? size + 1 : size}
                strokeWidth={focused ? 2.4 : 1.8}
              />
            </View>
          ),
        }}
      />
      <Tab.Screen
        name="Finance"
        component={FinanceScreen}
        options={{
          tabBarLabel: 'Keuangan',
          tabBarIcon: ({ color, size, focused }) => (
            <View
              style={[
                styles.iconWrapper,
                focused && [
                  styles.iconWrapperActive,
                  {
                    backgroundColor: colors.navActiveBg,
                    borderColor: isDark
                      ? 'rgba(209, 245, 232, 0.3)'
                      : 'rgba(64, 145, 108, 0.3)',
                  },
                ],
              ]}
            >
              <Wallet
                color={focused ? colors.navActive : color}
                size={focused ? size + 1 : size}
                strokeWidth={focused ? 2.4 : 1.8}
              />
            </View>
          ),
        }}
      />
      <Tab.Screen
        name="Profile"
        component={ProfileScreen}
        options={{
          tabBarLabel: 'Profil Toko',
          tabBarIcon: ({ color, size, focused }) => (
            <View
              style={[
                styles.iconWrapper,
                focused && [
                  styles.iconWrapperActive,
                  {
                    backgroundColor: colors.navActiveBg,
                    borderColor: isDark
                      ? 'rgba(209, 245, 232, 0.3)'
                      : 'rgba(64, 145, 108, 0.3)',
                  },
                ],
              ]}
            >
              <UserRound
                color={focused ? colors.navActive : color}
                size={focused ? size + 1 : size}
                strokeWidth={focused ? 2.4 : 1.8}
              />
            </View>
          ),
        }}
      />

      {/* Rute Sekunder Toko & Laporan (Diakses via Quick Menu Dashboard) */}
      <Tab.Screen name="Inventory" component={InventoryScreen} options={hiddenTabOption} />
      <Tab.Screen name="Promotions" component={PromotionsScreen} options={hiddenTabOption} />
      <Tab.Screen name="Analytics" component={AnalyticsScreen} options={hiddenTabOption} />
    </Tab.Navigator>
  );
}

const styles = StyleSheet.create({
  iconWrapper: {
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconWrapperActive: {
    borderWidth: 1,
  },
  tabTopGlassSheen: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 1.5,
  },
});