import { useCallback, useEffect, useReducer, useRef } from 'react';
import {
  FdaServerError,
  initialSearch,
  MIN_QUERY_LENGTH,
  readResponse,
  searchReducer,
  searchUrl,
  type SearchError,
} from './fda';

const DEBOUNCE_MS = 400;
const TIMEOUT_MS = 15_000;

/** The FDA search state: waits for typing to stop and cancels the previous request. */
export function useFdaSearch() {
  const [state, dispatch] = useReducer(searchReducer, initialSearch);
  const debounce = useRef<ReturnType<typeof setTimeout> | null>(null);
  const request = useRef<AbortController | null>(null);

  const cancel = useCallback(() => {
    if (debounce.current) clearTimeout(debounce.current);
    debounce.current = null;
    request.current?.abort();
    request.current = null;
  }, []);

  useEffect(() => cancel, [cancel]);

  const run = useCallback(async (query: string) => {
    const url = searchUrl(query);
    if (!url) return;
    const controller = new AbortController();
    request.current = controller;
    let timedOut = false;
    const timeout = setTimeout(() => {
      timedOut = true;
      controller.abort();
    }, TIMEOUT_MS);
    dispatch({ type: 'start', query });
    try {
      const results = await readResponse(await fetch(url, { signal: controller.signal }));
      if (request.current === controller) dispatch({ type: 'done', query, results });
    } catch (error) {
      if (request.current !== controller || (controller.signal.aborted && !timedOut)) return;
      const kind: SearchError = error instanceof FdaServerError || timedOut ? 'server' : 'offline';
      dispatch({ type: 'fail', query, error: kind });
    } finally {
      clearTimeout(timeout);
    }
  }, []);

  const setQuery = useCallback(
    (text: string) => {
      cancel();
      const query = text.trim();
      if (query.length < MIN_QUERY_LENGTH) {
        dispatch({ type: 'clear' });
        return;
      }
      debounce.current = setTimeout(() => void run(query), DEBOUNCE_MS);
    },
    [cancel, run],
  );

  const reset = useCallback(() => {
    cancel();
    dispatch({ type: 'clear' });
  }, [cancel]);

  const retry = useCallback(() => {
    cancel();
    void run(state.query);
  }, [cancel, run, state.query]);

  return { state, setQuery, reset, retry };
}
