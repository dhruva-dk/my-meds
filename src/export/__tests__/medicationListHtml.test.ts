import type { Medication, Profile } from '@/data/snapshot';
import { escapeHtml, medicationListHtml, pdfFileName } from '@/export/medicationListHtml';

const profile: Profile = {
  id: 1,
  name: 'Ann <b>',
  dob: '03/14/1958',
  pcp: '',
  healthConditions: 'A & B',
  pharmacy: '5125550142',
};
const medication: Medication = {
  id: 7,
  profileId: 1,
  name: 'Brand: X\nGeneric: "Y"',
  dosage: '10 mg',
  notes: 'Don’t <script>',
  photo: null,
};

describe('escapeHtml', () => {
  it('escapes every character HTML treats specially', () => {
    expect(escapeHtml(`<a href="x">'&`)).toBe('&lt;a href=&quot;x&quot;&gt;&#39;&amp;');
  });
});

describe('medicationListHtml', () => {
  it('escapes everything it was given and keeps curly punctuation', () => {
    const html = medicationListHtml(profile, [medication], new Map(), 'Nov 9, 2026');
    expect(html).toContain('Ann &lt;b&gt;');
    expect(html).toContain('Don’t &lt;script&gt;');
    expect(html).toContain('A &amp; B');
    expect(html).not.toContain('<script>');
    expect(html).toContain('<meta charset="utf-8">');
  });

  it('has the header fields, using a dash for empty ones', () => {
    const html = medicationListHtml(profile, [medication], new Map(), 'Nov 9, 2026');
    expect(html).toContain('Mar 14, 1958');
    expect(html).toContain('(512) 555-0142');
    expect(html).toContain('Primary Care Physician</dt><dd>—');
    expect(html).toContain('Nov 9, 2026');
  });

  it('is valid for an empty list', () => {
    const html = medicationListHtml(profile, [], new Map(), 'Nov 9, 2026');
    expect(html).toContain('No medications listed');
  });

  it('adds a thumbnail only for rows that have one', () => {
    const none = medicationListHtml(profile, [medication], new Map(), 'x');
    const one = medicationListHtml(profile, [medication], new Map([[7, 'data:x']]), 'x');
    expect(none).not.toContain('<img');
    expect(one).toContain('<img class="thumb" src="data:x"');
  });
});

describe('pdfFileName', () => {
  it('is named after the profile and safe as a file name', () => {
    expect(pdfFileName('Ann Lee')).toBe('Ann Lee Medications.pdf');
    expect(pdfFileName('a/b:c')).toBe('a b c Medications.pdf');
    expect(pdfFileName('///')).toBe('My Meds Medications.pdf');
  });
});
