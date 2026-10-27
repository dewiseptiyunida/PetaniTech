import React from 'react';
import {
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { useToastStore } from '@/store/useToastStore';
import { Toast, ToastVariant } from '@/types';
import { CheckCircle2, XCircle, AlertTriangle, Info, X } from 'lucide-react-native';
import { colors } from '@/theme/colors';
import { typography } from '@/theme/typography';

const VARIANT_CONFIG: Record<
  ToastVariant,
  {
    icon: (color: string) => React.ReactNode;
    color: string;
    bgColor: string;
  }
> = {
  success: {
    icon: (color) => <CheckCircle2 size={18} color={color} />,
    color: colors.primary.DEFAULT,
    bgColor: '#EAF4EE',
  },
  error: {
    icon: (color) => <XCircle size={18} color={color} />,
    color: colors.semantic.danger.DEFAULT,
    bgColor: '#FFF1F2',
  },
  warning: {
    icon: (color) => <AlertTriangle size={18} color={color} />,
    color: '#D97706',
    bgColor: '#FFFBEB',
  },
  info: {
    icon: (color) => <Info size={18} color={color} />,
    color: '#2563EB',
    bgColor: '#EFF6FF',
  },
};

const ToastItem: React.FC<{ toast: Toast }> = ({ toast }) => {
  const removeToast = useToastStore((state) => state.removeToast);
  const config = VARIANT_CONFIG[toast.variant];

  return (
    <View style={[styles.toastItem, { borderLeftColor: config.color }]}>
      <View style={[styles.iconContainer, { backgroundColor: config.bgColor }]}>
        {config.icon(config.color)}
      </View>

      <View style={styles.textContainer}>
        <Text style={styles.toastTitle}>{toast.title}</Text>
        {toast.message ? <Text style={styles.toastMessage}>{toast.message}</Text> : null}
      </View>

      <TouchableOpacity
        onPress={() => removeToast(toast.id)}
        hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
        style={styles.closeBtn}
      >
        <X size={16} color={colors.neutral[400]} />
      </TouchableOpacity>
    </View>
  );
};

export const ToastContainer: React.FC = () => {
  const toasts = useToastStore((state) => state.toasts);

  if (toasts.length === 0) return null;

  return (
    <View pointerEvents="box-none" style={styles.container}>
      {toasts.map((t) => (
        <ToastItem key={t.id} toast={t} />
      ))}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 50,
    left: 16,
    right: 16,
    zIndex: 9999,
    gap: 8,
  },
  toastItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: '#E6EDE7',
    borderLeftWidth: 4,
    padding: 12,
    shadowColor: '#1B261D',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 4,
    gap: 10,
  },
  iconContainer: {
    width: 32,
    height: 32,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  textContainer: {
    flex: 1,
    gap: 2,
  },
  toastTitle: {
    fontSize: 13,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    color: colors.neutral[900],
  },
  toastMessage: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.regular,
    color: colors.neutral[600],
  },
  closeBtn: {
    padding: 4,
  },
});
