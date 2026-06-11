import React from 'react';
import { TextInput, type KeyboardTypeOptions } from 'react-native';
import { useTheme } from '@/core/theme/useTheme';

interface Props {
  value: string;
  onChangeText: (v: string) => void;
  placeholder: string;
  secureTextEntry?: boolean;
  keyboardType?: KeyboardTypeOptions;
  autoCapitalize?: 'none' | 'sentences';
  testID?: string;
}

// Single-line input matching the 54px control height of buttons/choices.
export function TextField({
  value,
  onChangeText,
  placeholder,
  secureTextEntry,
  keyboardType,
  autoCapitalize = 'none',
  testID,
}: Props) {
  const theme = useTheme();
  return (
    <TextInput
      testID={testID}
      value={value}
      onChangeText={onChangeText}
      placeholder={placeholder}
      placeholderTextColor={theme.palette.ink4}
      secureTextEntry={secureTextEntry}
      keyboardType={keyboardType}
      autoCapitalize={autoCapitalize}
      autoCorrect={false}
      style={{
        height: 54,
        borderRadius: 14,
        borderWidth: 1.5,
        borderColor: theme.palette.line,
        backgroundColor: theme.palette.white,
        paddingHorizontal: 16,
        fontFamily: theme.fontFamily.body,
        fontSize: 16,
        color: theme.palette.charcoal,
      }}
    />
  );
}
