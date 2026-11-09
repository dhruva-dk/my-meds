import { HStack, Text, TextField, useNativeState, VStack } from '@expo/ui/swift-ui';
import {
  accessibilityHidden,
  accessibilityLabel,
  foregroundStyle,
} from '@expo/ui/swift-ui/modifiers';
import type { ComponentProps } from 'react';
import { useCallback, useRef, useState } from 'react';
import { useWindowDimensions } from 'react-native';
import { colors } from './theme';

/** Text state shared with SwiftUI, mirrored in React for validation and change detection. */
export function useTextValue(
  initial: string,
  transform?: (previous: string, next: string) => string,
) {
  const state = useNativeState(initial);
  const [value, setValue] = useState(initial);
  const latest = useRef(initial);
  const onChange = useCallback(
    (next: string) => {
      const result = transform ? transform(latest.current, next) : next;
      latest.current = result;
      if (result !== next) state.set(result);
      setValue(result);
    },
    [state, transform],
  );
  const set = useCallback(
    (next: string) => {
      latest.current = next;
      state.set(next);
      setValue(next);
    },
    [state],
  );
  return { state, value, onChange, set };
}

export type TextValue = ReturnType<typeof useTextValue>;

/** Secondary text that meets the 4.5:1 floor. */
export function SecondaryText({ children }: { children: string }) {
  return <Text modifiers={[foregroundStyle(colors.secondary)]}>{children}</Text>;
}

/** A section header in the app's readable secondary colour. */
export function SectionHeader({ children }: { children: string }) {
  return (
    <Text modifiers={[foregroundStyle(colors.secondary), accessibilityHidden(false)]}>
      {children}
    </Text>
  );
}

type TextRowProps = {
  label: string;
  value: TextValue;
  placeholder?: string;
  multiline?: boolean;
  modifiers?: ComponentProps<typeof TextField>['modifiers'];
};

/** A labelled text field. The label moves above the field at very large text sizes. */
export function TextRow({ label, value, placeholder, multiline, modifiers = [] }: TextRowProps) {
  const { fontScale } = useWindowDimensions();
  const field = (
    <TextField
      text={value.state}
      onTextChange={value.onChange}
      placeholder={placeholder}
      axis={multiline ? 'vertical' : 'horizontal'}
      modifiers={[accessibilityLabel(label), ...modifiers]}
    />
  );
  const caption = <Text modifiers={[accessibilityHidden(true)]}>{label}</Text>;
  if (fontScale >= 1.35) {
    return (
      <VStack alignment="leading" spacing={4}>
        {caption}
        {field}
      </VStack>
    );
  }
  return (
    <HStack spacing={12} alignment={multiline ? 'top' : 'center'}>
      {caption}
      {field}
    </HStack>
  );
}

/** A text field whose section header already names it. */
export function BareTextRow({ label, value, placeholder }: Omit<TextRowProps, 'multiline'>) {
  return (
    <TextField
      text={value.state}
      onTextChange={value.onChange}
      placeholder={placeholder}
      axis="vertical"
      modifiers={[accessibilityLabel(label)]}
    />
  );
}
