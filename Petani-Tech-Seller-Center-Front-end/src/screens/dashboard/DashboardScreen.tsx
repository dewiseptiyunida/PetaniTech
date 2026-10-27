import React, { useEffect, useState } from 'react';
import {
  Alert,
  Image,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { useSellerNavigation, useBottomTabSpace } from '@/navigation/hooks';
import { useAuthStore } from '@/store/useAuthStore';
import { useProductStore } from '@/store/useProductStore';
import { useOrderStore } from '@/store/useOrderStore';
import { useFinanceStore } from '@/store/useFinanceStore';
import { formatRupiah } from '@/constants';
import { resolveProductImage } from '@/utils/productImage';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme/ThemeContext';
import { FadeInUp, PressableScale } from '@/components/common';
import {
  TrendingUp,
  Package,
  ShoppingCart,
  Boxes,
  Wallet,
  Sparkles,
  Truck,
  RotateCcw,
  MessageSquare,
  AlertTriangle,
  ChevronRight,
  X,
  Tags,
  BarChart3,
  PlusCircle,
  Clock,
  ArrowUpRight,
  Bell,
  Store,
  MapPin,
  Sun,
  Moon,
  Settings,
} from 'lucide-react-native';

export function DashboardScreen() {
  const navigation = useSellerNavigation();
  const bottomSpace = useBottomTabSpace(28);
  const { user } = useAuthStore();
  const { products, fetchProducts } = useProductStore();
  const { orders, fetchOrders } = useOrderStore();
  const { summary: financeSummary, fetchFinance } = useFinanceStore();
  const { colors: themeColors, isDark, toggleTheme } = useTheme();

  const [showRecommendation, setShowRecommendation] = useState(true);

  useEffect(() => {
    fetchProducts();
    fetchOrders();
    fetchFinance();
  }, [fetchProducts, fetchOrders, fetchFinance]);

  const activeProductsCount = products.filter((p) => p.status === 'Aktif').length || 38;
  const lowStockCount = products.filter((p) => p.stock > 0 && p.stock <= p.minStockAlert).length;
  const processingOrdersCount = orders.filter((o) => o.status === 'Diproses').length;
  const pendingOrdersCount = orders.filter((o) => o.status === 'Menunggu Pembayaran').length;

  const quickMenus = [
    {
      name: 'Tambah Produk',
      screen: 'Products' as const,
      icon: PlusCircle,
      iconColor: isDark ? '#D1F5E8' : '#2D6A4F',
      tileBg: isDark ? 'rgba(64, 145, 108, 0.35)' : '#EAF5EE',
      tileBorder: isDark ? 'rgba(209, 245, 232, 0.35)' : '#C6E2D0',
    },
    {
      name: 'Semua Produk',
      screen: 'Products' as const,
      icon: Package,
      iconColor: isDark ? '#ECF39E' : '#40916C',
      tileBg: isDark ? 'rgba(144, 169, 85, 0.32)' : '#F2F7ED',
      tileBorder: isDark ? 'rgba(236, 243, 158, 0.35)' : '#D6E6CC',
    },
    {
      name: 'Pesanan Masuk',
      screen: 'Orders' as const,
      icon: ShoppingCart,
      iconColor: isDark ? '#7DD3FC' : '#0284C7',
      tileBg: isDark ? 'rgba(56, 189, 248, 0.28)' : '#EBF5FF',
      tileBorder: isDark ? 'rgba(56, 189, 248, 0.38)' : '#BEE0FF',
      count: processingOrdersCount ? String(processingOrdersCount) : undefined,
    },
    {
      name: 'Kelola Stok',
      screen: 'Inventory' as const,
      icon: Boxes,
      iconColor: isDark ? '#FCD34D' : '#D97706',
      tileBg: isDark ? 'rgba(245, 158, 11, 0.28)' : '#FFFBEB',
      tileBorder: isDark ? 'rgba(245, 158, 11, 0.38)' : '#FDE68A',
      count: lowStockCount ? String(lowStockCount) : undefined,
    },
    {
      name: 'Dompet Toko',
      screen: 'Finance' as const,
      icon: Wallet,
      iconColor: isDark ? '#6EE7B7' : '#059669',
      tileBg: isDark ? 'rgba(16, 185, 129, 0.28)' : '#E6F7F0',
      tileBorder: isDark ? 'rgba(16, 185, 129, 0.38)' : '#B6ECD7',
    },
    {
      name: 'Voucher Promo',
      screen: 'Promotions' as const,
      icon: Tags,
      iconColor: isDark ? '#FDA4AF' : '#E11D48',
      tileBg: isDark ? 'rgba(244, 63, 94, 0.28)' : '#FFF1F2',
      tileBorder: isDark ? 'rgba(244, 63, 94, 0.38)' : '#FECDD3',
    },
    {
      name: 'Analitik Bisnis',
      screen: 'Analytics' as const,
      icon: BarChart3,
      iconColor: isDark ? '#D8B4FE' : '#7C3AED',
      tileBg: isDark ? 'rgba(168, 85, 247, 0.28)' : '#F5F3FF',
      tileBorder: isDark ? 'rgba(168, 85, 247, 0.38)' : '#DDD6FE',
    },
    {
      name: 'Profil Toko',
      screen: 'Profile' as const,
      icon: Store,
      iconColor: isDark ? '#BEF264' : '#65A30D',
      tileBg: isDark ? 'rgba(132, 204, 22, 0.28)' : '#F7FEE7',
      tileBorder: isDark ? 'rgba(190, 242, 100, 0.38)' : '#D9F99D',
    },
  ];

  const handleNotificationPress = () => {
    Alert.alert(
      'Notifikasi Toko',
      'Semua sistem pemrosesan pesanan dan notifikasi WhatsApp pembeli aktif normal.'
    );
  };

  return (
    <View style={[styles.container, { backgroundColor: themeColors.background }]}>
      {/* 1. Subtle Botanical Canvas Gradient (Matches Login/Register Source of Truth) */}
      <LinearGradient
        colors={themeColors.gradients.main}
        locations={[0, 0.22, 0.55, 1]}
        start={{ x: 0.5, y: 0 }}
        end={{ x: 0.5, y: 1 }}
        style={StyleSheet.absoluteFill}
      />

      {/* 2. Soft Ambient Mint Orbs (Light & Airy depth) */}
      <View
        style={[
          styles.decorativeOrbTopRight,
          {
            borderColor: isDark ? 'rgba(209, 245, 232, 0.15)' : 'rgba(64, 145, 108, 0.06)',
          },
        ]}
        pointerEvents="none"
      >
        <LinearGradient
          colors={
            isDark
              ? ['rgba(209, 245, 232, 0.22)', 'rgba(64, 145, 108, 0.05)', 'transparent']
              : ['rgba(209, 245, 232, 0.45)', 'rgba(255, 255, 255, 0.2)', 'transparent']
          }
          start={{ x: 0.2, y: 0.2 }}
          end={{ x: 1, y: 1 }}
          style={styles.orbFill}
        />
      </View>

      <View style={styles.decorativeOrbMiddleLeft} pointerEvents="none">
        <LinearGradient
          colors={
            isDark
              ? ['rgba(236, 243, 158, 0.18)', 'rgba(144, 169, 85, 0.05)', 'transparent']
              : ['rgba(236, 243, 158, 0.25)', 'rgba(209, 245, 232, 0.1)', 'transparent']
          }
          start={{ x: 0.3, y: 0.3 }}
          end={{ x: 1, y: 1 }}
          style={styles.orbFill}
        />
      </View>

      <View style={styles.decorativeOrbBottomRight} pointerEvents="none">
        <LinearGradient
          colors={
            isDark
              ? ['rgba(64, 145, 108, 0.22)', 'rgba(11, 46, 32, 0.08)', 'transparent']
              : ['rgba(209, 245, 232, 0.3)', 'rgba(255, 255, 255, 0.15)', 'transparent']
          }
          start={{ x: 0.2, y: 0.2 }}
          end={{ x: 1, y: 1 }}
          style={styles.orbFill}
        />
      </View>

      <SafeAreaView style={styles.safeArea} edges={['top']}>
        <ScrollView
          contentContainerStyle={[styles.content, { paddingBottom: bottomSpace }]}
          showsVerticalScrollIndicator={false}
        >
          {/* 1. Header Hero Section: Soft Mint / White Glass Profile Card with Hairline Sheen */}
          <FadeInUp delay={0}>
            <View
              style={[
                styles.profileHeroCard,
                {
                  borderColor: isDark ? 'rgba(209, 245, 232, 0.25)' : '#E0ECE3',
                  backgroundColor: isDark ? 'transparent' : '#FFFFFF',
                },
              ]}
            >
              <LinearGradient
                colors={themeColors.gradients.header}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={StyleSheet.absoluteFill}
              />
              {/* Top Glossy Sheen Line */}
              <View
                style={[
                  styles.cardTopSheen,
                  { backgroundColor: themeColors.cardSheen },
                ]}
              />

              {/* Dedicated Top Action Bar: Verification Badge & Predictable Settings Controls */}
              <View style={styles.headerTopBar}>
                <View
                  style={[
                    styles.verifiedPill,
                    {
                      backgroundColor: isDark ? 'rgba(236, 243, 158, 0.20)' : '#EAF5EE',
                      borderColor: isDark ? 'rgba(236, 243, 158, 0.35)' : '#C6E2D0',
                    },
                  ]}
                >
                  <Sparkles size={11} color={isDark ? '#ECF39E' : '#2D6A4F'} />
                  <Text
                    style={[
                      styles.verifiedPillText,
                      { color: isDark ? '#ECF39E' : '#2D6A4F' },
                    ]}
                  >
                    TERVERIFIKASI
                  </Text>
                </View>

                {/* Predictable Settings, Theme & Notification Controls */}
                <View style={styles.headerActionRow}>
                  <PressableScale
                    onPress={() => navigation.navigate('Profile')}
                    style={[
                      styles.actionCircleBtn,
                      {
                        backgroundColor: isDark
                          ? 'rgba(255, 255, 255, 0.12)'
                          : '#F0F7F3',
                        borderColor: isDark
                          ? 'rgba(255, 255, 255, 0.22)'
                          : '#E0ECE3',
                      },
                    ]}
                    accessibilityLabel="Pengaturan Toko"
                  >
                    <Settings size={16} color={isDark ? '#D1F5E8' : '#2D6A4F'} />
                  </PressableScale>

                  <PressableScale
                    onPress={toggleTheme}
                    style={[
                      styles.actionCircleBtn,
                      {
                        backgroundColor: isDark
                          ? 'rgba(255, 255, 255, 0.12)'
                          : '#F0F7F3',
                        borderColor: isDark
                          ? 'rgba(255, 255, 255, 0.22)'
                          : '#E0ECE3',
                      },
                    ]}
                    accessibilityLabel="Ganti Mode Tampilan (Terang / Gelap)"
                  >
                    {isDark ? (
                      <Sun size={16} color="#D1F5E8" />
                    ) : (
                      <Moon size={16} color="#2D6A4F" />
                    )}
                  </PressableScale>

                  <PressableScale
                    onPress={handleNotificationPress}
                    style={[
                      styles.actionCircleBtn,
                      {
                        backgroundColor: isDark
                          ? 'rgba(255, 255, 255, 0.12)'
                          : '#F0F7F3',
                        borderColor: isDark
                          ? 'rgba(255, 255, 255, 0.22)'
                          : '#E0ECE3',
                      },
                    ]}
                    accessibilityLabel="Notifikasi toko"
                  >
                    <Bell size={16} color={isDark ? '#D1F5E8' : '#2D6A4F'} />
                    <View style={styles.bellDot} />
                  </PressableScale>
                </View>
              </View>

              {/* Seller Identity Row: Avatar + Greeting + Store Name */}
              <View style={styles.profileHeroMain}>
                <PressableScale
                  onPress={() => navigation.navigate('Profile')}
                  style={styles.avatarTouchable}
                  accessibilityLabel="Buka Profil Toko"
                >
                  <Image
                    source={{
                      uri:
                        user?.avatar ||
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
                    }}
                    style={[
                      styles.avatar,
                      {
                        borderColor: isDark ? 'rgba(255, 255, 255, 0.75)' : '#FFFFFF',
                      },
                    ]}
                  />
                  <View style={styles.onlineBadge} />
                </PressableScale>

                <View style={styles.profileTextCol}>
                  <Text
                    style={[
                      styles.ownerGreeting,
                      { color: themeColors.text },
                    ]}
                    numberOfLines={1}
                  >
                    Halo, {user?.name || 'Fahda Febriya'} 👋
                  </Text>

                  <Text
                    style={[
                      styles.storeNameText,
                      { color: isDark ? '#D1F5E8' : '#2D6A4F' },
                    ]}
                    numberOfLines={1}
                  >
                    {user?.storeName || 'Toko Tani Makmur Fahda'}
                  </Text>

                  <View style={styles.metaRow}>
                    <View style={styles.locationPill}>
                      <MapPin size={11} color={isDark ? '#D1F5E8' : '#40916C'} />
                      <Text
                        style={[
                          styles.locationText,
                          { color: themeColors.textSecondary },
                        ]}
                        numberOfLines={1}
                      >
                        {user?.storeAddress?.split(',')[0] || 'Indramayu, Jawa Barat'}
                      </Text>
                    </View>
                    <Text
                      style={[styles.dotDivider, { color: themeColors.textMuted }]}
                    >
                      •
                    </Text>
                    <Text style={styles.ratingText}>⭐ 4.95 (1.2k ulasan)</Text>
                  </View>
                </View>
              </View>
            </View>
          </FadeInUp>

          {/* 2. Status Pesanan Saya: Crisp White Card with Soft Pastel Icon Boxes */}
          <FadeInUp delay={60}>
            <View
              style={[
                styles.whiteCard,
                {
                  backgroundColor: themeColors.card,
                  borderColor: themeColors.cardBorder,
                },
              ]}
            >
              <View
                style={[
                  styles.cardTopSheen,
                  { backgroundColor: themeColors.cardSheen },
                ]}
              />
              <View style={styles.sectionHeaderRow}>
                <View style={styles.headerTitleLeft}>
                  <View style={styles.headerGreenDot} />
                  <Text style={[styles.sectionTitle, { color: themeColors.text }]}>
                    STATUS PESANAN SAYA
                  </Text>
                </View>
                <PressableScale
                  onPress={() => navigation.navigate('Orders')}
                  style={styles.linkRow}
                >
                  <Text
                    style={[
                      styles.linkText,
                      { color: isDark ? '#D1F5E8' : '#2D6A4F' },
                    ]}
                  >
                    Lihat Semua
                  </Text>
                  <ChevronRight
                    size={14}
                    color={isDark ? '#D1F5E8' : '#2D6A4F'}
                  />
                </PressableScale>
              </View>

              <View style={styles.pipelineGrid}>
                {/* Item 1: Perlu Dikirim (Soft Mint Box) */}
                <View style={styles.pipelineCol}>
                  <PressableScale
                    onPress={() => navigation.navigate('Orders')}
                    style={[
                      styles.pipelineIconBox,
                      isDark ? styles.pipelineIconMintDark : styles.pipelineIconMintLight,
                    ]}
                  >
                    <Truck size={20} color={isDark ? '#D1F5E8' : '#2D6A4F'} />
                    {processingOrdersCount > 0 && (
                      <View style={styles.badgeIndicator}>
                        <Text style={styles.badgeIndicatorText}>{processingOrdersCount}</Text>
                      </View>
                    )}
                  </PressableScale>
                  <Text
                    style={[
                      styles.pipelineCount,
                      { color: themeColors.text },
                    ]}
                  >
                    {processingOrdersCount}
                  </Text>
                  <Text
                    style={[
                      styles.pipelineLabel,
                      { color: themeColors.textSecondary },
                    ]}
                  >
                    Perlu Dikirim
                  </Text>
                </View>

                {/* Item 2: Menunggu Bayar (Soft Amber Box) */}
                <View style={styles.pipelineCol}>
                  <PressableScale
                    onPress={() => navigation.navigate('Orders')}
                    style={[
                      styles.pipelineIconBox,
                      isDark ? styles.pipelineIconAmberDark : styles.pipelineIconAmberLight,
                    ]}
                  >
                    <Clock size={20} color={isDark ? '#FCD34D' : '#D97706'} />
                    {pendingOrdersCount > 0 && (
                      <View style={[styles.badgeIndicator, { backgroundColor: '#F59E0B' }]}>
                        <Text style={styles.badgeIndicatorText}>{pendingOrdersCount}</Text>
                      </View>
                    )}
                  </PressableScale>
                  <Text
                    style={[
                      styles.pipelineCount,
                      { color: themeColors.text },
                    ]}
                  >
                    {pendingOrdersCount}
                  </Text>
                  <Text
                    style={[
                      styles.pipelineLabel,
                      { color: themeColors.textSecondary },
                    ]}
                  >
                    Menunggu Bayar
                  </Text>
                </View>

                {/* Item 3: Pengembalian (Soft Rose Box) */}
                <View style={styles.pipelineCol}>
                  <PressableScale
                    onPress={() => Alert.alert('Informasi Retur', 'Belum ada permintaan pengembalian produk.')}
                    style={[
                      styles.pipelineIconBox,
                      isDark ? styles.pipelineIconRoseDark : styles.pipelineIconRoseLight,
                    ]}
                  >
                    <RotateCcw size={20} color={isDark ? '#FCA5A5' : '#EF4444'} />
                  </PressableScale>
                  <Text
                    style={[
                      styles.pipelineCount,
                      { color: themeColors.text },
                    ]}
                  >
                    0
                  </Text>
                  <Text
                    style={[
                      styles.pipelineLabel,
                      { color: themeColors.textSecondary },
                    ]}
                  >
                    Pengembalian
                  </Text>
                </View>

                {/* Item 4: Ulasan Baru (Soft Sky Blue Box) */}
                <View style={styles.pipelineCol}>
                  <PressableScale
                    onPress={() =>
                      Alert.alert('Ulasan Mitra Tani', 'Toko Anda memiliki 1.280 ulasan dengan kepuasan 99.4%!')
                    }
                    style={[
                      styles.pipelineIconBox,
                      isDark ? styles.pipelineIconBlueDark : styles.pipelineIconBlueLight,
                    ]}
                  >
                    <MessageSquare size={20} color={isDark ? '#93C5FD' : '#2563EB'} />
                  </PressableScale>
                  <Text style={[styles.pipelineCount, { color: isDark ? '#93C5FD' : '#2563EB' }]}>
                    12
                  </Text>
                  <Text
                    style={[
                      styles.pipelineLabel,
                      { color: themeColors.textSecondary },
                    ]}
                  >
                    Ulasan Baru
                  </Text>
                </View>
              </View>
            </View>
          </FadeInUp>

          {/* 3. Saldo Toko: Premium Green Gradient Centerpiece Hero Card */}
          <FadeInUp delay={120}>
            <View style={styles.balanceCardWrapper}>
              <LinearGradient
                colors={themeColors.gradients.balance}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={styles.balanceCardGradient}
              >
                <View style={styles.balanceTopGloss} />

                <View style={styles.balanceTop}>
                  <View style={styles.balanceIconWrapper}>
                    <Wallet size={16} color="#ECF39E" />
                  </View>
                  <Text style={styles.balanceLabel}>SALDO SIAP DITARIK</Text>
                  <ArrowUpRight size={16} color="#ECF39E" style={styles.arrowTopRight} />
                </View>

                <Text style={styles.balanceValue}>
                  {formatRupiah(financeSummary?.availableBalance || 12850000)}
                </Text>

                <View style={styles.balanceBottom}>
                  <Text style={styles.balanceSub}>Rekening: BRI **** 53-2</Text>
                  <PressableScale
                    onPress={() => navigation.navigate('Finance')}
                    style={styles.withdrawButton}
                  >
                    <Text style={styles.withdrawBtnText}>Tarik Dana</Text>
                  </PressableScale>
                </View>
              </LinearGradient>
            </View>
          </FadeInUp>

          {/* 4. Statistik: 2-Column Pure White KPI Cards */}
          <FadeInUp delay={160}>
            <View style={styles.kpiRow}>
              {/* Penjualan Bulan Ini */}
              <View
                style={[
                  styles.kpiCardHalf,
                  {
                    backgroundColor: themeColors.card,
                    borderColor: themeColors.cardBorder,
                  },
                ]}
              >
                <View
                  style={[
                    styles.cardTopSheen,
                    { backgroundColor: themeColors.cardSheen },
                  ]}
                />
                <View style={styles.kpiHeaderRow}>
                  <Text
                    style={[
                      styles.kpiMiniTitle,
                      { color: themeColors.textSecondary },
                    ]}
                  >
                    Penjualan Bulan Ini
                  </Text>
                  <View
                    style={[
                      styles.kpiMiniIcon,
                      {
                        backgroundColor: isDark
                          ? 'rgba(64, 145, 108, 0.35)'
                          : '#EAF5EE',
                        borderColor: isDark
                          ? 'rgba(209, 245, 232, 0.35)'
                          : '#C6E2D0',
                      },
                    ]}
                  >
                    <TrendingUp
                      size={15}
                      color={isDark ? '#D1F5E8' : '#2D6A4F'}
                    />
                  </View>
                </View>
                <Text
                  style={[
                    styles.kpiMainNumber,
                    { color: themeColors.text },
                  ]}
                >
                  Rp 34,5 Jt
                </Text>
                <View style={styles.trendRow}>
                  <View
                    style={[
                      styles.trendCapsule,
                      {
                        backgroundColor: isDark
                          ? 'rgba(209, 245, 232, 0.18)'
                          : '#EAF5EE',
                        borderColor: isDark
                          ? 'rgba(209, 245, 232, 0.3)'
                          : '#C6E2D0',
                      },
                    ]}
                  >
                    <Text
                      style={[
                        styles.trendGreen,
                        { color: isDark ? '#D1F5E8' : '#2D6A4F' },
                      ]}
                    >
                      ↑ +18.4%
                    </Text>
                  </View>
                  <Text
                    style={[
                      styles.trendSub,
                      { color: themeColors.textMuted },
                    ]}
                  >
                    vs bln lalu
                  </Text>
                </View>
              </View>

              {/* Produk Aktif */}
              <View
                style={[
                  styles.kpiCardHalf,
                  {
                    backgroundColor: themeColors.card,
                    borderColor: themeColors.cardBorder,
                  },
                ]}
              >
                <View
                  style={[
                    styles.cardTopSheen,
                    { backgroundColor: themeColors.cardSheen },
                  ]}
                />
                <View style={styles.kpiHeaderRow}>
                  <Text
                    style={[
                      styles.kpiMiniTitle,
                      { color: themeColors.textSecondary },
                    ]}
                  >
                    Produk Aktif
                  </Text>
                  <View
                    style={[
                      styles.kpiMiniIcon,
                      {
                        backgroundColor: isDark
                          ? 'rgba(144, 169, 85, 0.35)'
                          : '#F4F9EB',
                        borderColor: isDark
                          ? 'rgba(236, 243, 158, 0.35)'
                          : '#DFECC6',
                      },
                    ]}
                  >
                    <Package
                      size={15}
                      color={isDark ? '#ECF39E' : '#40916C'}
                    />
                  </View>
                </View>
                <Text
                  style={[
                    styles.kpiMainNumber,
                    { color: themeColors.text },
                  ]}
                >
                  {activeProductsCount}
                </Text>
                <View style={styles.trendRow}>
                  <Text
                    style={[
                      styles.trendNeutral,
                      { color: themeColors.textSecondary },
                    ]}
                  >
                    4 Kategori Tani
                  </Text>
                </View>
              </View>
            </View>
          </FadeInUp>

          {/* 5. Menu Pengelolaan Toko: Pure White Panel with Soft Pastel Icon Tiles */}
          <FadeInUp delay={200}>
            <View
              style={[
                styles.whiteCard,
                {
                  backgroundColor: themeColors.card,
                  borderColor: themeColors.cardBorder,
                },
              ]}
            >
              <View
                style={[
                  styles.cardTopSheen,
                  { backgroundColor: themeColors.cardSheen },
                ]}
              />
              <View style={styles.sectionHeaderCol}>
                <View style={styles.headerTitleLeft}>
                  <View style={styles.headerGreenDot} />
                  <Text style={[styles.sectionTitle, { color: themeColors.text }]}>
                    MENU PENGELOLAAN TOKO
                  </Text>
                </View>
                <Text
                  style={[
                    styles.sectionSubtitle,
                    { color: themeColors.textSecondary },
                  ]}
                >
                  Akses cepat operasional dan manajemen toko
                </Text>
              </View>

              <View style={styles.quickMenuGrid}>
                {quickMenus.map((item) => {
                  const Icon = item.icon;
                  return (
                    <View key={item.name} style={styles.quickMenuItem}>
                      <PressableScale
                        onPress={() => navigation.navigate(item.screen)}
                        style={[
                          styles.quickMenuIcon,
                          {
                            backgroundColor: item.tileBg,
                            borderColor: item.tileBorder,
                          },
                        ]}
                      >
                        <Icon size={22} color={item.iconColor} />
                        {item.count ? (
                          <View style={styles.quickMenuBadge}>
                            <Text style={styles.quickMenuBadgeText}>{item.count}</Text>
                          </View>
                        ) : null}
                      </PressableScale>
                      <Text
                        style={[
                          styles.quickMenuLabel,
                          { color: themeColors.text },
                        ]}
                        numberOfLines={2}
                      >
                        {item.name}
                      </Text>
                    </View>
                  );
                })}
              </View>
            </View>
          </FadeInUp>

          {/* 6. Tips Promosi: Predominantly White Card with Soft Mint Tint */}
          {showRecommendation ? (
            <FadeInUp delay={240}>
              <View
                style={[
                  styles.recommendationBanner,
                  {
                    backgroundColor: isDark ? 'transparent' : '#FFFFFF',
                    borderColor: isDark ? 'rgba(209, 245, 232, 0.35)' : '#DCEADE',
                  },
                ]}
              >
                <LinearGradient
                  colors={themeColors.gradients.recommendation}
                  start={{ x: 0, y: 0 }}
                  end={{ x: 1, y: 1 }}
                  style={StyleSheet.absoluteFill}
                />
                <View
                  style={[
                    styles.cardTopSheen,
                    { backgroundColor: themeColors.cardSheen },
                  ]}
                />

                <PressableScale
                  onPress={() => setShowRecommendation(false)}
                  style={[
                    styles.recommendationClose,
                    {
                      backgroundColor: isDark
                        ? 'rgba(255, 255, 255, 0.15)'
                        : '#F0F4F1',
                    },
                  ]}
                  hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
                  accessibilityLabel="Tutup tips promosi"
                >
                  <X size={15} color={isDark ? '#D2E5D8' : '#5F7061'} />
                </PressableScale>

                <View style={styles.recommendationHeader}>
                  <View
                    style={[
                      styles.recommendationBadge,
                      {
                        backgroundColor: isDark ? '#ECF39E' : '#EAF5EE',
                        borderColor: isDark ? 'transparent' : '#C6E2D0',
                      },
                    ]}
                  >
                    <Sparkles size={11} color={isDark ? '#0B2E20' : '#2D6A4F'} />
                    <Text
                      style={[
                        styles.recommendationBadgeText,
                        { color: isDark ? '#0B2E20' : '#1E432E' },
                      ]}
                    >
                      TIPS MUSIM TANAM INDRAMAYU
                    </Text>
                  </View>
                </View>

                <Text
                  style={[
                    styles.recommendationTitle,
                    { color: isDark ? '#FFFFFF' : '#183326' },
                  ]}
                >
                  Tingkatkan Penjualan Pupuk NPK & Bionava Organik
                </Text>
                <Text
                  style={[
                    styles.recommendationDesc,
                    { color: isDark ? '#D2E5D8' : '#5F7061' },
                  ]}
                >
                  Musim tanam rendeng di wilayah pesisir Indramayu telah dimulai. Aktifkan voucher diskon ongkir untuk menarik kelompok tani mitra.
                </Text>

                <PressableScale
                  onPress={() => navigation.navigate('Promotions')}
                  style={styles.recommendationButton}
                >
                  <Text style={styles.recommendationBtnText}>Buat Voucher Diskon Sekarang</Text>
                </PressableScale>
              </View>
            </FadeInUp>
          ) : null}

          {/* 7. Peringatan Stok Menipis: Predominantly White Card */}
          <FadeInUp delay={280}>
            <View
              style={[
                styles.whiteCard,
                {
                  backgroundColor: themeColors.card,
                  borderColor: themeColors.cardBorder,
                },
              ]}
            >
              <View
                style={[
                  styles.cardTopSheen,
                  { backgroundColor: themeColors.cardSheen },
                ]}
              />
              <View style={styles.sectionHeaderRow}>
                <View style={styles.headerWithIcon}>
                  <AlertTriangle size={18} color="#F59E0B" />
                  <Text style={[styles.sectionTitle, { color: themeColors.text }]}>
                    PERINGATAN STOK MENIPIS
                  </Text>
                </View>
                <View style={styles.stockAlertBadge}>
                  <Text style={styles.stockAlertBadgeText}>{lowStockCount} Produk</Text>
                </View>
              </View>

              {products
                .filter((p) => p.stock <= p.minStockAlert)
                .slice(0, 3)
                .map((item, index, arr) => (
                  <View
                    key={item.id}
                    style={[
                      styles.stockItemRow,
                      {
                        borderBottomColor: themeColors.borderSubtle,
                      },
                      index === arr.length - 1 && styles.itemRowNoBorder,
                    ]}
                  >
                    <Image
                      source={resolveProductImage(item.image, item.name)}
                      style={[
                        styles.stockItemImg,
                        {
                          borderColor: themeColors.borderSubtle,
                          backgroundColor: isDark ? 'rgba(255, 255, 255, 0.08)' : '#F8FAF8',
                        },
                      ]}
                      resizeMode="cover"
                    />
                    <View style={styles.stockItemText}>
                      <Text
                        style={[
                          styles.stockItemName,
                          { color: themeColors.text },
                        ]}
                        numberOfLines={1}
                      >
                        {item.name}
                      </Text>
                      <Text
                        style={[
                          styles.stockItemSub,
                          { color: themeColors.textSecondary },
                        ]}
                      >
                        {item.category} · Sisa:{' '}
                        <Text style={styles.stockAlertText}>
                          {item.stock} {item.unit}
                        </Text>
                      </Text>
                    </View>
                    <PressableScale
                      onPress={() => navigation.navigate('Inventory')}
                      style={[
                        styles.restockBtn,
                        {
                          backgroundColor: isDark
                            ? 'rgba(64, 145, 108, 0.35)'
                            : '#EAF5EE',
                          borderColor: isDark
                            ? 'rgba(209, 245, 232, 0.35)'
                            : '#C6E2D0',
                        },
                      ]}
                    >
                      <Text
                        style={[
                          styles.restockBtnText,
                          { color: isDark ? '#D1F5E8' : '#2D6A4F' },
                        ]}
                      >
                        Restock
                      </Text>
                    </PressableScale>
                  </View>
                ))}
            </View>
          </FadeInUp>

          {/* 8. Pesanan Terbaru Masuk: Predominantly White Card */}
          <FadeInUp delay={320}>
            <View
              style={[
                styles.whiteCard,
                {
                  backgroundColor: themeColors.card,
                  borderColor: themeColors.cardBorder,
                },
              ]}
            >
              <View
                style={[
                  styles.cardTopSheen,
                  { backgroundColor: themeColors.cardSheen },
                ]}
              />
              <View style={styles.sectionHeaderRow}>
                <View style={styles.headerTitleLeft}>
                  <View style={styles.headerGreenDot} />
                  <Text style={[styles.sectionTitle, { color: themeColors.text }]}>
                    PESANAN TERBARU MASUK
                  </Text>
                </View>
                <PressableScale
                  onPress={() => navigation.navigate('Orders')}
                  style={styles.linkRow}
                >
                  <Text
                    style={[
                      styles.linkText,
                      { color: isDark ? '#D1F5E8' : '#2D6A4F' },
                    ]}
                  >
                    Lihat Semua
                  </Text>
                  <ChevronRight
                    size={14}
                    color={isDark ? '#D1F5E8' : '#2D6A4F'}
                  />
                </PressableScale>
              </View>

              {orders.slice(0, 3).map((order, index, arr) => (
                <PressableScale
                  key={order.id}
                  onPress={() => navigation.navigate('Orders')}
                  style={[
                    styles.recentOrderRow,
                    {
                      borderBottomColor: themeColors.borderSubtle,
                    },
                    index === arr.length - 1 && styles.itemRowNoBorder,
                  ]}
                >
                  <View style={styles.orderLeft}>
                    <Text
                      style={[
                        styles.orderNumber,
                        { color: themeColors.textMuted },
                      ]}
                    >
                      {order.orderNumber}
                    </Text>
                    <Text
                      style={[
                        styles.orderBuyer,
                        { color: themeColors.text },
                      ]}
                    >
                      {order.buyerName}
                    </Text>
                    <Text
                      style={[
                        styles.orderTotal,
                        { color: isDark ? '#ECF39E' : '#2D6A4F' },
                      ]}
                    >
                      {formatRupiah(order.totalAmount)}
                    </Text>
                  </View>
                  <View
                    style={[
                      styles.orderStatusBadge,
                      order.status === 'Selesai'
                        ? (isDark ? styles.statusSuccessDark : styles.statusSuccessLight)
                        : order.status === 'Diproses'
                        ? (isDark ? styles.statusBrandDark : styles.statusBrandLight)
                        : order.status === 'Dibatalkan'
                        ? (isDark ? styles.statusDangerDark : styles.statusDangerLight)
                        : (isDark ? styles.statusWarningDark : styles.statusWarningLight),
                    ]}
                  >
                    <Text
                      style={[
                        styles.orderStatusText,
                        order.status === 'Selesai'
                          ? (isDark ? styles.statusTextSuccessDark : styles.statusTextSuccessLight)
                          : order.status === 'Diproses'
                          ? (isDark ? styles.statusTextBrandDark : styles.statusTextBrandLight)
                          : order.status === 'Dibatalkan'
                          ? (isDark ? styles.statusTextDangerDark : styles.statusTextDangerLight)
                          : (isDark ? styles.statusTextWarningDark : styles.statusTextWarningLight),
                      ]}
                    >
                      {order.status}
                    </Text>
                  </View>
                </PressableScale>
              ))}
            </View>
          </FadeInUp>
        </ScrollView>
      </SafeAreaView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
  },
  content: {
    padding: 16,
    gap: 15,
  },
  // Ambient Soft Mint Orbs
  decorativeOrbTopRight: {
    position: 'absolute',
    top: -80,
    right: -100,
    width: 320,
    height: 320,
    borderRadius: 160,
    overflow: 'hidden',
    borderWidth: 1,
  },
  decorativeOrbMiddleLeft: {
    position: 'absolute',
    top: 320,
    left: -90,
    width: 260,
    height: 260,
    borderRadius: 130,
    overflow: 'hidden',
  },
  decorativeOrbBottomRight: {
    position: 'absolute',
    bottom: 120,
    right: -80,
    width: 300,
    height: 300,
    borderRadius: 150,
    overflow: 'hidden',
  },
  orbFill: {
    ...StyleSheet.absoluteFill,
  },
  // Universal Pure White Card
  whiteCard: {
    borderRadius: 22,
    borderWidth: 1.5,
    padding: 16,
    overflow: 'hidden',
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.05,
    shadowRadius: 12,
    elevation: 2,
    position: 'relative',
  },
  cardTopSheen: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 1.5,
  },
  // 1. Profile Hero Card (Soft Mint / White Glass Card)
  profileHeroCard: {
    borderRadius: 22,
    borderWidth: 1.5,
    padding: 16,
    overflow: 'hidden',
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 14,
    elevation: 3,
    position: 'relative',
  },
  headerTopBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 12,
  },
  headerActionRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 7,
  },
  actionCircleBtn: {
    width: 34,
    height: 34,
    borderRadius: 17,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
  },
  bellDot: {
    position: 'absolute',
    top: 5,
    right: 6,
    width: 7,
    height: 7,
    borderRadius: 3.5,
    backgroundColor: '#EF4444',
    borderWidth: 1.2,
    borderColor: '#FFFFFF',
  },
  profileHeroTop: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  profileHeroMain: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  avatarTouchable: {
    position: 'relative',
  },
  avatar: {
    width: 52,
    height: 52,
    borderRadius: 26,
    borderWidth: 2,
  },
  onlineBadge: {
    position: 'absolute',
    bottom: 1,
    right: 1,
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: '#32CD32',
    borderWidth: 2,
    borderColor: '#FFFFFF',
  },
  profileTextCol: {
    flex: 1,
    minWidth: 0,
  },
  ownerGreeting: {
    fontSize: 16,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    letterSpacing: -0.2,
    marginBottom: 2,
  },
  verifiedPill: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 12,
    borderWidth: 1,
  },
  verifiedPillText: {
    fontSize: 9.5,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
    letterSpacing: 0.4,
  },
  storeNameText: {
    fontSize: 13,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
    marginBottom: 3,
  },
  metaRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 5,
  },
  locationPill: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 3,
    flexShrink: 1,
    minWidth: 0,
  },
  locationText: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.regular,
    flexShrink: 1,
  },
  dotDivider: {
    fontSize: 11,
  },
  ratingText: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.medium,
    color: '#D97706',
    flexShrink: 0,
  },
  // Section Headers
  sectionHeaderRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 14,
  },
  sectionHeaderCol: {
    marginBottom: 14,
  },
  headerTitleLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  headerWithIcon: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 7,
  },
  headerGreenDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: '#32CD32',
  },
  sectionTitle: {
    fontSize: 12.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    letterSpacing: 0.5,
  },
  sectionSubtitle: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.regular,
    marginTop: 3,
    paddingLeft: 14,
  },
  linkRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 3,
  },
  linkText: {
    fontSize: 12,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  // 2. Order Fulfillment Pipeline (Soft Pastel Icon Boxes)
  pipelineGrid: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  pipelineCol: {
    alignItems: 'center',
    flex: 1,
  },
  pipelineIconBox: {
    width: 48,
    height: 48,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 6,
    position: 'relative',
    borderWidth: 1,
  },
  pipelineIconMintDark: {
    backgroundColor: 'rgba(64, 145, 108, 0.35)',
    borderColor: 'rgba(209, 245, 232, 0.35)',
  },
  pipelineIconMintLight: {
    backgroundColor: '#EAF5EE',
    borderColor: '#C6E2D0',
  },
  pipelineIconAmberDark: {
    backgroundColor: 'rgba(245, 158, 11, 0.25)',
    borderColor: 'rgba(245, 158, 11, 0.38)',
  },
  pipelineIconAmberLight: {
    backgroundColor: '#FEF9E7',
    borderColor: '#FDE68A',
  },
  pipelineIconRoseDark: {
    backgroundColor: 'rgba(239, 68, 68, 0.25)',
    borderColor: 'rgba(239, 68, 68, 0.38)',
  },
  pipelineIconRoseLight: {
    backgroundColor: '#FEF2F2',
    borderColor: '#FECDD3',
  },
  pipelineIconBlueDark: {
    backgroundColor: 'rgba(59, 130, 246, 0.25)',
    borderColor: 'rgba(59, 130, 246, 0.38)',
  },
  pipelineIconBlueLight: {
    backgroundColor: '#F0F7FF',
    borderColor: '#BAE6FD',
  },
  badgeIndicator: {
    position: 'absolute',
    top: -4,
    right: -4,
    backgroundColor: '#EF4444',
    borderRadius: 10,
    minWidth: 18,
    height: 18,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 4,
    borderWidth: 1.5,
    borderColor: '#FFFFFF',
  },
  badgeIndicatorText: {
    fontSize: 9.5,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
    color: '#FFFFFF',
  },
  pipelineCount: {
    fontSize: 16,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    marginBottom: 2,
  },
  pipelineLabel: {
    fontSize: 11,
    fontFamily: typography.fontFamily.medium,
    textAlign: 'center',
  },
  // 3. Saldo Centerpiece Card (Premium Green Gradient)
  balanceCardWrapper: {
    borderRadius: 22,
    borderWidth: 1.5,
    borderColor: 'rgba(209, 245, 232, 0.45)',
    overflow: 'hidden',
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.18,
    shadowRadius: 14,
    elevation: 6,
  },
  balanceCardGradient: {
    padding: 18,
    position: 'relative',
  },
  balanceTopGloss: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: '38%',
    backgroundColor: 'rgba(255, 255, 255, 0.12)',
  },
  balanceTop: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 7,
    marginBottom: 8,
  },
  balanceIconWrapper: {
    width: 26,
    height: 26,
    borderRadius: 13,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.35)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  balanceLabel: {
    fontSize: 11.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    color: '#D1F5E8',
    letterSpacing: 0.7,
  },
  arrowTopRight: {
    marginLeft: 'auto',
  },
  balanceValue: {
    fontSize: 27,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
    color: '#FFFFFF',
    letterSpacing: -0.5,
    marginBottom: 12,
  },
  balanceBottom: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  balanceSub: {
    fontSize: 12,
    fontFamily: typography.fontFamily.regular,
    color: '#D2E5D8',
  },
  withdrawButton: {
    backgroundColor: '#ECF39E',
    paddingHorizontal: 16,
    paddingVertical: 7,
    borderRadius: 20,
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.15,
    shadowRadius: 4,
    elevation: 2,
  },
  withdrawBtnText: {
    fontSize: 12.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    color: '#0B2E20',
  },
  // 4. Statistik 2-Column KPI (Pure White Cards)
  kpiRow: {
    flexDirection: 'row',
    gap: 12,
  },
  kpiCardHalf: {
    flex: 1,
    borderRadius: 20,
    borderWidth: 1.5,
    padding: 14,
    position: 'relative',
    overflow: 'hidden',
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
  },
  kpiHeaderRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  kpiMiniTitle: {
    fontSize: 11.5,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  kpiMiniIcon: {
    width: 26,
    height: 26,
    borderRadius: 13,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  kpiMainNumber: {
    fontSize: 19,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
    letterSpacing: -0.3,
    marginBottom: 6,
  },
  trendRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 5,
  },
  trendCapsule: {
    borderWidth: 1,
    borderRadius: 10,
    paddingHorizontal: 6,
    paddingVertical: 1.5,
  },
  trendGreen: {
    fontSize: 10.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  trendSub: {
    fontSize: 10.5,
    fontFamily: typography.fontFamily.regular,
  },
  trendNeutral: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
  },
  // 5. Menu Pengelolaan Toko (White Panel with Soft Pastel Tiles)
  quickMenuGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
    justifyContent: 'space-between',
  },
  quickMenuItem: {
    width: '22.5%',
    alignItems: 'center',
  },
  quickMenuIcon: {
    width: 52,
    height: 52,
    borderRadius: 18,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 6,
    position: 'relative',
    borderWidth: 1.2,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 5,
    elevation: 1,
  },
  quickMenuBadge: {
    position: 'absolute',
    top: -4,
    right: -4,
    backgroundColor: '#EF4444',
    borderRadius: 10,
    minWidth: 17,
    height: 17,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 3,
    borderWidth: 1.5,
    borderColor: '#FFFFFF',
  },
  quickMenuBadgeText: {
    fontSize: 9,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
    color: '#FFFFFF',
  },
  quickMenuLabel: {
    fontSize: 11,
    fontWeight: '600',
    fontFamily: typography.fontFamily.medium,
    textAlign: 'center',
    lineHeight: 14,
  },
  // 6. Tips Musim Tanam (Predominantly White Card)
  recommendationBanner: {
    borderRadius: 22,
    borderWidth: 1.5,
    padding: 16,
    position: 'relative',
    overflow: 'hidden',
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.05,
    shadowRadius: 12,
    elevation: 3,
  },
  recommendationClose: {
    position: 'absolute',
    top: 14,
    right: 14,
    width: 26,
    height: 26,
    borderRadius: 13,
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 2,
  },
  recommendationHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  recommendationBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 12,
    borderWidth: 1,
  },
  recommendationBadgeText: {
    fontSize: 9.5,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
    letterSpacing: 0.4,
  },
  recommendationTitle: {
    fontSize: 15,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    marginBottom: 6,
    lineHeight: 21,
    paddingRight: 24,
  },
  recommendationDesc: {
    fontSize: 12,
    fontFamily: typography.fontFamily.regular,
    lineHeight: 18,
    marginBottom: 14,
  },
  recommendationButton: {
    backgroundColor: '#2D6A4F',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: 'rgba(209, 245, 232, 0.4)',
    paddingVertical: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  recommendationBtnText: {
    fontSize: 12.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    color: '#FFFFFF',
  },
  // 7. Peringatan Stok Menipis (Predominantly White Card)
  stockAlertBadge: {
    backgroundColor: '#FEF3C7',
    borderWidth: 1,
    borderColor: '#FDE68A',
    borderRadius: 12,
    paddingHorizontal: 8,
    paddingVertical: 3,
  },
  stockAlertBadgeText: {
    fontSize: 10.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    color: '#B45309',
  },
  stockItemRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 10,
    borderBottomWidth: 1,
    gap: 12,
  },
  itemRowNoBorder: {
    borderBottomWidth: 0,
    paddingBottom: 0,
  },
  stockItemImg: {
    width: 48,
    height: 48,
    borderRadius: 14,
    borderWidth: 1,
  },
  stockItemText: {
    flex: 1,
  },
  stockItemName: {
    fontSize: 13,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
    marginBottom: 3,
  },
  stockItemSub: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.regular,
  },
  stockAlertText: {
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    color: '#D97706',
  },
  restockBtn: {
    borderWidth: 1,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 14,
  },
  restockBtnText: {
    fontSize: 11.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  // 8. Pesanan Terbaru (Predominantly White Card)
  recentOrderRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 10,
    borderBottomWidth: 1,
  },
  orderLeft: {
    gap: 2,
  },
  orderNumber: {
    fontSize: 11,
    fontFamily: typography.fontFamily.medium,
  },
  orderBuyer: {
    fontSize: 13,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  orderTotal: {
    fontSize: 13.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  orderStatusBadge: {
    paddingHorizontal: 9,
    paddingVertical: 3.5,
    borderRadius: 12,
    borderWidth: 1,
  },
  orderStatusText: {
    fontSize: 10.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  // Status badge styles: Light (Pastel) & Dark variants
  statusSuccessLight: {
    backgroundColor: '#EAF5EE',
    borderColor: '#C6E2D0',
  },
  statusTextSuccessLight: {
    color: '#1E432E',
  },
  statusSuccessDark: {
    backgroundColor: 'rgba(16, 185, 129, 0.22)',
    borderColor: 'rgba(16, 185, 129, 0.38)',
  },
  statusTextSuccessDark: {
    color: '#10B981',
  },
  statusBrandLight: {
    backgroundColor: '#E0F2FE',
    borderColor: '#BAE6FD',
  },
  statusTextBrandLight: {
    color: '#0369A1',
  },
  statusBrandDark: {
    backgroundColor: 'rgba(64, 145, 108, 0.25)',
    borderColor: 'rgba(64, 145, 108, 0.38)',
  },
  statusTextBrandDark: {
    color: '#40916C',
  },
  statusDangerLight: {
    backgroundColor: '#FEE2E2',
    borderColor: '#FECACA',
  },
  statusTextDangerLight: {
    color: '#B91C1C',
  },
  statusDangerDark: {
    backgroundColor: 'rgba(239, 68, 68, 0.22)',
    borderColor: 'rgba(239, 68, 68, 0.38)',
  },
  statusTextDangerDark: {
    color: '#EF4444',
  },
  statusWarningLight: {
    backgroundColor: '#FEF3C7',
    borderColor: '#FDE68A',
  },
  statusTextWarningLight: {
    color: '#B45309',
  },
  statusWarningDark: {
    backgroundColor: 'rgba(245, 158, 11, 0.22)',
    borderColor: 'rgba(245, 158, 11, 0.38)',
  },
  statusTextWarningDark: {
    color: '#D97706',
  },
});