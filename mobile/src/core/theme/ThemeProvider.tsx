import React, { createContext } from 'react';
import { theme as defaultTheme, type Theme } from './theme';

export const ThemeContext = createContext<Theme>(defaultTheme);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  return <ThemeContext.Provider value={defaultTheme}>{children}</ThemeContext.Provider>;
}
