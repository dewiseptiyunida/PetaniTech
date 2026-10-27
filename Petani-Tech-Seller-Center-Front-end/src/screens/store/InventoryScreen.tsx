import React, { useEffect, useState } from 'react';
import {
  StyleSheet,
  Text,
  View,
  ScrollView,
  Modal,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { useInventoryStore } from '@/store/useInventoryStore';
import { useToastStore } from '@/store/useToastStore';
import { InventoryItem } from '@/types';
import { Card } from '@/components/cards/Card';
import { Button } from '@/components/common/Button';
import { Badge } from '@/components/common/Badge';
import { StatCard } from '@/components/cards/StatCard';
import { EmptyState } from '@/components/common/EmptyState';
import { FilterChip, FilterChipGroup } from '@/components/common/FilterChip';
import { FadeInUp, PressableScale } from '@/components/common/Motion';
import { SearchInput } from '@/components/forms/SearchInput';
import { Input } from '@/components/forms/Input';
import { formatRupiah, PRODUCT_CATEGORIES } from '@/constants';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme/ThemeContext';
import { useBottomTabSpace } from '@/navigation/hooks';
import {
  Boxes,
  AlertTriangle,
  XCircle,
  Plus,
  Minus,
  History,
  ArrowUp,
  ArrowDown,
  X,
  MapPin,
  Building2,
} from 'lucide-react-native';

type ModalMode = 'add' | 'remove' | 'movement' | null;

export function InventoryScreen() {
  const { colors: themeColors, isDark } = useTheme();
  const bottomSpace = useBottomTabSpace(28);

  const {
    items,
    movements,
    summary,
    fetchInventory,
    fetchMovements,
    fetchSuppliers,
    addStock,
    removeStock,
    setFilterStatus,
    setFilterCategory,
    setSearchQuery,
    filterStatus,
    filterCategory,
    searchQuery,
  } = useInventoryStore();

  const toast = useToastStore();

  const [selectedItem, setSelectedItem] = useState<InventoryItem | null>(null);
  const [modalMode, setModalMode] = useState<ModalMode>(null);
  const [qty, setQty] = useState('');
  const [reason, setReason] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    fetchInventory();
    fetchSuppliers();
  }, [fetchInventory, fetchSuppliers]);

  const openModal = (item: InventoryItem, mode: ModalMode) => {
    setSelectedItem(item);
    setModalMode(mode);
    setQty('');
    setReason('');
    if (mode === 'movement') {
      fetchMovements(item.id);
    }
  };

  const closeModal = () => {
    setSelectedItem(null);
    setModalMode(null);
    setQty('');
    setReason('');
  };

  const handleSubmitStock = async () => {
    if (!selectedItem || !qty || !reason.trim()) return;
    setIsSubmitting(true);
    try {
      if (modalMode === 'add') {
        await addStock(selectedItem.id, Number(qty), reason);
        toast.success('Stok Berhasil Masuk', `+${qty} ${selectedItem.unit} telah ditambahkan`);
      } else if (modalMode === 'remove') {
        await removeStock(selectedItem.id, Number(qty), reason);
        toast.warning('Stok Berhasil Keluar', `-${qty} ${selectedItem.unit} telah dikurangi`);
      }
      closeModal();
    } catch (err: unknown) {
      toast.error('Gagal', err instanceof Error ? err.message : 'Terjadi kesalahan');
    } finally {
      setIsSubmitting(false);
    }
  };

  const statusFilters = [
    { key: 'all', label: 'Semua' },
    { key: 'Aman', label: 'Stok Aman' },
    { key: 'Menipis', label: 'Menipis' },
    { key: 'Habis', label: 'Habis' },
  ];

  return (
    <SafeAreaView
      style={[styles.safeArea, { backgroundColor: isDark ? themeColors.background : '#FAF9F6' }]}
      edges={['top']}
    >
      {/* 1. Subtle Botanical Canvas Gradient */}
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
            <Text
              style={[
                styles.eyebrow,
                { color: isDark ? themeColors.mint : themeColors.primary },
              ]}
            >
              PENGELOLAAN GUDANG
            </Text>
            <Text style={[styles.screenTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
              Inventori & Gudang
            </Text>
            <Text style={[styles.screenSubtitle, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
              Pantau stok produk, batas minimum, dan pencatatan mutasi barang
            </Text>
          </View>
        </View>
      </FadeInUp>

      <ScrollView
        contentContainerStyle={[styles.scrollContent, { paddingBottom: bottomSpace }]}
        showsVerticalScrollIndicator={false}
      >
        {/* KPI Summary Cards */}
        {summary ? (
          <FadeInUp delay={40}>
            <View style={styles.kpiContainer}>
              <View style={styles.kpiRow}>
                <StatCard
                  title="Total Item"
                  value={`${summary.totalItems} Produk`}
                  icon={Boxes}
                  iconBgColor={isDark ? 'rgba(64,145,108,0.25)' : '#EAF5EE'}
                  iconColor={isDark ? '#D1F5E8' : '#2D6A4F'}
                  style={styles.kpiCard}
                />
                <StatCard
                  title="Nilai Inventori"
                  value={formatRupiah(summary.totalStockValue)}
                  icon={Boxes}
                  iconBgColor={isDark ? 'rgba(37,99,235,0.22)' : '#EFF6FF'}
                  iconColor="#3B82F6"
                  style={styles.kpiCard}
                />
              </View>

              <View style={styles.kpiRow}>
                <StatCard
                  title="Stok Menipis"
                  value={`${summary.lowItems} Produk`}
                  icon={AlertTriangle}
                  iconBgColor={isDark ? 'rgba(245,158,11,0.22)' : '#FFFBEB'}
                  iconColor="#F59E0B"
                  style={styles.kpiCard}
                />
                <StatCard
                  title="Stok Habis"
                  value={`${summary.emptyItems} Produk`}
                  icon={XCircle}
                  iconBgColor={isDark ? 'rgba(239,68,68,0.22)' : '#FFF1F2'}
                  iconColor="#EF4444"
                  style={styles.kpiCard}
                />
              </View>
            </View>
          </FadeInUp>
        ) : null}

        {/* Search Input */}
        <FadeInUp delay={70}>
          <View style={styles.searchRow}>
            <SearchInput
              value={searchQuery}
              onChangeText={(text) => {
                setSearchQuery(text);
                fetchInventory();
              }}
              placeholder="Cari SKU, nama produk, supplier..."
              variant="glass"
            />
          </View>

          {/* Status Filter Chips */}
          <View style={styles.filterSection}>
            <FilterChipGroup contentContainerStyle={styles.filterRowPadding}>
              {statusFilters.map((flt) => {
                const isActive = filterStatus === flt.key;
                return (
                  <FilterChip
                    key={flt.key}
                    label={flt.label}
                    selected={isActive}
                    size="sm"
                    onPress={() => {
                      setFilterStatus(flt.key);
                      fetchInventory();
                    }}
                  />
                );
              })}
            </FilterChipGroup>
          </View>

          {/* Category Filter Chips */}
          <View style={styles.filterSection}>
            <FilterChipGroup contentContainerStyle={styles.filterRowPadding}>
              {PRODUCT_CATEGORIES.map((cat) => {
                const isActive = filterCategory === cat;
                return (
                  <FilterChip
                    key={cat}
                    label={cat}
                    selected={isActive}
                    size="sm"
                    onPress={() => {
                      setFilterCategory(cat);
                      fetchInventory();
                    }}
                  />
                );
              })}
            </FilterChipGroup>
          </View>
        </FadeInUp>

        {/* Inventory Item Cards */}
        {items.length === 0 ? (
          <EmptyState
            variant="default"
            title="Tidak Ada Data Inventori"
            description="Tidak ada item gudang yang cocok dengan kriteria filter Anda."
          />
        ) : (
          items.map((item, index) => (
            <FadeInUp key={item.id} delay={100 + Math.min(index, 6) * 35}>
              <Card
                sheen
                variant="elevated"
                style={[
                  styles.inventoryCard,
                  {
                    backgroundColor: isDark ? 'rgba(22, 58, 38, 0.72)' : '#FFFFFF',
                    borderColor: isDark ? 'rgba(209, 245, 232, 0.16)' : '#DDE8E0',
                  },
                ]}
              >
                <View style={styles.cardHeader}>
                  <View style={styles.cardHeaderLeft}>
                    <Text style={[styles.itemSku, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                      SKU: {item.sku}
                    </Text>
                    <Text style={[styles.itemName, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                      {item.productName}
                    </Text>
                    <Text style={[styles.itemCategory, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                      {item.category}
                    </Text>
                  </View>
                  <Badge
                    variant={
                      item.status === 'Aman'
                        ? 'brand'
                        : item.status === 'Menipis'
                        ? 'warning'
                        : 'danger'
                    }
                    size="sm"
                    dot
                  >
                    {item.status}
                  </Badge>
                </View>

                {/* Stock Numbers Details Grid */}
                <View
                  style={[
                    styles.stockDetailsGrid,
                    {
                      backgroundColor: isDark
                        ? 'rgba(255, 255, 255, 0.04)'
                        : '#F8FAF8',
                      borderColor: isDark ? 'rgba(209, 245, 232, 0.14)' : '#EFF4F0',
                    },
                  ]}
                >
                  <View style={styles.stockCol}>
                    <Text style={[styles.stockColLabel, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                      Stok Saat Ini
                    </Text>
                    <Text style={[styles.stockColVal, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                      {item.currentStock} {item.unit}
                    </Text>
                  </View>
                  <View style={styles.stockCol}>
                    <Text style={[styles.stockColLabel, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                      Batas Minimum
                    </Text>
                    <Text style={[styles.stockColVal, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                      {item.minimumStock} {item.unit}
                    </Text>
                  </View>
                  <View style={styles.stockCol}>
                    <Text style={[styles.stockColLabel, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                      Harga Beli
                    </Text>
                    <Text style={[styles.stockColVal, { color: isDark ? '#ECF39E' : themeColors.primaryDark }]}>
                      {formatRupiah(item.purchasePrice)}
                    </Text>
                  </View>
                </View>

                {/* Warehouse Location & Supplier */}
                <View
                  style={[
                    styles.supplierLocBox,
                    {
                      backgroundColor: isDark
                        ? 'rgba(255, 255, 255, 0.03)'
                        : '#F2FBF5',
                    },
                  ]}
                >
                  <View style={styles.locRow}>
                    <MapPin size={12} color={isDark ? '#D1F5E8' : '#40916C'} />
                    <Text style={[styles.locText, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                      Lokasi: {item.warehouseLocation}
                    </Text>
                  </View>
                  <View style={styles.locRow}>
                    <Building2 size={12} color={isDark ? '#ECF39E' : '#2D6A4F'} />
                    <Text style={[styles.locText, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                      Supplier: {item.supplierName}
                    </Text>
                  </View>
                </View>

                {/* Management Actions */}
                <View
                  style={[
                    styles.actionsRow,
                    { borderTopColor: isDark ? 'rgba(255, 255, 255, 0.08)' : '#EFF4F0' },
                  ]}
                >
                  <Button
                    variant="primary"
                    size="sm"
                    leftIcon={<Plus size={14} color="#FFFFFF" />}
                    onPress={() => openModal(item, 'add')}
                  >
                    Masuk
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    leftIcon={<Minus size={14} color={isDark ? '#D1F5E8' : themeColors.primaryDark} />}
                    onPress={() => openModal(item, 'remove')}
                  >
                    Keluar
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    leftIcon={<History size={14} color={isDark ? '#D1F5E8' : '#64746A'} />}
                    onPress={() => openModal(item, 'movement')}
                  >
                    Riwayat
                  </Button>
                </View>
              </Card>
            </FadeInUp>
          ))
        )}
      </ScrollView>

      {/* Adjust Stock Modal */}
      <Modal
        visible={modalMode === 'add' || modalMode === 'remove'}
        transparent
        animationType="fade"
        onRequestClose={closeModal}
      >
        <View style={styles.modalBackdrop}>
          <View
            style={[
              styles.modalBox,
              {
                backgroundColor: isDark ? 'rgba(22, 58, 38, 0.98)' : '#FFFFFF',
                borderColor: isDark ? 'rgba(209, 245, 232, 0.20)' : '#DDE8E0',
              },
            ]}
          >
            <Text style={[styles.modalTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
              {modalMode === 'add' ? 'Tambah Stok Masuk' : 'Kurangi Stok Keluar'}
            </Text>
            <Text style={[styles.modalSub, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
              {selectedItem?.productName} (Sisa saat ini: {selectedItem?.currentStock}{' '}
              {selectedItem?.unit})
            </Text>

            <Input
              label={`Jumlah (${selectedItem?.unit})`}
              value={qty}
              onChangeText={setQty}
              keyboardType="numeric"
              placeholder="0"
              autoFocus
            />

            <Input
              label="Keterangan / Alasan"
              value={reason}
              onChangeText={setReason}
              placeholder="Contoh: Kiriman dari distributor / Retur pembeli"
            />

            <View style={styles.modalActions}>
              <Button variant="ghost" size="sm" onPress={closeModal} disabled={isSubmitting}>
                Batal
              </Button>
              <Button
                variant={modalMode === 'add' ? 'primary' : 'danger'}
                size="sm"
                onPress={handleSubmitStock}
                isLoading={isSubmitting}
              >
                Simpan
              </Button>
            </View>
          </View>
        </View>
      </Modal>

      {/* Movements History Modal */}
      <Modal
        visible={modalMode === 'movement'}
        transparent
        animationType="slide"
        onRequestClose={closeModal}
      >
        <View style={styles.modalBackdrop}>
          <View
            style={[
              styles.modalBox,
              {
                maxHeight: '80%',
                backgroundColor: isDark ? 'rgba(22, 58, 38, 0.98)' : '#FFFFFF',
                borderColor: isDark ? 'rgba(209, 245, 232, 0.20)' : '#DDE8E0',
              },
            ]}
          >
            <View style={styles.movementHeader}>
              <Text style={[styles.modalTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                Riwayat Mutasi Stok
              </Text>
              <PressableScale
                onPress={closeModal}
                hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
                style={[
                  styles.closeCircleBtn,
                  { backgroundColor: isDark ? 'rgba(255,255,255,0.10)' : '#F2FBF5' },
                ]}
              >
                <X size={18} color={isDark ? '#D1F5E8' : '#64746A'} />
              </PressableScale>
            </View>
            <Text style={[styles.modalSub, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
              {selectedItem?.productName}
            </Text>

            <ScrollView style={{ marginTop: 12 }}>
              {movements.length === 0 ? (
                <Text style={[styles.emptyMovementText, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                  Belum ada riwayat mutasi.
                </Text>
              ) : (
                movements.map((mov) => (
                  <View
                    key={mov.id}
                    style={[
                      styles.movementRow,
                      { borderBottomColor: isDark ? 'rgba(255, 255, 255, 0.08)' : '#EFF4F0' },
                    ]}
                  >
                    <View
                      style={[
                        styles.movementIcon,
                        {
                          backgroundColor:
                            mov.type === 'masuk'
                              ? isDark
                                ? 'rgba(64, 145, 108, 0.30)'
                                : '#EAF5EE'
                              : isDark
                              ? 'rgba(239, 68, 68, 0.25)'
                              : '#FEF2F2',
                        },
                      ]}
                    >
                      {mov.type === 'masuk' ? (
                        <ArrowDown size={16} color={isDark ? '#D1F5E8' : '#2D6A4F'} />
                      ) : (
                        <ArrowUp size={16} color="#EF4444" />
                      )}
                    </View>
                    <View style={styles.movementDetails}>
                      <Text style={[styles.movementReason, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                        {mov.reason}
                      </Text>
                      <Text style={[styles.movementMeta, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                        {mov.date} · oleh {mov.performedBy}
                      </Text>
                    </View>
                    <Text
                      style={[
                        styles.movementQty,
                        mov.type === 'masuk'
                          ? { color: isDark ? '#D1F5E8' : '#2D6A4F' }
                          : styles.qtyRed,
                      ]}
                    >
                      {mov.type === 'masuk' ? `+${mov.quantity}` : `-${mov.quantity}`}
                    </Text>
                  </View>
                ))
              )}
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
  header: {
    paddingHorizontal: 16,
    paddingTop: 12,
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
    gap: 2,
  },
  eyebrow: {
    fontSize: 10,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    letterSpacing: 1,
  },
  screenTitle: {
    fontSize: 20,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
    letterSpacing: -0.3,
  },
  screenSubtitle: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.regular,
    marginTop: 1,
  },
  scrollContent: {
    paddingTop: 12,
  },
  kpiContainer: {
    paddingHorizontal: 16,
    gap: 10,
    marginBottom: 12,
  },
  kpiRow: {
    flexDirection: 'row',
    gap: 10,
  },
  kpiCard: {
    flex: 1,
  },
  searchRow: {
    paddingHorizontal: 16,
    marginBottom: 10,
  },
  filterSection: {
    marginBottom: 8,
  },
  filterRowPadding: {
    paddingHorizontal: 16,
  },
  inventoryCard: {
    marginHorizontal: 16,
    marginBottom: 12,
    borderRadius: 20,
    borderWidth: 1.5,
    padding: 14,
    gap: 10,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
    overflow: 'hidden',
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  cardHeaderLeft: {
    flex: 1,
    gap: 2,
    marginRight: 8,
  },
  itemSku: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
  },
  itemName: {
    fontSize: 14,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  itemCategory: {
    fontSize: 11,
    fontFamily: typography.fontFamily.medium,
  },
  stockDetailsGrid: {
    flexDirection: 'row',
    borderRadius: 14,
    borderWidth: 1,
    padding: 10,
    justifyContent: 'space-between',
  },
  stockCol: {
    flex: 1,
    gap: 2,
  },
  stockColLabel: {
    fontSize: 10,
    fontFamily: typography.fontFamily.medium,
  },
  stockColVal: {
    fontSize: 13,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  supplierLocBox: {
    gap: 4,
    padding: 10,
    borderRadius: 12,
  },
  locRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  locText: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
  },
  actionsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    paddingTop: 8,
    borderTopWidth: 1,
  },
  modalBackdrop: {
    flex: 1,
    backgroundColor: 'rgba(24, 51, 38, 0.55)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  modalBox: {
    width: '100%',
    maxWidth: 400,
    borderRadius: 24,
    borderWidth: 1,
    padding: 22,
    gap: 12,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.18,
    shadowRadius: 18,
    elevation: 8,
  },
  modalTitle: {
    fontSize: 16,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
  },
  modalSub: {
    fontSize: 12,
    fontFamily: typography.fontFamily.regular,
  },
  modalActions: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    gap: 10,
    marginTop: 6,
  },
  movementHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  closeCircleBtn: {
    width: 32,
    height: 32,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  emptyMovementText: {
    fontSize: 12,
    fontFamily: typography.fontFamily.regular,
    textAlign: 'center',
    paddingVertical: 20,
  },
  movementRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 10,
    borderBottomWidth: 1,
    gap: 10,
  },
  movementIcon: {
    width: 32,
    height: 32,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  movementDetails: {
    flex: 1,
    gap: 2,
  },
  movementReason: {
    fontSize: 12,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  movementMeta: {
    fontSize: 10.5,
    fontFamily: typography.fontFamily.regular,
  },
  movementQty: {
    fontSize: 13,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
  },
  qtyRed: {
    color: '#EF4444',
  },
});