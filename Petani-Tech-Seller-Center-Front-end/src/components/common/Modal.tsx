import React from 'react';
import {
  Modal as RNModal,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { X } from 'lucide-react-native';
import { useTheme } from '@/theme/ThemeContext';
import { typography } from '@/theme/typography';

export interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  description?: string;
  children: React.ReactNode;
  maxWidth?: 'sm' | 'md' | 'lg' | 'xl';
}

export const Modal: React.FC<ModalProps> = ({
  isOpen,
  onClose,
  title,
  description,
  children,
}) => {
  const { colors, isDark } = useTheme();

  return (
    <RNModal
      visible={isOpen}
      transparent
      animationType="fade"
      onRequestClose={onClose}
    >
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        style={[
          styles.backdrop,
          {
            backgroundColor: isDark
              ? 'rgba(0, 0, 0, 0.75)'
              : 'rgba(27, 38, 29, 0.55)',
          },
        ]}
      >
        <TouchableOpacity
          activeOpacity={1}
          onPress={onClose}
          style={styles.touchableBackground}
        />

        <View
          style={[
            styles.dialog,
            {
              backgroundColor: colors.surface,
              borderColor: colors.border,
            },
          ]}
        >
          {/* Header */}
          <View
            style={[
              styles.header,
              { borderBottomColor: colors.borderSubtle },
            ]}
          >
            <View style={styles.headerText}>
              {title ? (
                <Text style={[styles.title, { color: colors.text }]}>
                  {title}
                </Text>
              ) : null}
              {description ? (
                <Text
                  style={[styles.description, { color: colors.textSecondary }]}
                >
                  {description}
                </Text>
              ) : null}
            </View>
            <TouchableOpacity
              onPress={onClose}
              hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
              style={[
                styles.closeButton,
                {
                  backgroundColor: isDark
                    ? 'rgba(255, 255, 255, 0.12)'
                    : '#F0F5F1',
                },
              ]}
            >
              <X size={18} color={colors.textSecondary} />
            </TouchableOpacity>
          </View>

          {/* Body */}
          <ScrollView
            style={styles.body}
            contentContainerStyle={styles.bodyContent}
            keyboardShouldPersistTaps="handled"
            showsVerticalScrollIndicator={false}
          >
            {children}
          </ScrollView>
        </View>
      </KeyboardAvoidingView>
    </RNModal>
  );
};

const styles = StyleSheet.create({
  backdrop: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 16,
  },
  touchableBackground: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  dialog: {
    width: '100%',
    maxWidth: 480,
    maxHeight: '85%',
    borderRadius: 24,
    overflow: 'hidden',
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.25,
    shadowRadius: 18,
    elevation: 8,
    borderWidth: 1.5,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
    padding: 18,
    borderBottomWidth: 1,
  },
  headerText: {
    flex: 1,
    paddingRight: 12,
    gap: 4,
  },
  title: {
    fontSize: 16,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
  },
  description: {
    fontSize: 12,
    fontFamily: typography.fontFamily.regular,
    lineHeight: 18,
  },
  closeButton: {
    padding: 6,
    borderRadius: 9999,
  },
  body: {
    maxHeight: 520,
  },
  bodyContent: {
    padding: 18,
  },
});
