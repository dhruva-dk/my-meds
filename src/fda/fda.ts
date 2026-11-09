export const MIN_QUERY_LENGTH = 3;
const BASE_URL = 'https://api.fda.gov/drug/ndc.json';
const LIMIT = 50;

export type FdaDrug = { brandName: string; genericName: string; dosageForm: string; ndc: string };

type FdaResult = {
  brand_name?: string;
  generic_name?: string;
  dosage_form?: string;
  product_ndc?: string;
};

/** Field search syntax would change the meaning of the query. */
function wordsOf(query: string): string[] {
  return query
    .trim()
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\-.\s]/gu, ' ')
    .split(/\s+/)
    .filter(Boolean);
}

/** Matches whole words, with a prefix match on the last. openFDA needs 2 characters to prefix. */
function searchTerm(words: string[]): string {
  const last = words[words.length - 1];
  const complete = last.length < 2 ? words : words.slice(0, -1);
  const parts = complete.map((word) => encodeURIComponent(`"${word}"`));
  if (last.length >= 2) parts.push(`${encodeURIComponent(last)}*`);
  return parts.length === 1 ? parts[0] : `(${parts.join('+AND+')})`;
}

export function searchUrl(query: string): string | null {
  const words = wordsOf(query);
  if (words.length === 0) return null;
  const term = searchTerm(words);
  return `${BASE_URL}?search=brand_name:${term}+generic_name:${term}&limit=${LIMIT}`;
}

function titleCase(text: string): string {
  return text
    .split(' ')
    .map((word) => (word ? word[0].toUpperCase() + word.slice(1).toLowerCase() : word))
    .join(' ');
}

/** Reads openFDA's response, using 1.2.0's placeholders and title case, and merges identical rows. */
export function parseResults(body: unknown): FdaDrug[] {
  const results = (body as { results?: FdaResult[] } | null)?.results ?? [];
  const merged = new Map<string, FdaDrug>();
  for (const result of results) {
    const drug = {
      brandName: titleCase(result.brand_name ?? 'Unknown Brand Name'),
      genericName: titleCase(result.generic_name ?? 'Unknown Generic Name'),
      dosageForm: titleCase(result.dosage_form ?? 'Unknown'),
      ndc: result.product_ndc ?? 'Unknown',
    };
    const key = [drug.brandName, drug.genericName, drug.dosageForm, drug.ndc].join('\n');
    if (!merged.has(key)) merged.set(key, drug);
  }
  return [...merged.values()];
}

/** The same values 1.2.0 saved for an FDA pick, so saved data keeps its shape. */
export function prefillFrom(drug: FdaDrug): { name: string; notes: string } {
  return {
    name: `Brand: ${drug.brandName}\nGeneric: ${drug.genericName}`,
    notes: `Dosage type: ${drug.dosageForm}`,
  };
}

export type SearchError = 'offline' | 'server';

export type SearchState = {
  status: 'idle' | 'loading' | 'results' | 'empty' | 'error';
  /** The query these results or this status belong to. */
  query: string;
  results: FdaDrug[];
  error: SearchError | null;
};

export const initialSearch: SearchState = { status: 'idle', query: '', results: [], error: null };

export type SearchAction =
  | { type: 'clear' }
  | { type: 'start'; query: string }
  | { type: 'done'; query: string; results: FdaDrug[] }
  | { type: 'fail'; query: string; error: SearchError };

/** Answers for any query but the latest are dropped, so results never arrive out of order. */
export function searchReducer(state: SearchState, action: SearchAction): SearchState {
  switch (action.type) {
    case 'clear':
      return initialSearch;
    case 'start':
      // Earlier results stay on screen until the new ones arrive, so nothing flashes.
      return { ...state, status: 'loading', query: action.query, error: null };
    case 'done':
      if (action.query !== state.query) return state;
      return {
        status: action.results.length ? 'results' : 'empty',
        query: action.query,
        results: action.results,
        error: null,
      };
    case 'fail':
      if (action.query !== state.query) return state;
      return { status: 'error', query: action.query, results: [], error: action.error };
  }
}

/** What a finished request means: openFDA answers 404 when nothing matches. */
export async function readResponse(response: Response): Promise<FdaDrug[]> {
  if (response.status === 404) return [];
  if (!response.ok) throw new FdaServerError();
  return parseResults(await response.json());
}

export class FdaServerError extends Error {}
