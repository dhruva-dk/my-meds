import {
  Button,
  ContentUnavailableView,
  ContextMenu,
  Host,
  HStack,
  Image,
  List,
  Section,
  Spacer,
  SwipeActions,
  Text,
  VStack,
} from '@expo/ui/swift-ui';
import {
  accessibilityLabel,
  font,
  foregroundStyle,
  lineLimit,
  listRowBackground,
  listStyle,
} from '@expo/ui/swift-ui/modifiers';
import { router, Stack } from 'expo-router';
import { useState } from 'react';
import { deleteMedication } from '@/data/commands';
import type { Medication } from '@/data/snapshot';
import { useSnapshot } from '@/data/useSnapshot';
import { displayDob } from '@/domain/forms';
import { exportMedicationList } from '@/export/exportPdf';
import { confirmDelete, showFailure } from '@/ui/alerts';
import { photoUri } from '@/ui/photoUri';
import { SwipeDeleteButton } from '@/ui/SwipeDeleteButton';
import { CARD_GREEN, colors } from '@/ui/theme';
import { HostedThumbnail } from '@/ui/Thumbnail';

function askToDelete(medication: Medication) {
  confirmDelete(
    'Delete Medication',
    'Are you sure you want to delete this medication? This cannot be undone.',
    () => {
      try {
        deleteMedication(medication.id);
      } catch (error) {
        showFailure("Couldn't Delete Medication", error);
      }
    },
  );
}

function MedicationRow({ medication }: { medication: Medication }) {
  const open = () => router.push(`/medication/${medication.id}`);
  const label = [medication.name, medication.dosage, medication.notes].filter(Boolean).join(', ');
  return (
    <SwipeActions>
      <SwipeActions.Actions edge="trailing" allowsFullSwipe={false}>
        <SwipeDeleteButton onPress={() => askToDelete(medication)} />
      </SwipeActions.Actions>
      <ContextMenu>
        <ContextMenu.Items>
          <Button label="Edit" systemImage="pencil" onPress={open} />
          <Button
            role="destructive"
            label="Delete"
            systemImage="trash"
            onPress={() => askToDelete(medication)}
          />
        </ContextMenu.Items>
        <ContextMenu.Trigger>
          <Button onPress={open} modifiers={[accessibilityLabel(label)]}>
            <HStack spacing={12}>
              <HostedThumbnail uri={photoUri(medication.photo)} />
              <VStack alignment="leading" spacing={2}>
                <Text
                  modifiers={[
                    font({ textStyle: 'body', weight: 'semibold' }),
                    foregroundStyle(colors.label),
                  ]}
                >
                  {medication.name}
                </Text>
                {medication.dosage ? (
                  <Text modifiers={[foregroundStyle(colors.label)]}>{medication.dosage}</Text>
                ) : null}
                {medication.notes ? (
                  <Text modifiers={[foregroundStyle(colors.secondary), lineLimit(2)]}>
                    {medication.notes}
                  </Text>
                ) : null}
              </VStack>
              <Spacer />
              <Image
                systemName="chevron.right"
                size={13}
                modifiers={[foregroundStyle(colors.chevron)]}
              />
            </HStack>
          </Button>
        </ContextMenu.Trigger>
      </ContextMenu>
    </SwipeActions>
  );
}

export default function HomeScreen() {
  const { activeProfile, medications } = useSnapshot();
  const [exporting, setExporting] = useState(false);

  const onExport = async () => {
    setExporting(true);
    try {
      await exportMedicationList();
    } catch (error) {
      showFailure("Couldn't Export Your List", error);
    } finally {
      setExporting(false);
    }
  };

  return (
    <>
      <Stack.Toolbar placement="right">
        <Stack.Toolbar.Button
          icon="square.and.arrow.up"
          accessibilityLabel="Export"
          disabled={exporting}
          onPress={onExport}
        />
      </Stack.Toolbar>
      <Host style={{ flex: 1 }}>
        <List modifiers={[listStyle('insetGrouped')]}>
          <Section>
            <VStack alignment="leading" spacing={2} modifiers={[listRowBackground(CARD_GREEN)]}>
              <Text
                modifiers={[
                  font({ textStyle: 'title2', weight: 'bold' }),
                  foregroundStyle('#FFFFFF'),
                ]}
              >
                {activeProfile.name}
              </Text>
              <Text modifiers={[foregroundStyle('#FFFFFF')]}>
                {`Date of birth ${displayDob(activeProfile.dob)}`}
              </Text>
            </VStack>
          </Section>
          {medications.length > 0 ? (
            <Section>
              {medications.map((medication) => (
                <MedicationRow key={medication.id} medication={medication} />
              ))}
            </Section>
          ) : (
            <Section>
              <ContentUnavailableView
                title="No Medications"
                systemImage="pills"
                description="Add by tapping Add Med below."
                modifiers={[listRowBackground('clear')]}
              />
            </Section>
          )}
        </List>
      </Host>
    </>
  );
}
