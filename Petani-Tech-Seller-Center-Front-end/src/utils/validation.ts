export const isValidEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email.trim());
};

export const isValidPhone = (phone: string): boolean => {
  const phoneRegex = /^(\+62|62|0)8[1-9][0-9]{6,10}$/;
  return phoneRegex.test(phone.replace(/\s|-/g, ''));
};

export const isPositiveNumber = (val: string | number): boolean => {
  const n = Number(val);
  return !isNaN(n) && n > 0;
};
