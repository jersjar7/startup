import { useContext } from 'react';
import { UseCasesContext } from './AppContext';
import type { UseCases } from './container';

// The only way presentation reaches the application layer. Screens never `new`
// a repository — they ask for use cases here.
export function useUseCases(): UseCases {
  const ctx = useContext(UseCasesContext);
  if (!ctx) throw new Error('useUseCases must be used within <UseCasesProvider>');
  return ctx;
}
