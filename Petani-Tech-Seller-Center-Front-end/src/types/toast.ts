// ---------------------------------------------------------------------------
// Toast / Notification types
// ---------------------------------------------------------------------------
export type ToastVariant = 'success' | 'error' | 'warning' | 'info';

export interface Toast {
  id: string;
  title: string;
  message?: string;
  variant: ToastVariant;
  duration?: number; // ms, default 3500
}
