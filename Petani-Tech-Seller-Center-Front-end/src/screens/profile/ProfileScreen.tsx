import React, { useState, useMemo } from 'react';
import {
  StyleSheet,
  Text,
  View,
  ScrollView,
  Image,
  Alert,
  Modal,
  Switch,
} from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import * as ImagePicker from 'expo-image-picker';
import { useAuthStore } from '@/store/useAuthStore';
import { Card } from '@/components/cards/Card';
import { Button } from '@/components/common/Button';
import { Badge } from '@/components/common/Badge';
import { FadeInUp, PressableScale } from '@/components/common/Motion';
import { Input } from '@/components/forms/Input';
import { ThemeSelector } from '@/components/theme/ThemeSelector';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme/ThemeContext';
import { useBottomTabSpace } from '@/navigation/hooks';
import {
  Mail,
  Phone,
  MapPin,
  LogOut,
  Edit3,
  X,
  Camera,
  Store,
  User,
  Building2,
  Palette,
  ShieldCheck,
  Bell,
  Star,
} from 'lucide-react-native';

export function ProfileScreen() {
  const { user, logout, updateProfile } = useAuthStore();
  const { colors: themeColors, isDark } = useTheme();
  const insets = useSafeAreaInsets();
  const bottomSpace = useBottomTabSpace(28);

  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [storeName, setStoreName] = useState(user?.storeName || 'Toko Tani Makmur Fahda');
  const [name, setName] = useState(user?.name || 'Fahda Febriya');
  const [email, setEmail] = useState(user?.email || 'fahda@petanitech.id');
  const [phone, setPhone] = useState(user?.phone || '0812-3456-7890');
  const [storeAddress, setStoreAddress] = useState(
    user?.storeAddress ||
      'Jl. Raya Indramayu - Cirebon No. 88, Kec. Jatibarang, Kab. Indramayu, Jawa Barat 45214'
  );

  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [storeIsOpen, setStoreIsOpen] = useState(true);
  const [isSaving, setIsSaving] = useState(false);

  // Pick Image from Gallery or Camera
  const pickImage = async (useCamera = false) => {
    try {
      if (useCamera) {
        const { status } = await ImagePicker.requestCameraPermissionsAsync();
        if (status !== 'granted') {
          Alert.alert('Izin Kamera Ditolak', 'Aplikasi membutuhkan izin kamera untuk mengambil foto.');
          return;
        }
        const result = await ImagePicker.launchCameraAsync({
          allowsEditing: true,
          aspect: [1, 1],
          quality: 0.8,
        });
        if (!result.canceled && result.assets && result.assets.length > 0 && result.assets[0].uri) {
          await updateProfile({ avatar: result.assets[0].uri });
          Alert.alert('Foto Profil Diperbarui', 'Foto profil toko Anda berhasil diperbarui.');
        }
      } else {
        const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
        if (status !== 'granted') {
          Alert.alert(
            'Izin Galeri Ditolak',
            'Aplikasi membutuhkan izin galeri untuk memilih foto dari perangkat Anda.'
          );
          return;
        }
        const result = await ImagePicker.launchImageLibraryAsync({
          mediaTypes: ['images'],
          allowsEditing: true,
          aspect: [1, 1],
          quality: 0.8,
        });
        if (!result.canceled && result.assets && result.assets.length > 0 && result.assets[0].uri) {
          await updateProfile({ avatar: result.assets[0].uri });
          Alert.alert('Foto Profil Diperbarui', 'Foto profil toko berhasil dipilih dari perangkat.');
        }
      }
    } catch (err: unknown) {
      Alert.alert(
        'Gagal Membuka Gambar',
        err instanceof Error ? err.message : 'Terjadi kendala saat memilih foto.'
      );
    }
  };

  const handleAvatarPress = () => {
    Alert.alert(
      'Ganti Foto Profil Toko',
      'Pilih sumber gambar dari perangkat Anda:',
      [
        { text: 'Batal', style: 'cancel' },
        {
          text: 'Pilih dari Galeri Perangkat',
          onPress: () => void pickImage(false),
        },
        {
          text: 'Ambil Foto dengan Kamera',
          onPress: () => void pickImage(true),
        },
      ]
    );
  };

  const handleLogout = () => {
    Alert.alert(
      'Konfirmasi Keluar',
      'Apakah Anda yakin ingin keluar dari akun Petani Tech Seller Center?',
      [
        { text: 'Batal', style: 'cancel' },
        {
          text: 'Keluar',
          style: 'destructive',
          onPress: async () => {
            await logout();
          },
        },
      ]
    );
  };

  const handleStoreOpenToggle = (nextVal: boolean) => {
    if (!nextVal) {
      Alert.alert(
        'Tutup Toko Sementara?',
        'Saat toko ditutup, pembeli tidak dapat membuat pesanan baru hingga Anda mengaktifkannya kembali.',
        [
          { text: 'Batal', style: 'cancel' },
          {
            text: 'Tutup Toko',
            style: 'destructive',
            onPress: () => setStoreIsOpen(false),
          },
        ]
      );
    } else {
      setStoreIsOpen(true);
    }
  };

  const handleSaveProfile = async () => {
    if (!storeName.trim() || !name.trim() || !email.trim() || !storeAddress.trim()) {
      Alert.alert('Perhatian', 'Nama toko, nama pemilik, email, dan alamat tidak boleh kosong.');
      return;
    }

    setIsSaving(true);
    try {
      await updateProfile({
        name: name.trim(),
        storeName: storeName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        storeAddress: storeAddress.trim(),
      });
      setIsEditModalOpen(false);
      Alert.alert('Sukses', 'Informasi profil toko berhasil diperbarui!');
    } catch (err: unknown) {
      Alert.alert('Gagal', err instanceof Error ? err.message : 'Gagal memperbarui profil toko');
    } finally {
      setIsSaving(false);
    }
  };

  // Mask bank account number safely matching Finance screen
  const maskedAccountNumber = useMemo(() => {
    const raw = user?.bankAccount?.accountNumber?.trim();
    if (!raw) return '4321-01-••••••-53-2';
    const parts = raw.split('-');
    if (parts.length >= 3) {
      return `${parts[0]}-${parts[1]}-••••••-${parts[parts.length - 1]}`;
    }
    if (raw.length > 6) {
      return `${raw.slice(0, 4)} •••• ${raw.slice(-4)}`;
    }
    return raw;
  }, [user?.bankAccount?.accountNumber]);

  return (
    <SafeAreaView
      style={[styles.safeArea, { backgroundColor: isDark ? themeColors.background : '#FAF9F6' }]}
      edges={['top']}
    >
      {/* 1. Subtle Botanical Canvas Gradient (Matches Login/Register Source of Truth) */}
      <LinearGradient
        colors={themeColors.gradients.main}
        locations={[0, 0.22, 0.55, 1]}
        start={{ x: 0.5, y: 0 }}
        end={{ x: 0.5, y: 1 }}
        style={StyleSheet.absoluteFill}
      />

      {/* 2. Soft Ambient Mint Orbs */}
      <View
        style={[
          styles.decorativeOrbTopRight,
          {
            borderColor: isDark ? 'rgba(209, 245, 232, 0.12)' : 'rgba(64, 145, 108, 0.06)',
          },
        ]}
        pointerEvents="none"
      >
        <LinearGradient
          colors={
            isDark
              ? ['rgba(209, 245, 232, 0.18)', 'rgba(64, 145, 108, 0.04)', 'transparent']
              : ['rgba(209, 245, 232, 0.40)', 'rgba(255, 255, 255, 0.15)', 'transparent']
          }
          start={{ x: 0.2, y: 0.2 }}
          end={{ x: 1, y: 1 }}
          style={StyleSheet.absoluteFill}
        />
      </View>

      <View style={styles.decorativeOrbMiddleLeft} pointerEvents="none">
        <LinearGradient
          colors={
            isDark
              ? ['rgba(236, 243, 158, 0.16)', 'rgba(144, 169, 85, 0.04)', 'transparent']
              : ['rgba(236, 243, 158, 0.22)', 'rgba(209, 245, 232, 0.08)', 'transparent']
          }
          start={{ x: 0.3, y: 0.3 }}
          end={{ x: 1, y: 1 }}
          style={StyleSheet.absoluteFill}
        />
      </View>

      {/* 3. Screen Header */}
      <FadeInUp delay={0}>
        <View
          style={[
            styles.header,
            {
              backgroundColor: isDark ? 'rgba(22, 58, 38, 0.85)' : '#FFFFFF',
              borderBottomColor: isDark ? 'rgba(209, 245, 232, 0.14)' : '#DDE8E0',
            },
          ]}
        >
          {/* Top Hairline Sheen Line */}
          <View
            style={[
              styles.sheenLine,
              {
                backgroundColor: isDark
                  ? 'rgba(255, 255, 255, 0.18)'
                  : 'rgba(255, 255, 255, 0.95)',
              },
            ]}
          />
          <View style={styles.titleCol}>
            <View style={styles.eyebrowRow}>
              <View
                style={[
                  styles.eyebrowDot,
                  { backgroundColor: isDark ? themeColors.mint : themeColors.primary },
                ]}
              />
              <Text
                style={[
                  styles.eyebrow,
                  { color: isDark ? themeColors.mint : themeColors.primary },
                ]}
              >
                PENGATURAN & TOKO
              </Text>
            </View>
            <Text style={[styles.screenTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
              Profil & Pengaturan Toko
            </Text>
            <Text style={[styles.screenSubtitle, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
              Kelola identitas toko, alamat gudang pengiriman, dan preferensi akun
            </Text>
          </View>
        </View>
      </FadeInUp>

      <ScrollView
        contentContainerStyle={[styles.scrollContent, { paddingBottom: bottomSpace }]}
        showsVerticalScrollIndicator={false}
      >
        {/* 1. MAIN SELLER IDENTITY CARD */}
        <FadeInUp delay={50}>
          <Card
            sheen
            variant="elevated"
            style={[
              styles.profileCard,
              {
                backgroundColor: isDark ? 'rgba(22, 58, 38, 0.75)' : '#FFFFFF',
                borderColor: isDark ? 'rgba(209, 245, 232, 0.18)' : '#DDE8E0',
              },
            ]}
          >
            <View style={styles.profileHeader}>
              {/* Avatar & Camera Action */}
              <View style={styles.avatarContainer}>
                <Image
                  source={{
                    uri:
                      user?.avatar ||
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
                  }}
                  style={[
                    styles.avatar,
                    {
                      borderColor: isDark ? 'rgba(209, 245, 232, 0.4)' : themeColors.primary,
                    },
                  ]}
                />
                <PressableScale
                  onPress={handleAvatarPress}
                  style={[
                    styles.cameraBtn,
                    {
                      backgroundColor: themeColors.primary,
                      borderColor: isDark ? '#163A26' : '#FFFFFF',
                    },
                  ]}
                  accessibilityLabel="Ganti foto profil toko"
                >
                  <Camera size={13} color="#FFFFFF" />
                </PressableScale>
              </View>

              {/* Store Identification Details */}
              <View style={styles.profileDetails}>
                <Text
                  style={[styles.storeName, { color: isDark ? '#FFFFFF' : '#183326' }]}
                  numberOfLines={1}
                >
                  {user?.storeName || 'Toko Tani Makmur Fahda'}
                </Text>

                <View style={styles.badgeLine}>
                  <Badge variant="brand" size="sm" dot>
                    {user?.status || 'Seller Terverifikasi'}
                  </Badge>
                  <Text style={[styles.storeIdText, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                    ID: {user?.storeId || 'ID-AGRO-INDRAMAYU-01'}
                  </Text>
                </View>

                <Text style={[styles.ownerText, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                  Pemilik:{' '}
                  <Text style={[styles.ownerNameText, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                    {user?.name || 'Fahda Febriya'}
                  </Text>
                </Text>

                <View style={styles.tagRow}>
                  <View
                    style={[
                      styles.ratingBadge,
                      {
                        backgroundColor: isDark ? 'rgba(245, 158, 11, 0.18)' : '#FFFBEB',
                        borderColor: isDark ? 'rgba(245, 158, 11, 0.35)' : '#FDE68A',
                      },
                    ]}
                  >
                    <Star size={11} color="#D97706" fill="#D97706" />
                    <Text style={styles.ratingText}>
                      {user?.rating || 4.95} ({(user?.totalReview || 1280).toLocaleString('id-ID')} Ulasan)
                    </Text>
                  </View>
                  <View
                    style={[
                      styles.locationBadge,
                      {
                        backgroundColor: isDark ? 'rgba(64, 145, 108, 0.18)' : '#F2FBF5',
                        borderColor: isDark ? 'rgba(209, 245, 232, 0.22)' : '#DDE8E0',
                      },
                    ]}
                  >
                    <MapPin size={11} color={isDark ? themeColors.mint : themeColors.primary} />
                    <Text
                      style={[
                        styles.cityText,
                        { color: isDark ? themeColors.mint : themeColors.primaryDark },
                      ]}
                    >
                      Indramayu, Jawa Barat
                    </Text>
                  </View>
                </View>
              </View>
            </View>

            {/* Edit Store Action */}
            <Button
              variant="outline"
              size="md"
              leftIcon={<Edit3 size={15} color={isDark ? themeColors.mint : themeColors.primaryDark} />}
              onPress={() => {
                setName(user?.name || 'Fahda Febriya');
                setStoreName(user?.storeName || 'Toko Tani Makmur Fahda');
                setEmail(user?.email || 'fahda@petanitech.id');
                setPhone(user?.phone || '0812-3456-7890');
                setStoreAddress(
                  user?.storeAddress ||
                    'Jl. Raya Indramayu - Cirebon No. 88, Kec. Jatibarang, Kab. Indramayu, Jawa Barat 45214'
                );
                setIsEditModalOpen(true);
              }}
              style={styles.editProfileBtn}
            >
              Ubah Informasi Toko & Kontak
            </Button>
          </Card>
        </FadeInUp>

        {/* 2. CONTACT & WAREHOUSE INFORMATION */}
        <FadeInUp delay={90}>
          <Card
            sheen
            variant="elevated"
            style={[
              styles.sectionCard,
              {
                backgroundColor: isDark ? 'rgba(22, 58, 38, 0.75)' : '#FFFFFF',
                borderColor: isDark ? 'rgba(209, 245, 232, 0.18)' : '#DDE8E0',
              },
            ]}
          >
            <View style={styles.sectionHeaderRow}>
              <Text style={[styles.sectionHeading, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                INFORMASI KONTAK & GUDANG
              </Text>
            </View>

            {/* Owner Row */}
            <View style={styles.infoRow}>
              <View
                style={[
                  styles.infoIconBox,
                  {
                    backgroundColor: isDark ? 'rgba(64, 145, 108, 0.22)' : '#EAF4EE',
                  },
                ]}
              >
                <User size={17} color={isDark ? themeColors.mint : themeColors.primary} />
              </View>
              <View style={styles.infoTextBox}>
                <Text style={[styles.infoLabel, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                  Nama Pemilik Toko
                </Text>
                <Text style={[styles.infoValue, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                  {user?.name || 'Fahda Febriya'}
                </Text>
              </View>
            </View>

            <View style={[styles.divider, { backgroundColor: isDark ? 'rgba(209, 245, 232, 0.08)' : '#EFF4F0' }]} />

            {/* Email Row */}
            <View style={styles.infoRow}>
              <View
                style={[
                  styles.infoIconBox,
                  {
                    backgroundColor: isDark ? 'rgba(59, 130, 246, 0.22)' : '#EFF6FF',
                  },
                ]}
              >
                <Mail size={17} color="#3B82F6" />
              </View>
              <View style={styles.infoTextBox}>
                <Text style={[styles.infoLabel, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                  Email Resmi Toko
                </Text>
                <Text style={[styles.infoValue, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                  {user?.email || 'fahda@petanitech.id'}
                </Text>
              </View>
            </View>

            <View style={[styles.divider, { backgroundColor: isDark ? 'rgba(209, 245, 232, 0.08)' : '#EFF4F0' }]} />

            {/* Phone Row */}
            <View style={styles.infoRow}>
              <View
                style={[
                  styles.infoIconBox,
                  {
                    backgroundColor: isDark ? 'rgba(64, 145, 108, 0.22)' : '#EAF4EE',
                  },
                ]}
              >
                <Phone size={17} color={isDark ? themeColors.mint : themeColors.primary} />
              </View>
              <View style={styles.infoTextBox}>
                <Text style={[styles.infoLabel, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                  Nomor WhatsApp / Kontak
                </Text>
                <Text style={[styles.infoValue, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                  {user?.phone || '0812-3456-7890'}
                </Text>
              </View>
            </View>

            <View style={[styles.divider, { backgroundColor: isDark ? 'rgba(209, 245, 232, 0.08)' : '#EFF4F0' }]} />

            {/* Warehouse Address Row */}
            <View style={styles.infoRow}>
              <View
                style={[
                  styles.infoIconBox,
                  {
                    backgroundColor: isDark ? 'rgba(245, 158, 11, 0.22)' : '#FFFBEB',
                  },
                ]}
              >
                <MapPin size={17} color="#F59E0B" />
              </View>
              <View style={styles.infoTextBox}>
                <Text style={[styles.infoLabel, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                  Alamat Gudang Asal Pengiriman
                </Text>
                <Text
                  style={[
                    styles.infoValue,
                    styles.addressValue,
                    { color: isDark ? '#FFFFFF' : '#183326' },
                  ]}
                >
                  {user?.storeAddress ||
                    'Jl. Raya Indramayu - Cirebon No. 88, Kec. Jatibarang, Kab. Indramayu, Jawa Barat 45214'}
                </Text>
              </View>
            </View>
          </Card>
        </FadeInUp>

        {/* 3. PAYOUT ACCOUNT (Aligned with Finance Screen) */}
        <FadeInUp delay={130}>
          <Card
            sheen
            variant="elevated"
            style={[
              styles.sectionCard,
              {
                backgroundColor: isDark ? 'rgba(22, 58, 38, 0.75)' : '#FFFFFF',
                borderColor: isDark ? 'rgba(209, 245, 232, 0.18)' : '#DDE8E0',
              },
            ]}
          >
            {/* Header Row */}
            <View style={styles.payoutHeaderRow}>
              <View style={styles.payoutTitleWrap}>
                <View
                  style={[
                    styles.payoutIconCircle,
                    {
                      backgroundColor: isDark ? 'rgba(64, 145, 108, 0.22)' : '#EAF4EE',
                    },
                  ]}
                >
                  <Building2 size={17} color={isDark ? themeColors.mint : themeColors.primary} />
                </View>
                <View style={styles.payoutTitleCol}>
                  <Text style={[styles.payoutHeaderTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                    Rekening Pencairan Terdaftar
                  </Text>
                  <Text style={[styles.payoutHeaderSub, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                    Pencairan instan tanpa biaya admin
                  </Text>
                </View>
              </View>

              <Badge variant="brand" size="sm" dot>
                Terverifikasi
              </Badge>
            </View>

            {/* Account Detail Box */}
            <View
              style={[
                styles.payoutDetailBox,
                {
                  backgroundColor: isDark ? 'rgba(11, 32, 20, 0.65)' : '#FAF9F6',
                  borderColor: isDark ? 'rgba(209, 245, 232, 0.12)' : '#EDF2EE',
                },
              ]}
            >
              <View style={styles.payoutBankRow}>
                <Text style={[styles.payoutBankName, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                  {user?.bankAccount?.bankName || 'Bank Rakyat Indonesia (BRI)'}
                </Text>
                <Text style={[styles.payoutAccountNumber, { color: isDark ? '#D1F5E8' : '#2D6A4F' }]}>
                  {maskedAccountNumber}
                </Text>
              </View>

              <View style={styles.payoutHolderRow}>
                <Text style={[styles.payoutHolderLabel, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                  Atas Nama:
                </Text>
                <Text style={[styles.payoutHolderName, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                  {user?.bankAccount?.accountHolder || user?.name || 'Mitra Petani Terdaftar'}
                </Text>
              </View>
            </View>

            {/* Security Guarantee Note */}
            <View style={styles.payoutSecurityRow}>
              <ShieldCheck size={13} color={isDark ? themeColors.mint : '#40916C'} />
              <Text style={[styles.payoutSecurityText, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                Dilindungi verifikasi biometrik & notifikasi mutasi otomatis
              </Text>
            </View>
          </Card>
        </FadeInUp>

        {/* 4. THEME & DISPLAY PREFERENCES */}
        <FadeInUp delay={170}>
          <Card
            sheen
            variant="elevated"
            style={[
              styles.sectionCard,
              {
                backgroundColor: isDark ? 'rgba(22, 58, 38, 0.75)' : '#FFFFFF',
                borderColor: isDark ? 'rgba(209, 245, 232, 0.18)' : '#DDE8E0',
              },
            ]}
          >
            <View style={styles.sectionTitleRow}>
              <View
                style={[
                  styles.sectionIconWrap,
                  { backgroundColor: isDark ? 'rgba(64, 145, 108, 0.22)' : '#EAF4EE' },
                ]}
              >
                <Palette size={16} color={isDark ? themeColors.mint : themeColors.primary} />
              </View>
              <View style={styles.sectionHeaderCol}>
                <Text style={[styles.sectionHeading, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                  PENGATURAN TEMA & TAMPILAN
                </Text>
                <Text style={[styles.sectionSubheading, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                  Sesuaikan preferensi visual tema aplikasi sesuai kenyamanan Anda
                </Text>
              </View>
            </View>

            <ThemeSelector />
          </Card>
        </FadeInUp>

        {/* 5. OPERATIONAL SETTINGS */}
        <FadeInUp delay={210}>
          <Card
            sheen
            variant="elevated"
            style={[
              styles.sectionCard,
              {
                backgroundColor: isDark ? 'rgba(22, 58, 38, 0.75)' : '#FFFFFF',
                borderColor: isDark ? 'rgba(209, 245, 232, 0.18)' : '#DDE8E0',
              },
            ]}
          >
            <View style={styles.sectionTitleRow}>
              <View
                style={[
                  styles.sectionIconWrap,
                  { backgroundColor: isDark ? 'rgba(64, 145, 108, 0.22)' : '#EAF4EE' },
                ]}
              >
                <Store size={16} color={isDark ? themeColors.mint : themeColors.primary} />
              </View>
              <View style={styles.sectionHeaderCol}>
                <Text style={[styles.sectionHeading, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                  PENGATURAN OPERASIONAL TOKO
                </Text>
                <Text style={[styles.sectionSubheading, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                  Kontrol ketersediaan toko dan penerimaan notifikasi pesanan
                </Text>
              </View>
            </View>

            {/* Switch 1: Status Toko Aktif */}
            <View style={[styles.switchRow, { borderBottomColor: isDark ? 'rgba(209, 245, 232, 0.08)' : '#EFF4F0' }]}>
              <View style={styles.switchTextCol}>
                <View style={styles.switchLabelRow}>
                  <Text style={[styles.switchTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                    Status Toko Buka & Menerima Pesanan
                  </Text>
                  <View
                    style={[
                      styles.storeStatusDot,
                      { backgroundColor: storeIsOpen ? '#10B981' : '#94A3B8' },
                    ]}
                  />
                </View>
                <Text style={[styles.switchSub, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                  {storeIsOpen
                    ? 'Toko aktif. Pembeli dapat memesan seluruh produk yang tersedia'
                    : 'Toko libur. Pembeli tidak dapat membuat checkout pesanan baru'}
                </Text>
              </View>
              <Switch
                value={storeIsOpen}
                onValueChange={handleStoreOpenToggle}
                trackColor={{ false: '#CBD5E1', true: '#A7C8A9' }}
                thumbColor={storeIsOpen ? themeColors.primary : '#F1F5F9'}
              />
            </View>

            {/* Switch 2: Notifikasi Pesanan & Chat */}
            <View style={styles.switchRow}>
              <View style={styles.switchTextCol}>
                <View style={styles.switchLabelRow}>
                  <Bell size={14} color={notificationsEnabled ? (isDark ? themeColors.mint : themeColors.primary) : (isDark ? '#8BA899' : '#7E9180')} />
                  <Text style={[styles.switchTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                    Notifikasi Pesanan & Chat Baru
                  </Text>
                </View>
                <Text style={[styles.switchSub, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                  Dapatkan notifikasi seketika saat ada pesanan baru atau pesan dari pembeli
                </Text>
              </View>
              <Switch
                value={notificationsEnabled}
                onValueChange={setNotificationsEnabled}
                trackColor={{ false: '#CBD5E1', true: '#A7C8A9' }}
                thumbColor={notificationsEnabled ? themeColors.primary : '#F1F5F9'}
              />
            </View>
          </Card>
        </FadeInUp>

        {/* 6. LOGOUT BUTTON */}
        <FadeInUp delay={250}>
          <PressableScale
            onPress={handleLogout}
            style={[
              styles.logoutBtn,
              {
                backgroundColor: isDark ? 'rgba(239, 68, 68, 0.14)' : '#FFF1F2',
                borderColor: isDark ? 'rgba(239, 68, 68, 0.3)' : '#FECDD3',
              },
            ]}
          >
            <LogOut size={17} color="#EF4444" />
            <Text style={styles.logoutText}>Keluar dari Akun Seller</Text>
          </PressableScale>
        </FadeInUp>
      </ScrollView>

      {/* 7. MODAL EDIT INFORMASI TOKO */}
      <Modal
        visible={isEditModalOpen}
        animationType="slide"
        transparent
        onRequestClose={() => {
          if (!isSaving) setIsEditModalOpen(false);
        }}
      >
        <View style={styles.modalOverlay}>
          <View
            style={[
              styles.modalContent,
              {
                backgroundColor: isDark ? '#163A26' : '#FFFFFF',
                borderColor: isDark ? 'rgba(209, 245, 232, 0.20)' : '#DDE8E0',
              },
            ]}
          >
            {/* Modal Header */}
            <View
              style={[
                styles.modalHeader,
                { borderBottomColor: isDark ? 'rgba(209, 245, 232, 0.12)' : '#EFF4F0' },
              ]}
            >
              <View style={styles.modalHeaderTitleCol}>
                <Text style={[styles.modalTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                  Ubah Informasi Toko
                </Text>
                <Text style={[styles.modalSub, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                  Perbarui identitas toko dan alamat gudang pengiriman
                </Text>
              </View>
              <PressableScale
                onPress={() => setIsEditModalOpen(false)}
                disabled={isSaving}
                hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
                style={[
                  styles.modalCloseBtn,
                  { backgroundColor: isDark ? 'rgba(255, 255, 255, 0.10)' : '#F2FBF5' },
                ]}
                accessibilityLabel="Tutup modal edit profil"
              >
                <X size={18} color={isDark ? '#D1F5E8' : '#64746A'} />
              </PressableScale>
            </View>

            {/* Modal Form Scroll */}
            <ScrollView
              contentContainerStyle={[
                styles.modalScroll,
                { paddingBottom: Math.max(insets.bottom, 24) },
              ]}
              keyboardShouldPersistTaps="handled"
              showsVerticalScrollIndicator={false}
            >
              <Input
                label="Nama Pemilik Toko"
                value={name}
                onChangeText={setName}
                leftIcon={<User size={18} color={isDark ? '#8BA899' : '#7E9180'} />}
                required
              />

              <Input
                label="Nama Toko"
                value={storeName}
                onChangeText={setStoreName}
                leftIcon={<Store size={18} color={isDark ? '#8BA899' : '#7E9180'} />}
                required
              />

              <Input
                label="Email Resmi"
                value={email}
                onChangeText={setEmail}
                leftIcon={<Mail size={18} color={isDark ? '#8BA899' : '#7E9180'} />}
                keyboardType="email-address"
                autoCapitalize="none"
                required
              />

              <Input
                label="Nomor WhatsApp / Kontak"
                value={phone}
                onChangeText={setPhone}
                leftIcon={<Phone size={18} color={isDark ? '#8BA899' : '#7E9180'} />}
                keyboardType="phone-pad"
                required
              />

              <Input
                label="Alamat Lengkap Gudang (Indramayu)"
                value={storeAddress}
                onChangeText={setStoreAddress}
                leftIcon={<MapPin size={18} color={isDark ? '#8BA899' : '#7E9180'} />}
                multiline
                required
              />

              {/* Modal Actions */}
              <View style={styles.modalActions}>
                <Button
                  variant="outline"
                  size="md"
                  onPress={() => setIsEditModalOpen(false)}
                  disabled={isSaving}
                  style={styles.cancelBtn}
                >
                  Batal
                </Button>
                <Button
                  variant="primary"
                  size="md"
                  isLoading={isSaving}
                  onPress={() => void handleSaveProfile()}
                  style={styles.saveBtn}
                >
                  Simpan Perubahan
                </Button>
              </View>
            </ScrollView>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
  },
  decorativeOrbTopRight: {
    position: 'absolute',
    top: -80,
    right: -100,
    width: 300,
    height: 300,
    borderRadius: 150,
    overflow: 'hidden',
    borderWidth: 1,
  },
  decorativeOrbMiddleLeft: {
    position: 'absolute',
    top: 360,
    left: -80,
    width: 240,
    height: 240,
    borderRadius: 120,
    overflow: 'hidden',
  },
  header: {
    paddingHorizontal: 16,
    paddingTop: 10,
    paddingBottom: 14,
    borderBottomWidth: 1,
    position: 'relative',
    overflow: 'hidden',
  },
  sheenLine: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 1.5,
  },
  titleCol: {
    gap: 3,
  },
  eyebrowRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  eyebrowDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
  },
  eyebrow: {
    fontSize: 10.5,
    fontFamily: typography.fontFamily.bold,
    letterSpacing: 0.8,
  },
  screenTitle: {
    fontSize: 21,
    fontFamily: typography.fontFamily.extrabold,
    letterSpacing: -0.4,
  },
  screenSubtitle: {
    fontSize: 12,
    fontFamily: typography.fontFamily.regular,
    lineHeight: 16,
  },
  scrollContent: {
    padding: 16,
    gap: 16,
  },

  // 1. Profile Card
  profileCard: {
    padding: 18,
    borderRadius: 22,
    gap: 16,
    borderWidth: 1.5,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
    overflow: 'hidden',
  },
  profileHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 14,
  },
  avatarContainer: {
    position: 'relative',
  },
  avatar: {
    width: 72,
    height: 72,
    borderRadius: 36,
    borderWidth: 2.5,
  },
  cameraBtn: {
    position: 'absolute',
    bottom: -2,
    right: -2,
    width: 26,
    height: 26,
    borderRadius: 13,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.2,
    shadowRadius: 3,
    elevation: 2,
  },
  profileDetails: {
    flex: 1,
    gap: 4,
  },
  storeName: {
    fontSize: 17,
    fontFamily: typography.fontFamily.extrabold,
    letterSpacing: -0.3,
  },
  badgeLine: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginTop: 1,
  },
  storeIdText: {
    fontSize: 10.5,
    fontFamily: typography.fontFamily.medium,
  },
  ownerText: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.regular,
    marginTop: 1,
  },
  ownerNameText: {
    fontFamily: typography.fontFamily.bold,
  },
  tagRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    marginTop: 4,
    flexWrap: 'wrap',
  },
  ratingBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 8,
    borderWidth: 1,
  },
  ratingText: {
    fontSize: 10.5,
    color: '#D97706',
    fontFamily: typography.fontFamily.semibold,
  },
  locationBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 8,
    borderWidth: 1,
  },
  cityText: {
    fontSize: 10.5,
    fontFamily: typography.fontFamily.semibold,
  },
  editProfileBtn: {
    marginTop: 2,
  },

  // 2. Sections
  sectionCard: {
    padding: 16,
    borderRadius: 20,
    gap: 12,
    borderWidth: 1.5,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
    overflow: 'hidden',
  },
  sectionHeaderRow: {
    marginBottom: 2,
  },
  sectionTitleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    marginBottom: 4,
  },
  sectionIconWrap: {
    width: 32,
    height: 32,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  sectionHeaderCol: {
    flex: 1,
    gap: 1,
  },
  sectionHeading: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.bold,
    letterSpacing: 0.6,
  },
  sectionSubheading: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  infoIconBox: {
    width: 36,
    height: 36,
    borderRadius: 11,
    alignItems: 'center',
    justifyContent: 'center',
  },
  infoTextBox: {
    flex: 1,
    gap: 2,
  },
  infoLabel: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
  },
  infoValue: {
    fontSize: 12.5,
    fontFamily: typography.fontFamily.semibold,
  },
  addressValue: {
    lineHeight: 18,
  },
  divider: {
    height: 1,
    marginVertical: 2,
  },

  // 3. Payout Card
  payoutHeaderRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 10,
  },
  payoutTitleWrap: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    flex: 1,
  },
  payoutIconCircle: {
    width: 36,
    height: 36,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  payoutTitleCol: {
    flex: 1,
    gap: 2,
  },
  payoutHeaderTitle: {
    fontSize: 13,
    fontFamily: typography.fontFamily.bold,
    letterSpacing: -0.2,
  },
  payoutHeaderSub: {
    fontSize: 10.5,
    fontFamily: typography.fontFamily.regular,
  },
  payoutDetailBox: {
    padding: 12,
    borderRadius: 14,
    borderWidth: 1,
    gap: 6,
  },
  payoutBankRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  payoutBankName: {
    fontSize: 13,
    fontFamily: typography.fontFamily.bold,
  },
  payoutAccountNumber: {
    fontSize: 12,
    fontFamily: typography.fontFamily.semibold,
    letterSpacing: 0.4,
  },
  payoutHolderRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  payoutHolderLabel: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
  },
  payoutHolderName: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.semibold,
  },
  payoutSecurityRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    paddingHorizontal: 2,
  },
  payoutSecurityText: {
    fontSize: 10.5,
    fontFamily: typography.fontFamily.regular,
    flex: 1,
  },

  // 4. Switches
  switchRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 12,
    paddingVertical: 8,
    borderBottomWidth: 1,
  },
  switchTextCol: {
    flex: 1,
    gap: 2,
  },
  switchLabelRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  switchTitle: {
    fontSize: 12.5,
    fontFamily: typography.fontFamily.semibold,
  },
  storeStatusDot: {
    width: 7,
    height: 7,
    borderRadius: 3.5,
  },
  switchSub: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
    lineHeight: 15,
  },

  // 5. Logout
  logoutBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    borderWidth: 1,
    borderRadius: 18,
    paddingVertical: 14,
    paddingHorizontal: 16,
    marginTop: 2,
  },
  logoutText: {
    color: '#EF4444',
    fontSize: 13.5,
    fontFamily: typography.fontFamily.bold,
  },

  // 6. Modal
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(24, 51, 38, 0.55)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    padding: 22,
    maxHeight: '90%',
    borderTopWidth: 1,
  },
  modalHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 16,
    paddingBottom: 12,
    borderBottomWidth: 1,
  },
  modalHeaderTitleCol: {
    flex: 1,
    gap: 2,
  },
  modalTitle: {
    fontSize: 17,
    fontFamily: typography.fontFamily.extrabold,
    letterSpacing: -0.3,
  },
  modalSub: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.regular,
  },
  modalCloseBtn: {
    width: 32,
    height: 32,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  modalScroll: {
    gap: 14,
    paddingBottom: 24,
  },
  modalActions: {
    flexDirection: 'row',
    gap: 10,
    marginTop: 8,
  },
  cancelBtn: {
    flex: 1,
  },
  saveBtn: {
    flex: 1.6,
  },
});