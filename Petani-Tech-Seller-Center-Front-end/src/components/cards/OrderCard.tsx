import React from 'react';
import {
  StyleSheet,
  Text,
  View,
  Image,
  StyleProp,
  ViewStyle,
} from 'react-native';
import { Order, OrderStatus } from '@/types/order';
import { Card } from './Card';
import { Badge } from '@/components/common/Badge';
import { PressableScale } from '@/components/common/Motion';
import { formatRupiah, formatDate } from '@/utils/formatters';
import { resolveProductImage } from '@/utils/productImage';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme/ThemeContext';
import { Truck, MapPin, ChevronRight, User } from 'lucide-react-native';

export interface OrderCardProps {
  order: Order;
  onPress?: () => void;
  onActionPress?: () => void;
  actionLabel?: string;
  style?: StyleProp<ViewStyle>;
}

const getOrderStatusBadgeVariant = (
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

export const OrderCard: React.FC<OrderCardProps> = ({
  order,
  onPress,
  onActionPress,
  actionLabel,
  style,
}) => {
  const { colors, isDark } = useTheme();

  const firstItem = order.items && order.items.length > 0 ? order.items[0] : null;
  const totalItemCount = order.items
    ? order.items.reduce((acc, i) => acc + i.quantity, 0)
    : 0;
  const extraItemsCount = order.items ? order.items.length - 1 : 0;

  return (
    <Card
      onPress={onPress}
      sheen
      variant="elevated"
      style={[
        styles.card,
        {
          backgroundColor: isDark ? 'rgba(22, 58, 38, 0.72)' : '#FFFFFF',
          borderColor: isDark ? 'rgba(209, 245, 232, 0.16)' : '#DDE8E0',
        },
        style,
      ]}
    >
      {/* 1. Header: Order ID, Date & Status */}
      <View style={styles.headerRow}>
        <View style={styles.idGroup}>
          <Text
            style={[
              styles.orderNumber,
              { color: isDark ? '#FFFFFF' : '#183326' },
            ]}
          >
            {order.orderNumber || order.id}
          </Text>
          <Text style={[styles.dateText, { color: isDark ? '#8BA899' : '#7E9180' }]}>
            {formatDate(order.createdAt)}
          </Text>
        </View>

        <Badge variant={getOrderStatusBadgeVariant(order.status)} size="sm" dot>
          {order.status}
        </Badge>
      </View>

      {/* 2. Buyer & Logistics Block — Clear Separated Regions */}
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

      {/* 3. Product Preview Row */}
      {firstItem ? (
        <View style={styles.productRow}>
          <Image
            source={resolveProductImage(firstItem.productImage, firstItem.productName)}
            style={[
              styles.productImage,
              {
                backgroundColor: isDark ? 'rgba(255, 255, 255, 0.06)' : '#F8FAF8',
                borderColor: isDark ? 'rgba(209, 245, 232, 0.16)' : '#DDE8E0',
              },
            ]}
            resizeMode="cover"
          />

          <View style={styles.productDetails}>
            <Text
              style={[
                styles.productName,
                { color: isDark ? '#FFFFFF' : '#183326' },
              ]}
              numberOfLines={1}
            >
              {firstItem.productName}
            </Text>

            <Text style={[styles.productMeta, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
              {firstItem.quantity} {firstItem.unit || 'unit'} × {formatRupiah(firstItem.unitPrice)}
            </Text>

            {extraItemsCount > 0 ? (
              <Text style={[styles.extraCount, { color: isDark ? colors.mint : colors.primary }]}>
                +{extraItemsCount} produk pertanian lainnya
              </Text>
            ) : null}
          </View>

          <View style={styles.courierBadge}>
            <Truck size={12} color={isDark ? '#D1F5E8' : '#31572C'} />
            <Text
              style={[
                styles.courierText,
                { color: isDark ? '#D1F5E8' : '#31572C' },
              ]}
              numberOfLines={1}
            >
              {order.courier.split(' ')[0]}
            </Text>
          </View>
        </View>
      ) : null}

      {/* 4. Footer: Total Amount & Action CTA */}
      <View
        style={[
          styles.footerRow,
          { borderTopColor: isDark ? 'rgba(255, 255, 255, 0.08)' : '#EFF4F0' },
        ]}
      >
        <View style={styles.totalCol}>
          <Text style={[styles.totalLabel, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
            Total Tagihan ({totalItemCount} barang)
          </Text>
          <Text
            style={[
              styles.totalAmount,
              { color: isDark ? '#ECF39E' : colors.primaryDark },
            ]}
          >
            {formatRupiah(order.totalAmount)}
          </Text>
        </View>

        {onActionPress && actionLabel ? (
          <PressableScale
            onPress={onActionPress}
            style={[
              styles.actionButton,
              {
                backgroundColor: isDark ? 'rgba(64, 145, 108, 0.30)' : '#EAF4EE',
                borderColor: isDark ? 'rgba(209, 245, 232, 0.30)' : '#C6E2D0',
              },
            ]}
          >
            <Text
              style={[
                styles.actionBtnText,
                { color: isDark ? '#D1F5E8' : '#31572C' },
              ]}
            >
              {actionLabel}
            </Text>
            <ChevronRight size={14} color={isDark ? '#D1F5E8' : '#31572C'} />
          </PressableScale>
        ) : null}
      </View>
    </Card>
  );
};

const styles = StyleSheet.create({
  card: {
    padding: 15,
    marginBottom: 10,
    borderRadius: 20,
    borderWidth: 1,
    gap: 10,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.06,
    shadowRadius: 10,
    elevation: 2,
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
  },
  idGroup: {
    gap: 2,
  },
  orderNumber: {
    fontSize: 14,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  dateText: {
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
  productRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  productImage: {
    width: 52,
    height: 52,
    borderRadius: 12,
    borderWidth: 1,
  },
  productDetails: {
    flex: 1,
    gap: 2,
  },
  productName: {
    fontSize: 13,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  productMeta: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.regular,
  },
  extraCount: {
    fontSize: 10.5,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  courierBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 10,
    backgroundColor: 'rgba(64, 145, 108, 0.12)',
  },
  courierText: {
    fontSize: 10.5,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  footerRow: {
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
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
  },
  totalAmount: {
    fontSize: 15.5,
    fontWeight: '800',
    fontFamily: typography.fontFamily.extrabold,
    letterSpacing: -0.3,
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 12,
    paddingVertical: 7,
    borderRadius: 12,
    borderWidth: 1,
  },
  actionBtnText: {
    fontSize: 12,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
});
