import { Button, ContentUnavailableView, Host } from '@expo/ui/swift-ui';
import { buttonStyle } from '@expo/ui/swift-ui/modifiers';

type Props = {
  title: string;
  message: string;
  systemImage?: 'exclamationmark.triangle';
  actionLabel?: string;
  onAction?: () => void;
};

/** A full-screen message for states the app cannot render normally. */
export function MessageScreen({ title, message, actionLabel, onAction }: Props) {
  return (
    <Host style={{ flex: 1 }}>
      <ContentUnavailableView
        title={title}
        systemImage="exclamationmark.triangle"
        description={message}
        actions={
          actionLabel && onAction ? (
            <Button
              label={actionLabel}
              onPress={onAction}
              modifiers={[buttonStyle('borderedProminent')]}
            />
          ) : undefined
        }
      />
    </Host>
  );
}
