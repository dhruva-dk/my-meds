import { Button, DatePicker, Form, Host, HStack, Section, Spacer, Text } from '@expo/ui/swift-ui';
import {
  buttonStyle,
  datePickerStyle,
  keyboardType,
  labelsHidden,
  scrollDismissesKeyboard,
} from '@expo/ui/swift-ui/modifiers';
import { Stack, usePreventRemove } from 'expo-router';
import { useMemo, useState } from 'react';
import { Linking } from 'react-native';
import type { ProfileFields } from '@/data/commands';
import {
  displayDob,
  displayPhone,
  parseStoredDate,
  phoneAfterEdit,
  toStoredDate,
} from '@/domain/forms';
import { confirmLeave, showFailure } from './alerts';
import { BareTextRow, SectionHeader, TextRow, useTextValue } from './formFields';

const PRIVACY_POLICY = 'https://sites.google.com/view/mymedsapp/home';

type Props = {
  initial: ProfileFields;
  confirmLabel: string;
  failureTitle: string;
  /** Sheets offer cancel, and ask before unsaved changes are lost. */
  onCancel?: () => void;
  /** Saves the form. Throws if saving failed. */
  onSave: (fields: ProfileFields) => void;
  onSaved?: () => void;
  showPrivacyPolicy?: boolean;
};

/** The profile form. Key it by the profile, so it can never show or save another person's data. */
export function ProfileForm({
  initial,
  confirmLabel,
  failureTitle,
  onCancel,
  onSave,
  onSaved,
  showPrivacyPolicy,
}: Props) {
  const [saved, setSaved] = useState({ ...initial, pharmacy: displayPhone(initial.pharmacy) });
  const name = useTextValue(saved.name);
  const pcp = useTextValue(saved.pcp);
  const pharmacy = useTextValue(saved.pharmacy, phoneAfterEdit);
  const healthConditions = useTextValue(saved.healthConditions);
  const [dob, setDob] = useState(saved.dob);
  const [choosingDate, setChoosingDate] = useState(false);

  const values: ProfileFields = {
    name: name.value,
    dob,
    pcp: pcp.value,
    healthConditions: healthConditions.value,
    pharmacy: pharmacy.value,
  };
  const dirty = (Object.keys(values) as (keyof ProfileFields)[]).some(
    (key) => values[key].trim() !== saved[key].trim(),
  );
  const canSave = name.value.trim().length > 0 && dirty;

  // Set in the same handler that lifts the guard, so the guard stays down while the screen leaves.
  const [leaving, setLeaving] = useState(false);
  const allowLeaving = usePreventRemove(!!onCancel && dirty && !leaving, ({ repeat }) =>
    confirmLeave(() => {
      setLeaving(true);
      repeat();
    }),
  );

  const save = () => {
    if (!canSave) return;
    try {
      onSave(values);
    } catch (error) {
      showFailure(failureTitle, error);
      return;
    }
    setSaved(values);
    setChoosingDate(false);
    if (onCancel) {
      setLeaving(true);
      allowLeaving();
    }
    onSaved?.();
  };

  const pickerDate = useMemo(() => parseStoredDate(dob) ?? new Date(1980, 0, 1, 12), [dob]);
  const today = useMemo(() => new Date(), []);

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
          <Section header={<SectionHeader>Personal Information</SectionHeader>}>
            <TextRow label="Name" value={name} placeholder="Required" />
            <HStack>
              <Text>Date of Birth</Text>
              <Spacer />
              <Button
                label={dob ? displayDob(dob) : 'Add Date'}
                onPress={() => setChoosingDate((open) => !open)}
                modifiers={[buttonStyle('bordered')]}
              />
            </HStack>
            {choosingDate ? (
              <DatePicker
                title="Date of Birth"
                selection={pickerDate}
                range={{ end: today }}
                displayedComponents={['date']}
                onDateChange={(date) => setDob(toStoredDate(date))}
                modifiers={[datePickerStyle('wheel'), labelsHidden()]}
              />
            ) : null}
            {choosingDate ? (
              <Button
                label="Clear Date"
                onPress={() => {
                  setDob('');
                  setChoosingDate(false);
                }}
              />
            ) : null}
          </Section>
          <Section header={<SectionHeader>Health Information</SectionHeader>}>
            <TextRow label="Primary Care Physician" value={pcp} placeholder="Optional" />
            <TextRow
              label="Pharmacy Phone"
              value={pharmacy}
              placeholder="Optional"
              modifiers={[keyboardType('phone-pad')]}
            />
          </Section>
          <Section header={<SectionHeader>Health Conditions</SectionHeader>}>
            <BareTextRow
              label="Health Conditions"
              value={healthConditions}
              placeholder="Optional"
            />
          </Section>
          {showPrivacyPolicy ? (
            <Section>
              <Button
                label="Privacy Policy"
                systemImage="arrow.up.right"
                onPress={() => void Linking.openURL(PRIVACY_POLICY)}
              />
            </Section>
          ) : null}
        </Form>
      </Host>
    </>
  );
}
