import React, {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from 'react';
import { Appearance, useColorScheme } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { storage } from '@/services/storage';
import { ThemeColors, ThemeContextType, ThemeMode, ActiveTheme } from './types';
import { darkThemeColors, lightThemeColors } from './tokens';

const THEME_STORAGE_KEY = '@petani_tech_theme_mode';

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

interface ThemeProviderProps {
  children: React.ReactNode;
}

export const ThemeProvider: React.FC<ThemeProviderProps> = ({ children }) => {
  const systemColorScheme = useColorScheme();
  const [mode, setModeState] = useState<ThemeMode>('light');

  // Load saved preference on mount
  useEffect(() => {
    let isMounted = true;
    const loadSavedMode = async () => {
      try {
        const saved = await storage.getItem(THEME_STORAGE_KEY);
        if (isMounted && saved && (saved === 'light' || saved === 'dark' || saved === 'system')) {
          setModeState(saved as ThemeMode);
        }
      } catch {
        // Fallback to system default
      }
    };
    void loadSavedMode();
    return () => {
      isMounted = false;
    };
  }, []);

  // Update mode and persist to storage
  const setMode = useCallback((newMode: ThemeMode) => {
    setModeState(newMode);
    void storage.setItem(THEME_STORAGE_KEY, newMode).catch(() => {});
  }, []);

  // Toggle directly between light and dark
  const toggleTheme = useCallback(() => {
    setModeState((currentMode) => {
      let nextMode: ThemeMode;
      if (currentMode === 'dark') {
        nextMode = 'light';
      } else if (currentMode === 'light') {
        nextMode = 'dark';
      } else {
        // If current was system, toggle to the opposite of current system
        const currentSys = Appearance.getColorScheme();
        nextMode = currentSys === 'dark' ? 'light' : 'dark';
      }
      void storage.setItem(THEME_STORAGE_KEY, nextMode).catch(() => {});
      return nextMode;
    });
  }, []);

  // Compute active evaluated theme ('light' or 'dark')
  const activeTheme: ActiveTheme = useMemo(() => {
    if (mode === 'dark') return 'dark';
    if (mode === 'light') return 'light';
    // When 'system', evaluate from system appearance
    return systemColorScheme === 'dark' ? 'dark' : 'light';
  }, [mode, systemColorScheme]);

  const isDark = activeTheme === 'dark';

  const colors: ThemeColors = useMemo(() => {
    return isDark ? darkThemeColors : lightThemeColors;
  }, [isDark]);

  const contextValue = useMemo<ThemeContextType>(
    () => ({
      mode,
      activeTheme,
      isDark,
      isDarkMode: isDark,
      setMode,
      toggleTheme,
      colors,
      themeColors: colors,
    }),
    [mode, activeTheme, isDark, setMode, toggleTheme, colors]
  );

  return (
    <ThemeContext.Provider value={contextValue}>
      <StatusBar style={isDark ? 'light' : 'dark'} animated />
      {children}
    </ThemeContext.Provider>
  );
};

export function useTheme(): ThemeContextType {
  const context = useContext(ThemeContext);
  if (!context) {
    // Graceful fallback if used outside ThemeProvider
    const systemScheme = Appearance.getColorScheme();
    const isDark = systemScheme === 'dark';
    const colors = isDark ? darkThemeColors : lightThemeColors;
    return {
      mode: 'system',
      activeTheme: isDark ? 'dark' : 'light',
      isDark,
      isDarkMode: isDark,
      setMode: () => {},
      toggleTheme: () => {},
      colors,
      themeColors: colors,
    };
  }
  return context;
}
