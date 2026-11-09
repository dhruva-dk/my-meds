import {
  Button,
  Form,
  Host,
  HStack,
  Menu,
  Picker,
  Section,
  Spacer,
  Text,
  VStack,
} from '@expo/ui/swift-ui';
import {
  accessibilityLabel,
  buttonStyle,
  keyboardType,
  listRowBackground,
  pickerStyle,
  scrollDismissesKeyboard,
  tag,
} from '@expo/ui/swift-ui/modifiers';
import { Stack, usePreventRemove } from 'expo-router';
import { useState } from 'react';
import { combineDosage, splitDosage, UNITS, type Unit } from '@/domain/forms';
import { confirmLeave, showFailure } from './alerts';
import { BareTextRow, SectionHeader, TextRow, useTextValue } from './formFields';
import { PhotoViewer } from './PhotoViewer';
import { photoUri } from './photoUri';
import { pickPhoto, type PhotoSource } from './pickPhoto';
import { HostedThumbnail } from './Thumbnail';

export type MedicationDraft = {
  name: string;
  dosage: string;
  notes: string;
  /** Saved photo path relative to Documents, if any. */
  photo: string | null;
  /** A picked photo that has not been saved yet. */
  newPhotoUri: string | null;
};

type Props = {
  initial: MedicationDraft;
  /** Accessibility label of the confirm button. */
  confirmLabel: string;
  failureTitle: string;
  /** Shows a cancel button, for forms presented in a sheet. */
  onCancel?: () => void;
  /** Saves the form. Throws if saving failed. */
  onSave: (
    fields: { name: string; dosage: string; notes: string },
    newPhotoUri: string | null,
  ) => Promise<void>;
  /** Runs after a successful save, with leaving already allowed. */
  onSaved: () => void;
};

/** The medication form shared by Add Medication and View Medication. Key it by the record. */
export function MedicationForm({
  initial,
  confirmLabel,
  failureTitle,
  onCancel,
  onSave,
  onSaved,
}: Props) {
  const [split] = useState(() => splitDosage(initial.dosage));
  const name = useTextValue(initial.name);
  const dosage = useTextValue(split.text);
  const notes = useTextValue(initial.notes);
  const [unit, setUnit] = useState<Unit>(split.unit);
  const [newPhotoUri, setNewPhotoUri] = useState(initial.newPhotoUri);
  const [viewing, setViewing] = useState(false);
  const [saving, setSaving] = useState(false);

  const dirty =
    name.value !== initial.name ||
    dosage.value !== split.text ||
    unit !== split.unit ||
    notes.value !== initial.notes ||
    newPhotoUri !== initial.newPhotoUri;
  const canSave = name.value.trim().length > 0 && !saving;

  // Set in the same handler that lifts the guard, so the guard stays down while the screen leaves.
  const [leaving, setLeaving] = useState(false);
  const allowLeaving = usePreventRemove(dirty && !saving && !leaving, ({ repeat }) =>
    confirmLeave(() => {
      setLeaving(true);
      repeat();
    }),
  );

  const save = async () => {
    if (!canSave) return;
    setSaving(true);
    try {
      await onSave(
        {
          name: name.value,
          dosage: combineDosage(dosage.value, unit),
          notes: notes.value,
        },
        newPhotoUri,
      );
    } catch (error) {
      setSaving(false);
      showFailure(failureTitle, error);
      return;
    }
    setLeaving(true);
    allowLeaving();
    onSaved();
  };

  const choosePhoto = async (source: PhotoSource) => {
    const uri = await pickPhoto(source);
    if (uri) setNewPhotoUri(uri);
  };

  const displayedPhoto = newPhotoUri ?? photoUri(initial.photo);

  return (
    <>
      {onCancel ? (
        <Stack.Toolbar placement="left">
          <Stack.Toolbar.Button icon="xmark" accessibilityLabel="Cancel" onPress={onCancel} />
        </Stack.Toolbar>
      ) : null}
      <Stack.Toolbar placement="right">
        <Stack.Toolbar.Button
          icon="checkmark"
          variant="prominent"
          accessibilityLabel={confirmLabel}
          disabled={!canSave}
          onPress={save}
        />
      </Stack.Toolbar>
      <Host style={{ flex: 1 }}>
        <Form modifiers={[scrollDismissesKeyboard('immediately')]}>
          <Section>
            <HStack modifiers={[listRowBackground('clear')]}>
              <Spacer />
              <VStack spacing={8}>
                {displayedPhoto ? (
                  <Button
                    onPress={() => setViewing(true)}
                    modifiers={[buttonStyle('plain'), accessibilityLabel('View photo full screen')]}
                  >
                    <HostedThumbnail uri={displayedPhoto} size={120} />
                  </Button>
                ) : (
                  <HostedThumbnail uri={null} size={120} />
                )}
                <Menu
                  label={displayedPhoto ? 'Change Photo' : 'Add Photo'}
                  modifiers={[buttonStyle('borderless')]}
                >
                  <Button
                    label="Take Photo"
                    systemImage="camera"
                    onPress={() => void choosePhoto('camera')}
                  />
                  <Button
                    label="Photo Library"
                    systemImage="photo.on.rectangle"
                    onPress={() => void choosePhoto('library')}
                  />
                </Menu>
              </VStack>
              <Spacer />
            </HStack>
          </Section>
          <Section>
            <TextRow label="Name" value={name} placeholder="Required" multiline />
            <TextRow
              label="Dosage"
              value={dosage}
              placeholder="10 or 2 tablets"
              modifiers={[keyboardType('numbers-and-punctuation')]}
            />
            <Picker
              label="Unit"
              selection={unit}
              onSelectionChange={(selected: Unit) => setUnit(selected)}
              modifiers={[pickerStyle('menu')]}
            >
              {UNITS.map((option) => (
                <Text key={option} modifiers={[tag(option)]}>
                  {option}
                </Text>
              ))}
            </Picker>
          </Section>
          <Section header={<SectionHeader>Additional Info</SectionHeader>}>
            <BareTextRow label="Additional Info" value={notes} placeholder="Optional" />
          </Section>
        </Form>
      </Host>
      <PhotoViewer uri={viewing ? displayedPhoto : null} onClose={() => setViewing(false)} />
    </>
  );
}
