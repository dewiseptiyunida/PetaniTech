import { create } from 'zustand';
import { UserProfile } from '@/types';
import { authService, RegisterSellerData } from '@/services/authService';

interface AuthState {
  user: UserProfile | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  login: (identifier: string, pass: string) => Promise<void>;
  register: (data: RegisterSellerData) => Promise<void>;
  logout: () => Promise<void>;
  updateProfile: (data: Partial<UserProfile>) => Promise<void>;
  initAuth: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: false,
  isLoading: true,
  error: null,

  initAuth: async () => {
    try {
      if (await authService.isAuthenticated()) {
        const user = await authService.getCurrentUser();
        set({ user, isAuthenticated: true, isLoading: false, error: null });
      } else {
        set({ user: null, isAuthenticated: false, isLoading: false, error: null });
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Gagal memuat sesi';
      set({ user: null, isAuthenticated: false, isLoading: false, error: msg });
    }
  },

  login: async (identifier, pass) => {
    set({ isLoading: true, error: null });
    try {
      const user = await authService.login(identifier, pass);
      set({ user, isAuthenticated: true, isLoading: false, error: null });
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Gagal login';
      set({ isLoading: false, error: msg });
      throw err;
    }
  },

  register: async (data) => {
    set({ isLoading: true, error: null });
    try {
      const user = await authService.register(data);
      set({ user, isAuthenticated: true, isLoading: false, error: null });
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Gagal mendaftar';
      set({ isLoading: false, error: msg });
      throw err;
    }
  },

  logout: async () => {
    set({ isLoading: true, error: null });
    try {
      await authService.logout();
      set({ user: null, isAuthenticated: false, isLoading: false, error: null });
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Gagal keluar';
      set({ isLoading: false, error: msg });
      throw err;
    }
  },

  updateProfile: async (data) => {
    try {
      const updated = await authService.updateProfile(data);
      set({ user: updated });
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Gagal update profile';
      set({ error: msg });
    }
  },
}));

