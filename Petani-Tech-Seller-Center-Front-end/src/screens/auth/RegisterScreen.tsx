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
import { useNavigation } from '@react-navigation/native';
import {
  Mail,
  Lock,
  Store,
  User,
  Phone,
  MapPin,
  ShieldCheck,
  ChevronLeft,
  Sparkles,
  ArrowRight,
} from 'lucide-react-native';
import { useAuthStore } from '@/store/useAuthStore';
import { Input } from '@/components/forms/Input';
import { assets } from '@/assets';
import { colors } from '@/theme/colors';
import { typography } from '@/theme/typography';

const { width } = Dimensions.get('window');

export function RegisterScreen() {
  const navigation = useNavigation<any>();
  const register = useAuthStore((state) => state.register);
  const isLoading = useAuthStore((state) => state.isLoading);

  const [name, setName] = useState('Fahda Febriya');
  const [storeName, setStoreName] = useState('Toko Tani Makmur Fahda');
  const [phone, setPhone] = useState('0812-3456-7890');
  const [email, setEmail] = useState('');
  const [storeAddress, setStoreAddress] = useState('Indramayu, Jawa Barat');
  const [password, setPassword] = useState('');

  const handleRegister = async () => {
    if (!name.trim() || !storeName.trim() || !phone.trim() || !email.trim()) {
      Alert.alert('Data Belum Lengkap', 'Mohon lengkapi seluruh formulir registrasi toko.');
      return;
    }
    try {
      await register({
        name: name.trim(),
        storeName: storeName.trim(),
        phone: phone.trim(),
        email: email.trim(),
        storeAddress: storeAddress.trim(),
        password: password || '123456',
      });
      Alert.alert('Sukses', 'Toko Anda berhasil terdaftar!');
    } catch (err: unknown) {
      Alert.alert('Gagal', err instanceof Error ? err.message : 'Gagal mendaftar');
    }
  };

  const handleGoToLogin = () => {
    navigation.navigate('Login', { initialTab: 'login' });
  };

  return (
    <View style={styles.container}>
      {/* Rich Deep Botanical Gradient Canvas (No Flat White!) */}
      <LinearGradient
        colors={['#07190D', '#0F2F19', '#1C4927', '#255431']}
        locations={[0, 0.35, 0.7, 1]}
        start={{ x: 0.5, y: 0 }}
        end={{ x: 0.5, y: 1 }}
        style={StyleSheet.absoluteFill}
      />

      {/* Floating Translucent Ambient Orbs */}
      <View style={styles.bubbleTopRight}>
        <LinearGradient
          colors={['rgba(209, 245, 232, 0.30)', 'rgba(64, 145, 108, 0.05)', 'transparent']}
          start={{ x: 0.2, y: 0.2 }}
          end={{ x: 1, y: 1 }}
          style={styles.orbFill}
        />
      </View>

      <View style={styles.bubbleBottomLeft}>
        <LinearGradient
          colors={['rgba(236, 243, 158, 0.22)', 'rgba(144, 169, 85, 0.05)', 'transparent']}
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
                onPress={() => navigation.goBack()}
                style={styles.glassBackBtn}
                activeOpacity={0.75}
                accessibilityLabel="Kembali"
              >
                <ChevronLeft size={20} color="#FFFFFF" />
              </TouchableOpacity>

              <View style={styles.miniLogoBadge}>
                <Image source={assets.logo} style={styles.miniLogoImg} resizeMode="contain" />
                <Text style={styles.miniLogoText}>Petani Tech</Text>
              </View>

              <View style={styles.badgeOfficial}>
                <Sparkles size={11} color="#ECF39E" />
                <Text style={styles.badgeOfficialText}>RESMI</Text>
              </View>
            </View>

            {/* Header Title Section */}
            <View style={styles.headerTitleSection}>
              <Text style={styles.screenHeading}>Buka Toko Pertanian</Text>
              <Text style={styles.screenSubheading}>
                Gabung bersama ribuan distributor dan toko tani modern di Petani Tech
              </Text>
            </View>

            {/* Translucent Glassmorphism Auth Card */}
            <View style={styles.glassAuthCard}>
              <View style={styles.cardTopSheen} />

              {/* Segmented Auth Switch: Bubble Capsule Style */}
              <View style={styles.segmentedCapsule}>
                <TouchableOpacity
                  onPress={handleGoToLogin}
                  style={styles.segmentOption}
                  activeOpacity={0.8}
                >
                  <Text style={styles.segmentTextInactive}>Masuk Akun</Text>
                </TouchableOpacity>

                <TouchableOpacity
                  style={styles.segmentOption}
                  activeOpacity={0.8}
                >
                  <LinearGradient
                    colors={['#40916C', '#285830']}
                    start={{ x: 0, y: 0 }}
                    end={{ x: 1, y: 1 }}
                    style={styles.segmentPillActive}
                  >
                    <View style={styles.pillTopGloss} />
                    <Text style={styles.segmentTextActive}>Buka Toko Baru</Text>
                  </LinearGradient>
                </TouchableOpacity>
              </View>

              {/* FORM REGISTER */}
              <View style={styles.formContent}>
                <Input
                  label="Nama Pemilik Toko"
                  placeholder="Contoh: Fahda Febriya"
                  value={name}
                  onChangeText={setName}
                  leftIcon={<User size={18} color={colors.primary.DEFAULT} />}
                  returnKeyType="next"
                  required
                />

                <Input
                  label="Nama Toko Pertanian"
                  placeholder="Contoh: Toko Tani Makmur Fahda"
                  value={storeName}
                  onChangeText={setStoreName}
                  leftIcon={<Store size={18} color={colors.primary.DEFAULT} />}
                  returnKeyType="next"
                  required
                />

                <Input
                  label="Nomor WhatsApp Toko"
                  placeholder="0812-3456-7890"
                  value={phone}
                  onChangeText={setPhone}
                  leftIcon={<Phone size={18} color={colors.primary.DEFAULT} />}
                  keyboardType="phone-pad"
                  returnKeyType="next"
                  required
                />

                <Input
                  label="Email Resmi Toko"
                  placeholder="seller@petanitech.id"
                  value={email}
                  onChangeText={setEmail}
                  leftIcon={<Mail size={18} color={colors.primary.DEFAULT} />}
                  keyboardType="email-address"
                  autoCapitalize="none"
                  returnKeyType="next"
                  required
                />

                <Input
                  label="Alamat Gudang / Pengiriman"
                  placeholder="Indramayu, Jawa Barat"
                  value={storeAddress}
                  onChangeText={setStoreAddress}
                  leftIcon={<MapPin size={18} color={colors.primary.DEFAULT} />}
                  returnKeyType="next"
                  required
                />

                <Input
                  label="Kata Sandi Toko Baru"
                  placeholder="Minimal 6 karakter"
                  value={password}
                  onChangeText={setPassword}
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

                {/* Footer Switch Prompt */}
                <TouchableOpacity
                  onPress={handleGoToLogin}
                  style={styles.switchPromptRow}
                  activeOpacity={0.75}
                >
                  <Text style={styles.switchPromptText}>Sudah memiliki akun toko?</Text>
                  <Text style={styles.switchPromptAction}>Masuk di sini</Text>
                </TouchableOpacity>
              </View>

              {/* Security Trust Footer */}
              <View style={styles.securityTrustRow}>
                <ShieldCheck size={14} color="#5F7061" />
                <Text style={styles.securityTrustText}>
                  Data toko aman & terenkripsi oleh Petani Tech
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
  switchPromptRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 6,
    marginTop: 6,
  },
  switchPromptText: {
    fontSize: 12.5,
    color: '#5F7061',
    fontFamily: typography.fontFamily.regular,
  },
  switchPromptAction: {
    fontSize: 12.5,
    color: '#40916C',
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
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
