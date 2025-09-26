class EnvironmentConfig {
  // Firebase Web
  static const firebaseApiKeyWeb =
      String.fromEnvironment('FIREBASE_API_KEY_WEB');
  static const firebaseAuthDomainWeb =
      String.fromEnvironment('FIREBASE_AUTH_DOMAIN_WEB');
  static const firebaseProjectId =
      String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const firebaseStorageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const firebaseAppIdWeb = String.fromEnvironment('FIREBASE_APP_ID_WEB');
  static const firebaseMeasurementIdWeb =
      String.fromEnvironment('FIREBASE_MEASUREMENT_ID_WEB');
  static const firebaseMessagingSenderIdWeb =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID_WEB');

  // Stripe
  static const stripePublishableKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
}
