import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Counter } from 'k6/metrics';
import { config, getRandomProduct, logTestStart } from './config.js';

// Métriques personnalisées pour le stress test
const errorRate = new Rate('stress_errors');
const requestCount = new Counter('stress_requests');

export let options = {
  stages: config.stressTest.stages,
  thresholds: {
    // Seuils plus souples pour les tests de stress
    http_req_duration: ['p(95)<3000'],      // 3s max pour 95% des req
    http_req_failed: ['rate<0.05'],         // Jusqu'à 5% d'erreurs acceptées
    stress_errors: ['rate<0.1'],            // 10% d'erreurs max pendant stress
  },
  
  // Options pour gérer la charge
  discardResponseBodies: true,  // Économiser la mémoire
  noConnectionReuse: false,     // Réutiliser les connexions
  
  // Collecte détaillée des métriques
  summaryTrendStats: ['avg', 'min', 'med', 'max', 'p(90)', 'p(95)', 'p(99)', 'p(99.9)'],
};

export function setup() {
  logTestStart('Stress Test - ShopFlutter E-Commerce');
  
  // Vérification préliminaire que l'app est accessible
  const response = http.get(config.baseUrl);
  if (response.status !== 200) {
    throw new Error(`❌ Application inaccessible: ${response.status}`);
  }
  
  console.log('✅ Application accessible, début du stress test');
}

export default function () {
  const baseUrl = config.baseUrl;
  requestCount.add(1);
  
  // Scénario variable selon l'utilisateur virtuel
  const scenario = Math.random();
  
  if (scenario < 0.4) {
    // 40% - Navigation basique (homepage -> catalogue)
    basicNavigation(baseUrl);
  } else if (scenario < 0.7) {
    // 30% - Consultation produit
    productConsultation(baseUrl);
  } else if (scenario < 0.9) {
    // 20% - Simulation achat
    purchaseSimulation(baseUrl);
  } else {
    // 10% - Stress intensif (multiple requêtes)
    intensiveStress(baseUrl);
  }
  
  // Pause variable pour simuler comportement réel
  sleep(Math.random() * 3 + 0.5);
}

function basicNavigation(baseUrl) {
  // Homepage
  let response = http.get(`${baseUrl}/`, {
    tags: { scenario: 'basic_nav', step: 'homepage' }
  });
  
  let success = check(response, {
    '✅ Homepage OK': (r) => r.status === 200,
  });
  errorRate.add(!success);
  
  sleep(0.5);
  
  // Catalogue
  response = http.get(`${baseUrl}/catalogue`, {
    tags: { scenario: 'basic_nav', step: 'catalogue' }
  });
  
  success = check(response, {
    '✅ Catalogue OK': (r) => r.status === 200,
  });
  errorRate.add(!success);
}

function productConsultation(baseUrl) {
  const product = getRandomProduct();
  
  let response = http.get(`${baseUrl}/product/${product.id}`, {
    tags: { scenario: 'product_view', step: 'detail' }
  });
  
  let success = check(response, {
    '✅ Product detail OK': (r) => r.status === 200,
  });
  errorRate.add(!success);
  
  // Simulation interaction (images, avis, etc.)
  sleep(1);
  
  // Tentative d'ajout panier
  const payload = JSON.stringify({
    productId: product.id,
    quantity: 1
  });
  
  response = http.post(`${baseUrl}/api/cart/add`, payload, {
    headers: { 'Content-Type': 'application/json' },
    tags: { scenario: 'product_view', step: 'add_cart' }
  });
  
  check(response, {
    '✅ Add to cart handled': (r) => r.status === 200 || r.status === 404,
  });
}

function purchaseSimulation(baseUrl) {
  // Simulation du parcours d'achat complet
  const steps = [
    { path: '/catalogue', name: 'catalogue' },
    { path: `/product/${getRandomProduct().id}`, name: 'product' },
    { path: '/cart', name: 'cart' },
    { path: '/checkout', name: 'checkout' },
  ];
  
  steps.forEach((step, index) => {
    let response = http.get(`${baseUrl}${step.path}`, {
      tags: { scenario: 'purchase_flow', step: step.name }
    });
    
    let success = check(response, {
      [`✅ ${step.name} accessible`]: (r) => r.status === 200,
    });
    errorRate.add(!success);
    
    // Pause plus courte pour simuler un utilisateur déterminé
    sleep(0.3);
  });
}

function intensiveStress(baseUrl) {
  // Test de stress intensif - multiple requêtes rapides
  const requests = [
    http.get(`${baseUrl}/`, { tags: { scenario: 'intensive', step: 'home' }}),
    http.get(`${baseUrl}/catalogue`, { tags: { scenario: 'intensive', step: 'catalogue' }}),
    http.get(`${baseUrl}/product/${getRandomProduct().id}`, { tags: { scenario: 'intensive', step: 'product' }}),
  ];
  
  requests.forEach((response, index) => {
    let success = check(response, {
      [`✅ Intensive request ${index + 1} OK`]: (r) => r.status === 200,
    });
    errorRate.add(!success);
  });
}

export function teardown() {
  console.log('🏁 Stress test terminé');
  console.log('📊 Consultez les métriques pour analyser la résistance à la charge');
}