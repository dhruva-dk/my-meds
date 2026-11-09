import { RNHostView } from '@expo/ui/swift-ui';
import { SymbolView } from 'expo-symbols';
import { Image, StyleSheet, View } from 'react-native';
import { colors } from './theme';

type Props = { uri: string | null; size?: number };

/** A medication photo, or a pill placeholder when there is none. */
export function Thumbnail({ uri, size = 56 }: Props) {
  const box = { width: size, height: size, borderRadius: size / 5 };
  if (uri) {
    return <Image source={{ uri }} style={[styles.image, box]} accessibilityIgnoresInvertColors />;
  }
  return (
    <View style={[styles.placeholder, box]}>
      <SymbolView name="pills.fill" size={size * 0.45} tintColor={colors.secondary} />
    </View>
  );
}

/**
 * The thumbnail inside SwiftUI. A React Native image scales large 1.2.0 photos off the main
 * thread, and it ignores touches so the row or button around it receives them.
 */
export function HostedThumbnail(props: Props) {
  return (
    <RNHostView matchContents>
      <View pointerEvents="none" accessible={false} importantForAccessibility="no-hide-descendants">
        <Thumbnail {...props} />
      </View>
    </RNHostView>
  );
}

const styles = StyleSheet.create({
  image: { backgroundColor: colors.fill },
  placeholder: { alignItems: 'center', justifyContent: 'center', backgroundColor: colors.fill },
});
