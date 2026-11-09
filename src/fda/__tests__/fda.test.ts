import {
  initialSearch,
  parseResults,
  prefillFrom,
  readResponse,
  searchReducer,
  searchUrl,
} from '@/fda/fda';

const BASE = 'https://api.fda.gov/drug/ndc.json?search=';

describe('searchUrl', () => {
  it('prefix-matches a single word without quotes', () => {
    expect(searchUrl('Lipit')).toBe(`${BASE}brand_name:lipit*+generic_name:lipit*&limit=50`);
  });

  it('quotes complete words and prefix-matches the last', () => {
    expect(searchUrl('Tylenol Extra')).toBe(
      `${BASE}brand_name:(%22tylenol%22+AND+extra*)+generic_name:(%22tylenol%22+AND+extra*)&limit=50`,
    );
  });

  it('removes search syntax and encodes what is left', () => {
    expect(searchUrl('a"b*:(c)')).toBe(
      `${BASE}brand_name:(%22a%22+AND+%22b%22+AND+%22c%22)+generic_name:(%22a%22+AND+%22b%22+AND+%22c%22)&limit=50`,
    );
    expect(searchUrl('Ünï')).toContain('%C3%BCn%C3%AF*');
  });

  it('does not prefix-match a one-letter last word', () => {
    expect(searchUrl('tylenol e')).toBe(
      `${BASE}brand_name:(%22tylenol%22+AND+%22e%22)+generic_name:(%22tylenol%22+AND+%22e%22)&limit=50`,
    );
  });

  it('returns null when nothing searchable is left', () => {
    expect(searchUrl('***')).toBeNull();
  });
});

describe('parseResults', () => {
  it("uses 1.2.0's placeholders and title case for missing fields", () => {
    expect(parseResults({ results: [{ dosage_form: 'TABLET, FILM COATED' }] })).toEqual([
      {
        brandName: 'Unknown Brand Name',
        genericName: 'Unknown Generic Name',
        dosageForm: 'Tablet, Film Coated',
        ndc: 'Unknown',
      },
    ]);
  });

  it('merges identical rows and keeps different ones', () => {
    const row = { brand_name: 'A', generic_name: 'B', dosage_form: 'C', product_ndc: '1' };
    expect(parseResults({ results: [row, row, { ...row, product_ndc: '2' }] })).toHaveLength(2);
  });

  it('reads a body with no results', () => {
    expect(parseResults({})).toEqual([]);
    expect(parseResults(null)).toEqual([]);
  });
});

it('prefills the same values 1.2.0 saved', () => {
  expect(
    prefillFrom({
      brandName: 'Lipitor',
      genericName: 'Atorvastatin',
      dosageForm: 'Tablet',
      ndc: '1',
    }),
  ).toEqual({ name: 'Brand: Lipitor\nGeneric: Atorvastatin', notes: 'Dosage type: Tablet' });
});

describe('readResponse', () => {
  it('treats 404 as no results and other failures as errors', async () => {
    await expect(readResponse(new Response('{}', { status: 404 }))).resolves.toEqual([]);
    await expect(readResponse(new Response('{}', { status: 500 }))).rejects.toThrow();
  });
});

describe('searchReducer', () => {
  const drug = { brandName: 'A', genericName: 'B', dosageForm: 'C', ndc: '1' };

  it('ignores answers for an older query', () => {
    const first = searchReducer(initialSearch, { type: 'start', query: 'aspi' });
    const second = searchReducer(first, { type: 'start', query: 'aspir' });
    expect(searchReducer(second, { type: 'done', query: 'aspi', results: [drug] })).toBe(second);
    expect(searchReducer(second, { type: 'fail', query: 'aspi', error: 'offline' })).toBe(second);
  });

  it('keeps earlier results on screen while loading, so nothing flashes', () => {
    const start = searchReducer(initialSearch, { type: 'start', query: 'asp' });
    const done = searchReducer(start, { type: 'done', query: 'asp', results: [drug] });
    expect(searchReducer(done, { type: 'start', query: 'aspi' }).results).toEqual([drug]);
  });

  it('distinguishes empty from results', () => {
    const start = searchReducer(initialSearch, { type: 'start', query: 'zzz' });
    expect(searchReducer(start, { type: 'done', query: 'zzz', results: [] }).status).toBe('empty');
  });
});
