import {
  Button,
  ContentUnavailableView,
  Host,
  HStack,
  Image,
  Label,
  List,
  Menu,
  ProgressView,
  Section,
  Spacer,
  Text,
  VStack,
} from '@expo/ui/swift-ui';
import {
  accessibilityLabel,
  buttonStyle,
  font,
  foregroundStyle,
  listRowBackground,
  listStyle,
} from '@expo/ui/swift-ui/modifiers';
import { router, Stack } from 'expo-router';
import { useEffect, useRef } from 'react';
import { useWindowDimensions } from 'react-native';
import { prefillFrom, type FdaDrug } from '@/fda/fda';
import { useFdaSearch } from '@/fda/useFdaSearch';
import { onAddTabReset } from '@/ui/addTabReset';
import { SecondaryText, SectionHeader } from '@/ui/formFields';
import { pickPhoto, type PhotoSource } from '@/ui/pickPhoto';
import { colors } from '@/ui/theme';

const LARGE_TEXT = 1.35;

function Chevron() {
  return (
    <Image systemName="chevron.right" size={13} modifiers={[foregroundStyle(colors.chevron)]} />
  );
}

function RowLabel({
  title,
  systemImage,
}: {
  title: string;
  systemImage: 'square.and.pencil' | 'camera';
}) {
  return (
    <Label
      title={title}
      icon={
        <Image
          systemName={systemImage}
          modifiers={[font({ textStyle: 'body' }), foregroundStyle(colors.accent)]}
        />
      }
      modifiers={[foregroundStyle(colors.label)]}
    />
  );
}

function openManualForm() {
  router.push('/add/new');
}

async function startFromPhoto(source: PhotoSource) {
  const photo = await pickPhoto(source);
  if (photo) router.push({ pathname: '/add/new', params: { photo } });
}

function ResultRow({ drug }: { drug: FdaDrug }) {
  return (
    <Button
      onPress={() => router.push({ pathname: '/add/new', params: prefillFrom(drug) })}
      modifiers={[
        accessibilityLabel(
          `${drug.brandName}, ${drug.genericName}, ${drug.dosageForm}, NDC ${drug.ndc}`,
        ),
      ]}
    >
      <HStack>
        <VStack alignment="leading" spacing={2}>
          <Text
            modifiers={[
              font({ textStyle: 'body', weight: 'semibold' }),
              foregroundStyle(colors.label),
            ]}
          >
            {drug.brandName}
          </Text>
          <Text modifiers={[foregroundStyle(colors.label)]}>{drug.genericName}</Text>
          <SecondaryText>{drug.dosageForm}</SecondaryText>
          <SecondaryText>{`NDC: ${drug.ndc}`}</SecondaryText>
        </VStack>
        <Spacer />
        <Chevron />
      </HStack>
    </Button>
  );
}

type UnavailableProps = {
  title: string;
  systemImage: 'magnifyingglass' | 'wifi.slash' | 'exclamationmark.triangle';
  description: string;
  onRetry?: () => void;
};

function Unavailable({ onRetry, ...props }: UnavailableProps) {
  return (
    <ContentUnavailableView
      {...props}
      actions={onRetry ? <Button label="Try Again" onPress={onRetry} /> : undefined}
      modifiers={[listRowBackground('clear')]}
    />
  );
}

export default function AddMedScreen() {
  const { state, setQuery, reset, retry } = useFdaSearch();
  const searchBar = useRef<React.ComponentRef<typeof Stack.SearchBar> | null>(null);
  const searching = state.status !== 'idle';
  const largeText = useWindowDimensions().fontScale >= LARGE_TEXT;

  useEffect(
    () =>
      onAddTabReset(() => {
        reset();
        searchBar.current?.clearText();
        searchBar.current?.cancelSearch();
      }),
    [reset],
  );

  return (
    <>
      <Stack.SearchBar
        ref={searchBar}
        placeholder="Search"
        hideWhenScrolling={false}
        obscureBackground={false}
        autoCapitalize="none"
        onChangeText={(event) => setQuery(event.nativeEvent.text)}
        onCancelButtonPress={reset}
      />
      <Host style={{ flex: 1 }}>
        <List modifiers={[listStyle('insetGrouped')]}>
          {!searching ? (
            <Section
              footer={
                <SecondaryText>
                  {
                    'Search looks up drug names in the FDA directory. Only what you type in the search field leaves your iPhone.'
                  }
                </SecondaryText>
              }
            >
              <Button onPress={openManualForm}>
                <HStack>
                  <RowLabel title="Manual Input" systemImage="square.and.pencil" />
                  <Spacer />
                  <Chevron />
                </HStack>
              </Button>
              <Menu
                // At large text sizes a menu clips any title that shares its width, so only the title stays.
                label={
                  largeText ? (
                    'Upload Photo'
                  ) : (
                    <HStack>
                      <RowLabel title="Upload Photo" systemImage="camera" />
                      <Spacer />
                      <Chevron />
                    </HStack>
                  )
                }
                modifiers={[buttonStyle('automatic')]}
              >
                <Button
                  label="Take Photo"
                  systemImage="camera"
                  onPress={() => void startFromPhoto('camera')}
                />
                <Button
                  label="Photo Library"
                  systemImage="photo.on.rectangle"
                  onPress={() => void startFromPhoto('library')}
                />
              </Menu>
            </Section>
          ) : null}
          {state.status === 'loading' && state.results.length === 0 ? (
            <Section>
              <HStack modifiers={[listRowBackground('clear')]}>
                <Spacer />
                <ProgressView />
                <Spacer />
              </HStack>
            </Section>
          ) : null}
          {state.results.length > 0 ? (
            <Section header={<SectionHeader>Search Results</SectionHeader>}>
              {state.results.map((drug) => (
                <ResultRow
                  key={[drug.ndc, drug.brandName, drug.genericName, drug.dosageForm].join('|')}
                  drug={drug}
                />
              ))}
            </Section>
          ) : null}
          {state.status === 'empty' ? (
            <Section>
              <Unavailable
                title={`No Results for “${state.query}”`}
                systemImage="magnifyingglass"
                description="Check the spelling or try a new search."
              />
            </Section>
          ) : null}
          {state.status === 'error' && state.error === 'offline' ? (
            <Section>
              <Unavailable
                title="You’re Offline"
                systemImage="wifi.slash"
                description="Connect to the internet to search the FDA directory. You can still add a medication with Manual Input."
                onRetry={retry}
              />
            </Section>
          ) : null}
          {state.status === 'error' && state.error === 'server' ? (
            <Section>
              <Unavailable
                title="Search Isn’t Available"
                systemImage="exclamationmark.triangle"
                description="The FDA directory didn’t respond. Try again later, or add a medication with Manual Input."
                onRetry={retry}
              />
            </Section>
          ) : null}
        </List>
      </Host>
    </>
  );
}
