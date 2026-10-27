import React, { useEffect, useState, useMemo } from 'react';
import {
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  ScrollView,
  Image,
  Modal,
} from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { useOrderStore } from '@/store/useOrderStore';
import { OrderFilterTab, Order, OrderStatus } from '@/types';
import { Card } from '@/components/cards/Card';
import { Button } from '@/components/common/Button';
import { Badge } from '@/components/common/Badge';
import { FilterChip, FilterChipGroup } from '@/components/common/FilterChip';
import { EmptyState } from '@/components/common/EmptyState';
import { LoadingState } from '@/components/common/LoadingState';
import { ConfirmationModal } from '@/components/common/ConfirmationModal';
import { SearchInput } from '@/components/forms/SearchInput';
import { Input } from '@/components/forms/Input';
import { FadeInUp } from '@/components/common/Motion';
import { formatRupiah, formatDate } from '@/utils/formatters';
import { resolveProductImage } from '@/utils/productImage';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme/ThemeContext';
import { useBottomTabSpace } from '@/navigation/hooks';
import {
  Truck,
  Phone,
  MapPin,
  Clock,
  CheckCircle2,
  X,
  Receipt,
  User,
  CreditCard,
  FileText,
  Copy,
} from 'lucide-react-native';

const TABS: { key: OrderFilterTab; label: string }[] = [
  { key: 'all', label: 'Semua' },
  { key: 'unpaid', label: 'Menunggu Bayar' },
  { key: 'processing', label: 'Diproses' },
  { key: 'shipped', label: 'Dikirim' },
  { key: 'completed', label: 'Selesai' },
  { key: 'cancelled', label: 'Dibatalkan' },
];

