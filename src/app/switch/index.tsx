import {
  Button,
  Host,
  HStack,
  Image,
  List,
  Spacer,
  SwipeActions,
  Text,
  VStack,
} from '@expo/ui/swift-ui';
import {
  accessibilityAddTraits,
  font,
  foregroundStyle,
  listStyle,
} from '@expo/ui/swift-ui/modifiers';
import { router, Stack, useNavigation } from 'expo-router';
import { useCallback } from 'react';
import { countMedications, deleteProfile, setActiveProfile } from '@/data/commands';
import type { Profile } from '@/data/snapshot';
import { useSnapshot } from '@/data/useSnapshot';
import { displayDob } from '@/domain/forms';
import { confirmDelete, showFailure } from '@/ui/alerts';
import { SecondaryText } from '@/ui/formFields';
import { SwipeDeleteButton } from '@/ui/SwipeDeleteButton';
import { colors } from '@/ui/theme';

const HOME_TAB = '(home)';
const SWITCH_TAB = 'switch';

/** Returns every tab to its first screen, so nothing from the previous person stays open. */
function useResetTabs() {
  const navigation = useNavigation();
  return useCallback(
    (focusedTab: string) => {
      const tabs = navigation.getParent();
      const state = tabs?.getState();
      if (!tabs || !state) return;
      // Routes without keys get new ones, which starts each tab's stack again.
      tabs.reset({
        ...state,
        index: state.routes.findIndex((route) => route.name === focusedTab),
        routes: state.routes.map(({ name }) => ({ name })),
        stale: false,
      } as Parameters<typeof tabs.reset>[0]);
    },
    [navigation],
  );
}

function askToDelete(profile: Profile, onDeleted: () => void) {
  const count = countMedications(profile.id);
  const medications = `This also deletes their ${count} ${count === 1 ? 'medication' : 'medications'}.`;
  confirmDelete(
    'Delete Profile',
    `Are you sure you want to delete this profile? This cannot be undone.\n\n${medications}`,
    () => {
      try {
        deleteProfile(profile.id);
      } catch (error) {
        showFailure("Couldn't Delete Profile", error);
        return;
      }
      onDeleted();
    },
  );
}

function ProfileRow({
  profile,
  active,
  canDelete,
  onSelect,
  onDelete,
}: {
  profile: Profile;
  active: boolean;
  canDelete: boolean;
  onSelect: () => void;
  onDelete: () => void;
}) {
  const row = (
    <Button onPress={onSelect} modifiers={active ? [accessibilityAddTraits(['isSelected'])] : []}>
      <HStack>
        <VStack alignment="leading" spacing={2}>
          <Text
            modifiers={[
              font({ textStyle: 'body', weight: 'semibold' }),
              foregroundStyle(colors.label),
            ]}
          >
            {profile.name}
          </Text>
          <SecondaryText>{`Date of birth ${displayDob(profile.dob)}`}</SecondaryText>
        </VStack>
        <Spacer />
        {active ? (
          <Image
            systemName="checkmark"
            size={17}
            modifiers={[foregroundStyle(colors.accent)]}
          />
        ) : null}
      </HStack>
    </Button>
  );
  if (!canDelete) return row;
  return (
    <SwipeActions>
      <SwipeActions.Actions edge="trailing" allowsFullSwipe={false}>
        <SwipeDeleteButton onPress={onDelete} />
      </SwipeActions.Actions>
      {row}
    </SwipeActions>
  );
}

export default function SwitchScreen() {
  const { profiles, activeProfile } = useSnapshot();
  const resetTabs = useResetTabs();

  const switchTo = (profile: Profile) => {
    try {
      setActiveProfile(profile.id);
    } catch (error) {
      showFailure("Couldn't Switch Profile", error);
      return;
    }
    resetTabs(HOME_TAB);
  };

  const onDeleted = (profile: Profile) => {
    if (profile.id === activeProfile.id) resetTabs(SWITCH_TAB);
  };

  return (
    <>
      <Stack.Toolbar placement="right">
        <Stack.Toolbar.Button
          icon="plus"
          accessibilityLabel="Add Profile"
          onPress={() => router.push('/switch/new')}
        />
      </Stack.Toolbar>
      <Host style={{ flex: 1 }}>
        <List modifiers={[listStyle('insetGrouped')]}>
          {profiles.map((profile) => (
            <ProfileRow
              key={profile.id}
              profile={profile}
              active={profile.id === activeProfile.id}
              canDelete={profiles.length > 1}
              onSelect={() => switchTo(profile)}
              onDelete={() => askToDelete(profile, () => onDeleted(profile))}
            />
          ))}
        </List>
      </Host>
    </>
  );
}
