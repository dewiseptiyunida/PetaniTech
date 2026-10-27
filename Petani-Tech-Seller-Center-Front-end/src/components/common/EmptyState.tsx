import React from 'react';
import { StyleSheet, Text, View, StyleProp, ViewStyle } from 'react-native';
import {
  AlertCircle,
  SearchX,
  Package,
  ShoppingCart,
  Inbox,
} from 'lucide-react-native';
import { Button } from './Button';
import { colors } from '@/theme/colors';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme/ThemeContext';

export type EmptyStateVariant = 'products' | 'orders' | 'transactions' | 'search' | 'error' | 'default';

const VARIANT_CONFIG = {
  products: {
    emoji: '🌱',
    title: 'Belum Ada Produk',
    description: 'Tambahkan produk pertanian pertama Anda untuk mulai berjualan ke ribuan petani mitra.',
    icon: Package,
  },
  orders: {
    emoji: '📦',
    title: 'Belum Ada Pesanan',
    description: 'Aktifkan program promosi musim tanam untuk mendatangkan pesanan baru.',
    icon: ShoppingCart,
  },
  transactions: {
    emoji: '💳',
    title: 'Belum Ada Transaksi',
    description: 'Riwayat transaksi keuangan toko akan muncul di sini setelah ada pesanan selesai.',
    icon: Inbox,
  },
  search: {
    emoji: '🔍',
    title: 'Hasil Pencarian Kosong',
    description: 'Tidak ada data yang sesuai dengan kata kunci atau filter yang Anda pilih.',
    icon: SearchX,
  },
  error: {
    emoji: '⚠️',
    title: 'Terjadi Kesalahan',
    description: 'Gagal memuat data. Periksa koneksi internet dan coba lagi.',
    icon: AlertCircle,
  },
  default: {
    emoji: '📋',
    title: 'Data Kosong',
    description: 'Belum ada data yang tersedia untuk ditampilkan saat ini.',
    icon: Inbox,
  },
};

export interface EmptyStateProps {
  variant?: EmptyStateVariant;
  title?: string;
  description?: string;
  emoji?: string;
  action?: {
    label: string;
    onClick?: () => void;
    onPress?: () => void;
  };
  secondaryAction?: {
    label: string;
    onClick?: () => void;
    onPress?: () => void;
  };
  style?: StyleProp<ViewStyle>;
}

export const EmptyState: React.FC<EmptyStateProps> = ({
  variant = 'default',
  title,
  description,
  emoji,
  action,
  secondaryAction,
  style,
}) => {
  const { isDark } = useTheme();
  const config = VARIANT_CONFIG[variant];
  const displayEmoji = emoji ?? config.emoji;
  const displayTitle = title ?? config.title;
  const displayDesc = description ?? config.description;

  return (
    <View style={[styles.container, style]}>
      <View
        style={[
          styles.emojiCircle,
          {
            backgroundColor: isDark
              ? 'rgba(64, 145, 108, 0.22)'
              : '#EAF4EE',
            borderColor: isDark
              ? 'rgba(209, 245, 232, 0.28)'
              : '#C3DBC7',
          },
        ]}
      >
        <Text style={styles.emojiText}>{displayEmoji}</Text>
      </View>

      <Text
        style={[
          styles.title,
          { color: isDark ? '#FFFFFF' : '#183326' },
        ]}
      >
        {displayTitle}
      </Text>
      <Text
        style={[
          styles.description,
          { color: isDark ? '#D1F5E8' : '#64746A' },
        ]}
      >
        {displayDesc}
      </Text>

      {action ? (
        <View style={styles.actionRow}>
          <Button
            variant="primary"
            size="md"
            onPress={action.onPress || action.onClick}
          >
            {action.label}
          </Button>
          {secondaryAction ? (
            <Button
              variant="ghost"
              size="md"
              onPress={secondaryAction.onPress || secondaryAction.onClick}
            >
              {secondaryAction.label}
            </Button>
          ) : null}
        </View>
      ) : null}
    </View>
  );
};

export interface ErrorStateProps {
  message?: string;
  onRetry?: () => void;
  style?: StyleProp<ViewStyle>;
}

export const ErrorState: React.FC<ErrorStateProps> = ({
  message = 'Gagal memuat data. Silakan coba lagi.',
  onRetry,
  style,
}) => {
  const { isDark } = useTheme();

  return (
    <View style={[styles.container, style]}>
      <View
        style={[
          styles.emojiCircle,
          styles.errorCircle,
          {
            backgroundColor: isDark
              ? 'rgba(239, 68, 68, 0.20)'
              : '#FFF1F2',
            borderColor: isDark
              ? 'rgba(239, 68, 68, 0.35)'
              : '#FECDD3',
          },
        ]}
      >
        <AlertCircle
          size={32}
          color={isDark ? '#FCA5A5' : colors.semantic.danger.DEFAULT}
        />
      </View>
      <Text
        style={[
          styles.title,
          { color: isDark ? '#FFFFFF' : '#183326' },
        ]}
      >
        Oops! Terjadi Kesalahan
      </Text>
      <Text
        style={[
          styles.description,
          { color: isDark ? '#D1F5E8' : '#64746A' },
        ]}
      >
        {message}
      </Text>
      {onRetry ? (
        <Button variant="outline" size="sm" onPress={onRetry}>
          Coba Lagi
        </Button>
      ) : null}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 36,
    paddingHorizontal: 20,
    gap: 8,
  },
  emojiCircle: {
    width: 68,
    height: 68,
    borderRadius: 34,
    backgroundColor: '#EAF4EE',
    borderWidth: 1.5,
    borderColor: '#C3DBC7',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 6,
  },
  errorCircle: {
    backgroundColor: '#FFF1F2',
    borderColor: '#FECDD3',
  },
  emojiText: {
    fontSize: 30,
  },
  title: {
    fontSize: 16,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    color: colors.neutral[900],
    textAlign: 'center',
  },
  description: {
    fontSize: 12.5,
    fontFamily: typography.fontFamily.regular,
    color: colors.neutral[600],
    textAlign: 'center',
    lineHeight: 19,
    maxWidth: 290,
    marginBottom: 8,
  },
  actionRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    marginTop: 4,
  },
});
