import React, { useState } from 'react';
import {
  StyleSheet,
  Text,
  TextInput,
  TextInputProps,
  View,
  StyleProp,
  ViewStyle,
  TextStyle,
  TouchableOpacity,
} from 'react-native';
import { Eye, EyeOff } from 'lucide-react-native';
import { typography } from '@/theme/typography';
import { useTheme } from '@/theme/ThemeContext';

export interface InputProps extends Omit<TextInputProps, 'onChange'> {
  label?: string;
  error?: string;
  hint?: string;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  containerStyle?: StyleProp<ViewStyle>;
  inputStyle?: StyleProp<TextStyle>;
  variant?: 'default' | 'glass';
  type?: string;
  required?: boolean;
  min?: number;
  max?: number;
  onChange?: (e: { target: { value: string } }) => void;
}

export const Input = React.forwardRef<TextInput, InputProps>(
  (
    {
      label,
      error,
      hint,
      leftIcon,
      rightIcon,
      containerStyle,
      inputStyle,
      variant = 'default',
      type,
      onChange,
      onChangeText,
      value,
      onFocus,
      onBlur,
      ...props
    },
    ref
  ) => {
    const { colors, isDark } = useTheme();
    const isPasswordType = type === 'password' || props.secureTextEntry;
    const [isPasswordVisible, setIsPasswordVisible] = useState(false);
    const [isFocused, setIsFocused] = useState(false);

    const keyboardType =
      props.keyboardType ||
      (type === 'number' ? 'numeric' : type === 'email' ? 'email-address' : 'default');

    const handleChangeText = (text: string) => {
      if (onChangeText) {
        onChangeText(text);
      }
      if (onChange) {
        onChange({ target: { value: text } });
      }
    };

    const handleFocus = (e: any) => {
      setIsFocused(true);
      if (onFocus) onFocus(e);
    };

    const handleBlur = (e: any) => {
      setIsFocused(false);
      if (onBlur) onBlur(e);
    };

    const getBgColor = () => {
      if (error) {
        return isDark ? 'rgba(239, 68, 68, 0.15)' : '#FFF8F8';
      }
      if (variant === 'glass') {
        return isDark ? 'rgba(22, 58, 38, 0.65)' : 'rgba(255, 255, 255, 0.90)';
      }
      return colors.inputBg;
    };

    const getBorderColor = () => {
      if (error) {
        return colors.semantic.danger.DEFAULT;
      }
      if (isFocused) {
        return colors.primary;
      }
      if (variant === 'glass') {
        return isDark ? 'rgba(209, 245, 232, 0.25)' : '#DDE8E0';
      }
      return colors.inputBorder;
    };

    return (
      <View style={[styles.container, containerStyle]}>
        {label ? (
          <Text style={[styles.label, { color: colors.text }]}>
            {label}
            {props.required && <Text style={styles.required}> *</Text>}
          </Text>
        ) : null}

        <View
          style={[
            styles.inputWrapper,
            {
              backgroundColor: getBgColor(),
              borderColor: getBorderColor(),
            },
            variant === 'glass' && styles.inputGlass,
            isFocused && styles.inputFocused,
          ]}
        >
          {leftIcon ? <View style={styles.leftIcon}>{leftIcon}</View> : null}

          <TextInput
            ref={ref}
            value={value}
            onChangeText={handleChangeText}
            onFocus={handleFocus}
            onBlur={handleBlur}
            secureTextEntry={isPasswordType && !isPasswordVisible}
            keyboardType={keyboardType}
            placeholderTextColor={colors.inputPlaceholder}
            style={[
              styles.input,
              { color: colors.inputText },
              leftIcon ? styles.inputWithLeftIcon : null,
              rightIcon || isPasswordType ? styles.inputWithRightIcon : null,
              inputStyle,
            ]}
            {...props}
          />

          {isPasswordType ? (
            <TouchableOpacity
              onPress={() => setIsPasswordVisible(!isPasswordVisible)}
              style={styles.rightIcon}
              hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
              activeOpacity={0.7}
            >
              {isPasswordVisible ? (
                <EyeOff size={18} color={isFocused ? colors.primary : colors.textMuted} />
              ) : (
                <Eye size={18} color={isFocused ? colors.primary : colors.textMuted} />
              )}
            </TouchableOpacity>
          ) : rightIcon ? (
            <View style={styles.rightIcon}>{rightIcon}</View>
          ) : null}
        </View>

        {error ? <Text style={styles.errorText}>{error}</Text> : null}
        {!error && hint ? (
          <Text style={[styles.hintText, { color: colors.textSecondary }]}>{hint}</Text>
        ) : null}
      </View>
    );
  }
);

Input.displayName = 'Input';

export const GlassInput = React.forwardRef<TextInput, InputProps>((props, ref) => (
  <Input ref={ref} {...props} variant="glass" />
));

GlassInput.displayName = 'GlassInput';

const styles = StyleSheet.create({
  container: {
    width: '100%',
    gap: 6,
  },
  label: {
    fontSize: 13,
    fontWeight: '600',
    fontFamily: typography.fontFamily.semibold,
    letterSpacing: 0.1,
  },
  required: {
    color: '#EF4444',
  },
  inputWrapper: {
    position: 'relative',
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1.5,
    borderRadius: 16,
    minHeight: 48,
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.04,
    shadowRadius: 4,
    elevation: 1,
  },
  inputGlass: {
    shadowColor: '#183326',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 6,
    elevation: 2,
  },
  inputFocused: {
    shadowOpacity: 0.16,
    shadowRadius: 8,
    elevation: 2,
  },
  input: {
    flex: 1,
    paddingHorizontal: 16,
    paddingVertical: 12,
    fontSize: 14,
    fontFamily: typography.fontFamily.regular,
  },
  inputWithLeftIcon: {
    paddingLeft: 44,
  },
  inputWithRightIcon: {
    paddingRight: 44,
  },
  leftIcon: {
    position: 'absolute',
    left: 14,
    zIndex: 1,
  },
  rightIcon: {
    position: 'absolute',
    right: 14,
    zIndex: 1,
  },
  errorText: {
    fontSize: 11.5,
    color: '#EF4444',
    fontWeight: '500',
    fontFamily: typography.fontFamily.medium,
  },
  hintText: {
    fontSize: 11.5,
    fontFamily: typography.fontFamily.regular,
  },
});
