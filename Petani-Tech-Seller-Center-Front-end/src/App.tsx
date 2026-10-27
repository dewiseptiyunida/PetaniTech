import { useEffect } from 'react';
import { ActivityIndicator, Platform, StyleSheet, Text, View } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import {
  useFonts,
  Poppins_400Regular,
  Poppins_500Medium,
  Poppins_600SemiBold,
  Poppins_700Bold,
  Poppins_800ExtraBold,
} from '@expo-google-fonts/poppins';
import { AppNavigator } from '@/navigation/AppNavigator';
import { useAuthStore } from '@/store/useAuthStore';
import { ToastContainer } from '@/components/common/ToastContainer';
import { brand } from '@/theme/colors';
import { typography } from '@/theme/typography';
import { ThemeProvider } from '@/theme';

export default function App() {
  const [fontsLoaded, fontError] = useFonts({
    Poppins_400Regular,
    Poppins_500Medium,
    Poppins_600SemiBold,
    Poppins_700Bold,
    Poppins_800ExtraBold,
  });

  const initAuth = useAuthStore((state) => state.initAuth);
  const isLoading = useAuthStore((state) => state.isLoading);
  const error = useAuthStore((state) => state.error);
  const user = useAuthStore((state) => state.user);

  useEffect(() => {
    // Inject Poppins Google Fonts link for mobile web / desktop browser
    if (Platform.OS === 'web' && typeof document !== 'undefined') {
      const linkId = 'petani-tech-poppins-font';
      if (!document.getElementById(linkId)) {
        const link = document.createElement('link');
        link.id = linkId;
        link.rel = 'stylesheet';
        link.href =
          'https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap';
        document.head.appendChild(link);
      }
    }
    void initAuth();
  }, [initAuth]);

  const isFontReady = fontsLoaded || Boolean(fontError) || Platform.OS === 'web';

  return (
    <SafeAreaProvider>
      <ThemeProvider>
        {!isFontReady || isLoading ? (
          <View style={styles.loading}>
            <ActivityIndicator size="large" color={brand.grass} />
            <Text style={styles.loadingText}>Menyiapkan Petani Tech Seller Center...</Text>
          </View>
        ) : error && !user ? (
          <View style={styles.loading}>
            <Text style={styles.errorTitle}>Tidak dapat memuat sesi</Text>
            <Text style={styles.loadingText}>{error}</Text>
            <Text style={styles.retry} onPress={() => void initAuth()}>
              Coba lagi
            </Text>
          </View>
        ) : (
          <>
            <AppNavigator />
            <ToastContainer />
          </>
        )}
      </ThemeProvider>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  loading: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 12,
    backgroundColor: brand.softWhite,
    padding: 24,
  },
  loadingText: {
    color: brand.secondaryText,
    textAlign: 'center',
    fontSize: 13,
    fontWeight: '500',
    fontFamily: typography.fontFamily.medium,
  },
  errorTitle: {
    color: brand.primaryText,
    fontSize: 18,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  retry: {
    color: brand.grass,
    fontWeight: '700',
    padding: 12,
    fontSize: 14,
    fontFamily: typography.fontFamily.bold,
  },
});
