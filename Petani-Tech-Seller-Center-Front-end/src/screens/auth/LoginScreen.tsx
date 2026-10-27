import React, { useState } from 'react';
import {
  Alert,
  Dimensions,
  Image,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { useNavigation, useRoute } from '@react-navigation/native';
import {
  Mail,
  Lock,
  Store,
  User,
  Phone,
  MapPin,
  ShieldCheck,
  Sparkles,
  CheckCircle2,
  ChevronLeft,
  ArrowRight,
} from 'lucide-react-native';
import { useAuthStore } from '@/store/useAuthStore';
import { Input } from '@/components/forms/Input';
import { assets } from '@/assets';
import { colors } from '@/theme/colors';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme';

const { width } = Dimensions.get('window');

export function LoginScreen() {
  const { themeColors, isDarkMode } = useTheme();
  const navigation = useNavigation<any>();
  const route = useRoute<any>();

  const login = useAuthStore((state) => state.login);
  const register = useAuthStore((state) => state.register);
  const isLoading = useAuthStore((state) => state.isLoading);

  // Tab State: 'login' | 'register' derived with override support
  const [tabOverride, setTabOverride] = useState<'login' | 'register' | null>(null);
  const activeTab: 'login' | 'register' = tabOverride ?? route.params?.initialTab ?? 'login';
  const setActiveTab = (tab: 'login' | 'register') => setTabOverride(tab);

  // Form Fields - Login
  const [identifier, setIdentifier] = useState('fahda@petanitech.id');
  const [password, setPassword] = useState('123456');

  // Form Fields - Register
  const [regName, setRegName] = useState('Fahda Febriya');
  const [regStoreName, setRegStoreName] = useState('Toko Tani Makmur Fahda');
  const [regPhone, setRegPhone] = useState('0812-3456-7890');
  const [regEmail, setRegEmail] = useState('');
  const [regAddress, setRegAddress] = useState('Indramayu, Jawa Barat');
  const [regPassword, setRegPassword] = useState('');

  const handleLogin = async () => {
    if (!identifier.trim() || !password) {
      Alert.alert('Data Belum Lengkap', 'Masukkan email atau nomor HP serta kata sandi toko Anda.');
      return;
    }
    try {
      await login(identifier.trim(), password);
    } catch (error) {
      Alert.alert(
        'Gagal Masuk',
        error instanceof Error ? error.message : 'Silakan periksa kembali data login Anda.'
      );
    }
  };

  const handleRegister = async () => {
    if (!regName.trim() || !regStoreName.trim() || !regPhone.trim() || !regEmail.trim()) {
      Alert.alert('Data Belum Lengkap', 'Mohon lengkapi seluruh informasi pendaftaran seller.');
      return;
    }
    try {
      await register({
        name: regName.trim(),
        storeName: regStoreName.trim(),
        phone: regPhone.trim(),
        email: regEmail.trim(),
        storeAddress: regAddress.trim(),
        password: regPassword || '123456',
      });
      Alert.alert('Pendaftaran Berhasil', 'Selamat datang di Petani Tech Seller Center!');
    } catch (error) {
      Alert.alert(
        'Gagal Mendaftar',
        error instanceof Error ? error.message : 'Terjadi kendala saat mendaftarkan akun.'
      );
    }
  };

  const fillDemoAccount = () => {
    setIdentifier('fahda@petanitech.id');
    setPassword('123456');
  };

  const handleBackToSplash = () => {
    if (navigation.canGoBack()) {
      navigation.goBack();
    } else {
      navigation.navigate('Splash');
    }
  };

  return (
    <View style={styles.container}>
      {/* Rich Deep Botanical Gradient Canvas (No Flat White!) */}
      <LinearGradient
        colors={
          isDarkMode
            ? ['#07190D', '#0F2F19', '#1C4927', '#255431']
            : ['#F5FAF6', '#EAF5ED', '#DDF0E2', '#CCE7D2']
        }
        locations={[0, 0.35, 0.7, 1]}
        start={{ x: 0.5, y: 0 }}
        end={{ x: 0.5, y: 1 }}
        style={StyleSheet.absoluteFill}
      />

      {/* Floating Translucent Ambient Orbs */}
      <View style={styles.bubbleTopRight}>
        <LinearGradient
          colors={
            isDarkMode
              ? ['rgba(209, 245, 232, 0.30)', 'rgba(64, 145, 108, 0.05)', 'transparent']
              : ['rgba(64, 145, 108, 0.15)', 'rgba(209, 245, 232, 0.05)', 'transparent']
          }
          start={{ x: 0.2, y: 0.2 }}
          end={{ x: 1, y: 1 }}
          style={styles.orbFill}
        />
      </View>

      <View style={styles.bubbleBottomLeft}>
        <LinearGradient
          colors={
            isDarkMode
              ? ['rgba(236, 243, 158, 0.22)', 'rgba(144, 169, 85, 0.05)', 'transparent']
              : ['rgba(144, 169, 85, 0.15)', 'rgba(236, 243, 158, 0.05)', 'transparent']
          }
          start={{ x: 0.3, y: 0.3 }}
          end={{ x: 1, y: 1 }}
          style={styles.orbFill}
        />
      </View>

      <SafeAreaView style={styles.safeArea} edges={['top', 'bottom']}>
        <KeyboardAvoidingView
          style={styles.keyboardView}
          behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        >
          <ScrollView
            contentContainerStyle={styles.scrollContent}
            keyboardShouldPersistTaps="handled"
            showsVerticalScrollIndicator={false}
          >
            {/* Top Navigation Row: Back Button & Mini Brand Identity */}
            <View style={styles.topNavRow}>
              <TouchableOpacity
                onPress={handleBackToSplash}
                style={[
                  styles.glassBackBtn,
                  {
                    backgroundColor: isDarkMode
                      ? 'rgba(255, 255, 255, 0.12)'
                      : 'rgba(255, 255, 255, 0.85)',
                    borderColor: isDarkMode
                      ? 'rgba(255, 255, 255, 0.22)'
                      : '#DCE8DF',
                  },
                ]}
                activeOpacity={0.75}
                accessibilityLabel="Kembali ke halaman utama"
              >
                <ChevronLeft size={20} color={isDarkMode ? '#FFFFFF' : '#183326'} />
              </TouchableOpacity>

              <View
                style={[
                  styles.miniLogoBadge,
                  {
                    backgroundColor: isDarkMode
                      ? 'rgba(255, 255, 255, 0.12)'
                      : 'rgba(255, 255, 255, 0.85)',
                    borderColor: isDarkMode
                      ? 'rgba(255, 255, 255, 0.22)'
                      : '#DCE8DF',
                  },
                ]}
              >
                <Image source={assets.logo} style={styles.miniLogoImg} resizeMode="contain" />
                <Text
                  style={[
                    styles.miniLogoText,
                    { color: isDarkMode ? '#FFFFFF' : '#183326' },
                  ]}
                >
                  Petani Tech
                </Text>
              </View>

              <View style={styles.badgeOfficial}>
                <Sparkles size={11} color={isDarkMode ? '#ECF39E' : '#31572C'} />
                <Text
                  style={[
                    styles.badgeOfficialText,
                    !isDarkMode && { color: '#31572C' },
                  ]}
                >
                  RESMI
                </Text>
              </View>
            </View>

            {/* Header Title Section */}
            <View style={styles.headerTitleSection}>
              <Text
                style={[
                  styles.screenHeading,
                  {
                    color: isDarkMode ? '#FFFFFF' : '#183326',
                    textShadowColor: isDarkMode
                      ? 'rgba(0, 0, 0, 0.4)'
                      : 'transparent',
                  },
                ]}
              >
                {activeTab === 'login' ? 'Masuk ke Seller Center' : 'Buka Toko Pertanian'}
              </Text>
              <Text
                style={[
                  styles.screenSubheading,
                  { color: isDarkMode ? '#D1F5E8' : '#64776B' },
                ]}
              >
                {activeTab === 'login'
                  ? 'Kelola operasional toko sarana tani, produk, dan transaksi harian Anda.'
                  : 'Daftarkan toko pertanian Anda dan jangkau ribuan mitra pembeli nasional.'}
              </Text>
            </View>

            {/* Translucent Glassmorphism Auth Card */}
            <View
              style={[
                styles.glassAuthCard,
                {
                  backgroundColor: isDarkMode
                    ? 'rgba(18, 61, 43, 0.90)'
                    : 'rgba(255, 255, 255, 0.95)',
                  borderColor: isDarkMode
                    ? 'rgba(255, 255, 255, 0.18)'
                    : 'rgba(220, 232, 223, 0.8)',
                },
              ]}
            >
              <View style={styles.cardTopSheen} />

              {/* Segmented Auth Switch: Bubble Capsule Style */}
              <View
                style={[
                  styles.segmentedCapsule,
                  {
                    backgroundColor: isDarkMode
                      ? 'rgba(6, 31, 22, 0.65)'
                      : '#F0F6F2',
                    borderColor: isDarkMode
                      ? 'rgba(255, 255, 255, 0.12)'
                      : '#E3EDE6',
                  },
                ]}
              >
                <TouchableOpacity
                  onPress={() => setActiveTab('login')}
                  style={styles.segmentOption}
                  activeOpacity={0.8}
                >
                  {activeTab === 'login' ? (
                    <LinearGradient
                      colors={['#40916C', '#285830']}
                      start={{ x: 0, y: 0 }}
                      end={{ x: 1, y: 1 }}
                      style={styles.segmentPillActive}
                    >
                      <View style={styles.pillTopGloss} />
                      <Text style={styles.segmentTextActive}>Masuk Akun</Text>
                    </LinearGradient>
                  ) : (
                    <Text
                      style={[
                        styles.segmentTextInactive,
                        { color: isDarkMode ? '#D2E5D8' : '#5F7061' },
                      ]}
                    >
                      Masuk Akun
                    </Text>
                  )}
                </TouchableOpacity>

                <TouchableOpacity
                  onPress={() => setActiveTab('register')}
                  style={styles.segmentOption}
                  activeOpacity={0.8}
                >
                  {activeTab === 'register' ? (
                    <LinearGradient
                      colors={['#40916C', '#285830']}
                      start={{ x: 0, y: 0 }}
                      end={{ x: 1, y: 1 }}
                      style={styles.segmentPillActive}
                    >
                      <View style={styles.pillTopGloss} />
                      <Text style={styles.segmentTextActive}>Buka Toko Baru</Text>
                    </LinearGradient>
                  ) : (
                    <Text
                      style={[
                        styles.segmentTextInactive,
                        { color: isDarkMode ? '#D2E5D8' : '#5F7061' },
                      ]}
                    >
                      Buka Toko Baru
                    </Text>
                  )}
                </TouchableOpacity>
              </View>

              {/* TAB 1: FORM LOGIN */}
              {activeTab === 'login' ? (
                <View style={styles.formContent}>
                  <Input
                    label="Email Toko atau WhatsApp"
                    placeholder="Contoh: fahda@petanitech.id"
                    value={identifier}
                    onChangeText={setIdentifier}
                    leftIcon={<Mail size={18} color={themeColors.primary} />}
                    autoCapitalize="none"
                    keyboardType="email-address"
                    returnKeyType="next"
                  />

                  <Input
                    label="Kata Sandi Akun"
                    placeholder="Masukkan kata sandi toko"
                    value={password}
                    onChangeText={setPassword}
                    leftIcon={<Lock size={18} color={themeColors.primary} />}
                    secureTextEntry
                    type="password"
                    returnKeyType="done"
                    onSubmitEditing={() => void handleLogin()}
                  />

                  {/* Primary CTA Button */}
                  <TouchableOpacity
                    onPress={() => void handleLogin()}
                    disabled={isLoading}
                    activeOpacity={0.85}
                    style={styles.ctaButtonWrapper}
                  >
                    <LinearGradient
                      colors={['#40916C', '#285830']}
                      start={{ x: 0, y: 0 }}
                      end={{ x: 1, y: 1 }}
                      style={styles.ctaButtonGradient}
                    >
                      <View style={styles.btnTopSheen} />
                      <Text style={styles.ctaButtonText}>
                        {isLoading ? 'Memverifikasi...' : 'Masuk ke Seller Center'}
                      </Text>
                      <ArrowRight size={18} color="#FFFFFF" />
                    </LinearGradient>
                  </TouchableOpacity>

                  {/* Demo Account Quick-Fill Bubble */}
                  <TouchableOpacity
                    onPress={fillDemoAccount}
                    style={[
                      styles.demoAccountPill,
                      {
                        backgroundColor: isDarkMode
                          ? 'rgba(6, 31, 22, 0.65)'
                          : '#F4F9F5',
                        borderColor: isDarkMode
                          ? 'rgba(255, 255, 255, 0.14)'
                          : '#DEEDE2',
                      },
                    ]}
                    activeOpacity={0.75}
                  >
                    <View style={styles.demoLeft}>
                      <View style={styles.demoIconCircle}>
                        <CheckCircle2 size={15} color="#285830" />
                      </View>
                      <View style={styles.demoTextCol}>
                        <Text
                          style={[
                            styles.demoTitle,
                            { color: isDarkMode ? '#FFFFFF' : '#1B3520' },
                          ]}
                        >
                          Gunakan Akun Demo Toko
                        </Text>
                        <Text
                          style={[
                            styles.demoSubtitle,
                            { color: isDarkMode ? '#D2E5D8' : '#5F7061' },
                          ]}
                        >
                          Fahda Febriya · Sandi: 123456
                        </Text>
                      </View>
                    </View>
                    <View style={styles.demoFillAction}>
                      <Text style={styles.demoActionText}>Pakai</Text>
                    </View>
                  </TouchableOpacity>
                </View>
              ) : (
                /* TAB 2: FORM REGISTER */
                <View style={styles.formContent}>
                  <Input
                    label="Nama Pemilik Toko"
                    placeholder="Contoh: Fahda Febriya"
                    value={regName}
                    onChangeText={setRegName}
                    leftIcon={<User size={18} color={colors.primary.DEFAULT} />}
                    returnKeyType="next"
                    required
                  />

                  <Input
                    label="Nama Toko Pertanian"
                    placeholder="Contoh: Toko Tani Makmur Fahda"
                    value={regStoreName}
                    onChangeText={setRegStoreName}
                    leftIcon={<Store size={18} color={colors.primary.DEFAULT} />}
                    returnKeyType="next"
                    required
                  />

                  <Input
                    label="Nomor WhatsApp Toko"
                    placeholder="0812-3456-7890"
                    value={regPhone}
                    onChangeText={setRegPhone}
                    leftIcon={<Phone size={18} color={colors.primary.DEFAULT} />}
                    keyboardType="phone-pad"
                    returnKeyType="next"
                    required
                  />

                  <Input
                    label="Email Resmi Toko"
                    placeholder="Contoh: seller@petanitech.id"
                    value={regEmail}
                    onChangeText={setRegEmail}
                    leftIcon={<Mail size={18} color={colors.primary.DEFAULT} />}
                    keyboardType="email-address"
                    autoCapitalize="none"
                    returnKeyType="next"
                    required
                  />

                  <Input
                    label="Alamat Gudang / Pengiriman"
                    placeholder="Indramayu, Jawa Barat"
                    value={regAddress}
                    onChangeText={setRegAddress}
                    leftIcon={<MapPin size={18} color={colors.primary.DEFAULT} />}
                    returnKeyType="next"
                    required
                  />

                  <Input
                    label="Kata Sandi Baru"
                    placeholder="Minimal 6 karakter"
                    value={regPassword}
                    onChangeText={setRegPassword}
                    leftIcon={<Lock size={18} color={colors.primary.DEFAULT} />}
                    secureTextEntry
                    type="password"
                    returnKeyType="done"
                    onSubmitEditing={() => void handleRegister()}
                    required
                  />

                  {/* Primary CTA Button */}
                  <TouchableOpacity
                    onPress={() => void handleRegister()}
                    disabled={isLoading}
                    activeOpacity={0.85}
                    style={styles.ctaButtonWrapper}
                  >
                    <LinearGradient
                      colors={['#40916C', '#285830']}
                      start={{ x: 0, y: 0 }}
                      end={{ x: 1, y: 1 }}
                      style={styles.ctaButtonGradient}
                    >
                      <View style={styles.btnTopSheen} />
                      <Text style={styles.ctaButtonText}>
                        {isLoading ? 'Mendaftarkan Toko...' : 'Daftar Toko Sekarang'}
                      </Text>
                      <ArrowRight size={18} color="#FFFFFF" />
                    </LinearGradient>
                  </TouchableOpacity>
                </View>
              )}

              {/* Security Trust Footer */}
              <View style={styles.securityTrustRow}>
                <ShieldCheck size={14} color={isDarkMode ? '#90A955' : '#5F7061'} />
                <Text
                  style={[
                    styles.securityTrustText,
                    { color: isDarkMode ? '#D2E5D8' : '#5F7061' },
                  ]}
                >
                  Enkripsi Keamanan 256-bit Petani Tech Marketplace
                </Text>
              </View>
            </View>
          </ScrollView>
        </KeyboardAvoidingView>
      </SafeAreaView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#07190D',
  },
  safeArea: {
    flex: 1,
  },
  keyboardView: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 36,
  },
  // Ambient Orbs
  bubbleTopRight: {
    position: 'absolute',
    top: -50,
    right: -50,
    width: width * 0.7,
    height: width * 0.7,
    borderRadius: (width * 0.7) / 2,
    overflow: 'hidden',
  },
  bubbleBottomLeft: {
    position: 'absolute',
    bottom: -60,
    left: -50,
    width: width * 0.65,
    height: width * 0.65,
    borderRadius: (width * 0.65) / 2,
    overflow: 'hidden',
  },
  orbFill: {
    flex: 1,
  },
  // Top Nav Row
  topNavRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  glassBackBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(255, 255, 255, 0.14)',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.28)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  miniLogoBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    paddingHorizontal: 12,
    paddingVertical: 5,
    borderRadius: 9999,
    backgroundColor: 'rgba(255, 255, 255, 0.12)',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.22)',
  },
  miniLogoImg: {
    width: 20,
    height: 20,
  },
  miniLogoText: {
    fontSize: 12.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    color: '#FFFFFF',
    letterSpacing: 0.2,
  },
  badgeOfficial: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 9999,
    backgroundColor: 'rgba(236, 243, 158, 0.16)',
    borderWidth: 1,
    borderColor: 'rgba(236, 243, 158, 0.35)',
  },
  badgeOfficialText: {
    fontSize: 9.5,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
    color: '#ECF39E',
    letterSpacing: 0.6,
  },
  // Header Section
  headerTitleSection: {
    marginBottom: 20,
    paddingHorizontal: 4,
  },
  screenHeading: {
    fontSize: 25,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
    color: '#FFFFFF',
    letterSpacing: -0.4,
    marginBottom: 6,
    textShadowColor: 'rgba(0, 0, 0, 0.4)',
    textShadowOffset: { width: 0, height: 2 },
    textShadowRadius: 6,
  },
  screenSubheading: {
    fontSize: 13,
    fontFamily: typography.fontFamily.regular,
    color: '#D1F5E8',
    lineHeight: 19,
    opacity: 0.9,
  },
  // Glass Auth Card
  glassAuthCard: {
    backgroundColor: 'rgba(255, 255, 255, 0.95)',
    borderRadius: 26,
    borderWidth: 1.5,
    borderColor: 'rgba(255, 255, 255, 0.85)',
    padding: 20,
    overflow: 'hidden',
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 12 },
    shadowOpacity: 0.28,
    shadowRadius: 22,
    elevation: 8,
  },
  cardTopSheen: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 1.5,
    backgroundColor: 'rgba(255, 255, 255, 0.85)',
  },
  // Segmented Capsule
  segmentedCapsule: {
    flexDirection: 'row',
    height: 48,
    borderRadius: 24,
    backgroundColor: '#F0F6F2',
    borderWidth: 1,
    borderColor: '#E3EDE6',
    padding: 4,
    marginBottom: 20,
  },
  segmentOption: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  segmentPillActive: {
    width: '100%',
    height: '100%',
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
    overflow: 'hidden',
    shadowColor: '#40916C',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.35,
    shadowRadius: 6,
    elevation: 3,
  },
  pillTopGloss: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: '42%',
    backgroundColor: 'rgba(255, 255, 255, 0.22)',
  },
  segmentTextActive: {
    fontSize: 13,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    color: '#FFFFFF',
    letterSpacing: 0.1,
  },
  segmentTextInactive: {
    fontSize: 13,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
    color: '#5F7061',
  },
  // Form Content
  formContent: {
    gap: 16,
  },
  // CTA Button
  ctaButtonWrapper: {
    borderRadius: 18,
    overflow: 'hidden',
    marginTop: 6,
    shadowColor: '#40916C',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.4,
    shadowRadius: 12,
    elevation: 5,
  },
  ctaButtonGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
    paddingVertical: 14,
    position: 'relative',
  },
  btnTopSheen: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: '42%',
    backgroundColor: 'rgba(255, 255, 255, 0.22)',
  },
  ctaButtonText: {
    fontSize: 15,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    color: '#FFFFFF',
    letterSpacing: 0.2,
  },
  // Demo Account Pill
  demoAccountPill: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: '#EAF4EE',
    borderWidth: 1,
    borderColor: '#C3DBC7',
    borderRadius: 16,
    paddingVertical: 10,
    paddingHorizontal: 12,
    marginTop: 4,
  },
  demoLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    flex: 1,
  },
  demoIconCircle: {
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: '#ECF39E',
    justifyContent: 'center',
    alignItems: 'center',
  },
  demoTextCol: {
    flex: 1,
    gap: 1,
  },
  demoTitle: {
    fontSize: 12,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    color: '#285830',
  },
  demoSubtitle: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
    color: '#40916C',
  },
  demoFillAction: {
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 10,
    backgroundColor: '#40916C',
  },
  demoActionText: {
    fontSize: 11,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    color: '#FFFFFF',
  },
  // Trust Footer
  securityTrustRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 6,
    marginTop: 18,
    paddingTop: 14,
    borderTopWidth: 1,
    borderTopColor: '#F0F6F2',
  },
  securityTrustText: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
    color: '#5F7061',
  },
});
