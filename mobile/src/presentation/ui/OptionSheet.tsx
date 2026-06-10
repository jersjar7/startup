import React from 'react';
import { Modal, View, Pressable } from 'react-native';
import { Text } from './Text';
import { Overline } from './Overline';
import { useTheme } from '@/core/theme/useTheme';

export interface SheetOption {
  label: string;
  value: string;
}

interface Props {
  visible: boolean;
  title: string;
  options: readonly SheetOption[];
  selected?: string;
  onSelect: (value: string) => void;
  onClose: () => void;
}

// A bottom-sheet single-choice picker. Tap the scrim to dismiss.
export function OptionSheet({ visible, title, options, selected, onSelect, onClose }: Props) {
  const theme = useTheme();
  return (
    <Modal visible={visible} transparent animationType="fade" onRequestClose={onClose}>
      <Pressable
        onPress={onClose}
        style={{ flex: 1, backgroundColor: 'rgba(28,28,28,0.35)', justifyContent: 'flex-end' }}
      >
        <Pressable
          onPress={() => undefined}
          style={{
            backgroundColor: theme.palette.cream,
            borderTopLeftRadius: 24,
            borderTopRightRadius: 24,
            padding: 22,
            paddingBottom: 34,
          }}
        >
          <Overline color={theme.palette.ink3}>{title}</Overline>
          <View style={{ marginTop: 12, gap: 8 }}>
            {options.map((o) => {
              const on = o.value === selected;
              return (
                <Pressable
                  key={o.value}
                  onPress={() => onSelect(o.value)}
                  style={{
                    height: 54,
                    borderRadius: 14,
                    paddingHorizontal: 18,
                    justifyContent: 'center',
                    backgroundColor: on ? theme.palette.emberBg : theme.palette.white,
                    borderWidth: 1.5,
                    borderColor: on ? theme.palette.ember : theme.palette.line,
                  }}
                >
                  <Text variant="bodyStrong" color={on ? theme.palette.emberInk : theme.palette.charcoal}>
                    {o.label}
                  </Text>
                </Pressable>
              );
            })}
          </View>
        </Pressable>
      </Pressable>
    </Modal>
  );
}
