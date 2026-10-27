// ---------------------------------------------------------------------------
// User Roles – Architecture ready for Seller / Admin / Buyer
// ---------------------------------------------------------------------------
export type UserRole = 'seller' | 'admin' | 'buyer';

export interface BankAccount {
  bankName: string;
  accountNumber: string;
  accountHolder: string;
}

export interface UserProfile {
  id: string;
  name: string;
  email: string;
  phone: string;
  role: UserRole;
  storeName: string;
  storeId: string;
  status: 'Seller Aktif' | 'Seller Terverifikasi' | 'Akun Ditangguhkan';
  avatar: string;
  storeAddress: string;
  joinedDate: string;
  rating: number;
  totalReview: number;
  balance: number;
  bankAccount: BankAccount;
}

export interface AuthState {
  user: UserProfile | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}
