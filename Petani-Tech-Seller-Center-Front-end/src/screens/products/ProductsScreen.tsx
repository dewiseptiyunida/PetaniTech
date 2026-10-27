import React, { useEffect, useState, useMemo } from 'react';
import {
  StyleSheet,
  Text,
  View,
  ScrollView,
  Image,
  Modal,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { useProductStore } from '@/store/useProductStore';
import { ProductFilterTab, Product } from '@/types';
import { ProductCard } from '@/components/cards/ProductCard';
import { Button } from '@/components/common/Button';
import { Badge } from '@/components/common/Badge';
import { FilterChip, FilterChipGroup } from '@/components/common/FilterChip';
import { EmptyState } from '@/components/common/EmptyState';
import { LoadingState } from '@/components/common/LoadingState';
import { ConfirmationModal } from '@/components/common/ConfirmationModal';
import { FadeInUp, PressableScale } from '@/components/common/Motion';
import { SearchInput } from '@/components/forms/SearchInput';
import { Input } from '@/components/forms/Input';
import { ProductFormModal } from '@/components/products/ProductFormModal';
import { formatRupiah, PRODUCT_CATEGORIES } from '@/constants';
import { resolveProductImage } from '@/utils/productImage';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme/ThemeContext';
import { useBottomTabSpace } from '@/navigation/hooks';
import {
  Plus,
  Edit2,
  Boxes,
  X,
  Package,
} from 'lucide-react-native';

const STATUS_TABS: { key: ProductFilterTab; label: string }[] = [
  { key: 'all', label: 'Semua' },
  { key: 'active', label: 'Aktif' },
  { key: 'low_stock', label: 'Stok Menipis' },
  { key: 'out_of_stock', label: 'Habis' },
  { key: 'review', label: 'Review' },
];

export function ProductsScreen() {
  const { colors: themeColors, isDark } = useTheme();
  const bottomSpace = useBottomTabSpace(28);

  const {
    products,
    isLoading,
    activeTab,
    searchQuery,
    selectedCategory,
    fetchProducts,
    setActiveTab,
    setSearchQuery,
    setSelectedCategory,
    addProduct,
    updateProduct,
    deleteProduct,
    updateStock,
  } = useProductStore();

  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState<Product | null>(null);
  const [detailProduct, setDetailProduct] = useState<Product | null>(null);
  const [stockModalProduct, setStockModalProduct] = useState<Product | null>(null);
  const [newStockInput, setNewStockInput] = useState('');
  const [isStockSaving, setIsStockSaving] = useState(false);

  // Delete confirmation state
  const [deleteTargetProduct, setDeleteTargetProduct] = useState<Product | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);

  useEffect(() => {
    fetchProducts();
  }, [fetchProducts]);

  // Status counts for filter chips
  const activeCount = useMemo(
    () => products.filter((p) => p.status === 'Aktif').length,
    [products]
  );
  const lowStockCount = useMemo(
    () => products.filter((p) => p.stock > 0 && p.stock <= p.minStockAlert).length,
    [products]
  );
  const outOfStockCount = useMemo(
    () => products.filter((p) => p.stock === 0).length,
    [products]
  );
  const reviewCount = useMemo(
    () => products.filter((p) => p.status === 'Sedang Diperiksa').length,
    [products]
  );

  const getTabCount = (key: ProductFilterTab): number | undefined => {
    switch (key) {
      case 'all':
        return products.length;
      case 'active':
        return activeCount;
      case 'low_stock':
        return lowStockCount;
      case 'out_of_stock':
        return outOfStockCount;
      case 'review':
        return reviewCount;
      default:
        return undefined;
    }
  };

  const handleStockSave = async () => {
    if (!stockModalProduct || newStockInput.trim() === '') return;
    const num = parseInt(newStockInput, 10);
    if (isNaN(num) || num < 0) return;

    setIsStockSaving(true);
    try {
      await updateStock(stockModalProduct.id, num);
      setStockModalProduct(null);
      setNewStockInput('');
    } finally {
      setIsStockSaving(false);
    }
  };

  const handleConfirmDelete = async () => {
    if (!deleteTargetProduct) return;
    setIsDeleting(true);
    try {
      await deleteProduct(deleteTargetProduct.id);
      if (detailProduct?.id === deleteTargetProduct.id) {
        setDetailProduct(null);
      }
      setDeleteTargetProduct(null);
    } finally {
      setIsDeleting(false);
    }
  };

  const getStatusBadgeVariant = (status: Product['status']): 'brand' | 'warning' | 'danger' | 'neutral' => {
    switch (status) {
      case 'Aktif':
        return 'brand';
      case 'Stok Menipis':
        return 'warning';
      case 'Habis':
        return 'danger';
      case 'Sedang Diperiksa':
      default:
        return 'neutral';
    }
  };

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
          {/* Hairline top sheen */}
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
              INVENTARIS & KATALOG
            </Text>
            <Text style={[styles.screenTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
              Katalog Produk
            </Text>
            <Text style={[styles.screenSubtitle, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
              Kelola stok, harga, & varian sarana pertanian
            </Text>
          </View>

          <Button
            variant="primary"
            size="sm"
            leftIcon={<Plus size={15} color="#FFFFFF" />}
            onPress={() => {
              setEditingProduct(null);
              setIsAddModalOpen(true);
            }}
          >
            Tambah
          </Button>
        </View>
      </FadeInUp>

      {/* 4. Search and Filter Chips */}
      <FadeInUp delay={50}>
        <View style={styles.searchContainer}>
          <SearchInput
            value={searchQuery}
            onChangeText={setSearchQuery}
            placeholder="Cari nama produk, SKU, kategori..."
            variant="glass"
          />
        </View>

        {/* Status Filter Tabs */}
        <View style={styles.tabsSection}>
          <FilterChipGroup contentContainerStyle={styles.chipsRowPadding}>
            {STATUS_TABS.map((tab) => {
              const isSelected = activeTab === tab.key;
              return (
                <FilterChip
                  key={tab.key}
                  label={tab.label}
                  selected={isSelected}
                  count={getTabCount(tab.key)}
                  size="sm"
                  onPress={() => setActiveTab(tab.key)}
                />
              );
            })}
          </FilterChipGroup>
        </View>

        {/* Category Filter Chips */}
        <View style={styles.categorySection}>
          <FilterChipGroup contentContainerStyle={styles.chipsRowPadding}>
            {PRODUCT_CATEGORIES.map((cat) => {
              const isSelected = selectedCategory === cat;
              return (
                <FilterChip
                  key={cat}
                  label={cat}
                  selected={isSelected}
                  size="sm"
                  onPress={() => setSelectedCategory(cat)}
                />
              );
            })}
          </FilterChipGroup>
        </View>
      </FadeInUp>

      {/* 5. Quick Summary KPI Bar */}
      <FadeInUp delay={90}>
        <View style={styles.summaryBar}>
          <View
            style={[
              styles.summaryPill,
              {
                backgroundColor: isDark ? 'rgba(22, 58, 38, 0.65)' : '#FFFFFF',
                borderColor: isDark ? 'rgba(209, 245, 232, 0.16)' : '#DDE8E0',
              },
            ]}
          >
            <Text style={[styles.summaryLabel, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
              Total:{' '}
              <Text style={[styles.summaryValue, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                {products.length}
              </Text>
            </Text>
            <Text
              style={[
                styles.summaryDivider,
                { color: isDark ? 'rgba(255,255,255,0.2)' : '#DDE8E0' },
              ]}
            >
              |
            </Text>
            <Text style={[styles.summaryLabel, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
              Aktif:{' '}
              <Text style={[styles.summaryValue, { color: isDark ? '#D1F5E8' : '#31572C' }]}>
                {activeCount}
              </Text>
            </Text>

            {lowStockCount > 0 ? (
              <>
                <Text
                  style={[
                    styles.summaryDivider,
                    { color: isDark ? 'rgba(255,255,255,0.2)' : '#DDE8E0' },
                  ]}
                >
                  |
                </Text>
                <Text style={[styles.summaryLabel, { color: '#D97706' }]}>
                  Menipis:{' '}
                  <Text style={[styles.summaryValue, { color: '#D97706' }]}>
                    {lowStockCount}
                  </Text>
                </Text>
              </>
            ) : null}

            {outOfStockCount > 0 ? (
              <>
                <Text
                  style={[
                    styles.summaryDivider,
                    { color: isDark ? 'rgba(255,255,255,0.2)' : '#DDE8E0' },
                  ]}
                >
                  |
                </Text>
                <Text style={[styles.summaryLabel, { color: '#EF4444' }]}>
                  Habis:{' '}
                  <Text style={[styles.summaryValue, { color: '#EF4444' }]}>
                    {outOfStockCount}
                  </Text>
                </Text>
              </>
            ) : null}
          </View>
        </View>
      </FadeInUp>

      {/* 6. Product Cards List */}
      <ScrollView
        contentContainerStyle={[styles.listContent, { paddingBottom: bottomSpace }]}
        showsVerticalScrollIndicator={false}
      >
        {isLoading && products.length === 0 ? (
          <LoadingState message="Memuat katalog produk..." style={styles.loadingState} />
        ) : products.length === 0 ? (
          <EmptyState
            variant="products"
            title="Tidak Ada Produk"
            description="Tidak ada produk pertanian yang cocok dengan pencarian atau filter yang dipilih."
            action={{
              label: 'Tambah Produk',
              onPress: () => {
                setEditingProduct(null);
                setIsAddModalOpen(true);
              },
            }}
          />
        ) : (
          products.map((product, index) => (
            <FadeInUp key={product.id} delay={110 + Math.min(index, 6) * 35}>
              <ProductCard
                product={product}
                onPress={() => setDetailProduct(product)}
                onUpdateStock={() => {
                  setStockModalProduct(product);
                  setNewStockInput(String(product.stock));
                }}
                onEdit={() => {
                  setEditingProduct(product);
                  setIsAddModalOpen(true);
                }}
                onDelete={() => setDeleteTargetProduct(product)}
              />
            </FadeInUp>
          ))
        )}
      </ScrollView>

      {/* DETAIL PRODUK MODAL */}
      <Modal
        visible={!!detailProduct}
        transparent
        animationType="slide"
        onRequestClose={() => setDetailProduct(null)}
      >
        <View style={styles.modalBackdrop}>
          <View
            style={[
              styles.detailModalBox,
              {
                backgroundColor: isDark ? 'rgba(22, 58, 38, 0.98)' : '#FFFFFF',
                borderColor: isDark ? 'rgba(209, 245, 232, 0.20)' : '#DDE8E0',
              },
            ]}
          >
            <View
              style={[
                styles.detailModalHeader,
                { borderBottomColor: isDark ? 'rgba(255, 255, 255, 0.10)' : '#EFF4F0' },
              ]}
            >
              <View style={styles.detailHeaderLeft}>
                <Package size={18} color={themeColors.primary} />
                <Text style={[styles.detailModalTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                  Detail Produk
                </Text>
              </View>
              <PressableScale
                onPress={() => setDetailProduct(null)}
                style={[
                  styles.closeBtn,
                  {
                    backgroundColor: isDark ? 'rgba(255, 255, 255, 0.10)' : '#F2FBF5',
                  },
                ]}
                hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
                accessibilityLabel="Tutup detail produk"
              >
                <X size={18} color={isDark ? '#D1F5E8' : '#64746A'} />
              </PressableScale>
            </View>

            {detailProduct && (
              <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.detailContent}>
                {/* Hero Product Image */}
                <View
                  style={[
                    styles.detailHeroImageWrapper,
                    {
                      backgroundColor: isDark ? 'rgba(255, 255, 255, 0.05)' : '#FAF9F6',
                      borderColor: isDark ? 'rgba(209, 245, 232, 0.18)' : '#DDE8E0',
                    },
                  ]}
                >
                  <Image
                    source={resolveProductImage(detailProduct.image, detailProduct.name)}
                    style={styles.detailHeroImage}
                    resizeMode="contain"
                  />
                  <View style={styles.detailHeroBadgeRow}>
                    <Badge variant="brand" size="sm">
                      {detailProduct.category}
                    </Badge>
                    <Badge variant={getStatusBadgeVariant(detailProduct.status)} size="sm" dot>
                      {detailProduct.status}
                    </Badge>
                  </View>
                </View>

                {/* Product Title & Price */}
                <Text style={[styles.detailProductName, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                  {detailProduct.name}
                </Text>

                <View style={styles.detailPriceRow}>
                  <Text style={[styles.detailPrice, { color: isDark ? '#ECF39E' : themeColors.primaryDark }]}>
                    {formatRupiah(detailProduct.price)}
                  </Text>
                  {detailProduct.originalPrice ? (
                    <Text style={[styles.detailOriginalPrice, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                      {formatRupiah(detailProduct.originalPrice)}
                    </Text>
                  ) : null}
                </View>

                {/* Spec Summary Card */}
                <View
                  style={[
                    styles.detailSpecCard,
                    {
                      backgroundColor: isDark ? 'rgba(64, 145, 108, 0.20)' : '#F2FBF5',
                      borderColor: isDark ? 'rgba(209, 245, 232, 0.22)' : '#DDE8E0',
                    },
                  ]}
                >
                  <View style={styles.specItem}>
                    <Text style={[styles.specLabel, { color: isDark ? '#D1F5E8' : '#64746A' }]}>SKU Toko</Text>
                    <Text style={[styles.specValue, { color: isDark ? '#FFFFFF' : '#183326' }]}>{detailProduct.sku}</Text>
                  </View>
                  <View style={[styles.specDivider, { backgroundColor: isDark ? 'rgba(255, 255, 255, 0.10)' : '#DDE8E0' }]} />
                  <View style={styles.specItem}>
                    <Text style={[styles.specLabel, { color: isDark ? '#D1F5E8' : '#64746A' }]}>Sisa Stok</Text>
                    <Text style={[styles.specValue, { color: isDark ? '#D1F5E8' : themeColors.primary }]}>
                      {detailProduct.stock} {detailProduct.unit}
                    </Text>
                  </View>
                  <View style={[styles.specDivider, { backgroundColor: isDark ? 'rgba(255, 255, 255, 0.10)' : '#DDE8E0' }]} />
                  <View style={styles.specItem}>
                    <Text style={[styles.specLabel, { color: isDark ? '#D1F5E8' : '#64746A' }]}>Terjual</Text>
                    <Text style={[styles.specValue, { color: isDark ? '#FFFFFF' : '#183326' }]}>{detailProduct.soldCount} pcs</Text>
                  </View>
                </View>

                {/* Description */}
                <View style={styles.detailDescSection}>
                  <Text style={[styles.detailSectionTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                    Deskripsi & Spesifikasi
                  </Text>
                  <Text style={[styles.detailDescText, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                    {detailProduct.description}
                  </Text>
                </View>

                {/* Action Buttons */}
                <View style={styles.detailActionsRow}>
                  <Button
                    variant="secondary"
                    size="md"
                    style={{ flex: 1 }}
                    leftIcon={<Boxes size={16} color={isDark ? '#D1F5E8' : themeColors.primaryDark} />}
                    onPress={() => {
                      const p = detailProduct;
                      setDetailProduct(null);
                      setStockModalProduct(p);
                      setNewStockInput(String(p.stock));
                    }}
                  >
                    Ubah Stok
                  </Button>

                  <Button
                    variant="primary"
                    size="md"
                    style={{ flex: 1 }}
                    leftIcon={<Edit2 size={16} color="#FFFFFF" />}
                    onPress={() => {
                      const p = detailProduct;
                      setDetailProduct(null);
                      setEditingProduct(p);
                      setIsAddModalOpen(true);
                    }}
                  >
                    Edit Produk
                  </Button>
                </View>
              </ScrollView>
            )}
          </View>
        </View>
      </Modal>

      {/* ADD / EDIT PRODUCT MODAL */}
      {isAddModalOpen && (
        <ProductFormModal
          isOpen={isAddModalOpen}
          onClose={() => setIsAddModalOpen(false)}
          initialData={
            editingProduct
              ? {
                  name: editingProduct.name,
                  category: editingProduct.category,
                  price: editingProduct.price,
                  stock: editingProduct.stock,
                  unit: editingProduct.unit,
                  description: editingProduct.description,
                  minStockAlert: editingProduct.minStockAlert,
                  image: editingProduct.image,
                }
              : undefined
          }
          onSubmit={async (data) => {
            if (editingProduct) {
              await updateProduct(editingProduct.id, data);
            } else {
              await addProduct(data);
            }
            fetchProducts();
          }}
        />
      )}

      {/* QUICK STOCK MODAL */}
      <Modal
        visible={!!stockModalProduct}
        transparent
        animationType="fade"
        onRequestClose={() => setStockModalProduct(null)}
      >
        <View style={styles.modalBackdrop}>
          <View
            style={[
              styles.stockModalBox,
              {
                backgroundColor: isDark ? 'rgba(22, 58, 38, 0.98)' : '#FFFFFF',
                borderColor: isDark ? 'rgba(209, 245, 232, 0.20)' : '#DDE8E0',
              },
            ]}
          >
            <Text style={[styles.stockModalTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
              Ubah Jumlah Stok
            </Text>
            <Text style={[styles.stockModalDesc, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
              {stockModalProduct?.name} ({stockModalProduct?.unit})
            </Text>
            <Input
              value={newStockInput}
              onChangeText={setNewStockInput}
              keyboardType="numeric"
              placeholder="0"
              autoFocus
            />
            <View style={styles.stockModalActions}>
              <Button
                variant="ghost"
                size="sm"
                onPress={() => setStockModalProduct(null)}
              >
                Batal
              </Button>
              <Button
                variant="primary"
                size="sm"
                onPress={handleStockSave}
                isLoading={isStockSaving}
              >
                Simpan Stok
              </Button>
            </View>
          </View>
        </View>
      </Modal>

      {/* CONFIRMATION MODAL FOR DELETE */}
      <ConfirmationModal
        isOpen={!!deleteTargetProduct}
        onClose={() => setDeleteTargetProduct(null)}
        onConfirm={handleConfirmDelete}
        title="Hapus Produk?"
        message={`Apakah Anda yakin ingin menghapus "${deleteTargetProduct?.name}" dari katalog toko? Pembeli tidak akan dapat menemukan atau memesan produk ini lagi.`}
        confirmLabel="Hapus Produk"
        cancelLabel="Batal"
        type="danger"
        isLoading={isDeleting}
      />
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
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
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
    flex: 1,
    gap: 2,
    marginRight: 12,
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
  searchContainer: {
    paddingHorizontal: 16,
    marginTop: 12,
    marginBottom: 8,
  },
  tabsSection: {
    marginBottom: 8,
  },
  categorySection: {
    marginBottom: 10,
  },
  chipsRowPadding: {
    paddingHorizontal: 16,
  },
  summaryBar: {
    paddingHorizontal: 16,
    marginBottom: 10,
  },
  summaryPill: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 14,
    paddingVertical: 7,
    borderRadius: 14,
    borderWidth: 1,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.04,
    shadowRadius: 4,
    elevation: 1,
  },
  summaryLabel: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.medium,
  },
  summaryValue: {
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  summaryDivider: {
    fontSize: 12,
  },
  listContent: {
    paddingHorizontal: 16,
    gap: 12,
    paddingTop: 2,
  },
  loadingState: {
    paddingVertical: 40,
  },
  modalBackdrop: {
    flex: 1,
    backgroundColor: 'rgba(24, 51, 38, 0.55)',
    justifyContent: 'flex-end',
  },
  detailModalBox: {
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    borderWidth: 1,
    borderBottomWidth: 0,
    maxHeight: '85%',
    overflow: 'hidden',
  },
  detailModalHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingVertical: 14,
    borderBottomWidth: 1,
  },
  detailHeaderLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  detailModalTitle: {
    fontSize: 16,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  closeBtn: {
    width: 32,
    height: 32,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  detailContent: {
    padding: 20,
    gap: 14,
  },
  detailHeroImageWrapper: {
    width: '100%',
    height: 190,
    borderRadius: 20,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
    overflow: 'hidden',
  },
  detailHeroImage: {
    width: '80%',
    height: '80%',
  },
  detailHeroBadgeRow: {
    position: 'absolute',
    top: 10,
    right: 10,
    flexDirection: 'row',
    gap: 6,
  },
  detailProductName: {
    fontSize: 18,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    lineHeight: 24,
  },
  detailPriceRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
    gap: 10,
  },
  detailPrice: {
    fontSize: 22,
    fontWeight: '800',
    fontFamily: typography.fontFamily.extrabold,
    letterSpacing: -0.4,
  },
  detailOriginalPrice: {
    fontSize: 14,
    fontFamily: typography.fontFamily.regular,
    textDecorationLine: 'line-through',
  },
  detailSpecCard: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
    paddingVertical: 12,
    paddingHorizontal: 8,
    borderRadius: 16,
    borderWidth: 1,
  },
  specItem: {
    alignItems: 'center',
    gap: 3,
    flex: 1,
  },
  specDivider: {
    width: 1,
    height: 28,
  },
  specLabel: {
    fontSize: 10.5,
    fontFamily: typography.fontFamily.medium,
  },
  specValue: {
    fontSize: 12.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  detailDescSection: {
    gap: 6,
  },
  detailSectionTitle: {
    fontSize: 13.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  detailDescText: {
    fontSize: 12.5,
    lineHeight: 18,
    fontFamily: typography.fontFamily.regular,
  },
  detailActionsRow: {
    flexDirection: 'row',
    gap: 10,
    marginTop: 6,
    marginBottom: 8,
  },
  stockModalBox: {
    margin: 24,
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
  stockModalTitle: {
    fontSize: 17,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  stockModalDesc: {
    fontSize: 12.5,
    fontFamily: typography.fontFamily.regular,
    marginTop: -4,
  },
  stockModalActions: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-end',
    gap: 10,
    marginTop: 6,
  },
});