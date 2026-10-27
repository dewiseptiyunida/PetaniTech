export type MainTabParamList = {
  Dashboard: undefined;
  Products: undefined;
  Orders: undefined;
  Inventory: undefined;
  Finance: undefined;
  Promotions: undefined;
  Analytics: undefined;
  Profile: undefined;
};

export type RootStackParamList = {
  Auth: undefined;
  Main: undefined;
};

export type AuthStackParamList = {
  Splash: undefined;
  Login: { initialTab?: 'login' | 'register' } | undefined;
  Register: undefined;
};