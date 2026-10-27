import type { ReactNode } from 'react';
import {
  ScrollView,
  StyleSheet,
  Text,
  View,
  type StyleProp,
  type ViewStyle,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTheme } from '@/theme/ThemeContext';
import { typography } from '@/theme/typography';
import { useBottomTabSpace } from '@/navigation/hooks';

export interface PageMetric {
  label: string;
  value: string;
  detail?: string;
}

export interface PageRecord {
  title: string;
  detail: string;
  value?: string;
  status?: string;
}

interface NativePageProps {
  title: string;
  subtitle: string;
  metrics?: PageMetric[];
  records?: PageRecord[];
  children?: ReactNode;
}

export function NativePage({ title, subtitle, metrics = [], records = [], children }: NativePageProps) {
  const { colors, isDark } = useTheme();
  const bottomSpace = useBottomTabSpace(20);

  return (
    <SafeAreaView
      style={[
        styles.safeArea,
        { backgroundColor: isDark ? colors.background : '#FAF9F6' },
      ]}
      edges={['top']}
    >
      <ScrollView
        contentContainerStyle={[styles.content, { paddingBottom: bottomSpace }]}
        keyboardShouldPersistTaps="handled"
      >
        <View style={styles.heading}>
          <Text
            style={[
              styles.eyebrow,
              { color: isDark ? colors.mint : colors.primary },
            ]}
          >
            PETANI TECH SELLER
          </Text>
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
              styles.subtitle,
              { color: isDark ? '#D1F5E8' : '#64746A' },
            ]}
          >
            {subtitle}
          </Text>
        </View>

        {metrics.length > 0 && (
          <View style={styles.metrics}>
            {metrics.map((metric) => (
              <View
                key={metric.label}
                style={[
                  styles.metric,
                  {
                    backgroundColor: isDark
                      ? 'rgba(22, 58, 38, 0.72)'
                      : '#FFFFFF',
                    borderColor: isDark
                      ? 'rgba(209, 245, 232, 0.16)'
                      : '#DDE8E0',
                  },
                ]}
              >
                <Text
                  style={[
                    styles.metricLabel,
                    { color: isDark ? '#8BA899' : '#64746A' },
                  ]}
                >
                  {metric.label}
                </Text>
                <Text
                  style={[
                    styles.metricValue,
                    { color: isDark ? '#FFFFFF' : '#183326' },
                  ]}
                >
                  {metric.value}
                </Text>
                {metric.detail ? (
                  <Text
                    style={[
                      styles.metricDetail,
                      { color: isDark ? colors.mint : colors.primary },
                    ]}
                  >
                    {metric.detail}
                  </Text>
                ) : null}
              </View>
            ))}
          </View>
        )}

        {children}

        {records.length > 0 && (
          <View style={styles.section}>
            <Text
              style={[
                styles.sectionTitle,
                { color: isDark ? '#FFFFFF' : '#183326' },
              ]}
            >
              Ringkasan
            </Text>
            {records.map((record, index) => (
              <View
                key={`${record.title}-${index}`}
                style={[
                  styles.record,
                  {
                    backgroundColor: isDark
                      ? 'rgba(22, 58, 38, 0.72)'
                      : '#FFFFFF',
                    borderColor: isDark
                      ? 'rgba(209, 245, 232, 0.16)'
                      : '#DDE8E0',
                  },
                ]}
              >
                <View style={styles.recordText}>
                  <Text
                    style={[
                      styles.recordTitle,
                      { color: isDark ? '#FFFFFF' : '#183326' },
                    ]}
                  >
                    {record.title}
                  </Text>
                  <Text
                    style={[
                      styles.recordDetail,
                      { color: isDark ? '#D1F5E8' : '#64746A' },
                    ]}
                  >
                    {record.detail}
                  </Text>
                  {record.status ? (
                    <Text
                      style={[
                        styles.status,
                        { color: isDark ? colors.mint : colors.primary },
                      ]}
                    >
                      {record.status}
                    </Text>
                  ) : null}
                </View>
                {record.value ? (
                  <Text
                    style={[
                      styles.recordValue,
                      { color: isDark ? colors.mint : colors.primary },
                    ]}
                  >
                    {record.value}
                  </Text>
                ) : null}
              </View>
            ))}
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

export function Surface({ children, style }: { children: ReactNode; style?: StyleProp<ViewStyle> }) {
  const { isDark } = useTheme();
  return (
    <View
      style={[
        styles.surface,
        {
          backgroundColor: isDark
            ? 'rgba(22, 58, 38, 0.72)'
            : '#FFFFFF',
          borderColor: isDark
            ? 'rgba(209, 245, 232, 0.16)'
            : '#DDE8E0',
        },
        style,
      ]}
    >
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  safeArea: { flex: 1 },
  content: { padding: 18, gap: 16 },
  heading: { gap: 4, marginBottom: 4 },
  eyebrow: {
    fontSize: 10.5,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    letterSpacing: 1.2,
  },
  title: {
    fontSize: 24,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
    letterSpacing: -0.3,
  },
  subtitle: {
    fontSize: 13,
    lineHeight: 18,
    fontFamily: typography.fontFamily.regular,
  },
  metrics: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
  metric: {
    flexGrow: 1,
    flexBasis: '45%',
    minHeight: 88,
    padding: 14,
    borderRadius: 18,
    borderWidth: 1,
    justifyContent: 'center',
    gap: 4,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.04,
    shadowRadius: 6,
    elevation: 2,
  },
  metricLabel: {
    fontSize: 11,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  metricValue: {
    fontSize: 19,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
  },
  metricDetail: {
    fontSize: 10.5,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
  },
  section: { gap: 10 },
  sectionTitle: {
    fontSize: 15,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
    marginBottom: 2,
  },
  surface: {
    padding: 16,
    borderRadius: 18,
    borderWidth: 1,
    gap: 10,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.04,
    shadowRadius: 6,
    elevation: 2,
  },
  record: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 12,
    padding: 14,
    borderRadius: 16,
    borderWidth: 1,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.04,
    shadowRadius: 6,
    elevation: 2,
  },
  recordText: { flex: 1, gap: 4 },
  recordTitle: {
    fontSize: 13,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
  recordDetail: {
    fontSize: 11.5,
    lineHeight: 16,
    fontFamily: typography.fontFamily.regular,
  },
  recordValue: {
    fontSize: 13,
    fontWeight: '800',
    fontFamily: typography.fontFamily.bold,
  },
  status: {
    fontSize: 10,
    fontWeight: '700',
    fontFamily: typography.fontFamily.bold,
  },
});
