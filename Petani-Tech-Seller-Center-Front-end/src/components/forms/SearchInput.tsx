import React from 'react';
import {
  StyleSheet,
  TextInput,
  TouchableOpacity,
  View,
  StyleProp,
  ViewStyle,
} from 'react-native';
import { Search, X } from 'lucide-react-native';
import { useTheme } from '@/theme/ThemeContext';
import { typography } from '@/theme/typography';

export interface SearchInputProps {
  value: string;
  onChangeText: (text: string) => void;
  placeholder?: string;
  onClear?: () => void;
  variant?: 'default' | 'glass';
  style?: StyleProp<ViewStyle>;
}

export const SearchInput: React.FC<SearchInputProps> = ({
  value,
  onChangeText,
  placeholder = 'Cari...',
  onClear,
  variant = 'default',
  style,
}) => {
  const { colors, isDark } = useTheme();
  const [isFocused, setIsFocused] = React.useState(false);

  const handleClear = () => {
    onChangeText('');
    onClear?.();
  };

  const getBgColor = () => {
    if (variant === 'glass') {
      return isDark ? 'rgba(22, 58, 38, 0.65)' : 'rgba(255, 255, 255, 0.90)';
    }
    return colors.inputBg;
  };

  const getBorderColor = () => {
    if (isFocused) {
      return isDark ? colors.mint : colors.primary;
    }
    if (variant === 'glass') {
      return isDark ? 'rgba(209, 245, 232, 0.22)' : '#DDE8E0';
    }
    return colors.inputBorder;
  };

  return (
    <View
      style={[
        styles.container,
        {
          backgroundColor: getBgColor(),
          borderColor: getBorderColor(),
        },
        isFocused && styles.containerFocused,
        style,
      ]}
    >
      <Search
        size={18}
        color={isFocused ? (isDark ? colors.mint : colors.primary) : (isDark ? '#8BA899' : '#7E9180')}
        style={styles.searchIcon}
      />
      <TextInput
        value={value}
        onChangeText={onChangeText}
        onFocus={() => setIsFocused(true)}
        onBlur={() => setIsFocused(false)}
        placeholder={placeholder}
        placeholderTextColor={colors.inputPlaceholder}
        selectionColor={colors.primary}
        style={[styles.input, { color: colors.inputText }]}
      />
      {value.length > 0 && (
        <TouchableOpacity
          onPress={handleClear}
          hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
          style={styles.clearBtn}
          accessibilityLabel="Hapus pencarian"
        >
          <X size={16} color={colors.textMuted} />
        </TouchableOpacity>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1.5,
    borderRadius: 16,
    paddingHorizontal: 14,
    height: 46,
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 5,
    elevation: 2,
  },
  searchIcon: {
    marginRight: 8,
  },
  input: {
    flex: 1,
    fontSize: 13.5,
    fontFamily: typography.fontFamily.regular,
    paddingVertical: 8,
  },
  clearBtn: {
    padding: 4,
  },
  containerFocused: {
    shadowColor: '#40916C',
    shadowOpacity: 0.12,
    shadowRadius: 8,
    elevation: 3,
  },
});
