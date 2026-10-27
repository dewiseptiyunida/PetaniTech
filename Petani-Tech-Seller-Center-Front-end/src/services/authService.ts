import initialUserData from '@/mock/users.json';
import { UserProfile } from '@/types';
import { axiosInstance, simulateDelay, USE_MOCK } from '@/services/api/client';
import { storage } from '@/services/storage';

const STORAGE_KEY_USER = 'petani_tech_user';
const STORAGE_KEY_TOKEN = 'petani_tech_token';

export interface RegisterSellerData {
  name: string;
  email: string;
  phone: string;
  storeName: string;
  storeAddress: string;
  password?: string;
}

class AuthService {
  private async getUserFromStorage(): Promise<UserProfile | null> {
    const raw = await storage.getItem(STORAGE_KEY_USER);
    if (!raw) {
      return initialUserData.user as UserProfile;
    }
    try {
      return JSON.parse(raw) as UserProfile;
    } catch {
      return initialUserData.user as UserProfile;
    }
  }

  async login(identifier: string, pass: string): Promise<UserProfile> {
    if (!USE_MOCK) {
      const response = await axiosInstance.post<{ token: string; user: UserProfile }>(
        '/auth/seller/login',
        { identifier, password: pass }
      );
      await storage.setItem(STORAGE_KEY_TOKEN, response.data.token);
      await storage.setItem(STORAGE_KEY_USER, JSON.stringify(response.data.user));
      return response.data.user;
    }

    await simulateDelay(400);

    const idTrim = identifier.trim().toLowerCase();
    const isValidId =
      idTrim === 'fahda@petanitech.id' ||
      idTrim === 'seller@petanitech.id' ||
      idTrim === '081234567890' ||
      idTrim === 'fahda' ||
      idTrim === 'pakbudi';

    if ((isValidId && pass === '123456') || pass === '123456') {
      const user = (await this.getUserFromStorage()) || (initialUserData.user as UserProfile);
      await storage.setItem(STORAGE_KEY_USER, JSON.stringify(user));
      await storage.setItem(STORAGE_KEY_TOKEN, 'jwt-petani-tech-seller-' + Date.now());
      return user;
    }

    throw new Error('Email/Nomor HP atau kata sandi salah. Gunakan akun demo (123456).');
  }

  async register(data: RegisterSellerData): Promise<UserProfile> {
    if (!USE_MOCK) {
      const response = await axiosInstance.post<{ token: string; user: UserProfile }>(
        '/auth/seller/register',
        data
      );
      await storage.setItem(STORAGE_KEY_TOKEN, response.data.token);
      await storage.setItem(STORAGE_KEY_USER, JSON.stringify(response.data.user));
      return response.data.user;
    }

    await simulateDelay(500);

    const newUser: UserProfile = {
      id: 'usr-seller-' + Date.now(),
      name: data.name,
      email: data.email,
      phone: data.phone,
      role: 'seller',
      storeName: data.storeName,
      storeId: 'ID-AGRO-' + Math.floor(1000 + Math.random() * 9000),
      status: 'Seller Terverifikasi',
      avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
      storeAddress: data.storeAddress || 'Indramayu, Jawa Barat',
      joinedDate: 'Oktober 2026',
      rating: 5.0,
      totalReview: 0,
      balance: 0,
      bankAccount: {
        bankName: 'Bank Rakyat Indonesia (BRI)',
        accountNumber: '4321-01-098765-53-2',
        accountHolder: data.name.toUpperCase(),
      },
    };

    await storage.setItem(STORAGE_KEY_USER, JSON.stringify(newUser));
    await storage.setItem(STORAGE_KEY_TOKEN, 'jwt-petani-tech-seller-' + Date.now());
    return newUser;
  }

  async getCurrentUser(): Promise<UserProfile> {
    if (!USE_MOCK) {
      const response = await axiosInstance.get<UserProfile>('/auth/seller/me');
      await storage.setItem(STORAGE_KEY_USER, JSON.stringify(response.data));
      return response.data;
    }

    await simulateDelay(150);
    const user = await this.getUserFromStorage();
    if (!user) {
      throw new Error('Sesi telah berakhir. Silakan login kembali.');
    }
    return user;
  }

  async updateProfile(updates: Partial<UserProfile>): Promise<UserProfile> {
    if (!USE_MOCK) {
      const response = await axiosInstance.patch<UserProfile>('/auth/seller/profile', updates);
      await storage.setItem(STORAGE_KEY_USER, JSON.stringify(response.data));
      return response.data;
    }

    await simulateDelay(250);
    const current = (await this.getUserFromStorage()) || (initialUserData.user as UserProfile);
    const updated = { ...current, ...updates };
    await storage.setItem(STORAGE_KEY_USER, JSON.stringify(updated));
    return updated;
  }

  async logout(): Promise<void> {
    await simulateDelay(150);
    await storage.removeItem(STORAGE_KEY_TOKEN);
  }

  async isAuthenticated(): Promise<boolean> {
    return !!(await storage.getItem(STORAGE_KEY_TOKEN));
  }
}

export const authService = new AuthService();
export default authService;

