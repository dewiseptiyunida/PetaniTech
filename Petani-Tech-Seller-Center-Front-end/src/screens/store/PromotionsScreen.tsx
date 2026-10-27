import React, { useState, useEffect } from 'react';
import {
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  ScrollView,
  Modal,
  Alert,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { promotionService } from '@/services/promotionService';
import { Promotion, PromotionType } from '@/types';
import { Card } from '@/components/cards/Card';
import { Button } from '@/components/common/Button';
import { Badge } from '@/components/common/Badge';
import { EmptyState } from '@/components/common/EmptyState';
import { FadeInUp } from '@/components/common/Motion';
import { Input } from '@/components/forms/Input';
import { formatRupiah } from '@/constants';
import { colors } from '@/theme/colors';
import { useTheme } from '@/theme';
import { useBottomTabSpace } from '@/navigation/hooks';
import {
  Plus,
  Tag,
  Percent,
  Calendar,
  X,
  Flame,
} from 'lucide-react-native';

const PROMO_TYPES: PromotionType[] = ['Diskon Produk', 'Voucher', 'Campaign'];

export function PromotionsScreen() {
  const { themeColors, isDarkMode } = useTheme();
  const bottomSpace = useBottomTabSpace(28);
  const [promotions, setPromotions] = useState<Promotion[]>([]);
  const [activeTab, setActiveTab] = useState<'all' | 'Diskon Produk' | 'Voucher' | 'Campaign'>('all');
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);

  // Form states
  const [promoName, setPromoName] = useState('');
  const [promoType, setPromoType] = useState<PromotionType>('Diskon Produk');
  const [discountValue, setDiscountValue] = useState('20');
  const [minPurchase, setMinPurchase] = useState('100000');
  const [quota, setQuota] = useState('200');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const loadPromos = async () => {
    const list = await promotionService.getPromotions();
    setPromotions(list);
  };

  useEffect(() => {
    let isMounted = true;
    void promotionService.getPromotions().then((list) => {
      if (isMounted) {
        setPromotions(list);
      }
    });
    return () => {
      isMounted = false;
    };
  }, []);

  const handleCreatePromo = async () => {
    if (!promoName.trim() || !discountValue || !minPurchase) {
      Alert.alert('Perhatian', 'Lengkapi nama promosi dan nominal diskon.');
      return;
    }

    setIsSubmitting(true);
    try {
      await promotionService.createPromotion({
        name: promoName.trim(),
        type: promoType,
        discountType: 'percentage',
        discountValue: Number(discountValue),
        minPurchase: Number(minPurchase),
        startDate: 'Hari ini',
        endDate: '30 Hari kedepan',
        status: 'Aktif',
        targetCategory: 'Pupuk & Benih',
        totalQuota: Number(quota) || 100,
      });
      setIsCreateModalOpen(false);
      setPromoName('');
      await loadPromos();
      Alert.alert('Sukses', 'Promosi baru berhasil dibuat dan langsung aktif!');
    } catch (err: unknown) {
      Alert.alert('Gagal', err instanceof Error ? err.message : 'Gagal membuat promosi');
    } finally {
      setIsSubmitting(false);
    }
  };

  const filtered = promotions.filter((p) => {
    if (activeTab === 'all') return true;
    return p.type === activeTab;
  });

  const tabs: { key: 'all' | 'Diskon Produk' | 'Voucher' | 'Campaign'; label: string }[] = [
    { key: 'all', label: 'Semua' },
    { key: 'Diskon Produk', label: 'Diskon' },
    { key: 'Voucher', label: 'Voucher' },
    { key: 'Campaign', label: 'Campaign' },
  ];

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
          <Text style={[styles.screenTitle, { color: themeColors.textPrimary }]}>Promosi & Voucher</Text>
          <Text style={[styles.screenSubtitle, { color: themeColors.textSecondary }]}>
            Tingkatkan omset toko dengan diskon pupuk dan voucher subsidi ongkir
          </Text>
        </View>
        <Button
          variant="primary"
          size="sm"
          leftIcon={<Plus size={16} color="#FFFFFF" />}
          onPress={() => setIsCreateModalOpen(true)}
        >
          Buat
        </Button>
      </LinearGradient>

      {/* Tabs */}
      <View
        style={[
          styles.tabsContainer,
          {
            backgroundColor: themeColors.background,
            borderBottomColor: themeColors.divider,
          },
        ]}
      >
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.tabsContent}
        >
          {tabs.map((tab) => {
            const isActive = activeTab === tab.key;
            return (
              <TouchableOpacity
                key={tab.key}
                onPress={() => setActiveTab(tab.key)}
                style={[
                  styles.tabChip,
                  {
                    backgroundColor: themeColors.cardBackground,
                    borderColor: themeColors.cardBorder,
                  },
                  isActive && {
                    backgroundColor: themeColors.primary,
                    borderColor: themeColors.primary,
                  },
                ]}
                activeOpacity={0.75}
              >
                <Text
                  style={[
                    styles.tabChipText,
                    { color: themeColors.textSecondary },
                    isActive && styles.tabChipTextActive,
                  ]}
                >
                  {tab.label}
                </Text>
              </TouchableOpacity>
            );
          })}
        </ScrollView>
      </View>

      <ScrollView
        contentContainerStyle={[styles.scrollContent, { paddingBottom: bottomSpace }]}
        showsVerticalScrollIndicator={false}
      >
        {/* Banner Promo Musim Tanam */}
        <FadeInUp delay={30}>
          <Card style={styles.bannerCard}>
            <View style={styles.bannerIconBox}>
              <Flame size={20} color="#FFFFFF" />
            </View>
            <View style={styles.bannerText}>
              <Text style={styles.bannerTitle}>Campaign Musim Tanam Rendeng</Text>
              <Text style={styles.bannerSub}>
                Subsidi komisi 1% untuk produk benih dan pupuk organik wilayah Indramayu & Pantura.
              </Text>
            </View>
          </Card>
        </FadeInUp>

        {/* Promo Cards List */}
        {filtered.length === 0 ? (
          <EmptyState
            variant="default"
            title="Belum Ada Promosi"
            description="Buat program diskon atau voucher belanja untuk menarik lebih banyak pembeli."
            action={{
              label: 'Buat Promosi Baru',
              onPress: () => setIsCreateModalOpen(true),
            }}
          />
        ) : (
          filtered.map((promo, index) => {
            const usagePercent = promo.totalQuota
              ? Math.min(100, Math.round((promo.usedCount / promo.totalQuota) * 100))
              : 0;

            return (
              <FadeInUp key={promo.id} delay={70 + Math.min(index, 6) * 35}>
                <Card
                  style={[
                    styles.promoCard,
                    {
                      backgroundColor: themeColors.cardBackground,
                      borderColor: themeColors.cardBorder,
                    },
                  ]}
                >
                <View style={styles.promoHeader}>
                  <View style={styles.promoHeaderLeft}>
                    <View
                      style={[
                        styles.promoTypeTag,
                        {
                          backgroundColor: isDarkMode
                            ? 'rgba(64, 145, 108, 0.2)'
                            : '#EAF4EE',
                        },
                      ]}
                    >
                      <Tag size={12} color={themeColors.accent} />
                      <Text style={[styles.promoTypeText, { color: themeColors.accent }]}>
                        {promo.type}
                      </Text>
                    </View>
                    <Text style={[styles.promoName, { color: themeColors.textPrimary }]}>
                      {promo.name}
                    </Text>
                  </View>
                  <Badge
                    variant={promo.status === 'Aktif' ? 'brand' : 'neutral'}
                    size="sm"
                  >
                    {promo.status}
                  </Badge>
                </View>

                {/* Promo Details */}
                <View style={styles.promoDetailsRow}>
                  <View
                    style={[
                      styles.discountBadge,
                      {
                        backgroundColor: isDarkMode
                          ? 'rgba(64, 145, 108, 0.2)'
                          : '#EAF4EE',
                      },
                    ]}
                  >
                    <Percent size={14} color={themeColors.accent} />
                    <Text style={[styles.discountText, { color: themeColors.accent }]}>
                      Diskon {promo.discountValue}%
                    </Text>
                  </View>

                  <Text style={[styles.minPurchaseText, { color: themeColors.textSecondary }]}>
                    Min. Belanja {formatRupiah(promo.minPurchase || 0)}
                  </Text>
                </View>

                {/* Quota Progress */}
                <View style={styles.quotaSection}>
                  <View style={styles.quotaHeader}>
                    <Text style={[styles.quotaLabel, { color: themeColors.textMuted }]}>
                      Kuota Terpakai
                    </Text>
                    <Text style={[styles.quotaValue, { color: themeColors.textPrimary }]}>
                      {promo.usedCount} / {promo.totalQuota} ({usagePercent}%)
                    </Text>
                  </View>
                  <View
                    style={[
                      styles.progressBarBg,
                      {
                        backgroundColor: isDarkMode
                          ? 'rgba(255, 255, 255, 0.08)'
                          : '#F0F5F1',
                      },
                    ]}
                  >
                    <View
                      style={[
                        styles.progressBarFill,
                        { width: `${usagePercent}%`, backgroundColor: themeColors.accent },
                      ]}
                    />
                  </View>
                </View>

                {/* Date Footer */}
                <View
                  style={[
                    styles.dateFooter,
                    { borderTopColor: themeColors.divider },
                  ]}
                >
                  <Calendar size={12} color={themeColors.textMuted} />
                  <Text style={[styles.dateText, { color: themeColors.textMuted }]}>
                    Periode: {promo.startDate} s/d {promo.endDate}
                  </Text>
                </View>
              </Card>
            </FadeInUp>
          );
        })
        )}
      </ScrollView>

      {/* Create Promo Modal */}
      <Modal
        visible={isCreateModalOpen}
        transparent
        animationType="slide"
        onRequestClose={() => setIsCreateModalOpen(false)}
      >
        <View style={styles.modalBackdrop}>
          <View
            style={[
              styles.modalBox,
              {
                backgroundColor: themeColors.modalBackground,
                borderColor: themeColors.modalBorder,
                borderWidth: 1,
              },
            ]}
          >
            <View style={styles.modalHeader}>
              <Text style={[styles.modalTitle, { color: themeColors.textPrimary }]}>
                Buat Promosi Toko Baru
              </Text>
              <TouchableOpacity
                onPress={() => setIsCreateModalOpen(false)}
                hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
              >
                <X size={20} color={themeColors.textSecondary} />
              </TouchableOpacity>
            </View>

            <ScrollView style={{ marginTop: 8 }} keyboardShouldPersistTaps="handled">
              <Input
                label="Nama Promosi / Diskon"
                value={promoName}
                onChangeText={setPromoName}
                placeholder="Contoh: Diskon Pupuk Olah Tanah 20%"
                containerStyle={{ marginBottom: 12 }}
              />

              <View style={styles.formGroup}>
                <Text style={[styles.formLabel, { color: themeColors.textSecondary }]}>
                  Tipe Promosi
                </Text>
                <View style={styles.typeChipsRow}>
                  {PROMO_TYPES.map((t) => {
                    const isActive = promoType === t;
                    return (
                      <TouchableOpacity
                        key={t}
                        onPress={() => setPromoType(t)}
                        style={[
                          styles.typeChip,
                          {
                            backgroundColor: themeColors.cardBackgroundSecondary,
                            borderColor: themeColors.cardBorder,
                          },
                          isActive && {
                            backgroundColor: themeColors.primary,
                            borderColor: themeColors.primary,
                          },
                        ]}
                        activeOpacity={0.75}
                      >
                        <Text
                          style={[
                            styles.typeChipText,
                            { color: themeColors.textSecondary },
                            isActive && styles.typeChipTextActive,
                          ]}
                        >
                          {t}
                        </Text>
                      </TouchableOpacity>
                    );
                  })}
                </View>
              </View>

              <View style={styles.formRow}>
                <View style={{ flex: 1 }}>
                  <Input
                    label="Diskon (%)"
                    value={discountValue}
                    onChangeText={setDiscountValue}
                    keyboardType="numeric"
                    placeholder="20"
                  />
                </View>
                <View style={{ flex: 1 }}>
                  <Input
                    label="Kuota Voucher"
                    value={quota}
                    onChangeText={setQuota}
                    keyboardType="numeric"
                    placeholder="200"
                  />
                </View>
              </View>

              <Input
                label="Minimum Pembelian (Rp)"
                value={minPurchase}
                onChangeText={setMinPurchase}
                keyboardType="numeric"
                placeholder="100000"
                containerStyle={{ marginTop: 12 }}
              />

              <View style={styles.modalActions}>
                <Button
                  variant="ghost"
                  size="md"
                  onPress={() => setIsCreateModalOpen(false)}
                  disabled={isSubmitting}
                >
                  Batal
                </Button>
                <Button
                  variant="primary"
                  size="md"
                  onPress={handleCreatePromo}
                  isLoading={isSubmitting}
                >
                  Aktifkan Promosi
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
    backgroundColor: '#FAF9F6',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingTop: 12,
    paddingBottom: 8,
  },
  titleCol: {
    flex: 1,
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
  tabsContainer: {
    paddingVertical: 6,
  },
  tabsContent: {
    paddingHorizontal: 16,
    gap: 8,
  },
  tabChip: {
    paddingHorizontal: 14,
    paddingVertical: 7,
    borderRadius: 20,
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E6EDE7',
  },
  tabChipActive: {
    backgroundColor: colors.primary.DEFAULT,
    borderColor: colors.primary.DEFAULT,
  },
  tabChipText: {
    fontSize: 12,
    fontWeight: '600',
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[600],
  },
  tabChipTextActive: {
    color: '#FFFFFF',
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 96,
    gap: 12,
  },
  bannerCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    padding: 16,
    backgroundColor: '#EAF4EE',
    borderColor: '#C3DBC7',
    borderRadius: 20,
  },
  bannerIconBox: {
    width: 40,
    height: 40,
    borderRadius: 12,
    backgroundColor: colors.primary.DEFAULT,
    alignItems: 'center',
    justifyContent: 'center',
  },
  bannerText: {
    flex: 1,
    gap: 2,
  },
  bannerTitle: {
    fontSize: 13,
    fontWeight: '700',
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[900],
  },
  bannerSub: {
    fontSize: 11,
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[600],
    lineHeight: 16,
  },
  promoCard: {
    padding: 16,
    gap: 10,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#E6EDE7',
    backgroundColor: '#FFFFFF',
  },
  promoHeader: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
  },
  promoHeaderLeft: {
    flex: 1,
    gap: 4,
  },
  promoTypeTag: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  promoTypeText: {
    fontSize: 10,
    color: colors.primary.dark,
    fontWeight: '700',
    fontFamily: 'Poppins, sans-serif',
    textTransform: 'uppercase',
  },
  promoName: {
    fontSize: 14,
    fontWeight: '700',
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[900],
  },
  promoDetailsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 4,
  },
  discountBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: '#EAF4EE',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#C3DBC7',
  },
  discountText: {
    fontSize: 12,
    fontWeight: '700',
    fontFamily: 'Poppins, sans-serif',
    color: colors.primary.dark,
  },
  minPurchaseText: {
    fontSize: 11,
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[600],
  },
  quotaSection: {
    gap: 4,
  },
  quotaHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  quotaLabel: {
    fontSize: 10.5,
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[500],
  },
  quotaValue: {
    fontSize: 10.5,
    fontWeight: '700',
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[900],
  },
  progressBarBg: {
    height: 6,
    borderRadius: 3,
    backgroundColor: '#F0F5F1',
    overflow: 'hidden',
  },
  progressBarFill: {
    height: '100%',
    borderRadius: 3,
    backgroundColor: colors.primary.DEFAULT,
  },
  dateFooter: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: '#F0F5F1',
  },
  dateText: {
    fontSize: 10.5,
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[500],
  },
  modalBackdrop: {
    flex: 1,
    backgroundColor: 'rgba(27, 38, 29, 0.55)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  modalBox: {
    width: '100%',
    maxWidth: 400,
    backgroundColor: '#FFFFFF',
    borderRadius: 24,
    padding: 22,
    gap: 12,
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  modalTitle: {
    fontSize: 16,
    fontWeight: '800',
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[900],
  },
  formGroup: {
    gap: 6,
    marginBottom: 12,
  },
  formRow: {
    flexDirection: 'row',
    gap: 10,
  },
  formLabel: {
    fontSize: 12.5,
    fontWeight: '600',
    fontFamily: 'Poppins, sans-serif',
    color: colors.neutral[800],
  },
  typeChipsRow: {
    flexDirection: 'row',
    gap: 8,
  },
  typeChip: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 12,
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E6EDE7',
  },
  typeChipActive: {
    backgroundColor: '#EAF4EE',
    borderColor: colors.primary.DEFAULT,
  },
  typeChipText: {
    fontSize: 11,
    color: colors.neutral[600],
    fontFamily: 'Poppins, sans-serif',
    fontWeight: '500',
  },
  typeChipTextActive: {
    color: colors.primary.dark,
    fontWeight: '700',
  },
  modalActions: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    gap: 10,
    marginTop: 14,
  },
});