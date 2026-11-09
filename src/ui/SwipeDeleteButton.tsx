import { Button } from '@expo/ui/swift-ui';
import { tint } from '@expo/ui/swift-ui/modifiers';
import { colors } from '@/ui/theme';

/**
 * A red Delete for list swipe actions. It is tinted instead of using `role="destructive"` because
 * SwiftUI removes the row as soon as a destructive swipe action is tapped, so a row would vanish
 * even when the confirmation alert is cancelled.
 */
export function SwipeDeleteButton({ onPress }: { onPress: () => void }) {
  return (
    <Button
      label="Delete"
      systemImage="trash"
      onPress={onPress}
      modifiers={[tint(colors.destructive)]}
    />
  );
}
