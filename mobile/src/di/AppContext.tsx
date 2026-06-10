import React, { createContext, useMemo } from 'react';
import { createUseCases, type UseCases } from './container';

export const UseCasesContext = createContext<UseCases | null>(null);

export function UseCasesProvider({ children }: { children: React.ReactNode }) {
  const useCases = useMemo(() => createUseCases(), []);
  return <UseCasesContext.Provider value={useCases}>{children}</UseCasesContext.Provider>;
}
