// Configuration centralisée pour les tests K6
export const config = {
  // URL de base - peut être surchargée par variable d'environnement
  baseUrl: __ENV.TARGET_URL || 'https://shopflutter.web.app',
  
  // Configuration des tests de charge
  loadTest: {
    vus: 10,              // Utilisateurs virtuels simultanés
    duration: '2m',       // Durée du test
    rampUp: '30s',        // Montée en charge progressive
    rampDown: '30s',      // Descente progressive
  },
  
  // Configuration des tests de stress
  stressTest: {
    stages: [
      { duration: '1m', target: 10 },    // Montée normale
      { duration: '3m', target: 50 },    // Montée de charge
      { duration: '2m', target: 100 },   // Test de stress
      { duration: '1m', target: 0 },     // Redescente
    ],
  },
  
  // Configuration des tests de checkout
  checkoutTest: {
    vus: 20,
    duration: '90s',
    rampUp: '20s',
    rampDown: '20s',
  },
  
  // Seuils de performance communs
  thresholds: {
    // 95% des requêtes doivent être < 1s
    http_req_duration: ['p(95)<1000'],
    // 99% des requêtes doivent être < 2s  
    'http_req_duration{type:page}': ['p(99)<2000'],
    // Taux d'erreur < 1%
    http_req_failed: ['rate<0.01'],
    // Taux de succès des checks > 99%
    checks: ['rate>0.99'],
  },
  
  // En-têtes HTTP communs
  headers: {
    'User-Agent': 'K6-ShopFlutter-LoadTest/1.0',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'fr-FR,fr;q=0.9,en;q=0.8',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
  },
  
  // Produits de test (pour éviter les hardcodes)
  testData: {
    products: [
      { id: '123', name: 'Produit Test 1' },
      { id: '456', name: 'Produit Test 2' },
      { id: '789', name: 'Produit Test 3' },
    ],
    users: {
      testEmail: 'test@shopflutter.com',
      testPassword: 'TestPass123!',
    }
  }
};

// Utilitaires pour les tests
export function getRandomProduct() {
  const products = config.testData.products;
  return products[Math.floor(Math.random() * products.length)];
}

export function logTestStart(testName) {
  console.log(`🚀 Démarrage du test: ${testName}`);
  console.log(`📍 URL cible: ${config.baseUrl}`);
  console.log(`⏰ Timestamp: ${new Date().toISOString()}`);
}