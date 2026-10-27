import { create } from 'zustand';
import { Toast } from '@/types';

interface ToastState {
  toasts: Toast[];
  addToast: (toast: Omit<Toast, 'id'>) => void;
  removeToast: (id: string) => void;
  success: (title: string, message?: string) => void;
  error: (title: string, message?: string) => void;
  warning: (title: string, message?: string) => void;
  info: (title: string, message?: string) => void;
}

export const useToastStore = create<ToastState>((set, get) => ({
  toasts: [],

  addToast: (toast) => {
    const id = `toast-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`;
    const duration = toast.duration ?? 3500;
    set((state) => ({ toasts: [...state.toasts, { ...toast, id }] }));
    setTimeout(() => get().removeToast(id), duration);
  },

  removeToast: (id) =>
    set((state) => ({ toasts: state.toasts.filter((t) => t.id !== id) })),

  success: (title, message) =>
    get().addToast({ variant: 'success', title, message }),

  error: (title, message) =>
    get().addToast({ variant: 'error', title, message, duration: 5000 }),

  warning: (title, message) =>
    get().addToast({ variant: 'warning', title, message }),

  info: (title, message) =>
    get().addToast({ variant: 'info', title, message }),
}));