export function OrdersScreen() {
  const { colors: themeColors, isDark } = useTheme();
  const insets = useSafeAreaInsets();
  const bottomSpace = useBottomTabSpace(28);

  const {
    orders,
    isLoading,
    activeTab,
    searchQuery,
    fetchOrders,
    setActiveTab,
    setSearchQuery,
    shipOrder,
    completeOrder,
    cancelOrder,
    syncPaymentStatus,
  } = useOrderStore();

  const [selectedOrderForShip, setSelectedOrderForShip] = useState<Order | null>(null);
  const [trackingNumberInput, setTrackingNumberInput] = useState('');
  const [isShipping, setIsShipping] = useState(false);

  const [selectedOrderReceipt, setSelectedOrderReceipt] = useState<Order | null>(null);

  // Cancel order confirmation modal state
  const [cancelTargetOrder, setCancelTargetOrder] = useState<Order | null>(null);
  const [isCancelling, setIsCancelling] = useState(false);

  useEffect(() => {
    fetchOrders();
  }, [fetchOrders]);

  // Dynamic counts for each filter tab
  const unpaidCount = useMemo(
    () => orders.filter((o) => o.status === 'Menunggu Pembayaran').length,
    [orders]
  );
  const processingCount = useMemo(
    () => orders.filter((o) => o.status === 'Diproses').length,
    [orders]
  );
  const shippedCount = useMemo(
    () => orders.filter((o) => o.status === 'Dikirim').length,
    [orders]
  );
  const completedCount = useMemo(
    () => orders.filter((o) => o.status === 'Selesai').length,
    [orders]
  );
  const cancelledCount = useMemo(
    () => orders.filter((o) => o.status === 'Dibatalkan').length,
    [orders]
  );

  const getTabCount = (key: OrderFilterTab): number | undefined => {
    switch (key) {
      case 'all':
        return orders.length;
      case 'unpaid':
        return unpaidCount;
      case 'processing':
        return processingCount;
      case 'shipped':
        return shippedCount;
      case 'completed':
        return completedCount;
      case 'cancelled':
        return cancelledCount;
      default:
        return undefined;
    }
  };

  const getStatusBadgeVariant = (
    status: OrderStatus
  ): 'brand' | 'success' | 'warning' | 'danger' | 'info' | 'neutral' => {
    switch (status) {
      case 'Menunggu Pembayaran':
        return 'warning';
      case 'Diproses':
        return 'info';
      case 'Dikirim':
        return 'brand';
      case 'Selesai':
        return 'success';
      case 'Dibatalkan':
        return 'danger';
      default:
        return 'neutral';
    }
  };

  const handleShipSubmit = async () => {
    if (!selectedOrderForShip || !trackingNumberInput.trim()) return;
    setIsShipping(true);
    try {
      await shipOrder(selectedOrderForShip.id, trackingNumberInput.trim());
      if (selectedOrderReceipt?.id === selectedOrderForShip.id) {
        setSelectedOrderReceipt({
          ...selectedOrderReceipt,
          status: 'Dikirim',
          trackingNumber: trackingNumberInput.trim(),
        });
      }
      setSelectedOrderForShip(null);
      setTrackingNumberInput('');
    } finally {
      setIsShipping(false);
    }
  };

  const handleConfirmCancel = async () => {
    if (!cancelTargetOrder) return;
    setIsCancelling(true);
    try {
      await cancelOrder(cancelTargetOrder.id, 'Dibatalkan oleh penjual');
      if (selectedOrderReceipt?.id === cancelTargetOrder.id) {
        setSelectedOrderReceipt(null);
      }
      setCancelTargetOrder(null);
    } finally {
      setIsCancelling(false);
    }
  };

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

      {/* 2. Soft Ambient Mint Orb Top Right */}
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
              TRANSAKSI & PENGIRIMAN
            </Text>
            <Text style={[styles.screenTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
              Pesanan Masuk
            </Text>
            <Text style={[styles.screenSubtitle, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
              Pantau pesanan, proses resi pengiriman, & konfirmasi transaksi
            </Text>
          </View>
        </View>
      </FadeInUp>

      {/* 4. Search Input */}
      <FadeInUp delay={40}>
        <View style={styles.searchContainer}>
          <SearchInput
            value={searchQuery}
            onChangeText={setSearchQuery}
            placeholder="Cari no. pesanan, nama pembeli, produk..."
            variant="glass"
          />
        </View>

        {/* 5. Status Filter Tabs */}
        <View style={styles.tabsSection}>
          <FilterChipGroup contentContainerStyle={styles.chipsRowPadding}>
            {TABS.map((tab) => {
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
      </FadeInUp>

      {/* 6. Quick Orders KPI Summary Bar */}
      <FadeInUp delay={70}>
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
              Total: <Text style={[styles.summaryValue, { color: isDark ? '#FFFFFF' : '#183326' }]}>{orders.length}</Text>
            </Text>
            <Text style={[styles.summaryDivider, { color: isDark ? 'rgba(255,255,255,0.2)' : '#DDE8E0' }]}>|</Text>
            <Text style={[styles.summaryLabel, { color: isDark ? '#93C5FD' : '#2563EB' }]}>
              Diproses: <Text style={[styles.summaryValue, { color: isDark ? '#93C5FD' : '#2563EB' }]}>{processingCount}</Text>
            </Text>
            <Text style={[styles.summaryDivider, { color: isDark ? 'rgba(255,255,255,0.2)' : '#DDE8E0' }]}>|</Text>
            <Text style={[styles.summaryLabel, { color: isDark ? '#D1F5E8' : '#31572C' }]}>
              Dikirim: <Text style={[styles.summaryValue, { color: isDark ? '#D1F5E8' : '#31572C' }]}>{shippedCount}</Text>
            </Text>
            {unpaidCount > 0 ? (
              <>
                <Text style={[styles.summaryDivider, { color: isDark ? 'rgba(255,255,255,0.2)' : '#DDE8E0' }]}>|</Text>
                <Text style={[styles.summaryLabel, { color: '#D97706' }]}>
                  Unpaid: <Text style={[styles.summaryValue, { color: '#D97706' }]}>{unpaidCount}</Text>
                </Text>
              </>
            ) : null}
          </View>
        </View>
      </FadeInUp>

      {/* 7. Orders List */}
      <ScrollView
        contentContainerStyle={[styles.listContent, { paddingBottom: bottomSpace }]}
        showsVerticalScrollIndicator={false}
      >
        {isLoading && orders.length === 0 ? (
          <LoadingState message="Memuat pesanan masuk..." style={styles.loadingState} />
        ) : orders.length === 0 ? (
          <EmptyState
            variant="orders"
            title="Tidak Ada Pesanan"
            description="Tidak ada pesanan yang sesuai dengan filter atau kata kunci pencarian yang dipilih."
          />
        ) : (
          orders.map((order, index) => {
            const firstItem = order.items && order.items.length > 0 ? order.items[0] : null;
            const extraItemsCount = order.items ? order.items.length - 1 : 0;

            return (
              <FadeInUp key={order.id} delay={100 + Math.min(index, 6) * 35}>
                <Card
                  sheen
                  variant="elevated"
                  style={[
                    styles.orderCard,
                    {
                      backgroundColor: isDark ? 'rgba(22, 58, 38, 0.72)' : '#FFFFFF',
                      borderColor: isDark ? 'rgba(209, 245, 232, 0.16)' : '#DDE8E0',
                    },
                  ]}
                  onPress={() => setSelectedOrderReceipt(order)}
                >
                  {/* Header: ID, Date & Status */}
                  <View style={styles.orderCardHeader}>
                    <View style={styles.orderHeaderLeft}>
                      <Text
                        style={[
                          styles.orderNumber,
                          { color: isDark ? '#FFFFFF' : '#183326' },
                        ]}
                      >
                        {order.orderNumber || order.id}
                      </Text>
                      <View style={styles.clockRow}>
                        <Clock size={11} color={isDark ? '#8BA899' : '#7E9180'} />
                        <Text style={[styles.orderDate, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                          {formatDate(order.createdAt)}
                        </Text>
                      </View>
                    </View>

                    <Badge variant={getStatusBadgeVariant(order.status)} size="sm" dot>
                      {order.status}
                    </Badge>
                  </View>

                  {/* Buyer & Logistics Block — Clear Separated Regions */}
                  <View
                    style={[
                      styles.buyerInfoBlock,
                      {
                        backgroundColor: isDark ? 'rgba(255, 255, 255, 0.04)' : '#F9FAF7',
                        borderColor: isDark ? 'rgba(209, 245, 232, 0.12)' : '#EAF0EB',
                      },
                    ]}
                  >
                    {/* Region 1: Buyer Identity */}
                    <View style={styles.buyerIdentityRow}>
                      <View style={styles.buyerIdentityLeft}>
                        <View
                          style={[
                            styles.buyerIconWrap,
                            {
                              backgroundColor: isDark
                                ? 'rgba(64, 145, 108, 0.22)'
                                : '#EAF5EE',
                            },
                          ]}
                        >
                          <User size={12} color={isDark ? '#D1F5E8' : '#2D6A4F'} />
                        </View>
                        <Text
                          style={[
                            styles.buyerName,
                            { color: isDark ? '#FFFFFF' : '#183326' },
                          ]}
                          numberOfLines={1}
                        >
                          {order.buyerName}
                        </Text>
                      </View>

                      {order.buyerPhone ? (
                        <View style={styles.buyerPhoneBadge}>
                          <Phone size={10} color={isDark ? '#8BA899' : '#64746A'} />
                          <Text
                            style={[
                              styles.buyerPhoneText,
                              { color: isDark ? '#8BA899' : '#64746A' },
                            ]}
                            numberOfLines={1}
                          >
                            {order.buyerPhone}
                          </Text>
                        </View>
                      ) : null}
                    </View>

                    {/* Region 2: Delivery Address */}
                    <View style={styles.buyerAddressRow}>
                      <View style={styles.addressIconWrap}>
                        <MapPin size={11} color={isDark ? '#8BA899' : '#7E9180'} />
                      </View>
                      <Text
                        style={[
                          styles.addressText,
                          { color: isDark ? '#D1F5E8' : '#55655B' },
                        ]}
                        numberOfLines={1}
                      >
                        {order.buyerAddress}
                      </Text>
                    </View>
                  </View>

                {/* Product Summary Row */}
                {firstItem ? (
                  <View style={styles.productSummaryRow}>
                    <Image
                      source={resolveProductImage(firstItem.productImage, firstItem.productName)}
                      style={[
                        styles.productThumb,
                        {
                          backgroundColor: isDark ? 'rgba(255, 255, 255, 0.06)' : '#F8FAF8',
                          borderColor: isDark ? 'rgba(209, 245, 232, 0.16)' : '#DDE8E0',
                        },
                      ]}
                      resizeMode="cover"
                    />

                    <View style={styles.productSummaryDetails}>
                      <Text
                        style={[
                          styles.productSummaryName,
                          { color: isDark ? '#FFFFFF' : '#183326' },
                        ]}
                        numberOfLines={1}
                      >
                        {firstItem.productName}
                      </Text>

                      <Text style={[styles.productSummaryMeta, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                        {firstItem.quantity} {firstItem.unit || 'unit'} × {formatRupiah(firstItem.unitPrice)}
                      </Text>

                      {extraItemsCount > 0 ? (
                        <Text style={[styles.extraItemsLabel, { color: isDark ? themeColors.mint : themeColors.primary }]}>
                          +{extraItemsCount} produk pertanian lainnya
                        </Text>
                      ) : null}
                    </View>

                    <View
                      style={[
                        styles.courierTag,
                        {
                          backgroundColor: isDark ? 'rgba(64, 145, 108, 0.20)' : 'rgba(64, 145, 108, 0.10)',
                        },
                      ]}
                    >
                      <Truck size={12} color={isDark ? '#D1F5E8' : '#31572C'} />
                      <Text
                        style={[
                          styles.courierTagText,
                          { color: isDark ? '#D1F5E8' : '#31572C' },
                        ]}
                        numberOfLines={1}
                      >
                        {order.courier.split(' ')[0]}
                      </Text>
                    </View>
                  </View>
                ) : null}

                {/* Card Action Footer */}
                <View
                  style={[
                    styles.orderFooter,
                    { borderTopColor: isDark ? 'rgba(255, 255, 255, 0.08)' : '#EFF4F0' },
                  ]}
                >
                  <View style={styles.totalCol}>
                    <Text style={[styles.totalLabel, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                      Total Pembayaran
                    </Text>
                    <Text
                      style={[
                        styles.totalAmount,
                        { color: isDark ? '#ECF39E' : themeColors.primaryDark },
                      ]}
                    >
                      {formatRupiah(order.totalAmount)}
                    </Text>
                  </View>

                  <View style={styles.actionBtnGroup}>
                    {order.status === 'Menunggu Pembayaran' ? (
                      <Button
                        variant="primary"
                        size="sm"
                        onPress={async () => {
                          try {
                            const res = await syncPaymentStatus(order.orderNumber);
                            const st = res?.order_status || res?.transaction_status || res?.payment_status || 'Dicek';
                            alert(`[Midtrans Sync]\nNo Pesanan: ${order.orderNumber}\nStatus: ${st}`);
                          } catch {
                            alert('Gagal mengecek status pembayaran ke Midtrans');
                          }
                        }}
                      >
                        Cek Bayar
                      </Button>
                    ) : order.status === 'Diproses' ? (
                      <Button
                        variant="primary"
                        size="sm"
                        leftIcon={<Truck size={13} color="#FFFFFF" />}
                        onPress={() => {
                          setSelectedOrderForShip(order);
                          setTrackingNumberInput(`AGRO-${Math.floor(1000000 + Math.random() * 9000000)}`);
                        }}
                      >
                        Kirim
                      </Button>
                    ) : order.status === 'Dikirim' ? (
                      <Button
                        variant="primary"
                        size="sm"
                        leftIcon={<CheckCircle2 size={13} color="#FFFFFF" />}
                        onPress={async () => {
                          await completeOrder(order.id);
                        }}
                      >
                        Selesaikan
                      </Button>
                    ) : null}

                    <Button
                      variant="secondary"
                      size="sm"
                      onPress={() => setSelectedOrderReceipt(order)}
                    >
                      Detail
                    </Button>

                    {order.status === 'Diproses' ? (
                      <Button
                        variant="ghost"
                        size="sm"
                        onPress={() => setCancelTargetOrder(order)}
                        textStyle={{ color: '#EF4444' }}
                      >
                        Batal
                      </Button>
                    ) : null}
                  </View>
                </View>
              </Card>
            </FadeInUp>
          );
        })
        )}
      </ScrollView>

      {/* MODAL: INPUT RESI PENGIRIMAN */}
      <Modal
        visible={!!selectedOrderForShip}
        transparent
        animationType="fade"
        onRequestClose={() => setSelectedOrderForShip(null)}
      >
        <View style={styles.modalBackdrop}>
          <View
            style={[
              styles.shipModalBox,
              {
                backgroundColor: isDark ? 'rgba(22, 58, 38, 0.98)' : '#FFFFFF',
                borderColor: isDark ? 'rgba(209, 245, 232, 0.20)' : '#DDE8E0',
              },
            ]}
          >
            {/* Top Sheen */}
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
            <View style={styles.shipModalHeaderRow}>
              <View style={styles.shipIconCircle}>
                <Truck size={22} color={themeColors.primary} />
              </View>
              <View style={{ flex: 1 }}>
                <Text style={[styles.shipModalTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                  Input Resi Pengiriman
                </Text>
                <Text style={[styles.shipModalDesc, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                  Pesanan {selectedOrderForShip?.orderNumber} • {selectedOrderForShip?.courier}
                </Text>
              </View>
            </View>

            <View style={{ marginTop: 6 }}>
              <Input
                label="Nomor Resi / AWB Ekspedisi *"
                value={trackingNumberInput}
                onChangeText={setTrackingNumberInput}
                placeholder="Contoh: AGRO-8821943"
                autoFocus
              />
            </View>

            <TouchableOpacity
              onPress={() => {
                setTrackingNumberInput(`AGRO-${Math.floor(1000000 + Math.random() * 9000000)}`);
              }}
              style={styles.autoResiButton}
              activeOpacity={0.7}
            >
              <Copy size={12} color={isDark ? themeColors.mint : themeColors.primary} />
              <Text style={[styles.autoResiText, { color: isDark ? themeColors.mint : themeColors.primary }]}>
                Gunakan Resi Mitra Otomatis
              </Text>
            </TouchableOpacity>

            <View style={styles.shipModalActions}>
              <Button
                variant="ghost"
                size="md"
                onPress={() => setSelectedOrderForShip(null)}
                disabled={isShipping}
              >
                Batal
              </Button>
              <Button
                variant="primary"
                size="md"
                onPress={handleShipSubmit}
                isLoading={isShipping}
              >
                Konfirmasi Kirim
              </Button>
            </View>
          </View>
        </View>
      </Modal>

      {/* MODAL: RINCIAN DETAIL PESANAN */}
      <Modal
        visible={!!selectedOrderReceipt}
        transparent
        animationType="slide"
        onRequestClose={() => setSelectedOrderReceipt(null)}
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
            {/* Modal Header */}
            <View
              style={[
                styles.detailModalHeader,
                { borderBottomColor: isDark ? 'rgba(255, 255, 255, 0.10)' : '#EFF4F0' },
              ]}
            >
              <View style={styles.detailHeaderLeft}>
                <Receipt size={18} color={themeColors.primary} />
                <Text style={[styles.detailModalTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                  Rincian Pesanan
                </Text>
              </View>

              <TouchableOpacity
                onPress={() => setSelectedOrderReceipt(null)}
                style={[
                  styles.closeBtn,
                  {
                    backgroundColor: isDark ? 'rgba(255, 255, 255, 0.10)' : '#F2FBF5',
                  },
                ]}
                hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
                accessibilityLabel="Tutup rincian pesanan"
              >
                <X size={18} color={isDark ? '#D1F5E8' : '#64746A'} />
              </TouchableOpacity>
            </View>

            {selectedOrderReceipt ? (
              <ScrollView
                showsVerticalScrollIndicator={false}
                contentContainerStyle={[
                  styles.detailContent,
                  { paddingBottom: Math.max(insets.bottom, 24) },
                ]}
              >
                {/* 1. Status Banner Card */}
                <View
                  style={[
                    styles.statusBannerCard,
                    {
                      backgroundColor: isDark ? 'rgba(64, 145, 108, 0.18)' : '#F2FBF5',
                      borderColor: isDark ? 'rgba(209, 245, 232, 0.20)' : '#DDE8E0',
                    },
                  ]}
                >
                  <View style={styles.statusBannerLeft}>
                    <Text style={[styles.statusBannerNo, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                      {selectedOrderReceipt.orderNumber}
                    </Text>
                    <Text style={[styles.statusBannerDate, { color: isDark ? '#8BA899' : '#7E9180' }]}>
                      Dipesan pada {formatDate(selectedOrderReceipt.createdAt)}
                    </Text>
                  </View>
                  <Badge variant={getStatusBadgeVariant(selectedOrderReceipt.status)} size="md" dot>
                    {selectedOrderReceipt.status}
                  </Badge>
                </View>

                {/* 2. Informasi Pembeli & Kontak */}
                <View
                  style={[
                    styles.infoSectionCard,
                    {
                      backgroundColor: isDark ? 'rgba(22, 58, 38, 0.65)' : '#FFFFFF',
                      borderColor: isDark ? 'rgba(209, 245, 232, 0.16)' : '#DDE8E0',
                    },
                  ]}
                >
                  <View style={styles.sectionHeaderRow}>
                    <User size={15} color={isDark ? themeColors.mint : themeColors.primary} />
                    <Text style={[styles.sectionCardTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                      Informasi Pembeli
                    </Text>
                  </View>

                  <View style={styles.buyerDetailRow}>
                    <Text style={[styles.buyerNameLarge, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                      {selectedOrderReceipt.buyerName}
                    </Text>
                    <View style={styles.phoneTag}>
                      <Phone size={12} color={isDark ? '#D1F5E8' : '#31572C'} />
                      <Text style={[styles.phoneTagText, { color: isDark ? '#D1F5E8' : '#31572C' }]}>
                        {selectedOrderReceipt.buyerPhone}
                      </Text>
                    </View>
                  </View>

                  <View style={styles.addressBox}>
                    <MapPin size={14} color={isDark ? '#8BA899' : '#7E9180'} style={{ marginTop: 2 }} />
                    <Text style={[styles.addressDetailText, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                      {selectedOrderReceipt.buyerAddress}
                    </Text>
                  </View>

                  {selectedOrderReceipt.note ? (
                    <View
                      style={[
                        styles.noteBox,
                        {
                          backgroundColor: isDark ? 'rgba(245, 158, 11, 0.12)' : '#FEF9E7',
                          borderColor: isDark ? 'rgba(245, 158, 11, 0.30)' : '#FDE68A',
                        },
                      ]}
                    >
                      <FileText size={13} color="#D97706" style={{ marginTop: 2 }} />
                      <Text style={[styles.noteText, { color: isDark ? '#FCD34D' : '#92400E' }]}>
                        Catatan: "{selectedOrderReceipt.note}"
                      </Text>
                    </View>
                  ) : null}
                </View>

                {/* 3. Logistik & Resi */}
                <View
                  style={[
                    styles.infoSectionCard,
                    {
                      backgroundColor: isDark ? 'rgba(22, 58, 38, 0.65)' : '#FFFFFF',
                      borderColor: isDark ? 'rgba(209, 245, 232, 0.16)' : '#DDE8E0',
                    },
                  ]}
                >
                  <View style={styles.sectionHeaderRow}>
                    <Truck size={15} color={isDark ? themeColors.mint : themeColors.primary} />
                    <Text style={[styles.sectionCardTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                      Ekspedisi & Pengiriman
                    </Text>
                  </View>

                  <View style={styles.logisticsRow}>
                    <Text style={[styles.logisticsCourier, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                      {selectedOrderReceipt.courier}
                    </Text>
                    {selectedOrderReceipt.trackingNumber ? (
                      <View style={styles.resiBadge}>
                        <Text style={[styles.resiText, { color: isDark ? '#D1F5E8' : '#31572C' }]}>
                          Resi: {selectedOrderReceipt.trackingNumber}
                        </Text>
                      </View>
                    ) : (
                      <Badge variant="warning" size="sm">
                        Belum Dikirim
                      </Badge>
                    )}
                  </View>
                </View>

                {/* 4. Daftar Produk */}
                <View
                  style={[
                    styles.infoSectionCard,
                    {
                      backgroundColor: isDark ? 'rgba(22, 58, 38, 0.65)' : '#FFFFFF',
                      borderColor: isDark ? 'rgba(209, 245, 232, 0.16)' : '#DDE8E0',
                    },
                  ]}
                >
                  <View style={styles.sectionHeaderRow}>
                    <CreditCard size={15} color={isDark ? themeColors.mint : themeColors.primary} />
                    <Text style={[styles.sectionCardTitle, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                      Daftar Produk ({selectedOrderReceipt.items.length})
                    </Text>
                  </View>

                  <View style={styles.orderItemsList}>
                    {selectedOrderReceipt.items.map((it, idx) => (
                      <View
                        key={idx}
                        style={[
                          styles.receiptItemRow,
                          idx !== selectedOrderReceipt.items.length - 1 && {
                            borderBottomWidth: 1,
                            borderBottomColor: isDark ? 'rgba(255, 255, 255, 0.08)' : '#EFF4F0',
                            paddingBottom: 10,
                            marginBottom: 10,
                          },
                        ]}
                      >
                        <Image
                          source={resolveProductImage(it.productImage, it.productName)}
                          style={[
                            styles.receiptItemThumb,
                            {
                              backgroundColor: isDark ? 'rgba(255, 255, 255, 0.06)' : '#F8FAF8',
                              borderColor: isDark ? 'rgba(209, 245, 232, 0.16)' : '#DDE8E0',
                            },
                          ]}
                          resizeMode="cover"
                        />

                        <View style={{ flex: 1, gap: 2 }}>
                          <Text style={[styles.receiptItemName, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                            {it.productName}
                          </Text>
                          <Text style={[styles.receiptItemUnit, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                            {it.quantity} {it.unit || 'unit'} × {formatRupiah(it.unitPrice)}
                          </Text>
                        </View>

                        <Text style={[styles.receiptItemPrice, { color: isDark ? '#ECF39E' : themeColors.primaryDark }]}>
                          {formatRupiah(it.unitPrice * it.quantity)}
                        </Text>
                      </View>
                    ))}
                  </View>
                </View>

                {/* 5. Rincian Pembayaran */}
                <View
                  style={[
                    styles.infoSectionCard,
                    {
                      backgroundColor: isDark ? 'rgba(22, 58, 38, 0.65)' : '#FFFFFF',
                      borderColor: isDark ? 'rgba(209, 245, 232, 0.16)' : '#DDE8E0',
                    },
                  ]}
                >
                  <Text style={[styles.sectionCardTitle, { color: isDark ? '#FFFFFF' : '#183326', marginBottom: 10 }]}>
                    Rincian Pembayaran
                  </Text>

                  <View style={styles.paymentLineRow}>
                    <Text style={[styles.paymentLineLabel, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                      Subtotal Produk
                    </Text>
                    <Text style={[styles.paymentLineValue, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                      {formatRupiah(
                        selectedOrderReceipt.items.reduce((acc, i) => acc + i.subtotal, 0)
                      )}
                    </Text>
                  </View>

                  <View style={styles.paymentLineRow}>
                    <Text style={[styles.paymentLineLabel, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                      Ongkos Kirim
                    </Text>
                    <Text style={[styles.paymentLineValue, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                      {formatRupiah(selectedOrderReceipt.shippingFee)}
                    </Text>
                  </View>

                  <View style={styles.paymentLineRow}>
                    <Text style={[styles.paymentLineLabel, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
                      Metode Pembayaran
                    </Text>
                    <Text style={[styles.paymentLineValue, { color: isDark ? '#D1F5E8' : '#31572C' }]}>
                      {selectedOrderReceipt.paymentMethod}
                    </Text>
                  </View>

                  <View
                    style={[
                      styles.receiptTotalRow,
                      {
                        borderTopColor: isDark ? 'rgba(255, 255, 255, 0.10)' : '#DDE8E0',
                      },
                    ]}
                  >
                    <Text style={[styles.receiptTotalLabel, { color: isDark ? '#FFFFFF' : '#183326' }]}>
                      Total Pembayaran:
                    </Text>
                    <Text style={[styles.receiptTotalVal, { color: isDark ? '#ECF39E' : themeColors.primaryDark }]}>
                      {formatRupiah(selectedOrderReceipt.totalAmount)}
                    </Text>
                  </View>
                </View>

                {/* 6. Contextual Detail Actions */}
                <View style={styles.detailActionsRow}>
                  {selectedOrderReceipt.status === 'Diproses' ? (
                    <>
                      <Button
                        variant="primary"
                        size="md"
                        style={{ flex: 1 }}
                        leftIcon={<Truck size={15} color="#FFFFFF" />}
                        onPress={() => {
                          const o = selectedOrderReceipt;
                          setSelectedOrderReceipt(null);
                          setSelectedOrderForShip(o);
                          setTrackingNumberInput(`AGRO-${Math.floor(1000000 + Math.random() * 9000000)}`);
                        }}
                      >
                        Kirim Pesanan
                      </Button>

                      <Button
                        variant="ghost"
                        size="md"
                        textStyle={{ color: '#EF4444' }}
                        onPress={() => {
                          const o = selectedOrderReceipt;
                          setSelectedOrderReceipt(null);
                          setCancelTargetOrder(o);
                        }}
                      >
                        Batalkan
                      </Button>
                    </>
                  ) : selectedOrderReceipt.status === 'Dikirim' ? (
                    <Button
                      variant="primary"
                      size="md"
                      style={{ flex: 1 }}
                      leftIcon={<CheckCircle2 size={15} color="#FFFFFF" />}
                      onPress={async () => {
                        await completeOrder(selectedOrderReceipt.id);
                        setSelectedOrderReceipt(null);
                      }}
                    >
                      Konfirmasi Pesanan Selesai
                    </Button>
                  ) : (
                    <Button
                      variant="secondary"
                      size="md"
                      style={{ flex: 1 }}
                      onPress={() => setSelectedOrderReceipt(null)}
                    >
                      Tutup
                    </Button>
                  )}
                </View>
              </ScrollView>
            ) : null}
          </View>
        </View>
      </Modal>

      {/* CONFIRMATION MODAL: BATALKAN PESANAN */}
      <ConfirmationModal
        isOpen={!!cancelTargetOrder}
        onClose={() => setCancelTargetOrder(null)}
        onConfirm={handleConfirmCancel}
        title="Batalkan Pesanan?"
        message={`Apakah Anda yakin ingin membatalkan pesanan ${cancelTargetOrder?.orderNumber} atas nama ${cancelTargetOrder?.buyerName}? Stok produk akan dikembalikan ke katalog toko.`}
        confirmLabel="Batalkan Pesanan"
        cancelLabel="Kembali"
        type="danger"
        isLoading={isCancelling}
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
  orderCard: {
    borderRadius: 20,
    borderWidth: 1,
    padding: 15,
    gap: 10,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.06,
    shadowRadius: 10,
    elevation: 2,
  },
  orderCardHeader: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
  },
  orderHeaderLeft: {
    gap: 2,
  },
  orderNumber: {
    fontSize: 14,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  clockRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  orderDate: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
  },
  buyerInfoBlock: {
    paddingHorizontal: 11,
    paddingVertical: 8,
    borderRadius: 14,
    borderWidth: 1,
    gap: 6,
  },
  buyerIdentityRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 8,
  },
  buyerIdentityLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 7,
    flex: 1,
    minWidth: 0,
  },
  buyerIconWrap: {
    width: 22,
    height: 22,
    borderRadius: 11,
    alignItems: 'center',
    justifyContent: 'center',
    flexShrink: 0,
  },
  buyerName: {
    fontSize: 12.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    flexShrink: 1,
  },
  buyerPhoneBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    flexShrink: 0,
  },
  buyerPhoneText: {
    fontSize: 10.5,
    fontFamily: typography.fontFamily.medium,
  },
  buyerAddressRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    minWidth: 0,
  },
  addressIconWrap: {
    width: 16,
    alignItems: 'center',
    justifyContent: 'center',
    flexShrink: 0,
  },
  addressText: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.regular,
    flex: 1,
    flexShrink: 1,
    lineHeight: 15,
  },
  productSummaryRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  productThumb: {
    width: 52,
    height: 52,
    borderRadius: 12,
    borderWidth: 1,
  },
  productSummaryDetails: {
    flex: 1,
    gap: 2,
  },
  productSummaryName: {
    fontSize: 13,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  productSummaryMeta: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.regular,
  },
  extraItemsLabel: {
    fontSize: 10.5,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  courierTag: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 10,
  },
  courierTagText: {
    fontSize: 10.5,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  orderFooter: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingTop: 10,
    borderTopWidth: 1,
  },
  totalCol: {
    gap: 2,
  },
  totalLabel: {
    fontSize: 10.5,
    fontFamily: typography.fontFamily.regular,
  },
  totalAmount: {
    fontSize: 15.5,
    fontWeight: '800',
    fontFamily: typography.fontFamily.extrabold,
    letterSpacing: -0.3,
  },
  actionBtnGroup: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  modalBackdrop: {
    flex: 1,
    backgroundColor: 'rgba(24, 51, 38, 0.55)',
    justifyContent: 'flex-end',
  },
  shipModalBox: {
    margin: 20,
    marginBottom: 40,
    borderRadius: 24,
    borderWidth: 1,
    padding: 22,
    gap: 12,
    position: 'relative',
    overflow: 'hidden',
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.18,
    shadowRadius: 18,
    elevation: 8,
  },
  shipModalHeaderRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    marginBottom: 2,
  },
  shipIconCircle: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(64, 145, 108, 0.15)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  shipModalTitle: {
    fontSize: 17,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  shipModalDesc: {
    fontSize: 12,
    fontFamily: typography.fontFamily.regular,
    marginTop: 2,
  },
  autoResiButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    paddingVertical: 4,
    alignSelf: 'flex-start',
  },
  autoResiText: {
    fontSize: 11.5,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  shipModalActions: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-end',
    gap: 10,
    marginTop: 10,
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
    padding: 18,
    gap: 12,
  },
  statusBannerCard: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 14,
    borderRadius: 16,
    borderWidth: 1,
  },
  statusBannerLeft: {
    gap: 2,
  },
  statusBannerNo: {
    fontSize: 15,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  statusBannerDate: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
  },
  infoSectionCard: {
    borderRadius: 18,
    borderWidth: 1,
    padding: 14,
    gap: 10,
  },
  sectionHeaderRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  sectionCardTitle: {
    fontSize: 13,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  buyerDetailRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  buyerNameLarge: {
    fontSize: 14,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  phoneTag: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 10,
    backgroundColor: 'rgba(64, 145, 108, 0.12)',
  },
  phoneTagText: {
    fontSize: 11,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  addressBox: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 6,
  },
  addressDetailText: {
    fontSize: 12,
    lineHeight: 17,
    fontFamily: typography.fontFamily.regular,
    flex: 1,
  },
  noteBox: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 6,
    padding: 8,
    borderRadius: 10,
    borderWidth: 1,
  },
  noteText: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.regular,
    fontStyle: 'italic',
    flex: 1,
  },
  logisticsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  logisticsCourier: {
    fontSize: 13,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  resiBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 8,
    backgroundColor: 'rgba(64, 145, 108, 0.15)',
  },
  resiText: {
    fontSize: 11,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  orderItemsList: {
    gap: 8,
  },
  receiptItemRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  receiptItemThumb: {
    width: 44,
    height: 44,
    borderRadius: 10,
    borderWidth: 1,
  },
  receiptItemName: {
    fontSize: 13,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  receiptItemUnit: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
  },
  receiptItemPrice: {
    fontSize: 13,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  paymentLineRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 2,
  },
  paymentLineLabel: {
    fontSize: 12,
    fontFamily: typography.fontFamily.regular,
  },
  paymentLineValue: {
    fontSize: 12.5,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  receiptTotalRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingTop: 8,
    marginTop: 6,
    borderTopWidth: 1,
  },
  receiptTotalLabel: {
    fontSize: 13,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  receiptTotalVal: {
    fontSize: 17,
    fontWeight: '800',
    fontFamily: typography.fontFamily.extrabold,
    letterSpacing: -0.3,
  },
  detailActionsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    marginTop: 6,
    marginBottom: 8,
  },
});