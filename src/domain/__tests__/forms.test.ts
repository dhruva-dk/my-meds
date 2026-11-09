import {
  combineDosage,
  displayDob,
  displayPhone,
  parseStoredDate,
  phoneAfterEdit,
  splitDosage,
  toStoredDate,
} from '@/domain/forms';

describe('dosage', () => {
  it.each([
    ['10', 'mg', '10 mg'],
    ['10 mg', 'mg', '10 mg'],
    ['10mg', 'mg', '10mg'],
    ['2 tablets', 'N/A', '2 tablets'],
    ['1 tablet twice daily', 'N/A', '1 tablet twice daily'],
    ['  5 ', 'mL', '5 mL'],
    ['', 'mg', ''],
    ['10%', '%', '10%'],
    ['10 ml', 'mL', '10 ml'],
  ] as const)('%j + %s gives %j', (text, unit, expected) => {
    expect(combineDosage(text, unit)).toBe(expected);
  });

  it.each([
    ['10 mg', { text: '10', unit: 'mg' }],
    ['10 ', { text: '10', unit: 'N/A' }],
    ['1 capsule daily', { text: '1 capsule daily', unit: 'N/A' }],
    ['1000 IU', { text: '1000', unit: 'IU' }],
    ['', { text: '', unit: 'N/A' }],
    ['mg', { text: 'mg', unit: 'N/A' }],
  ])('splits %j', (saved, expected) => {
    expect(splitDosage(saved)).toEqual(expected);
  });
});

describe('date of birth', () => {
  it('parses stored dates strictly', () => {
    expect(toStoredDate(parseStoredDate('03/14/1958')!)).toBe('03/14/1958');
    expect(parseStoredDate('02/30/2000')).toBeNull();
    expect(parseStoredDate('March 3')).toBeNull();
  });

  it('displays a date, stored text as typed, or a dash', () => {
    expect(displayDob('03/14/1958')).toBe('Mar 14, 1958');
    expect(displayDob('sometime in 1950')).toBe('sometime in 1950');
    expect(displayDob('')).toBe('—');
  });
});

describe('pharmacy phone', () => {
  it('formats exactly 10 digits and leaves the rest as typed', () => {
    expect(displayPhone('5125550142')).toBe('(512) 555-0142');
    expect(displayPhone('(512) 555-0142')).toBe('(512) 555-0142');
    expect(displayPhone('555-0142')).toBe('555-0142');
    expect(displayPhone('+1 512 555 0142')).toBe('+1 512 555 0142');
  });

  it('removes one character per backspace', () => {
    expect(phoneAfterEdit('(512) 555-0142', '(512) 555-014')).toBe('(512) 555-014');
    expect(phoneAfterEdit('(512) 555-0142', '(512 555-0142')).toBe('(512 555-0142');
  });

  it('formats when the tenth digit is typed', () => {
    expect(phoneAfterEdit('512555014', '5125550142')).toBe('(512) 555-0142');
  });
});
