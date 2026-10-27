export const formatRupiah = (value: number): string =>
  new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    maximumFractionDigits: 0,
  }).format(value);

export const formatNumber = (value: number): string =>
  new Intl.NumberFormat('id-ID').format(value);

export const formatCompactNumber = (value: number): string =>
  new Intl.NumberFormat('id-ID', { notation: 'compact' }).format(value);

export const formatDate = (dateString: string): string => {
  try {
    const d = new Date(dateString);
    return new Intl.DateTimeFormat('id-ID', {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
    }).format(d);
  } catch {
    return dateString;
  }
};