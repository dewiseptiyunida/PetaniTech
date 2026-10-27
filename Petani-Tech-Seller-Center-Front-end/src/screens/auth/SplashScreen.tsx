import React, { useEffect, useState } from 'react';
import {
  Animated,
  Dimensions,
  Easing,
  Image,
  Platform,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import {
  ArrowRight,
  Sparkles,
  Store,
  ShieldCheck,
  TrendingUp,
  Leaf,
} from 'lucide-react-native';
import { AuthStackParamList } from '@/navigation/types';
import { assets } from '@/assets';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme';

type Props = NativeStackScreenProps<AuthStackParamList, 'Splash'>;

const { width, height } = Dimensions.get('window');

export function SplashScreen({ navigation }: Props) {
  const { isDarkMode } = useTheme();
  // Animation Values initialized lazily with useState
  const [logoScale] = useState(() => new Animated.Value(0.7));
  const [logoOpacity] = useState(() => new Animated.Value(0));
  const [contentOpacity] = useState(() => new Animated.Value(0));
  const [contentTranslateY] = useState(() => new Animated.Value(30));
  const [bubbleFloat1] = useState(() => new Animated.Value(0));
  const [bubbleFloat2] = useState(() => new Animated.Value(0));
  const [glowPulse] = useState(() => new Animated.Value(0.85));

  useEffect(() => {
    // 1. Entrance Sequence: Logo fade + scale
    Animated.parallel([
      Animated.timing(logoOpacity, {
        toValue: 1,
        duration: 900,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }),
      Animated.spring(logoScale, {
        toValue: 1,
        friction: 6,
        tension: 40,
        useNativeDriver: true,
      }),
    ]).start(() => {
      // 2. Content Sequence: Text & Card reveal
      Animated.parallel([
        Animated.timing(contentOpacity, {
          toValue: 1,
          duration: 700,
          easing: Easing.out(Easing.cubic),
          useNativeDriver: true,
        }),
        Animated.timing(contentTranslateY, {
          toValue: 0,
          duration: 700,
          easing: Easing.out(Easing.cubic),
          useNativeDriver: true,
        }),
      ]).start();
    });

    // 3. Ambient Floating Bubbles Loop
    Animated.loop(
      Animated.sequence([
        Animated.timing(bubbleFloat1, {
          toValue: -15,
          duration: 3500,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
        Animated.timing(bubbleFloat1, {
          toValue: 0,
          duration: 3500,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
      ])
    ).start();

    Animated.loop(
      Animated.sequence([
        Animated.timing(bubbleFloat2, {
          toValue: 15,
          duration: 4000,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
        Animated.timing(bubbleFloat2, {
          toValue: 0,
          duration: 4000,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
      ])
    ).start();

    // 4. Subtle Ambient Glow Pulse
    Animated.loop(
      Animated.sequence([
        Animated.timing(glowPulse, {
          toValue: 1.15,
          duration: 2500,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
        Animated.timing(glowPulse, {
          toValue: 0.85,
          duration: 2500,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
      ])
    ).start();
  }, [logoOpacity, logoScale, contentOpacity, contentTranslateY, bubbleFloat1, bubbleFloat2, glowPulse]);

  const handleGoToLogin = () => {
    navigation.navigate('Login', { initialTab: 'login' });
  };

  const handleGoToRegister = () => {
    navigation.navigate('Login', { initialTab: 'register' });
  };

  return (
    <View style={styles.container}>
      {/* Rich Deep Botanical Gradient Background */}
      <LinearGradient
        colors={
          isDarkMode
            ? ['#07190D', '#0F2F19', '#1C4927', '#285C34']
            : ['#F5FAF6', '#EAF5ED', '#D8ECE0', '#C3E2CC']
        }
        locations={[0, 0.35, 0.7, 1]}
        start={{ x: 0.5, y: 0 }}
        end={{ x: 0.5, y: 1 }}
        style={StyleSheet.absoluteFill}
      />

      {/* Floating Translucent Glass Orb 1 (Top-Right Mint Orb) */}
      <Animated.View
        style={[
          styles.decorativeOrb1,
          {
            transform: [{ translateY: bubbleFloat1 }],
          },
        ]}
      >
        <LinearGradient
          colors={
            isDarkMode
              ? ['rgba(209, 245, 232, 0.35)', 'rgba(64, 145, 108, 0.08)', 'transparent']
              : ['rgba(64, 145, 108, 0.18)', 'rgba(209, 245, 232, 0.08)', 'transparent']
          }
          start={{ x: 0.2, y: 0.2 }}
          end={{ x: 1, y: 1 }}
          style={styles.orbGradient}
        />
      </Animated.View>

      {/* Floating Translucent Glass Orb 2 (Bottom-Left Leaf Orb) */}
      <Animated.View
        style={[
          styles.decorativeOrb2,
          {
            transform: [{ translateY: bubbleFloat2 }],
          },
        ]}
      >
        <LinearGradient
          colors={
            isDarkMode
              ? ['rgba(236, 243, 158, 0.25)', 'rgba(144, 169, 85, 0.08)', 'transparent']
              : ['rgba(144, 169, 85, 0.18)', 'rgba(236, 243, 158, 0.08)', 'transparent']
          }
          start={{ x: 0.3, y: 0.3 }}
          end={{ x: 1, y: 1 }}
          style={styles.orbGradient}
        />
      </Animated.View>

      {/* Ambient Pulsing Glow behind Logo */}
      <Animated.View
        style={[
          styles.ambientLogoGlow,
          {
            backgroundColor: isDarkMode ? 'rgba(64, 145, 108, 0.22)' : 'rgba(64, 145, 108, 0.1)',
            transform: [{ scale: glowPulse }],
          },
        ]}
      />

      <SafeAreaView style={styles.safeArea}>
        <View style={styles.mainContent}>
          {/* Logo Section with Glass Capsule Badge */}
          <Animated.View
            style={[
              styles.logoSection,
              {
                opacity: logoOpacity,
                transform: [{ scale: logoScale }],
              },
            ]}
          >
            {/* Watery Glass Capsule Container */}
            <View
              style={[
                styles.glassLogoCapsule,
                {
                  borderColor: isDarkMode
                    ? 'rgba(255, 255, 255, 0.35)'
                    : 'rgba(49, 87, 44, 0.18)',
                },
              ]}
            >
              <LinearGradient
                colors={
                  isDarkMode
                    ? ['rgba(255, 255, 255, 0.28)', 'rgba(255, 255, 255, 0.06)']
                    : ['rgba(255, 255, 255, 0.90)', 'rgba(255, 255, 255, 0.60)']
                }
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={StyleSheet.absoluteFill}
              />
              <View style={styles.glassHighlightSheen} />
              <Image
                source={assets.logo}
                style={styles.logoImage}
                resizeMode="contain"
              />
            </View>

            {/* Official Badge Pill */}
            <View style={styles.officialPill}>
              <Sparkles size={12} color={isDarkMode ? '#ECF39E' : '#31572C'} />
              <Text
                style={[
                  styles.officialPillText,
                  !isDarkMode && { color: '#31572C' },
                ]}
              >
                SELLER CENTER RESMI
              </Text>
            </View>
          </Animated.View>

          {/* Animated Brand Content & Features Card */}
          <Animated.View
            style={[
              styles.animatedContent,
              {
                opacity: contentOpacity,
                transform: [{ translateY: contentTranslateY }],
              },
            ]}
          >
            {/* Title & Tagline */}
            <View style={styles.titleContainer}>
              <Text
                style={[
                  styles.brandTitle,
                  { color: isDarkMode ? '#FFFFFF' : '#183326' },
                ]}
              >
                Petani Tech Seller
              </Text>
              <Text
                style={[
                  styles.brandSubtitle,
                  { color: isDarkMode ? '#D1F5E8' : '#64776B' },
                ]}
              >
                Platform modern untuk pengelolaan toko pertanian, produk unggulan, dan distribusi hasil bumi terpercaya.
              </Text>
            </View>

            {/* Glassmorphic Feature Card (Watery / Liquid Card) */}
            <View
              style={[
                styles.glassHeroCard,
                {
                  borderColor: isDarkMode
                    ? 'rgba(255, 255, 255, 0.18)'
                    : 'rgba(49, 87, 44, 0.14)',
                },
              ]}
            >
              <LinearGradient
                colors={
                  isDarkMode
                    ? ['rgba(255, 255, 255, 0.16)', 'rgba(255, 255, 255, 0.05)']
                    : ['rgba(255, 255, 255, 0.88)', 'rgba(255, 255, 255, 0.65)']
                }
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={StyleSheet.absoluteFill}
              />
              <View style={styles.glassCardTopSheen} />

              <View style={styles.featureItem}>
                <View
                  style={[
                    styles.featureIconBadge,
                    !isDarkMode && { backgroundColor: 'rgba(49, 87, 44, 0.1)' },
                  ]}
                >
                  <Leaf size={16} color={isDarkMode ? '#ECF39E' : '#31572C'} />
                </View>
                <View style={styles.featureTextCol}>
                  <Text
                    style={[
                      styles.featureTitle,
                      { color: isDarkMode ? '#FFFFFF' : '#183326' },
                    ]}
                  >
                    Katalog & Stok Real-Time
                  </Text>
                  <Text
                    style={[
                      styles.featureDesc,
                      { color: isDarkMode ? '#D1F5E8' : '#64776B' },
                    ]}
                  >
                    Pantau pupuk, nutrisi hayati, dan alat tani dengan mudah
                  </Text>
                </View>
              </View>

              <View
                style={[
                  styles.featureDivider,
                  {
                    backgroundColor: isDarkMode
                      ? 'rgba(255, 255, 255, 0.1)'
                      : 'rgba(49, 87, 44, 0.1)',
                  },
                ]}
              />

              <View style={styles.featureItem}>
                <View
                  style={[
                    styles.featureIconBadge,
                    !isDarkMode && { backgroundColor: 'rgba(49, 87, 44, 0.1)' },
                  ]}
                >
                  <TrendingUp size={16} color={isDarkMode ? '#D1F5E8' : '#40916C'} />
                </View>
                <View style={styles.featureTextCol}>
                  <Text
                    style={[
                      styles.featureTitle,
                      { color: isDarkMode ? '#FFFFFF' : '#183326' },
                    ]}
                  >
                    Penjualan & Omset Transparan
                  </Text>
                  <Text
                    style={[
                      styles.featureDesc,
                      { color: isDarkMode ? '#D1F5E8' : '#64776B' },
                    ]}
                  >
                    Rekap transaksi harian dan penarikan saldo instan ke rekening
                  </Text>
                </View>
              </View>

              <View
                style={[
                  styles.featureDivider,
                  {
                    backgroundColor: isDarkMode
                      ? 'rgba(255, 255, 255, 0.1)'
                      : 'rgba(49, 87, 44, 0.1)',
                  },
                ]}
              />

              <View style={styles.featureItem}>
                <View
                  style={[
                    styles.featureIconBadge,
                    !isDarkMode && { backgroundColor: 'rgba(49, 87, 44, 0.1)' },
                  ]}
                >
                  <ShieldCheck size={16} color={isDarkMode ? '#FFFFFF' : '#31572C'} />
                </View>
                <View style={styles.featureTextCol}>
                  <Text
                    style={[
                      styles.featureTitle,
                      { color: isDarkMode ? '#FFFFFF' : '#183326' },
                    ]}
                  >
                    Mitra Terverifikasi
                  </Text>
                  <Text
                    style={[
                      styles.featureDesc,
                      { color: isDarkMode ? '#D1F5E8' : '#64776B' },
                    ]}
                  >
                    Jaringan resmi petani modern dan toko pertanian nasional
                  </Text>
                </View>
              </View>
            </View>

            {/* Action Buttons */}
            <View style={styles.actionButtonsContainer}>
              {/* Primary CTA with Green Gradient */}
              <TouchableOpacity
                onPress={handleGoToLogin}
                activeOpacity={0.85}
                style={styles.primaryBtnWrapper}
              >
                <LinearGradient
                  colors={['#40916C', '#285830']}
                  start={{ x: 0, y: 0 }}
                  end={{ x: 1, y: 1 }}
                  style={styles.primaryBtnGradient}
                >
                  <View style={styles.btnTopSheen} />
                  <Text style={styles.primaryBtnText}>Masuk ke Seller Center</Text>
                  <View style={styles.arrowCircle}>
                    <ArrowRight size={18} color="#285830" />
                  </View>
                </LinearGradient>
              </TouchableOpacity>

              {/* Secondary CTA: Translucent Bubble Button */}
              <TouchableOpacity
                onPress={handleGoToRegister}
                activeOpacity={0.8}
                style={[
                  styles.secondaryGlassBtn,
                  {
                    backgroundColor: isDarkMode
                      ? 'rgba(255, 255, 255, 0.08)'
                      : 'rgba(49, 87, 44, 0.08)',
                    borderColor: isDarkMode
                      ? 'rgba(255, 255, 255, 0.2)'
                      : 'rgba(49, 87, 44, 0.15)',
                  },
                ]}
              >
                <Store size={18} color={isDarkMode ? '#D1F5E8' : '#31572C'} />
                <Text
                  style={[
                    styles.secondaryBtnText,
                    { color: isDarkMode ? '#D1F5E8' : '#31572C' },
                  ]}
                >
                  Buka Toko Baru / Daftar
                </Text>
              </TouchableOpacity>
            </View>
          </Animated.View>
        </View>
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
  mainContent: {
    flex: 1,
    paddingHorizontal: 22,
    justifyContent: 'space-between',
    paddingTop: Platform.OS === 'ios' ? 16 : 24,
    paddingBottom: 24,
  },
  // Decorative Floating Orbs
  decorativeOrb1: {
    position: 'absolute',
    top: -40,
    right: -40,
    width: width * 0.75,
    height: width * 0.75,
    borderRadius: (width * 0.75) / 2,
    overflow: 'hidden',
    zIndex: 1,
  },
  decorativeOrb2: {
    position: 'absolute',
    bottom: height * 0.28,
    left: -50,
    width: width * 0.6,
    height: width * 0.6,
    borderRadius: (width * 0.6) / 2,
    overflow: 'hidden',
    zIndex: 1,
  },
  orbGradient: {
    flex: 1,
  },
  ambientLogoGlow: {
    position: 'absolute',
    top: height * 0.08,
    alignSelf: 'center',
    width: 220,
    height: 220,
    borderRadius: 110,
    backgroundColor: 'rgba(64, 145, 108, 0.25)',
    filter: Platform.OS === 'web' ? 'blur(40px)' : undefined,
    zIndex: 1,
  },
  // Logo & Badge
  logoSection: {
    alignItems: 'center',
    zIndex: 2,
    marginTop: 8,
  },
  glassLogoCapsule: {
    width: 110,
    height: 110,
    borderRadius: 55,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: 'rgba(255, 255, 255, 0.35)',
    backgroundColor: 'rgba(255, 255, 255, 0.12)',
    overflow: 'hidden',
    shadowColor: '#40916C',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.45,
    shadowRadius: 18,
    elevation: 8,
  },
  glassHighlightSheen: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: '48%',
    backgroundColor: 'rgba(255, 255, 255, 0.18)',
    borderTopLeftRadius: 55,
    borderTopRightRadius: 55,
  },
  logoImage: {
    width: 74,
    height: 74,
  },
  officialPill: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    marginTop: 14,
    paddingHorizontal: 14,
    paddingVertical: 5,
    borderRadius: 9999,
    backgroundColor: 'rgba(236, 243, 158, 0.18)',
    borderWidth: 1,
    borderColor: 'rgba(236, 243, 158, 0.4)',
  },
  officialPillText: {
    fontSize: 10.5,
    fontWeight: '700',
    color: '#ECF39E',
    fontFamily: typography.fontFamily.bold,
    letterSpacing: 0.8,
  },
  // Content Section
  animatedContent: {
    zIndex: 2,
    gap: 18,
  },
  titleContainer: {
    alignItems: 'center',
    paddingHorizontal: 6,
  },
  brandTitle: {
    fontSize: 27,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
    color: '#FFFFFF',
    letterSpacing: -0.4,
    textAlign: 'center',
    textShadowColor: 'rgba(0, 0, 0, 0.4)',
    textShadowOffset: { width: 0, height: 2 },
    textShadowRadius: 6,
  },
  brandSubtitle: {
    fontSize: 13,
    fontFamily: typography.fontFamily.regular,
    color: '#D1F5E8',
    textAlign: 'center',
    lineHeight: 19,
    marginTop: 6,
    opacity: 0.92,
  },
  // Glass Hero Card
  glassHeroCard: {
    borderRadius: 22,
    borderWidth: 1.5,
    borderColor: 'rgba(255, 255, 255, 0.22)',
    paddingVertical: 14,
    paddingHorizontal: 16,
    overflow: 'hidden',
    backgroundColor: 'rgba(255, 255, 255, 0.08)',
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.25,
    shadowRadius: 14,
    elevation: 4,
  },
  glassCardTopSheen: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 1,
    backgroundColor: 'rgba(255, 255, 255, 0.45)',
  },
  featureItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    paddingVertical: 6,
  },
  featureIconBadge: {
    width: 34,
    height: 34,
    borderRadius: 10,
    backgroundColor: 'rgba(255, 255, 255, 0.12)',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.25)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  featureTextCol: {
    flex: 1,
    gap: 1,
  },
  featureTitle: {
    fontSize: 12.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    color: '#FFFFFF',
  },
  featureDesc: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
    color: '#D1F5E8',
    opacity: 0.85,
  },
  featureDivider: {
    height: 1,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    marginVertical: 4,
  },
  // Buttons
  actionButtonsContainer: {
    gap: 10,
    marginTop: 4,
  },
  primaryBtnWrapper: {
    borderRadius: 18,
    overflow: 'hidden',
    shadowColor: '#40916C',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.45,
    shadowRadius: 14,
    elevation: 6,
  },
  primaryBtnGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 14,
    paddingHorizontal: 20,
    position: 'relative',
  },
  btnTopSheen: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: '40%',
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
  },
  primaryBtnText: {
    fontSize: 15,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    color: '#FFFFFF',
    letterSpacing: 0.2,
  },
  arrowCircle: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: '#ECF39E',
    justifyContent: 'center',
    alignItems: 'center',
  },
  secondaryGlassBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    paddingVertical: 13,
    borderRadius: 18,
    backgroundColor: 'rgba(255, 255, 255, 0.12)',
    borderWidth: 1.5,
    borderColor: 'rgba(255, 255, 255, 0.24)',
  },
  secondaryBtnText: {
    fontSize: 14,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
    color: '#FFFFFF',
    letterSpacing: 0.1,
  },
});
