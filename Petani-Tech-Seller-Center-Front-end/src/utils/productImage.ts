import { ImageSourcePropType } from 'react-native';
import { assets } from '@/assets';

export function resolveProductImage(image?: string, name?: string): ImageSourcePropType {
  const imgStr = (image || '').toLowerCase();
  const nameStr = (name || '').toLowerCase();

  if (imgStr.includes('bionava') || nameStr.includes('bionava')) {
    return assets.products.bionava;
  }
  if (imgStr.includes('cangkul2') || nameStr.includes('cangkul 2') || nameStr.includes('cangkul2')) {
    return assets.products.cangkul2;
  }
  if (imgStr.includes('cangkul') || nameStr.includes('cangkul')) {
    return assets.products.cangkul;
  }
  if (imgStr.includes('grao') || imgStr.includes('verde') || nameStr.includes('grao')) {
    return assets.products.graoVerde;
  }
  if (imgStr.includes('pintinhos') || nameStr.includes('pintinhos')) {
    return assets.products.pintinhos;
  }
  if (imgStr.includes('prosil') || nameStr.includes('prosil')) {
    return assets.products.prosil;
  }
  if (imgStr.includes('npk') || nameStr.includes('pupuk npk') || nameStr.includes('npk')) {
    return assets.products.pupukNpk;
  }
  if (imgStr.includes('skop') || nameStr.includes('skop') || nameStr.includes('sekop')) {
    return assets.products.skop;
  }
  if (imgStr.includes('sprayer') || nameStr.includes('sprayer')) {
    return assets.products.sprayer;
  }

  if (image && (image.startsWith('http://') || image.startsWith('https://') || image.startsWith('file://') || image.startsWith('content://') || image.startsWith('data:'))) {
    return { uri: image };
  }

  // Fallback to logo or bionava
  return assets.products.bionava;
}
