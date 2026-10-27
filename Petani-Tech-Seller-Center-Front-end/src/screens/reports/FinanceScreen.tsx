import React, { useEffect, useState, useMemo } from 'react';
import {
  StyleSheet,
  Text,
  View,
  ScrollView,
  Modal,
  Alert,
  ActivityIndicator,
  RefreshControl,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { useFinanceStore } from '@/store/useFinanceStore';
import { useAuthStore } from '@/store/useAuthStore';
import { Card } from '@/components/cards/Card';
import { Button } from '@/components/common/Button';
import { Badge } from '@/components/common/Badge';
import { FilterChip, FilterChipGroup } from '@/components/common/FilterChip';
import { EmptyState } from '@/components/common/EmptyState';
import { FadeInUp, PressableScale } from '@/components/common/Motion';
import { Input } from '@/components/forms/Input';
import { formatRupiah } from '@/utils/formatters';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme/ThemeContext';
import { useBottomTabSpace } from '@/navigation/hooks';
import {
  Wallet,
  ArrowUpRight,
  ArrowDownLeft,
  Building2,
  Clock,
  X,
  Eye,
  EyeOff,
  ShieldCheck,
  TrendingUp,
  CheckCircle2,
  Receipt,
  RotateCw,
  Sparkles,
} from 'lucide-react-native';

type FilterType = 'all' | 'Penjualan' | 'Pencairan';

export function FinanceScreen() {
  const { colors: themeColors, isDark } = useTheme();
  const bottomSpace = useBottomTabSpace(28);

  const { summary, transactions, isLoading, fetchFinance, withdrawBalance } = useFinanceStore();
  const { user } = useAuthStore();

  const [isWithdrawModalOpen, setIsWithdrawModalOpen] = useState(false);
  const [withdrawAmount, setWithdrawAmount] = useState('2000000');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [filterType, setFilterType] = useState<FilterType>('all');
  const [isBalanceHidden, setIsBalanceHidden] = useState(false);

  useEffect(() => {
    fetchFinance();
  }, [fetchFinance]);

  const handleRefresh = async () => {
    setIsRefreshing(true);
    try {
      await fetchFinance();
    } finally {
      setIsRefreshing(false);
    }
  };

  const handleWithdraw = async () => {
    const num = Number(withdrawAmount);
    if (!withdrawAmount || isNaN(num) || num <= 0) {
      Alert.alert('Nominal Tidak Valid', 'Masukkan nominal penarikan dana yang valid.');
      return;
    }

    const available = summary?.availableBalance || 0;
    if (num > available) {
      Alert.alert(
        'Saldo Tidak Mencukupi',
        `Nominal penarikan (${formatRupiah(num)}) melebihi saldo tersedia (${formatRupiah(available)}).`
      );
      return;
    }

    setIsSubmitting(true);
    try {
      const bankName = user?.bankAccount?.bankName || 'Bank Rakyat Indonesia (BRI)';
      const accNumber = user?.bankAccount?.accountNumber || '4321-01-098765-53-2';
      const bankInfo = `${bankName} (${accNumber})`;

      await withdrawBalance(num, bankInfo);
      setIsWithdrawModalOpen(false);
      Alert.alert(
        'Penarikan Berhasil Diproses',
        `Pencairan dana ${formatRupiah(num)} sedang dikirim ke rekening ${bankInfo}. Saldo Anda telah diperbarui.`
      );
    } catch (err: unknown) {
      Alert.alert('Gagal Memproses Penarikan', err instanceof Error ? err.message : 'Terjadi kesalahan sistem.');
    } finally {
      setIsSubmitting(false);
    }
  };

  // Filter transactions
  const filteredTransactions = useMemo(() => {
    if (filterType === 'all') return transactions;
    return transactions.filter((tx) => tx.type === filterType);
  }, [transactions, filterType]);

  const salesCount = useMemo(
    () => transactions.filter((tx) => tx.type === 'Penjualan').length,
    [transactions]
  );
  const withdrawCount = useMemo(
    () => transactions.filter((tx) => tx.type === 'Pencairan').length,
    [transactions]
  );

  // Mask bank account number safely preserving real digits
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

  const availableBalanceDisplay = isBalanceHidden
    ? '••••••••'
    : formatRupiah(summary?.availableBalance ?? 8500000);

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
          <View style={styles.headerContentRow}>
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
                  KEUANGAN & DOMPET
                </Text>
              </View>
              <Text style={[styles.screenTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                Keuangan & Saldo
              </Text>
              <Text style={[styles.screenSubtitle, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                Pantau saldo hasil penjualan produk dan riwayat mutasi rekening
              </Text>
            </View>

            <PressableScale
              onPress={handleRefresh}
              disabled={isRefreshing || isLoading}
              style={[
                styles.refreshButton,
                {
                  backgroundColor: isDark ? 'rgba(209, 245, 232, 0.12)' : '#F2FBF5',
                  borderColor: isDark ? 'rgba(209, 245, 232, 0.20)' : '#DDE8E0',
                },
              ]}
              accessibilityLabel="Segarkan data keuangan"
            >
              {isRefreshing ? (
                <ActivityIndicator size="small" color={isDark ? themeColors.mint : themeColors.primary} />
              ) : (
                <RotateCw size={17} color={isDark ? themeColors.mint : themeColors.primary} />
              )}
            </PressableScale>
          </View>
        </View>
      </FadeInUp>

      {/* Scrollable Content */}
      <ScrollView
        contentContainerStyle={[styles.scrollContent, { paddingBottom: bottomSpace }]}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={isRefreshing}
            onRefresh={handleRefresh}
            colors={[themeColors.primary]}
            tintColor={themeColors.primary}
          />
        }
      >
        {/* 1. HERO BALANCE CARD (Saldo Tersedia Focal Point) */}
        <FadeInUp delay={50}>
          <View style={styles.heroCardContainer}>
            <LinearGradient
              colors={
                isDark
                  ? ['#143526', '#1D4533', '#275B44']
                  : ['#225A41', '#2D6E50', '#3D8C67']
              }
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={styles.heroCardGradient}
            >
              {/* Top Sheen */}
              <View style={styles.heroSheen} />

              {/* Header: Label + Eye Privacy Toggle */}
              <View style={styles.heroTopRow}>
                <View style={styles.heroLabelBox}>
                  <View style={styles.heroWalletIconWrap}>
                    <Wallet size={15} color="#D1F5E8" />
                  </View>
                  <Text style={styles.heroLabelText}>SALDO TERSEDIA</Text>
                </View>

                <PressableScale
                  onPress={() => setIsBalanceHidden(!isBalanceHidden)}
                  hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
                  style={styles.heroEyeButton}
                  accessibilityLabel="Sembunyikan saldo"
                >
                  {isBalanceHidden ? (
                    <EyeOff size={16} color="rgba(255, 255, 255, 0.85)" />
                  ) : (
                    <Eye size={16} color="rgba(255, 255, 255, 0.85)" />
                  )}
                </PressableScale>
              </View>

              {/* Main Balance Value */}
              <View style={styles.heroBalanceRow}>
                <Text
                  style={styles.heroBalanceValue}
                  numberOfLines={1}
                  adjustsFontSizeToFit
                >
                  {availableBalanceDisplay}
                </Text>
              </View>

              {/* Pending Balance Indicator (Context) */}
              {summary?.pendingBalance ? (
                <View style={styles.pendingRow}>
                  <Clock size={12} color="#D1F5E8" />
                  <Text style={styles.pendingText}>
                    {formatRupiah(summary.pendingBalance)} sedang diproses penyelesaian pesanan
                  </Text>
                </View>
              ) : null}

              {/* Tarik Saldo Primary Action */}
              <PressableScale
                onPress={() => setIsWithdrawModalOpen(true)}
                style={[
                  styles.withdrawHeroButton,
                  {
                    backgroundColor: isDark ? '#D1F5E8' : '#FFFFFF',
                  },
                ]}
              >
                <Text
                  style={[
                    styles.withdrawHeroButtonText,
                    { color: isDark ? '#143526' : '#1D4A34' },
                  ]}
                >
                  Tarik Saldo ke Rekening
                </Text>
                <View
                  style={[
                    styles.withdrawHeroIconCircle,
                    {
                      backgroundColor: isDark
                        ? 'rgba(20, 53, 38, 0.15)'
                        : 'rgba(29, 74, 52, 0.10)',
                    },
                  ]}
                >
                  <ArrowUpRight size={15} color={isDark ? '#143526' : '#1D4A34'} />
                </View>
              </PressableScale>
            </LinearGradient>
          </View>
        </FadeInUp>

        {/* 2. SUPPORTING FINANCIAL METRICS (Neutral Clean Cards) */}
        <FadeInUp delay={90}>
          <View style={styles.metricsRow}>
            {/* Card 1: Pendapatan Bulan Ini */}
            <Card
              sheen
              variant="elevated"
              style={[
                styles.metricCard,
                {
                  backgroundColor: isDark ? 'rgba(22, 58, 38, 0.70)' : '#FFFFFF',
                  borderColor: isDark ? 'rgba(209, 245, 232, 0.18)' : '#DDE8E0',
                },
              ]}
            >
              <View style={styles.metricTop}>
                <View
                  style={[
                    styles.metricIconWrap,
                    {
                      backgroundColor: isDark
                        ? 'rgba(64, 145, 108, 0.22)'
                        : '#EAF4EE',
                    },
                  ]}
                >
                  <TrendingUp size={16} color={isDark ? themeColors.mint : themeColors.primary} />
                </View>
                <View
                  style={[
                    styles.trendBadge,
                    {
                      backgroundColor: isDark
                        ? 'rgba(64, 145, 108, 0.25)'
                        : '#EAF4EE',
                    },
                  ]}
                >
                  <Text
                    style={[
                      styles.trendBadgeText,
                      { color: isDark ? '#D1F5E8' : '#2D6A4F' },
                    ]}
                  >
                    +18.4%
                  </Text>
                </View>
              </View>

              <Text style={[styles.metricLabel, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                Pendapatan Bulan Ini
              </Text>
              <Text
                style={[styles.metricValue, { color: isDark ? '#FFFFFF' : '#183326' }]}
                numberOfLines={1}
                adjustsFontSizeToFit
              >
                {formatRupiah(summary?.monthlyRevenue || 15200000)}
              </Text>
              <Text style={[styles.metricSubtext, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                Dari transaksi pesanan selesai
              </Text>
            </Card>

            {/* Card 2: Total Sudah Ditarik */}
            <Card
              sheen
              variant="elevated"
              style={[
                styles.metricCard,
                {
                  backgroundColor: isDark ? 'rgba(22, 58, 38, 0.70)' : '#FFFFFF',
                  borderColor: isDark ? 'rgba(209, 245, 232, 0.18)' : '#DDE8E0',
                },
              ]}
            >
              <View style={styles.metricTop}>
                <View
                  style={[
                    styles.metricIconWrap,
                    {
                      backgroundColor: isDark
                        ? 'rgba(209, 245, 232, 0.15)'
                        : '#F2FBF5',
                    },
                  ]}
                >
                  <CheckCircle2 size={16} color={isDark ? themeColors.mint : '#40916C'} />
                </View>
                <View
                  style={[
                    styles.statusPill,
                    {
                      backgroundColor: isDark
                        ? 'rgba(255, 255, 255, 0.08)'
                        : '#F4F7F2',
                    },
                  ]}
                >
                  <Text
                    style={[
                      styles.statusPillText,
                      { color: isDark ? '#D1F5E8' : '#64746A' },
                    ]}
                  >
                    Mutasi Bank
                  </Text>
                </View>
              </View>

              <Text style={[styles.metricLabel, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                Total Sudah Ditarik
              </Text>
              <Text
                style={[styles.metricValue, { color: isDark ? '#FFFFFF' : '#183326' }]}
                numberOfLines={1}
                adjustsFontSizeToFit
              >
                {formatRupiah(summary?.totalWithdrawn || 34500000)}
              </Text>
              <Text style={[styles.metricSubtext, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                Berhasil ditransfer ke rekening
              </Text>
            </Card>
          </View>
        </FadeInUp>

        {/* 3. REGISTERED PAYOUT ACCOUNT (Clean & Trustworthy) */}
        <FadeInUp delay={130}>
          <Card
            sheen
            variant="elevated"
            style={[
              styles.payoutCard,
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
                      backgroundColor: isDark
                        ? 'rgba(64, 145, 108, 0.22)'
                        : '#EAF4EE',
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

              {/* Verification Status Badge */}
              <Badge variant="brand" size="sm" dot>
                Terverifikasi
              </Badge>
            </View>

            {/* Account Details Box */}
            <View
              style={[
                styles.payoutDetailBox,
                {
                  backgroundColor: isDark
                    ? 'rgba(11, 32, 20, 0.65)'
                    : '#FAF9F6',
                  borderColor: isDark
                    ? 'rgba(209, 245, 232, 0.12)'
                    : '#EDF2EE',
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

        {/* 4. TRANSACTION HISTORY SECTION */}
        <FadeInUp delay={170}>
          <View style={styles.txSectionHeader}>
            <View style={styles.txTitleRow}>
              <Text style={[styles.txSectionTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                Riwayat Transaksi
              </Text>
              <View
                style={[
                  styles.txCountBadge,
                  {
                    backgroundColor: isDark
                      ? 'rgba(209, 245, 232, 0.15)'
                      : '#EAF4EE',
                  },
                ]}
              >
                <Text
                  style={[
                    styles.txCountText,
                    { color: isDark ? themeColors.mint : themeColors.primary },
                  ]}
                >
                  {filteredTransactions.length}
                </Text>
              </View>
            </View>
          </View>

          {/* Filter Chips */}
          <FilterChipGroup style={styles.filterChipGroup} contentContainerStyle={styles.filterChipContent}>
            <FilterChip
              label="Semua"
              count={transactions.length}
              selected={filterType === 'all'}
              onPress={() => setFilterType('all')}
              size="sm"
            />
            <FilterChip
              label="Penjualan"
              count={salesCount}
              selected={filterType === 'Penjualan'}
              onPress={() => setFilterType('Penjualan')}
              size="sm"
            />
            <FilterChip
              label="Pencairan"
              count={withdrawCount}
              selected={filterType === 'Pencairan'}
              onPress={() => setFilterType('Pencairan')}
              size="sm"
            />
          </FilterChipGroup>
        </FadeInUp>

        {/* Transactions List */}
        {isLoading && transactions.length === 0 ? (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color={themeColors.primary} />
            <Text style={[styles.loadingText, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
              Memuat mutasi keuangan...
            </Text>
          </View>
        ) : filteredTransactions.length === 0 ? (
          <EmptyState
            variant="transactions"
            title="Belum Ada Transaksi"
            description="Riwayat transaksi penjualan dan mutasi pencairan akan otomatis tercatat di sini."
          />
        ) : (
          filteredTransactions.map((tx, index) => {
            const isNegative = tx.amount < 0;
            const isPenjualan = tx.type === 'Penjualan';
            const isPencairan = tx.type === 'Pencairan';

            return (
              <FadeInUp key={tx.id} delay={190 + Math.min(index, 6) * 35}>
                <Card
                  sheen
                  variant="elevated"
                  style={[
                    styles.txCard,
                    {
                      backgroundColor: isDark ? 'rgba(22, 58, 38, 0.65)' : '#FFFFFF',
                      borderColor: isDark ? 'rgba(209, 245, 232, 0.16)' : '#DDE8E0',
                    },
                  ]}
                >
                  <View style={styles.txRow}>
                    {/* Left: Directional Icon Box */}
                    <View
                      style={[
                        styles.txIconBox,
                        {
                          backgroundColor: isPenjualan
                            ? isDark
                              ? 'rgba(64, 145, 108, 0.25)'
                              : '#EAF4EE'
                            : isPencairan
                            ? isDark
                              ? 'rgba(239, 68, 68, 0.18)'
                              : '#FEF2F2'
                            : isDark
                            ? 'rgba(255, 255, 255, 0.08)'
                            : '#F1F5F9',
                        },
                      ]}
                    >
                      {isPenjualan ? (
                        <ArrowDownLeft size={16} color={isDark ? themeColors.mint : '#2D6A4F'} />
                      ) : isPencairan ? (
                        <ArrowUpRight size={16} color={isDark ? '#F87171' : '#DC2626'} />
                      ) : tx.type === 'Cashback Promo' ? (
                        <Sparkles size={16} color={isDark ? themeColors.mint : '#0D9488'} />
                      ) : (
                        <Receipt size={16} color={isDark ? '#94A3B8' : '#475569'} />
                      )}
                    </View>

                    {/* Middle: Description & Metadata */}
                    <View style={styles.txInfoCol}>
                      <Text
                        style={[styles.txTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}
                        numberOfLines={1}
                      >
                        {tx.description}
                      </Text>

                      <View style={styles.txMetaRow}>
                        <Clock size={11} color={isDark ? '#8BA899' : '#7E9180'} />
                        <Text style={[styles.txDateText, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                          {tx.date}
                        </Text>
                        <Text style={[styles.txDividerBullet, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                          •
                        </Text>
                        <Text style={[styles.txRefText, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                          Ref: {tx.referenceNo}
                        </Text>
                      </View>
                    </View>

                    {/* Right: Amount & Status Badge */}
                    <View style={styles.txRightCol}>
                      <Text
                        style={[
                          styles.txAmountText,
                          {
                            color: isNegative
                              ? isDark
                                ? '#F87171'
                                : '#DC2626'
                              : isDark
                              ? themeColors.mint
                              : '#2D6A4F',
                          },
                        ]}
                      >
                        {isNegative ? '-' : '+'}{formatRupiah(Math.abs(tx.amount))}
                      </Text>

                      <Badge
                        variant={
                          tx.status === 'Berhasil'
                            ? 'brand'
                            : tx.status === 'Diproses'
                            ? 'warning'
                            : 'danger'
                        }
                        size="sm"
                      >
                        {tx.status}
                      </Badge>
                    </View>
                  </View>
                </Card>
              </FadeInUp>
            );
          })
        )}
      </ScrollView>

      {/* 5. WITHDRAWAL MODAL (Tarik Saldo ke Rekening) */}
      <Modal
        visible={isWithdrawModalOpen}
        transparent
        animationType="fade"
        onRequestClose={() => {
          if (!isSubmitting) setIsWithdrawModalOpen(false);
        }}
      >
        <View style={styles.modalOverlay}>
          <View
            style={[
              styles.modalCard,
              {
                backgroundColor: isDark ? '#163A26' : '#FFFFFF',
                borderColor: isDark ? 'rgba(209, 245, 232, 0.22)' : '#DDE8E0',
              },
            ]}
          >
            {/* Modal Header */}
            <View style={styles.modalHeaderRow}>
              <View style={styles.modalHeaderTitleCol}>
                <Text style={[styles.modalTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                  Tarik Saldo ke Rekening
                </Text>
                <Text style={[styles.modalSubtitle, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                  Pencairan dana langsung diproses ke rekening tujuan
                </Text>
              </View>
              <PressableScale
                onPress={() => setIsWithdrawModalOpen(false)}
                disabled={isSubmitting}
                hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
                style={[
                  styles.modalCloseBtn,
                  {
                    backgroundColor: isDark ? 'rgba(255, 255, 255, 0.10)' : '#F2FBF5',
                  },
                ]}
                accessibilityLabel="Tutup modal penarikan"
              >
                <X size={18} color={isDark ? '#D1F5E8' : '#64746A'} />
              </PressableScale>
            </View>

            {/* Available Balance Indicator */}
            <View
              style={[
                styles.modalBalanceBanner,
                {
                  backgroundColor: isDark ? 'rgba(64, 145, 108, 0.18)' : '#EAF4EE',
                  borderColor: isDark ? 'rgba(209, 245, 232, 0.25)' : '#C3DBC7',
                },
              ]}
            >
              <View style={styles.modalBalanceLabelRow}>
                <Wallet size={14} color={isDark ? themeColors.mint : themeColors.primary} />
                <Text style={[styles.modalBalanceLabel, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                  Saldo Tersedia Saat Ini:
                </Text>
              </View>
              <Text
                style={[
                  styles.modalBalanceAmount,
                  { color: isDark ? themeColors.mint : '#183D2A' },
                ]}
              >
                {formatRupiah(summary?.availableBalance || 0)}
              </Text>
            </View>

            {/* Input Nominal Penarikan */}
            <Input
              label="Nominal Penarikan (Rp)"
              value={withdrawAmount}
              onChangeText={setWithdrawAmount}
              keyboardType="numeric"
              placeholder="Contoh: 1000000"
              hint="Minimal penarikan dana Rp 50.000"
            />

            {/* Quick Amount Chips */}
            <View style={styles.quickAmountRow}>
              {[500000, 1000000, 2000000, summary?.availableBalance || 0].map((amt, idx) => {
                const label = idx === 3 ? 'Semua Saldo' : `${amt / 1000}rb`;
                const isSelected = withdrawAmount === String(amt);

                return (
                  <PressableScale
                    key={idx}
                    onPress={() => setWithdrawAmount(String(amt))}
                    style={[
                      styles.quickChip,
                      {
                        backgroundColor: isSelected
                          ? isDark
                            ? 'rgba(64, 145, 108, 0.35)'
                            : '#D1F5E8'
                          : isDark
                          ? 'rgba(255, 255, 255, 0.08)'
                          : '#FAF9F6',
                        borderColor: isSelected
                          ? isDark
                            ? themeColors.mint
                            : '#40916C'
                          : isDark
                          ? 'rgba(209, 245, 232, 0.18)'
                          : '#E6EDE7',
                      },
                    ]}
                  >
                    <Text
                      style={[
                        styles.quickChipText,
                        {
                          color: isSelected
                            ? isDark
                              ? '#FFFFFF'
                              : '#183D2A'
                            : isDark
                            ? '#FFFFFF'
                            : '#183326',
                          fontFamily: isSelected
                            ? typography.fontFamily.bold
                            : typography.fontFamily.medium,
                        },
                      ]}
                    >
                      {label}
                    </Text>
                  </PressableScale>
                );
              })}
            </View>

            {/* Target Account Summary Box */}
            <View
              style={[
                styles.modalBankBox,
                {
                  backgroundColor: isDark ? 'rgba(11, 32, 20, 0.70)' : '#FAF9F6',
                  borderColor: isDark ? 'rgba(209, 245, 232, 0.14)' : '#EDF2EE',
                },
              ]}
            >
              <View style={styles.modalBankHeader}>
                <Building2 size={15} color={isDark ? themeColors.mint : themeColors.primary} />
                <Text style={[styles.modalBankTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                  {user?.bankAccount?.bankName || 'Bank Rakyat Indonesia (BRI)'}
                </Text>
              </View>
              <Text style={[styles.modalBankAcc, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                {maskedAccountNumber} • a.n. {user?.bankAccount?.accountHolder || user?.name || 'Mitra Penjual'}
              </Text>
              <Text style={[styles.modalBankGuarantee, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                ✓ Transfer otomatis diproses dalam 1-5 menit
              </Text>
            </View>

            {/* Action Buttons */}
            <View style={styles.modalActionRow}>
              <Button
                variant="ghost"
                size="md"
                onPress={() => setIsWithdrawModalOpen(false)}
                disabled={isSubmitting}
                style={styles.modalCancelBtn}
              >
                Batal
              </Button>
              <Button
                variant="primary"
                size="md"
                onPress={handleWithdraw}
                isLoading={isSubmitting}
                style={styles.modalSubmitBtn}
              >
                Konfirmasi Penarikan
              </Button>
            </View>
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
  headerContentRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 12,
  },
  titleCol: {
    flex: 1,
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
  refreshButton: {
    width: 38,
    height: 38,
    borderRadius: 12,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  scrollContent: {
    padding: 16,
    gap: 16,
  },

  // 1. Hero Balance Card
  heroCardContainer: {
    borderRadius: 24,
    overflow: 'hidden',
    shadowColor: '#183D2A',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.22,
    shadowRadius: 14,
    elevation: 5,
  },
  heroCardGradient: {
    padding: 20,
    gap: 14,
    position: 'relative',
  },
  heroSheen: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 1.5,
    backgroundColor: 'rgba(255, 255, 255, 0.22)',
  },
  heroTopRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  heroLabelBox: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  heroWalletIconWrap: {
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: 'rgba(255, 255, 255, 0.16)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  heroLabelText: {
    fontSize: 11,
    fontFamily: typography.fontFamily.bold,
    color: '#D1F5E8',
    letterSpacing: 0.8,
  },
  heroEyeButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: 'rgba(255, 255, 255, 0.14)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  heroBalanceRow: {
    paddingVertical: 2,
  },
  heroBalanceValue: {
    fontSize: 30,
    fontFamily: typography.fontFamily.extrabold,
    color: '#FFFFFF',
    letterSpacing: -0.6,
  },
  pendingRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    backgroundColor: 'rgba(255, 255, 255, 0.12)',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 8,
    alignSelf: 'flex-start',
  },
  pendingText: {
    fontSize: 11,
    fontFamily: typography.fontFamily.medium,
    color: '#D1F5E8',
  },
  withdrawHeroButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    backgroundColor: '#D1F5E8',
    paddingVertical: 13,
    paddingHorizontal: 18,
    borderRadius: 16,
    marginTop: 4,
  },
  withdrawHeroButtonText: {
    fontSize: 13.5,
    fontFamily: typography.fontFamily.bold,
    color: '#183D2A',
    letterSpacing: -0.2,
  },
  withdrawHeroIconCircle: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: 'rgba(24, 61, 42, 0.12)',
    alignItems: 'center',
    justifyContent: 'center',
  },

  // 2. Metrics Row
  metricsRow: {
    flexDirection: 'row',
    gap: 12,
  },
  metricCard: {
    flex: 1,
    padding: 14,
    gap: 4,
    borderRadius: 20,
    borderWidth: 1.5,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
    overflow: 'hidden',
  },
  metricTop: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 6,
  },
  metricIconWrap: {
    width: 32,
    height: 32,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  trendBadge: {
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 9999,
  },
  trendBadgeText: {
    fontSize: 11,
    fontFamily: typography.fontFamily.bold,
  },
  statusPill: {
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 9999,
  },
  statusPillText: {
    fontSize: 10.5,
    fontFamily: typography.fontFamily.semibold,
  },
  metricLabel: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.medium,
  },
  metricValue: {
    fontSize: 16,
    fontFamily: typography.fontFamily.extrabold,
    letterSpacing: -0.3,
  },
  metricSubtext: {
    fontSize: 10.5,
    fontFamily: typography.fontFamily.regular,
    marginTop: 2,
  },

  // 3. Payout Card
  payoutCard: {
    padding: 16,
    borderRadius: 20,
    borderWidth: 1.5,
    gap: 12,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
    overflow: 'hidden',
  },
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

  // 4. Transaction History
  txSectionHeader: {
    paddingTop: 4,
  },
  txTitleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  txSectionTitle: {
    fontSize: 15,
    fontFamily: typography.fontFamily.bold,
    letterSpacing: -0.2,
  },
  txCountBadge: {
    paddingHorizontal: 9,
    paddingVertical: 3,
    borderRadius: 9999,
  },
  txCountText: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.bold,
  },
  filterChipGroup: {
    marginHorizontal: -16,
  },
  filterChipContent: {
    paddingHorizontal: 16,
    gap: 8,
  },
  txCard: {
    padding: 14,
    borderRadius: 18,
    borderWidth: 1.5,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.04,
    shadowRadius: 8,
    elevation: 2,
    overflow: 'hidden',
  },
  txRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  txIconBox: {
    width: 38,
    height: 38,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  txInfoCol: {
    flex: 1,
    gap: 3,
  },
  txTitle: {
    fontSize: 12.5,
    fontFamily: typography.fontFamily.bold,
    letterSpacing: -0.2,
  },
  txMetaRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 5,
  },
  txDateText: {
    fontSize: 10.5,
    fontFamily: typography.fontFamily.regular,
  },
  txDividerBullet: {
    fontSize: 10,
  },
  txRefText: {
    fontSize: 10.5,
    fontFamily: typography.fontFamily.medium,
  },
  txRightCol: {
    alignItems: 'flex-end',
    gap: 4,
  },
  txAmountText: {
    fontSize: 13.5,
    fontFamily: typography.fontFamily.bold,
    letterSpacing: -0.2,
  },
  loadingContainer: {
    paddingVertical: 36,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
  },
  loadingText: {
    fontSize: 12.5,
    fontFamily: typography.fontFamily.medium,
  },

  // 5. Modal
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(24, 51, 38, 0.55)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 18,
  },
  modalCard: {
    width: '100%',
    maxWidth: 420,
    borderRadius: 24,
    padding: 20,
    borderWidth: 1.5,
    gap: 14,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.22,
    shadowRadius: 20,
    elevation: 8,
    overflow: 'hidden',
  },
  modalHeaderRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
    gap: 10,
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
  modalSubtitle: {
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
  modalBalanceBanner: {
    padding: 12,
    borderRadius: 14,
    borderWidth: 1,
    gap: 4,
  },
  modalBalanceLabelRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  modalBalanceLabel: {
    fontSize: 11,
    fontFamily: typography.fontFamily.medium,
  },
  modalBalanceAmount: {
    fontSize: 18,
    fontFamily: typography.fontFamily.extrabold,
    letterSpacing: -0.3,
  },
  quickAmountRow: {
    flexDirection: 'row',
    gap: 8,
  },
  quickChip: {
    flex: 1,
    paddingVertical: 8,
    borderRadius: 12,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  quickChipText: {
    fontSize: 11,
  },
  modalBankBox: {
    padding: 12,
    borderRadius: 14,
    borderWidth: 1,
    gap: 4,
  },
  modalBankHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  modalBankTitle: {
    fontSize: 12.5,
    fontFamily: typography.fontFamily.bold,
  },
  modalBankAcc: {
    fontSize: 11,
    fontFamily: typography.fontFamily.medium,
  },
  modalBankGuarantee: {
    fontSize: 10.5,
    fontFamily: typography.fontFamily.medium,
    marginTop: 2,
  },
  modalActionRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    marginTop: 4,
  },
  modalCancelBtn: {
    flex: 1,
  },
  modalSubmitBtn: {
    flex: 2,
  },
});