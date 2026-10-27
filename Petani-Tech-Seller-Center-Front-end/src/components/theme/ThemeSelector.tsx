import React from 'react';
import {
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { Sun, Moon, Smartphone, Check } from 'lucide-react-native';
import { useTheme } from '@/theme/ThemeContext';
import { ThemeMode } from '@/theme/types';
import { typography } from '@/theme/typography';
import { PressableScale } from '@/components/common/Motion';

interface ThemeOption {
  key: ThemeMode;
  title: string;
  subtitle: string;
  icon: typeof Sun;
}

const THEME_OPTIONS: ThemeOption[] = [
  {
    key: 'light',
    title: 'Mode Terang',
    subtitle: 'Tampilan terang dengan latar bersih dan aksen hijau',
    icon: Sun,
  },
  {
    key: 'dark',
    title: 'Mode Gelap',
    subtitle: 'Tampilan gelap forest green yang nyaman di malam hari',
    icon: Moon,
  },
  {
    key: 'system',
    title: 'Ikuti Sistem Perangkat',
    subtitle: 'Tema otomatis mengikuti preferensi perangkat Anda',
    icon: Smartphone,
  },
];

export function ThemeSelector() {
  const { mode, setMode, colors, isDark } = useTheme();

  return (
    <View style={styles.container}>
      <View style={styles.optionsList}>
        {THEME_OPTIONS.map((option) => {
          const isSelected = mode === option.key;
          const Icon = option.icon;

          return (
            <PressableScale
              key={option.key}
              onPress={() => setMode(option.key)}
              accessibilityRole="radio"
              accessibilityState={{ selected: isSelected }}
              accessibilityLabel={`${option.title}: ${option.subtitle}`}
              style={[
                styles.optionCard,
                {
                  backgroundColor: isSelected
                    ? isDark
                      ? 'rgba(64, 145, 108, 0.28)'
                      : '#EAF4EE'
                    : isDark
                    ? 'rgba(255, 255, 255, 0.05)'
                    : '#FFFFFF',
                  borderColor: isSelected
                    ? colors.primary
                    : isDark
                    ? 'rgba(255, 255, 255, 0.12)'
                    : '#E3EDE6',
                },
              ]}
            >
              <View
                style={[
                  styles.iconBox,
                  {
                    backgroundColor: isSelected
                      ? colors.primary
                      : isDark
                      ? 'rgba(255, 255, 255, 0.1)'
                      : '#F0F5F1',
                  },
                ]}
              >
                <Icon
                  size={20}
                  color={
                    isSelected
                      ? '#FFFFFF'
                      : isDark
                      ? colors.mint
                      : colors.primaryDark
                  }
                />
              </View>

              <View style={styles.textCol}>
                <View style={styles.titleRow}>
                  <Text
                    style={[
                      styles.title,
                      {
                        color: colors.text,
                        fontFamily: isSelected
                          ? typography.fontFamily.bold
                          : typography.fontFamily.semibold,
                      },
                    ]}
                  >
                    {option.title}
                  </Text>
                  {isSelected && (
                    <View
                      style={[
                        styles.activeBadge,
                        { backgroundColor: colors.primary },
                      ]}
                    >
                      <Check size={11} color="#FFFFFF" strokeWidth={3} />
                      <Text style={styles.activeBadgeText}>Aktif</Text>
                    </View>
                  )}
                </View>
                <Text
                  style={[
                    styles.subtitle,
                    { color: colors.textSecondary },
                  ]}
                >
                  {option.subtitle}
                </Text>
              </View>
            </PressableScale>
          );
        })}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    width: '100%',
  },
  optionsList: {
    gap: 10,
  },
  optionCard: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    borderRadius: 18,
    borderWidth: 1.5,
    gap: 12,
  },
  iconBox: {
    width: 42,
    height: 42,
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
  },
  textCol: {
    flex: 1,
  },
  titleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 2,
  },
  title: {
    fontSize: 13.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  subtitle: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.regular,
    lineHeight: 16,
  },
  activeBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 3,
    paddingHorizontal: 7,
    paddingVertical: 2,
    borderRadius: 10,
  },
  activeBadgeText: {
    fontSize: 10,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
    color: '#FFFFFF',
  },
});
