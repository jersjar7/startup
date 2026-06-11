import React, { useState } from 'react';
import { View, TextInput, Pressable, type KeyboardTypeOptions } from 'react-native';
import Svg, { Path, Circle } from 'react-native-svg';
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
// Secure fields get a show/hide eye — blind password entry on a phone means
// failed attempts.
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
  const [hidden, setHidden] = useState(secureTextEntry === true);

  return (
    <View>
      <TextInput
        testID={testID}
        value={value}
        onChangeText={onChangeText}
        placeholder={placeholder}
        placeholderTextColor={theme.palette.ink4}
        secureTextEntry={hidden}
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
          paddingRight: secureTextEntry ? 46 : 16,
          fontFamily: theme.fontFamily.body,
          fontSize: 16,
          color: theme.palette.charcoal,
        }}
      />
      {secureTextEntry ? (
        <Pressable
          onPress={() => setHidden((h) => !h)}
          hitSlop={10}
          accessibilityLabel={hidden ? 'Show password' : 'Hide password'}
          style={{ position: 'absolute', right: 14, top: 0, height: 54, justifyContent: 'center' }}
        >
          <Svg width={20} height={20} viewBox="0 0 256 256" fill="none" stroke={theme.palette.ink3} strokeWidth={16}>
            <Path d="M128 56c-64 0-104 72-104 72s40 72 104 72 104-72 104-72-40-72-104-72z" />
            <Circle cx={128} cy={128} r={34} />
            {hidden ? null : <Path d="M48 40l160 176" strokeLinecap="round" />}
          </Svg>
        </Pressable>
      ) : null}
    </View>
  );
}
