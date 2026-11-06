import { Pressable, StyleSheet, Text, View } from 'react-native';
import { colors } from './theme';

type Props = {
  title: string;
  message: string;
  actionLabel?: string;
  onAction?: () => void;
};

/** A full-screen message for states the app cannot render normally. */
export function MessageScreen({ title, message, actionLabel, onAction }: Props) {
  return (
    <View style={styles.container}>
      <Text style={styles.title} accessibilityRole="header">
        {title}
      </Text>
      <Text style={styles.message}>{message}</Text>
      {actionLabel && onAction ? (
        <Pressable
          accessibilityRole="button"
          onPress={onAction}
          style={({ pressed }) => [styles.button, pressed && styles.pressed]}
        >
          <Text style={styles.buttonText}>{actionLabel}</Text>
        </Pressable>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 32,
    gap: 12,
    backgroundColor: colors.background,
  },
  title: { fontSize: 22, fontWeight: '600', color: colors.label, textAlign: 'center' },
  message: { fontSize: 17, color: colors.secondaryLabel, textAlign: 'center' },
  button: {
    marginTop: 12,
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 12,
    backgroundColor: colors.tint,
  },
  pressed: { opacity: 0.7 },
  buttonText: { fontSize: 17, fontWeight: '600', color: colors.onTint },
});
