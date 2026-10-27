import axios, { AxiosError, AxiosInstance } from 'axios';
import { Platform } from 'react-native';
import { storage } from '@/services/storage';

const getBaseUrl = () => {
  let url = process.env.EXPO_PUBLIC_API_URL || 'http://localhost:8080/api/v1';
  if (Platform.OS === 'android' && url.includes('localhost')) {
    url = url.replace('localhost', '10.0.2.2');
  }
  return url;
};

const API_BASE_URL = getBaseUrl();
const API_TIMEOUT = Number(process.env.EXPO_PUBLIC_API_TIMEOUT) || 10000;
export const USE_MOCK = process.env.EXPO_PUBLIC_USE_MOCK === 'true';

const axiosInstance: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: API_TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  },
});

axiosInstance.interceptors.request.use(
  async (config) => {
    const token = await storage.getItem('petani_tech_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

axiosInstance.interceptors.response.use(
  (response) => response,
  async (error: AxiosError<{ message?: string }>) => {
    if (error.response?.status === 401) {
      await storage.removeItem('petani_tech_token');
    }
    const message =
      error.response?.data?.message ||
      error.message ||
      'Terjadi kesalahan jaringan. Periksa koneksi internet Anda.';
    return Promise.reject(new Error(message));
  }
);

export { axiosInstance };

export const simulateDelay = (ms = 350): Promise<void> =>
  new Promise((resolve) => setTimeout(resolve, ms));

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
  pagination?: {
    currentPage: number;
    totalPages: number;
    totalItems: number;
  };
}

export const API_BASE_URL_EXPORT = API_BASE_URL;
