import { createContext, useContext } from 'react';

// Lets a deep screen ask the root to re-evaluate first-run state (after a reset).
export const AppRestartContext = createContext<() => void>(() => undefined);
export const useAppRestart = () => useContext(AppRestartContext);
