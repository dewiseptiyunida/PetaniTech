import { NavigationContainer, DefaultTheme, DarkTheme } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { AuthNavigator } from '@/navigation/AuthNavigator';
import { BottomTabNavigator } from '@/navigation/BottomTabNavigator';
import { RootStackParamList } from '@/navigation/types';
import { useAuthStore } from '@/store/useAuthStore';
import { useTheme } from '@/theme';

const Stack = createNativeStackNavigator<RootStackParamList>();

export function AppNavigator() {
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);
  const { isDarkMode, themeColors } = useTheme();

  const navTheme = {
    ...(isDarkMode ? DarkTheme : DefaultTheme),
    colors: {
      ...(isDarkMode ? DarkTheme.colors : DefaultTheme.colors),
      background: themeColors.background,
      card: themeColors.surface,
      text: themeColors.textPrimary,
      border: themeColors.border,
      primary: themeColors.primary,
    },
  };

  return (
    <NavigationContainer theme={navTheme}>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {isAuthenticated ? (
          <Stack.Screen name="Main" component={BottomTabNavigator} />
        ) : (
          <Stack.Screen name="Auth" component={AuthNavigator} />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}