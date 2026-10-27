export type TransactionType = 'Penjualan' | 'Pencairan' | 'Biaya Layanan' | 'Cashback Promo';

export type TransactionStatus = 'Berhasil' | 'Diproses' | 'Gagal';

export interface Transaction {
  id: string;
  referenceNo: string;
  date: string;
  type: TransactionType;
  amount: number;
  status: TransactionStatus;
  description: string;
}

export interface FinanceSummary {
  availableBalance: number;
  monthlyRevenue: number;
  pendingBalance: number;
  totalWithdrawn: number;
}
