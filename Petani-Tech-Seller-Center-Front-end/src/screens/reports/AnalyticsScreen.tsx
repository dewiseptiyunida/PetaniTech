import React, { useState, useEffect } from 'react';
import {
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  ScrollView,
  ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { analyticsService } from '@/services/analyticsService';
import { AnalyticsSummary } from '@/types';
import { Card } from '@/components/cards/Card';
import { StatCard } from '@/components/cards/StatCard';
import { Badge } from '@/components/common/Badge';
import { formatRupiah, formatNumber } from '@/constants';
import { colors } from '@/theme/colors';
import { useTheme } from '@/theme';
import { useBottomTabSpace } from '@/navigation/hooks';
import { FadeInUp } from '@/components/common/Motion';
import {
  Users,
  TrendingUp,
  ShoppingCart,
  DollarSign,
  BarChart3,
} from 'lucide-react-native';

export function AnalyticsScreen() {
  const { themeColors, isDarkMode } = useTheme();
  const bottomSpace = useBottomTabSpace(28);
  const [data, setData] = useState<AnalyticsSummary | null>(null);
  const [timeframe, setTimeframe] = useState<'daily' | 'weekly' | 'monthly'>('daily');
  const [metricView, setMetricView] = useState<'revenue' | 'orders'>('revenue');

  useEffect(() => {
    analyticsService.getAnalytics().then(setData);
  }, []);

  if (!data) {
    return (
      <SafeAreaView style={[styles.safeArea, { backgroundColor: themeColors.background }]}>
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={themeColors.primary} />
          <Text style={[styles.loadingText, { color: themeColors.textSecondary }]}>
            Memuat analitik performa toko...
          </Text>
        </View>
      </SafeAreaView>
    );
  }

  const currentChartData =
    timeframe === 'daily'
      ? data.dailyData
      : timeframe === 'weekly'
      ? data.weeklyData
      : data.monthlyData;

  const maxVal = Math.max(
    ...currentChartData.map((d) => (metricView === 'revenue' ? d.penjualan : d.pesanan)),
    1
  );

  return (
    <SafeAreaView style={[styles.safeArea, { backgroundColor: themeColors.background }]} edges={['top']}>
      {/* Header */}
      <LinearGradient
        colors={themeColors.headerGradient}
        start={{ x: 0, y: 0 }}
        end={{ x: 0, y: 1 }}
        style={styles.header}
      >
        <View style={styles.titleCol}>
          <Text style={[styles.screenTitle, { color: themeColors.textPrimary }]}>Performa Toko</Text>
          <Text style={[styles.screenSubtitle, { color: themeColors.textSecondary }]}>
            Metrik penjualan produk pertanian dan konversi pembeli mitra
          </Text>
        </View>
      </LinearGradient>

      <ScrollView
        contentContainerStyle={[styles.scrollContent, { paddingBottom: bottomSpace }]}
        showsVerticalScrollIndicator={false}
      >
        {/* Timeframe Switcher */}
        <FadeInUp delay={40}>
          <View
            style={[
              styles.timeframeRow,
              {
                backgroundColor: themeColors.cardBackground,
                borderColor: themeColors.cardBorder,
              },
            ]}
          >
            {(['daily', 'weekly', 'monthly'] as const).map((t) => (
              <TouchableOpacity
                key={t}
                onPress={() => setTimeframe(t)}
                style={[
                  styles.timeframeBtn,
                  timeframe === t && { backgroundColor: themeColors.primary },
                ]}
                activeOpacity={0.75}
              >
                <Text
                  style={[
                    styles.timeframeBtnText,
                    { color: themeColors.textSecondary },
                    timeframe === t && styles.timeframeBtnTextActive,
                  ]}
                >
                  {t === 'daily' ? 'Harian (7 Hari)' : t === 'weekly' ? 'Mingguan' : 'Bulanan'}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </FadeInUp>

        {/* 4 Summary Stat Cards */}
        <FadeInUp delay={80}>
          <View style={styles.statsRow}>
            <StatCard
              title="Total Pendapatan"
              value={formatRupiah(data.summary.totalOrders * data.summary.averageOrderValue)}
              icon={DollarSign}
              iconBgColor={isDarkMode ? 'rgba(64,145,108,0.2)' : '#EAF4EE'}
              iconColor={themeColors.accent}
              trend={{ value: '+18.4%', isPositive: true }}
              style={styles.statCardHalf}
            />
            <StatCard
              title="Total Pesanan"
              value={`${data.summary.totalOrders} Pesanan`}
              icon={ShoppingCart}
              iconBgColor={isDarkMode ? 'rgba(37,99,235,0.18)' : '#EFF6FF'}
              iconColor="#3B82F6"
              trend={{ value: '+12%', isPositive: true }}
              style={styles.statCardHalf}
            />
          </View>
        </FadeInUp>

        <FadeInUp delay={120}>
          <View style={styles.statsRow}>
            <StatCard
              title="Pengunjung Toko"
              value={formatNumber(data.summary.totalVisitors)}
              icon={Users}
              iconBgColor={isDarkMode ? 'rgba(217,119,6,0.18)' : '#FFFBEB'}
              iconColor="#F59E0B"
              trend={{ value: '+24%', isPositive: true }}
              style={styles.statCardHalf}
            />
            <StatCard
              title="Tingkat Konversi"
              value={`${data.summary.conversionRate}%`}
              icon={TrendingUp}
              iconBgColor={isDarkMode ? 'rgba(64,145,108,0.2)' : '#EAF4EE'}
              iconColor={themeColors.accent}
              trend={{ value: '+1.8%', isPositive: true }}
              style={styles.statCardHalf}
            />
          </View>
        </FadeInUp>

        {/* Interactive Bar Chart Card */}
        <FadeInUp delay={160}>
          <Card
            style={[
              styles.chartCard,
              {
                backgroundColor: themeColors.cardBackground,
                borderColor: themeColors.cardBorder,
              },
            ]}
          >
          <View style={styles.chartHeader}>
            <View>
              <Text style={[styles.chartTitle, { color: themeColors.textPrimary }]}>
                Grafik Tren Penjualan
              </Text>
              <Text style={[styles.chartSub, { color: themeColors.textMuted }]}>
                {metricView === 'revenue' ? 'Omset Penjualan (Rp)' : 'Volume Jumlah Pesanan'}
              </Text>
            </View>

            <View
              style={[
                styles.metricSwitchRow,
                {
                  backgroundColor: isDarkMode
                    ? 'rgba(255,255,255,0.08)'
                    : '#F0F5F1',
                },
              ]}
            >
              <TouchableOpacity
                onPress={() => setMetricView('revenue')}
                style={[
                  styles.metricSwitchChip,
                  metricView === 'revenue' && {
                    backgroundColor: isDarkMode ? themeColors.surface : '#FFFFFF',
                  },
                ]}
                activeOpacity={0.75}
              >
                <Text
                  style={[
                    styles.metricSwitchText,
                    { color: themeColors.textMuted },
                    metricView === 'revenue' && {
                      color: themeColors.textPrimary,
                      fontWeight: '700',
                    },
                  ]}
                >
                  Omset
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                onPress={() => setMetricView('orders')}
                style={[
                  styles.metricSwitchChip,
                  metricView === 'orders' && {
                    backgroundColor: isDarkMode ? themeColors.surface : '#FFFFFF',
                  },
                ]}
                activeOpacity={0.75}
              >
                <Text
                  style={[
                    styles.metricSwitchText,
                    { color: themeColors.textMuted },
                    metricView === 'orders' && {
                      color: themeColors.textPrimary,
                      fontWeight: '700',
                    },
                  ]}
                >
                  Pesanan
                </Text>
              </TouchableOpacity>
            </View>
          </View>

          {/* Bar Chart Visualization */}
          <View style={styles.barChartContainer}>
            {currentChartData.map((item, idx) => {
              const val = metricView === 'revenue' ? item.penjualan : item.pesanan;
              const barHeightPct = Math.max(14, Math.round((val / maxVal) * 100));
              const label =
                'date' in item
                  ? (item as { date: string }).date
                  : 'week' in item
                  ? (item as { week: string }).week
                  : (item as { month: string }).month;

              return (
                <View key={idx} style={styles.barColumn}>
                  <Text style={[styles.barValueText, { color: themeColors.textMuted }]}>
                    {metricView === 'revenue' ? `${Math.round(val / 1000000)}jt` : val}
                  </Text>
                  <View
                    style={[
                      styles.barTrack,
                      {
                        backgroundColor: isDarkMode
                          ? 'rgba(255,255,255,0.08)'
                          : '#F0F5F1',
                      },
                    ]}
                  >
                    <View
                      style={[
                        styles.barFill,
                        {
                          height: `${barHeightPct}%`,
                          backgroundColor: themeColors.accent,
                        },
                      ]}
                    />
                  </View>
                  <Text style={[styles.barLabelText, { color: themeColors.textSecondary }]}>
                    {label}
                  </Text>
                </View>
              );
            })}
          </View>
        </Card>
        </FadeInUp>

        {/* Top Selling Products List */}
        <FadeInUp delay={200}>
          <Card
            style={[
              styles.topProductsCard,
              {
                backgroundColor: themeColors.cardBackground,
                borderColor: themeColors.cardBorder,
              },
            ]}
          >
            <View style={styles.topProductsHeader}>
              <BarChart3 size={18} color={themeColors.accent} />
              <Text style={[styles.topProductsTitle, { color: themeColors.textPrimary }]}>
                Produk Terlaris Bulan Ini
              </Text>
            </View>

            {data.topProducts.map((prod, idx) => (
              <View
                key={idx}
                style={[
                  styles.topProductRow,
                  { borderBottomColor: themeColors.divider },
                ]}
              >
                <View
                  style={[
                    styles.rankCircle,
                    {
                      backgroundColor: isDarkMode
                        ? 'rgba(64,145,108,0.2)'
                        : '#EAF4EE',
                    },
                  ]}
                >
                  <Text style={[styles.rankText, { color: themeColors.accent }]}>
                    {idx + 1}
                  </Text>
                </View>

                <View style={styles.topProductDetails}>
                  <Text style={[styles.topProductName, { color: themeColors.textPrimary }]}>
                    {prod.name}
                  </Text>
                  <Text style={[styles.topProductSub, { color: themeColors.textMuted }]}>
                    {prod.category} · Terjual {prod.soldCount} pcs
                  </Text>
                </View>

                <View style={styles.topProductRight}>
                  <Text style={[styles.topProductRevenue, { color: themeColors.accent }]}>
                    {formatRupiah(prod.revenue)}
                  </Text>
                  <Badge variant="brand" size="sm">
                    {`+${prod.growth}%`}
                  </Badge>
                </View>
              </View>
            ))}
          </Card>
        </FadeInUp>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#FAF9F6',
  },
  loadingContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 12,
  },
  loadingText: {
    color: colors.neutral[600],
    fontSize: 13,
    fontFamily: 'Poppins, sans-serif',
  },
  header: {
    paddingHorizontal: 16,
    paddingTop: 12,
    paddingBottom: 8,
  },
  titleCol: {
    gap: 2,
  },
  screenTitle: {
    fontSize: 20,
    fontWeight: '800',
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[900],
    letterSpacing: -0.3,
  },
  screenSubtitle: {
    fontSize: 12,
    color: colors.neutral[600],
    fontFamily: 'Poppins, sans-serif',
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 96,
    gap: 14,
  },
  timeframeRow: {
    flexDirection: 'row',
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E6EDE7',
    borderRadius: 16,
    padding: 4,
    gap: 4,
  },
  timeframeBtn: {
    flex: 1,
    paddingVertical: 8,
    borderRadius: 12,
    alignItems: 'center',
  },
  timeframeBtnActive: {
    backgroundColor: colors.primary.DEFAULT,
  },
  timeframeBtnText: {
    fontSize: 11,
    fontWeight: '600',
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[600],
  },
  timeframeBtnTextActive: {
    color: '#FFFFFF',
    fontWeight: '700',
  },
  statsRow: {
    flexDirection: 'row',
    gap: 10,
  },
  statCardHalf: {
    flex: 1,
  },
  chartCard: {
    padding: 18,
    gap: 14,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#E6EDE7',
    backgroundColor: '#FFFFFF',
  },
  chartHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  chartTitle: {
    fontSize: 14,
    fontWeight: '700',
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[900],
  },
  chartSub: {
    fontSize: 11,
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[500],
    marginTop: 1,
  },
  metricSwitchRow: {
    flexDirection: 'row',
    backgroundColor: '#F0F5F1',
    borderRadius: 10,
    padding: 2,
    gap: 2,
  },
  metricSwitchChip: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 8,
  },
  metricSwitchChipActive: {
    backgroundColor: '#FFFFFF',
    shadowColor: '#1B261D',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.08,
    shadowRadius: 2,
    elevation: 1,
  },
  metricSwitchText: {
    fontSize: 10,
    fontWeight: '600',
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[500],
  },
  metricSwitchTextActive: {
    color: colors.primary.dark,
    fontWeight: '700',
  },
  barChartContainer: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
    height: 160,
    paddingTop: 24,
    paddingBottom: 4,
  },
  barColumn: {
    flex: 1,
    alignItems: 'center',
    height: '100%',
    justifyContent: 'flex-end',
    gap: 4,
  },
  barValueText: {
    fontSize: 9.5,
    color: colors.neutral[500],
    fontFamily: 'Poppins, sans-serif',
    fontWeight: '600',
  },
  barTrack: {
    width: 22,
    height: 110,
    backgroundColor: '#F0F5F1',
    borderRadius: 8,
    overflow: 'hidden',
    justifyContent: 'flex-end',
  },
  barFill: {
    width: '100%',
    backgroundColor: colors.primary.DEFAULT,
    borderRadius: 8,
  },
  barLabelText: {
    fontSize: 9.5,
    color: colors.neutral[600],
    fontFamily: 'Poppins, sans-serif',
    fontWeight: '600',
  },
  topProductsCard: {
    padding: 18,
    gap: 12,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#E6EDE7',
    backgroundColor: '#FFFFFF',
  },
  topProductsHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    paddingBottom: 4,
  },
  topProductsTitle: {
    fontSize: 14,
    fontWeight: '700',
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[900],
  },
  topProductRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#F0F5F1',
  },
  rankCircle: {
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: '#EAF4EE',
    alignItems: 'center',
    justifyContent: 'center',
  },
  rankText: {
    fontSize: 11.5,
    fontWeight: '800',
    fontFamily: 'Poppins, sans-serif',
    color: colors.primary.dark,
  },
  topProductDetails: {
    flex: 1,
    gap: 2,
  },
  topProductName: {
    fontSize: 12.5,
    fontWeight: '700',
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[900],
  },
  topProductSub: {
    fontSize: 10.5,
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[500],
  },
  topProductRight: {
    alignItems: 'flex-end',
    gap: 4,
  },
  topProductRevenue: {
    fontSize: 12.5,
    fontWeight: '700',
    fontFamily: 'Poppins, sans-serif',
    color: colors.primary.DEFAULT,
  },
});