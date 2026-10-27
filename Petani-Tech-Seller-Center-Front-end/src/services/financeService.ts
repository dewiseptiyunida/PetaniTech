import initialFinance from '@/mock/finance.json';
import { FinanceSummary, Transaction } from '@/types';
import { axiosInstance, USE_MOCK, simulateDelay } from '@/services/api/client';
import { storage } from '@/services/storage';

const STORAGE_KEY_FINANCE = 'petani_tech_finance';

class FinanceService {
  private async getLocalData(): Promise<{ summary: FinanceSummary; transactions: Transaction[] }> {
    const raw = await storage.getItem(STORAGE_KEY_FINANCE);
    if (!raw) {
      await storage.setItem(STORAGE_KEY_FINANCE, JSON.stringify(initialFinance));
      return initialFinance as { summary: FinanceSummary; transactions: Transaction[] };
    }
    try {
      return JSON.parse(raw);
    } catch {
      return initialFinance as { summary: FinanceSummary; transactions: Transaction[] };
    }
  }

  private async saveData(data: { summary: FinanceSummary; transactions: Transaction[] }): Promise<void> {
    await storage.setItem(STORAGE_KEY_FINANCE, JSON.stringify(data));
  }

  async getFinanceSummary(): Promise<FinanceSummary> {
    if (!USE_MOCK) {
      try {
        const response = await axiosInstance.get('/seller/finance/summary');
        return response.data?.data || response.data;
      } catch (err) {
        console.warn('API getFinanceSummary error, falling back to local storage:', err);
      }
    }

    await simulateDelay(200);
    const data = await this.getLocalData();
    return data.summary;
  }

  async getTransactions(): Promise<Transaction[]> {
    if (!USE_MOCK) {
      try {
        const response = await axiosInstance.get('/seller/finance/transactions');
        const raw = response.data;
        const list = Array.isArray(raw)
          ? raw
          : Array.isArray(raw?.data)
          ? raw.data
          : [];
        if (list.length > 0) return list;
      } catch (err) {
        console.warn('API getTransactions error, falling back to local storage:', err);
      }
    }

    await simulateDelay(250);
    const data = await this.getLocalData();
    return data.transactions;
  }

  async withdrawBalance(amount: number, bankDetails: string): Promise<Transaction> {
    if (!USE_MOCK) {
      try {
        const response = await axiosInstance.post('/seller/finance/withdraw', {
          amount,
          bankDetails,
        });
        return response.data?.data || response.data;
      } catch (err) {
        console.warn('API withdrawBalance error, using local fallback:', err);
      }
    }

    await simulateDelay(400);
    const data = await this.getLocalData();

    if (amount <= 0 || amount > data.summary.availableBalance) {
      throw new Error('Jumlah penarikan tidak valid atau melebihi saldo tersedia');
    }

    const newTx: Transaction = {
      id: `TX-${Date.now().toString().slice(-6)}`,
      referenceNo: `WD-${Math.floor(100000 + Math.random() * 900000)}`,
      date: 'Baru saja',
      type: 'Pencairan',
      amount: -amount,
      status: 'Berhasil',
      description: `Penarikan saldo ke Rekening ${bankDetails}`,
    };

    data.summary.availableBalance -= amount;
    data.summary.totalWithdrawn += amount;
    data.transactions.unshift(newTx);

    await this.saveData(data);
    return newTx;
  }
}

export const financeService = new FinanceService();
export default financeService;
