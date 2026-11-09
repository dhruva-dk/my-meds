const listeners = new Set<() => void>();

/** Lets a sheet or another tab return the Add Med tab to its first screen. */
export function onAddTabReset(listener: () => void): () => void {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

export function resetAddTab(): void {
  listeners.forEach((listener) => listener());
}
