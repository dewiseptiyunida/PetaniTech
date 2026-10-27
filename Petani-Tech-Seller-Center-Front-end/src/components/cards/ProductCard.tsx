import React from 'react';
import {
  StyleSheet,
  Text,
  View,
  Image,
  StyleProp,
  ViewStyle,
} from 'react-native';
import { Product } from '@/types/product';
import { Card } from './Card';
import { Badge } from '@/components/common/Badge';
import { PressableScale } from '@/components/common/Motion';
import { formatRupiah } from '@/constants';
import { resolveProductImage } from '@/utils/productImage';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme/ThemeContext';
import { Edit2, Boxes, Trash2, AlertTriangle } from 'lucide-react-native';

export interface ProductCardProps {
  product: Product;
  onPress?: () => void;
  onEdit?: () => void;
  onUpdateStock?: () => void;
  onDelete?: () => void;
  style?: StyleProp<ViewStyle>;
}

export const ProductCard: React.FC<ProductCardProps> = ({
  product,
  onPress,
  onEdit,
  onUpdateStock,
  onDelete,
  style,
}) => {
  const { colors, isDark } = useTheme();

  const isLowStock = product.stock > 0 && product.stock <= product.minStockAlert;
  const isOutOfStock = product.stock === 0;

  const getBadgeVariant = (status: Product['status']): 'brand' | 'warning' | 'danger' | 'neutral' => {
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
      <View style={styles.row}>
        {/* Thumbnail Image */}
        <Image
          source={resolveProductImage(product.image, product.name)}
          style={[
            styles.image,
            {
              backgroundColor: isDark ? 'rgba(255, 255, 255, 0.06)' : '#F8FAF8',
              borderColor: isDark ? 'rgba(209, 245, 232, 0.18)' : '#DDE8E0',
            },
          ]}
          resizeMode="cover"
        />

        {/* Content Column */}
        <View style={styles.content}>
          <View style={styles.headerRow}>
            <Text
              style={[
                styles.category,
                { color: isDark ? '#D1F5E8' : '#64746A' },
              ]}
              numberOfLines={1}
            >
              {product.category}
            </Text>
            <Badge variant={getBadgeVariant(product.status)} size="sm" dot>
              {product.status}
            </Badge>
          </View>

          <Text
            style={[
              styles.name,
              { color: isDark ? '#FFFFFF' : '#183326' },
            ]}
            numberOfLines={2}
          >
            {product.name}
          </Text>

          <Text style={[styles.skuText, { color: isDark ? '#8BA899' : '#7E9180' }]}>
            SKU: {product.sku} {product.unit ? `· ${product.unit}` : ''}
          </Text>

          <Text
            style={[
              styles.price,
              { color: isDark ? '#ECF39E' : colors.primaryDark },
            ]}
          >
            {formatRupiah(product.price)}
          </Text>
        </View>
      </View>

      {/* Warning Strips for Low / Out of Stock */}
      {isLowStock ? (
        <View
          style={[
            styles.warningStrip,
            {
              backgroundColor: isDark ? 'rgba(245, 158, 11, 0.18)' : '#FEF9E7',
              borderColor: isDark ? 'rgba(245, 158, 11, 0.35)' : '#FDE68A',
            },
          ]}
        >
          <AlertTriangle size={13} color="#D97706" />
          <Text style={styles.warningStripText}>
            Stok menipis! Sisa {product.stock} {product.unit} (Alert: {product.minStockAlert})
          </Text>
        </View>
      ) : isOutOfStock ? (
        <View
          style={[
            styles.warningStrip,
            styles.dangerStrip,
            {
              backgroundColor: isDark ? 'rgba(239, 68, 68, 0.18)' : '#FEF2F2',
              borderColor: isDark ? 'rgba(239, 68, 68, 0.35)' : '#FECDD3',
            },
          ]}
        >
          <AlertTriangle size={13} color="#EF4444" />
          <Text style={[styles.warningStripText, styles.dangerStripText]}>
            Stok habis! Pembeli tidak dapat memesan produk ini.
          </Text>
        </View>
      ) : null}

      {/* Card Footer: Stock & Management Actions */}
      <View
        style={[
          styles.footer,
          { borderTopColor: isDark ? 'rgba(255, 255, 255, 0.08)' : '#EFF4F0' },
        ]}
      >
        <Text style={[styles.stockText, { color: isDark ? '#D1F5E8' : '#64746A' }]}>
          Stok:{' '}
          <Text style={[styles.stockBold, { color: isDark ? '#FFFFFF' : '#183326' }]}>
            {product.stock}
          </Text>{' '}
          · Terjual:{' '}
          <Text style={[styles.stockBold, { color: isDark ? '#FFFFFF' : '#183326' }]}>
            {product.soldCount}
          </Text>
        </Text>

        {/* Grouped Management Action Buttons */}
        <View style={styles.actionButtonsRow}>
          {onUpdateStock ? (
            <PressableScale
              onPress={onUpdateStock}
              style={[
                styles.actionBtn,
                {
                  backgroundColor: isDark ? 'rgba(64, 145, 108, 0.35)' : '#EAF5EE',
                  borderColor: isDark ? 'rgba(209, 245, 232, 0.35)' : '#C6E2D0',
                },
              ]}
              accessibilityLabel="Ubah stok"
            >
              <Boxes size={14} color={isDark ? '#D1F5E8' : '#2D6A4F'} />
            </PressableScale>
          ) : null}

          {onEdit ? (
            <PressableScale
              onPress={onEdit}
              style={[
                styles.actionBtn,
                {
                  backgroundColor: isDark ? 'rgba(255, 255, 255, 0.10)' : '#F2FBF5',
                  borderColor: isDark ? 'rgba(209, 245, 232, 0.22)' : '#DDE8E0',
                },
              ]}
              accessibilityLabel="Edit produk"
            >
              <Edit2 size={14} color={isDark ? '#D1F5E8' : '#2D6A4F'} />
            </PressableScale>
          ) : null}

          {onDelete ? (
            <PressableScale
              onPress={onDelete}
              style={[
                styles.actionBtn,
                {
                  backgroundColor: isDark ? 'rgba(239, 68, 68, 0.22)' : '#FEF2F2',
                  borderColor: isDark ? 'rgba(239, 68, 68, 0.35)' : '#FECDD3',
                },
              ]}
              accessibilityLabel="Hapus produk"
            >
              <Trash2 size={14} color="#EF4444" />
            </PressableScale>
          ) : null}
        </View>
      </View>
    </Card>
  );
};

