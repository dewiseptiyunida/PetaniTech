import React from 'react';
import {
  Modal as RNModal,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  ActivityIndicator,
} from 'react-native';
import {
  AlertTriangle,
  Trash2,
  CheckCircle2,
  Info,
  X,
} from 'lucide-react-native';
import { useTheme } from '@/theme/ThemeContext';
import { typography } from '@/theme/typography';

export type ConfirmationType = 'danger' | 'warning' | 'info' | 'success';

export interface ConfirmationModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  title: string;
  message: string;
  confirmLabel?: string;
  cancelLabel?: string;
  type?: ConfirmationType;
  isLoading?: boolean;
}

export const ConfirmationModal: React.FC<ConfirmationModalProps> = ({
  isOpen,
  onClose,
  onConfirm,
  title,
  message,
  confirmLabel = 'Konfirmasi',
  cancelLabel = 'Batal',
  type = 'warning',
  isLoading = false,
}) => {
  const { isDark } = useTheme();

  const getTypeConfig = () => {
    switch (type) {
      case 'danger':
        return {
          icon: Trash2,
          iconColor: '#EF4444',
          circleBg: isDark ? 'rgba(239, 68, 68, 0.18)' : '#FEE2E2',
          circleBorder: isDark ? 'rgba(239, 68, 68, 0.32)' : '#FECACA',
          confirmBg: '#EF4444',
          confirmText: '#FFFFFF',
        };
      case 'success':
        return {
          icon: CheckCircle2,
          iconColor: '#40916C',
          circleBg: isDark ? 'rgba(64, 145, 108, 0.22)' : '#EAF4EE',
          circleBorder: isDark ? 'rgba(209, 245, 232, 0.30)' : '#C6E2D0',
          confirmBg: '#40916C',
          confirmText: '#FFFFFF',
        };
      case 'info':
        return {
          icon: Info,
          iconColor: '#2563EB',
          circleBg: isDark ? 'rgba(37, 99, 235, 0.18)' : '#EFF6FF',
          circleBorder: isDark ? 'rgba(37, 99, 235, 0.30)' : '#BFDBFE',
          confirmBg: '#2563EB',
          confirmText: '#FFFFFF',
        };
      case 'warning':
      default:
        return {
          icon: AlertTriangle,
          iconColor: '#D97706',
          circleBg: isDark ? 'rgba(217, 119, 6, 0.18)' : '#FEF3C7',
          circleBorder: isDark ? 'rgba(217, 119, 6, 0.32)' : '#FDE68A',
          confirmBg: '#D97706',
          confirmText: '#FFFFFF',
        };
    }
  };

  const config = getTypeConfig();
  const IconComponent = config.icon;

  return (
    <RNModal
      visible={isOpen}
      transparent
      animationType="fade"
      onRequestClose={isLoading ? undefined : onClose}
    >
      <View
        style={[
          styles.backdrop,
          {
            backgroundColor: isDark
              ? 'rgba(0, 0, 0, 0.78)'
              : 'rgba(24, 51, 38, 0.52)',
          },
        ]}
      >
        <TouchableOpacity
          activeOpacity={1}
          onPress={isLoading ? undefined : onClose}
          style={styles.touchableBackdrop}
        />

        <View
          style={[
            styles.dialog,
            {
              backgroundColor: isDark ? 'rgba(22, 58, 38, 0.95)' : '#FFFFFF',
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

          {/* Close button */}
          {!isLoading ? (
            <TouchableOpacity
              onPress={onClose}
              hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
              style={[
                styles.closeBtn,
                {
                  backgroundColor: isDark
                    ? 'rgba(255, 255, 255, 0.10)'
                    : '#F2FBF5',
                },
              ]}
            >
              <X size={16} color={isDark ? '#D1F5E8' : '#64746A'} />
            </TouchableOpacity>
          ) : null}

          {/* Icon Circle */}
          <View
            style={[
              styles.iconCircle,
              {
                backgroundColor: config.circleBg,
                borderColor: config.circleBorder,
              },
            ]}
          >
            <IconComponent size={28} color={config.iconColor} />
          </View>

          {/* Text Container */}
          <Text
            style={[
              styles.title,
              { color: isDark ? '#FFFFFF' : '#183326' },
            ]}
          >
            {title}
          </Text>

          <Text
            style={[
              styles.message,
              { color: isDark ? '#D1F5E8' : '#64746A' },
            ]}
          >
            {message}
          </Text>

          {/* Actions */}
          <View style={styles.actionsRow}>
            <TouchableOpacity
              onPress={onClose}
              disabled={isLoading}
              activeOpacity={0.75}
              style={[
                styles.cancelButton,
                {
                  backgroundColor: isDark
                    ? 'rgba(255, 255, 255, 0.10)'
                    : '#F2FBF5',
                  borderColor: isDark
                    ? 'rgba(209, 245, 232, 0.18)'
                    : '#DDE8E0',
                },
              ]}
            >
              <Text
                style={[
                  styles.cancelText,
                  { color: isDark ? '#D1F5E8' : '#64746A' },
                ]}
              >
                {cancelLabel}
              </Text>
            </TouchableOpacity>

            <TouchableOpacity
              onPress={onConfirm}
              disabled={isLoading}
              activeOpacity={0.82}
              style={[
                styles.confirmButton,
                { backgroundColor: config.confirmBg },
                isLoading && styles.btnDisabled,
              ]}
            >
              {isLoading ? (
                <ActivityIndicator size="small" color="#FFFFFF" />
              ) : (
                <Text
                  style={[
                    styles.confirmText,
                    { color: config.confirmText },
                  ]}
                >
                  {confirmLabel}
                </Text>
              )}
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </RNModal>
  );
};

const styles = StyleSheet.create({
  backdrop: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  touchableBackdrop: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  dialog: {
    width: '100%',
    maxWidth: 380,
    borderRadius: 24,
    borderWidth: 1.2,
    padding: 22,
    alignItems: 'center',
    position: 'relative',
    overflow: 'hidden',
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.18,
    shadowRadius: 20,
    elevation: 8,
  },
  sheenLine: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 1.5,
  },
  closeBtn: {
    position: 'absolute',
    top: 14,
    right: 14,
    width: 28,
    height: 28,
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconCircle: {
    width: 58,
    height: 58,
    borderRadius: 29,
    borderWidth: 1.5,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 6,
    marginBottom: 14,
  },
  title: {
    fontSize: 17,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    textAlign: 'center',
    marginBottom: 6,
  },
  message: {
    fontSize: 13,
    fontFamily: typography.fontFamily.regular,
    textAlign: 'center',
    lineHeight: 18,
    marginBottom: 20,
  },
  actionsRow: {
    flexDirection: 'row',
    gap: 12,
    width: '100%',
  },
  cancelButton: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 14,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  cancelText: {
    fontSize: 13.5,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  confirmButton: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
  },
  confirmText: {
    fontSize: 13.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  btnDisabled: {
    opacity: 0.7,
  },
});
