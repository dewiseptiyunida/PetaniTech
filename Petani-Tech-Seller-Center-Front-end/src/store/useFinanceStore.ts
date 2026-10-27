import { create } from 'zustand';
import { FinanceSummary, Transaction } from '@/types';
import { financeService } from '@/services/financeService';

interface FinanceState {
  summary: FinanceSummary | null;
  transactions: Transaction[];
  isLoading: boolean;
  error: string | null;

  fetchFinance: () => Promise<void>;
  withdrawBalance: (amount: number, bankDetails: string) => Promise<void>;
}

export const useFinanceStore = create<FinanceState>((set, get) => ({
  summary: null,
  transactions: [],
  isLoading: false,
  error: null,

  fetchFinance: async () => {
    set({ isLoading: true, error: null });
    try {
      const [summary, transactions] = await Promise.all([
        financeService.getFinanceSummary(),
        financeService.getTransactions(),
      ]);
      set({ summary, transactions, isLoading: false });
    } catch (err: unknown) {
      set({
        isLoading: false,
        error: err instanceof Error ? err.message : 'Gagal memuat keuangan',
      });
    }
  },

  withdrawBalance: async (amount, bankDetails) => {
    set({ isLoading: true });
    try {
      await financeService.withdrawBalance(amount, bankDetails);
      await get().fetchFinance();
    } finally {
      set({ isLoading: false });
    }
  },
}));
