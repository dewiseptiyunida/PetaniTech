import React, { useState } from 'react';
import {
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  StyleProp,
  ViewStyle,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import {
  Wallet,
  Eye,
  EyeOff,
  ArrowUpRight,
  History,
  TrendingUp,
} from 'lucide-react-native';
import { useTheme } from '@/theme/ThemeContext';
import { typography } from '@/theme/typography';

export interface FinancialAction {
  label: string;
  onPress: () => void;
  icon?: React.ReactNode;
}

export interface FinancialCardProps {
  title?: string;
  balance: number | string;
  subtitle?: string;
  trend?: {
    value: string;
    isPositive: boolean;
  };
  actions?: FinancialAction[];
  variant?: 'forestGradient' | 'whiteGlass' | 'softMint';
  style?: StyleProp<ViewStyle>;
  allowToggleVisibility?: boolean;
}

export const FinancialCard: React.FC<FinancialCardProps> = ({
  title = 'Saldo Penghasilan',
  balance,
  subtitle,
  trend,
  actions,
  variant = 'forestGradient',
  style,
  allowToggleVisibility = true,
}) => {
  const { isDark } = useTheme();
  const [isVisible, setIsVisible] = useState(true);

  const formattedBalance =
    typeof balance === 'number'
      ? `Rp ${balance.toLocaleString('id-ID')}`
      : balance;

  const displayBalance = isVisible ? formattedBalance : '••••••••';

  const isGradient = variant === 'forestGradient';

  return (
    <View
      style={[
        styles.card,
        !isGradient && {
          backgroundColor:
            variant === 'whiteGlass'
              ? isDark
                ? 'rgba(22, 58, 38, 0.75)'
                : '#FFFFFF'
              : isDark
              ? 'rgba(64, 145, 108, 0.22)'
              : '#F2FBF5',
          borderColor: isDark ? 'rgba(209, 245, 232, 0.22)' : '#DDE8E0',
          borderWidth: 1.5,
        },
        style,
      ]}
    >
      {isGradient ? (
        <LinearGradient
          colors={
            isDark
              ? ['#143526', '#1D4533', '#275B44']
              : ['#225A41', '#2D6E50', '#3D8C67']
          }
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={StyleSheet.absoluteFill}
        />
      ) : null}

      {/* Top Hairline Sheen */}
      <View
        style={[
          styles.sheenLine,
          {
            backgroundColor: isGradient
              ? 'rgba(255, 255, 255, 0.22)'
              : isDark
              ? 'rgba(255, 255, 255, 0.16)'
              : 'rgba(255, 255, 255, 0.95)',
          },
        ]}
      />

      {/* Header Row */}
      <View style={styles.headerRow}>
        <View style={styles.titleWithIcon}>
          <View
            style={[
              styles.iconWrapper,
              {
                backgroundColor: isGradient
                  ? 'rgba(255, 255, 255, 0.18)'
                  : isDark
                  ? 'rgba(209, 245, 232, 0.20)'
                  : '#D1F5E8',
              },
            ]}
          >
            <Wallet
              size={16}
              color={isGradient ? '#FFFFFF' : isDark ? '#D1F5E8' : '#31572C'}
            />
          </View>
          <Text
            style={[
              styles.title,
              {
                color: isGradient
                  ? 'rgba(255, 255, 255, 0.88)'
                  : isDark
                  ? '#D1F5E8'
                  : '#64746A',
              },
            ]}
          >
            {title}
          </Text>
        </View>

        {allowToggleVisibility ? (
          <TouchableOpacity
            onPress={() => setIsVisible(!isVisible)}
            hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
            style={[
              styles.eyeButton,
              {
                backgroundColor: isGradient
                  ? 'rgba(255, 255, 255, 0.15)'
                  : isDark
                  ? 'rgba(255, 255, 255, 0.10)'
                  : '#F2FBF5',
              },
            ]}
          >
            {isVisible ? (
              <Eye
                size={16}
                color={isGradient ? '#FFFFFF' : isDark ? '#D1F5E8' : '#64746A'}
              />
            ) : (
              <EyeOff
                size={16}
                color={isGradient ? '#FFFFFF' : isDark ? '#D1F5E8' : '#64746A'}
              />
            )}
          </TouchableOpacity>
        ) : null}
      </View>

      {/* Balance Amount Row */}
      <View style={styles.amountContainer}>
        <Text
          style={[
            styles.balanceText,
            {
              color: isGradient
                ? '#FFFFFF'
                : isDark
                ? '#FFFFFF'
                : '#183326',
            },
          ]}
          numberOfLines={1}
        >
          {displayBalance}
        </Text>

        {trend ? (
          <View
            style={[
              styles.trendBadge,
              {
                backgroundColor: isGradient
                  ? 'rgba(209, 245, 232, 0.22)'
                  : trend.isPositive
                  ? '#EAF4EE'
                  : '#FEF2F2',
              },
            ]}
          >
            <TrendingUp
              size={12}
              color={
                isGradient
                  ? '#D1F5E8'
                  : trend.isPositive
                  ? '#40916C'
                  : '#EF4444'
              }
            />
            <Text
              style={[
                styles.trendText,
                {
                  color: isGradient
                    ? '#D1F5E8'
                    : trend.isPositive
                    ? '#1E432E'
                    : '#B91C1C',
                },
              ]}
            >
              {trend.value}
            </Text>
          </View>
        ) : null}
      </View>

      {subtitle ? (
        <Text
          style={[
            styles.subtitle,
            {
              color: isGradient
                ? 'rgba(255, 255, 255, 0.72)'
                : isDark
                ? '#8BA899'
                : '#7E9180',
            },
          ]}
        >
          {subtitle}
        </Text>
      ) : null}

      {/* Action Buttons Row */}
      {actions && actions.length > 0 ? (
        <View style={styles.actionsRow}>
          {actions.map((act, index) => {
            const isFirst = index === 0;
            return (
              <TouchableOpacity
                key={act.label}
                onPress={act.onPress}
                activeOpacity={0.78}
                style={[
                  styles.actionBtn,
                  isGradient
                    ? isFirst
                      ? styles.actionBtnGradientPrimary
                      : styles.actionBtnGradientSecondary
                    : isFirst
                    ? styles.actionBtnCleanPrimary
                    : styles.actionBtnCleanSecondary,
                ]}
              >
                {act.icon ? (
                  act.icon
                ) : isFirst ? (
                  <ArrowUpRight
                    size={15}
                    color={isGradient ? '#183326' : '#FFFFFF'}
                  />
                ) : (
                  <History
                    size={14}
                    color={isGradient ? '#FFFFFF' : '#40916C'}
                  />
                )}
                <Text
                  style={[
                    styles.actionBtnText,
                    isGradient
                      ? isFirst
                        ? styles.actionTextGradientPrimary
                        : styles.actionTextGradientSecondary
                      : isFirst
                      ? styles.actionTextCleanPrimary
                      : styles.actionTextCleanSecondary,
                  ]}
                >
                  {act.label}
                </Text>
              </TouchableOpacity>
            );
          })}
        </View>
      ) : null}
    </View>
  );
};

export const FinancialSummaryCard = FinancialCard;

const styles = StyleSheet.create({
  card: {
    borderRadius: 22,
    padding: 18,
    position: 'relative',
    overflow: 'hidden',
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.12,
    shadowRadius: 14,
    elevation: 4,
  },
  sheenLine: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 1.5,
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 10,
  },
  titleWithIcon: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  iconWrapper: {
    width: 28,
    height: 28,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    fontSize: 12.5,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  eyeButton: {
    width: 32,
    height: 32,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  amountContainer: {
    flexDirection: 'row',
    alignItems: 'baseline',
    gap: 10,
    flexWrap: 'wrap',
  },
  balanceText: {
    fontSize: 24,
    fontWeight: '800',
    fontFamily: typography.fontFamily.extrabold,
    letterSpacing: -0.5,
  },
  trendBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 9999,
  },
  trendText: {
    fontSize: 11,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  subtitle: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.regular,
    marginTop: 4,
  },
  actionsRow: {
    flexDirection: 'row',
    gap: 10,
    marginTop: 16,
    paddingTop: 14,
    borderTopWidth: 1,
    borderTopColor: 'rgba(255, 255, 255, 0.15)',
  },
  actionBtn: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 6,
    paddingVertical: 10,
    paddingHorizontal: 12,
    borderRadius: 14,
  },
  actionBtnGradientPrimary: {
    backgroundColor: '#FFFFFF',
  },
  actionBtnGradientSecondary: {
    backgroundColor: 'rgba(255, 255, 255, 0.16)',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.25)',
  },
  actionBtnCleanPrimary: {
    backgroundColor: '#40916C',
  },
  actionBtnCleanSecondary: {
    backgroundColor: '#F2FBF5',
    borderWidth: 1,
    borderColor: '#DDE8E0',
  },
  actionBtnText: {
    fontSize: 12.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  actionTextGradientPrimary: {
    color: '#183326',
  },
  actionTextGradientSecondary: {
    color: '#FFFFFF',
  },
  actionTextCleanPrimary: {
    color: '#FFFFFF',
  },
  actionTextCleanSecondary: {
    color: '#31572C',
  },
});