const styles = StyleSheet.create({
  card: {
    padding: 14,
    marginBottom: 10,
    borderRadius: 20,
    borderWidth: 1.5,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
    overflow: 'hidden',
  },
  row: {
    flexDirection: 'row',
    gap: 12,
  },
  image: {
    width: 78,
    height: 78,
    borderRadius: 15,
    borderWidth: 1,
  },
  content: {
    flex: 1,
    justifyContent: 'space-between',
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 2,
  },
  category: {
    fontSize: 11,
    fontFamily: typography.fontFamily.medium,
    flex: 1,
    marginRight: 6,
  },
  name: {
    fontSize: 13.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    lineHeight: 18,
    marginBottom: 2,
  },
  skuText: {
    fontSize: 11,
    fontFamily: typography.fontFamily.regular,
    marginBottom: 4,
  },
  price: {
    fontSize: 15,
    fontWeight: '800',
    fontFamily: typography.fontFamily.extrabold,
    letterSpacing: -0.2,
  },
  warningStrip: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 10,
    borderWidth: 1,
    marginTop: 10,
  },
  warningStripText: {
    fontSize: 11,
    fontFamily: typography.fontFamily.medium,
    color: '#B45309',
    flex: 1,
  },
  dangerStrip: {},
  dangerStripText: {
    color: '#B91C1C',
  },
  footer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingTop: 10,
    marginTop: 10,
    borderTopWidth: 1,
  },
  stockText: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.regular,
  },
  stockBold: {
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  actionButtonsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  actionBtn: {
    width: 32,
    height: 32,
    borderRadius: 16,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
