import initialAnalytics from '@/mock/analytics.json';
import { AnalyticsSummary } from '@/types';
import { axiosInstance, USE_MOCK, simulateDelay } from '@/services/api/client';

class AnalyticsService {
  async getAnalytics(): Promise<AnalyticsSummary> {
    if (!USE_MOCK) {
      try {
        const response = await axiosInstance.get('/seller/analytics');
        const data = response.data?.data || response.data;
        if (data && data.summary) {
          return data as AnalyticsSummary;
        }
      } catch (err) {
        console.warn('API getAnalytics error, falling back to mock:', err);
      }
    }

    await simulateDelay(250);
    return initialAnalytics as unknown as AnalyticsSummary;
  }
}

export const analyticsService = new AnalyticsService();
export default analyticsService;
