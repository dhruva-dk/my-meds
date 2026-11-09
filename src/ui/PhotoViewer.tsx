import { useRef, type ComponentRef } from 'react';
import {
  Image,
  Modal,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  useWindowDimensions,
  View,
  type GestureResponderEvent,
  type NativeScrollEvent,
  type NativeSyntheticEvent,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

const DOUBLE_TAP_MS = 400;
const DISMISS_PULL = 90;
const ZOOMED_IN = 2.5;

type Props = { uri: string | null; onClose: () => void };

/** Full-screen photo with pinch and double-tap zoom. Pull down or tap Done to close. */
export function PhotoViewer({ uri, onClose }: Props) {
  return (
    <Modal
      visible={!!uri}
      presentationStyle="fullScreen"
      animationType="slide"
      onRequestClose={onClose}
    >
      {uri ? <ZoomablePhoto uri={uri} onClose={onClose} /> : null}
    </Modal>
  );
}

function ZoomablePhoto({ uri, onClose }: { uri: string; onClose: () => void }) {
  const { width, height } = useWindowDimensions();
  const { top } = useSafeAreaInsets();
  const scroller = useRef<ComponentRef<typeof ScrollView>>(null);
  const lastTap = useRef(0);
  const scale = useRef(1);

  const onTap = (event: GestureResponderEvent) => {
    const now = Date.now();
    const isDoubleTap = now - lastTap.current < DOUBLE_TAP_MS;
    lastTap.current = isDoubleTap ? 0 : now;
    if (!isDoubleTap) return;
    const zoomedIn = scale.current > 1.01;
    const rectWidth = zoomedIn ? width : width / ZOOMED_IN;
    const rectHeight = zoomedIn ? height : height / ZOOMED_IN;
    const { locationX, locationY } = event.nativeEvent;
    scroller.current?.scrollResponderZoomTo({
      x: zoomedIn ? 0 : locationX - rectWidth / 2,
      y: zoomedIn ? 0 : locationY - rectHeight / 2,
      width: rectWidth,
      height: rectHeight,
      animated: true,
    });
  };

  const onScroll = (event: NativeSyntheticEvent<NativeScrollEvent>) => {
    scale.current = event.nativeEvent.zoomScale ?? 1;
  };

  const onEndDrag = (event: NativeSyntheticEvent<NativeScrollEvent>) => {
    const { zoomScale = 1, contentOffset } = event.nativeEvent;
    if (zoomScale <= 1.01 && contentOffset.y < -DISMISS_PULL) onClose();
  };

  return (
    <View style={styles.container}>
      <ScrollView
        ref={scroller}
        style={StyleSheet.absoluteFill}
        contentContainerStyle={{ width, height }}
        minimumZoomScale={1}
        maximumZoomScale={5}
        centerContent
        alwaysBounceVertical
        showsHorizontalScrollIndicator={false}
        showsVerticalScrollIndicator={false}
        scrollEventThrottle={16}
        onScroll={onScroll}
        onScrollEndDrag={onEndDrag}
        contentInsetAdjustmentBehavior="never"
      >
        <Pressable onPress={onTap} accessibilityLabel="Medication photo" accessibilityRole="image">
          <Image source={{ uri }} style={{ width, height }} resizeMode="contain" />
        </Pressable>
      </ScrollView>
      <Pressable
        onPress={onClose}
        accessibilityRole="button"
        hitSlop={8}
        style={[styles.done, { top: top + 8 }]}
      >
        <Text style={styles.doneText}>Done</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#000' },
  done: {
    position: 'absolute',
    right: 16,
    minHeight: 44,
    minWidth: 64,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 22,
    backgroundColor: 'rgba(60,60,67,0.8)',
  },
  doneText: { fontSize: 17, fontWeight: '600', color: '#FFFFFF' },
});
