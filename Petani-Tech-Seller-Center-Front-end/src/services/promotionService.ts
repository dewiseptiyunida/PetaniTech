import initialPromotions from '@/mock/promotions.json';
import { Promotion } from '@/types';
import { simulateDelay } from '@/api/client';
import { storage } from '@/services/storage';

const STORAGE_KEY_PROMOS = 'petani_tech_promos';

class PromotionService {
  private async getLocalPromos(): Promise<Promotion[]> {
    const raw = await storage.getItem(STORAGE_KEY_PROMOS);
    if (!raw) {
      await storage.setItem(STORAGE_KEY_PROMOS, JSON.stringify(initialPromotions));
      return initialPromotions as Promotion[];
    }
    try {
      return JSON.parse(raw) as Promotion[];
    } catch {
      return initialPromotions as Promotion[];
    }
  }

  private async saveLocalPromos(promos: Promotion[]): Promise<void> {
    await storage.setItem(STORAGE_KEY_PROMOS, JSON.stringify(promos));
  }

  async getPromotions(): Promise<Promotion[]> {
    await simulateDelay(200);
    return this.getLocalPromos();
  }

  async createPromotion(promo: Omit<Promotion, 'id' | 'usedCount'>): Promise<Promotion> {
    await simulateDelay(300);
    const list = await this.getLocalPromos();
    const newPromo: Promotion = {
      ...promo,
      id: `PRM-${Math.floor(100 + Math.random() * 900)}`,
      usedCount: 0,
    };
    list.unshift(newPromo);
    await this.saveLocalPromos(list);
    return newPromo;
  }
}

export const promotionService = new PromotionService();
export default promotionService;
