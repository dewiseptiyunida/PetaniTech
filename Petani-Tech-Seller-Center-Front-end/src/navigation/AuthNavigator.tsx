import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { SplashScreen, LoginScreen, RegisterScreen } from '@/screens/auth';
import { AuthStackParamList } from '@/navigation/types';

const Stack = createNativeStackNavigator<AuthStackParamList>();

export function AuthNavigator() {
  return (
    <Stack.Navigator
      initialRouteName="Splash"
      screenOptions={{
        headerShown: false,
        animation: 'fade',
      }}
    >
      <Stack.Screen name="Splash" component={SplashScreen} />
      <Stack.Screen
        name="Login"
        component={LoginScreen}
        options={{ animation: 'fade' }}
      />
      <Stack.Screen
        name="Register"
        component={RegisterScreen}
        options={{ animation: 'slide_from_right' }}
      />
    </Stack.Navigator>
  );
}