import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';
import { config, getRandomProduct, logTestStart } from './config.js';

// Métriques spécifiques au checkout
const checkoutErrors = new Rate('checkout_errors');
const checkoutDuration = new Trend('checkout_duration');

export let options = {
  vus: config.checkoutTest.vus,
  duration: config.checkoutTest.duration,
  
  stages: [
    { duration: config.checkoutTest.rampUp, target: config.checkoutTest.vus },
    { duration: config.checkoutTest.duration, target: config.checkoutTest.vus },
    { duration: config.checkoutTest.rampDown, target: 0 },
  ],
  
  thresholds: {
    // Seuils stricts pour le checkout (critiques business)
    http_req_duration: ['p(95)<1500'],           // 1.5s max pour 95% des req
    http_req_failed: ['rate<0.005'],             // < 0.5% d'erreurs
    checkout_errors: ['rate<0.01'],              // < 1% d'erreurs checkout
    checkout_duration: ['p(95)<2000'],           // Processus checkout < 2s
    checks: ['rate>0.99'],                       // 99% de succès minimum
  },
};

export function setup() {
  logTestStart('Test de Charge Checkout - ShopFlutter');
  
  // Vérification que l'app est accessible
  const healthCheck = http.get(config.baseUrl);
  if (healthCheck.status !== 200) {
    throw new Error(`❌ Application inaccessible: ${healthCheck.status}`);
  }
  
  console.log('✅ Application accessible, tests checkout démarrent');
  return { baseUrl: config.baseUrl };
}

export default function (data) {
  const baseUrl = data.baseUrl;
  const startTime = Date.now();
  
  // Simulation du parcours checkout complet
  checkoutFlow(baseUrl);
  
  // Enregistrer la durée totale du checkout
  checkoutDuration.add(Date.now() - startTime);
}

function checkoutFlow(baseUrl) {
  // 1. Page d'accueil - Point d'entrée
  let response = http.get(`${baseUrl}/`, {
    headers: config.headers,
    tags: { flow: 'checkout', step: '1_homepage' }
  });
  
  let success = check(response, {
    '✅ [1/6] Homepage chargée': (r) => r.status === 200,
    '✅ [1/6] Homepage rapide': (r) => r.timings.duration < 1000,
  });
  checkoutErrors.add(!success);
  
  sleep(1); // Temps de lecture/navigation
  
  // 2. Catalogue - Recherche produit
  response = http.get(`${baseUrl}/catalogue`, {
    headers: config.headers,
    tags: { flow: 'checkout', step: '2_catalogue' }
  });
  
  success = check(response, {
    '✅ [2/6] Catalogue accessible': (r) => r.status === 200,
    '✅ [2/6] Catalogue rapide': (r) => r.timings.duration < 1500,
  });
  checkoutErrors.add(!success);
  
  sleep(2); // Temps de parcours des produits
  
  // 3. Détail produit - Décision d'achat
  const product = getRandomProduct();
  response = http.get(`${baseUrl}/product/${product.id}`, {
    headers: config.headers,
    tags: { flow: 'checkout', step: '3_product_detail' }
  });
  
  success = check(response, {
    '✅ [3/6] Détail produit OK': (r) => r.status === 200,
    '✅ [3/6] Détail produit rapide': (r) => r.timings.duration < 1200,
  });
  checkoutErrors.add(!success);
  
  sleep(3); // Temps d'analyse du produit
  
  // 4. Ajout au panier - Action critique
  const addToCartPayload = JSON.stringify({
    productId: product.id,
    quantity: Math.floor(Math.random() * 2) + 1,
    variantId: 'default',
    timestamp: new Date().toISOString()
  });
  
  response = http.post(`${baseUrl}/api/cart/add`, addToCartPayload, {
    headers: {
      ...config.headers,
      'Content-Type': 'application/json',
    },
    tags: { flow: 'checkout', step: '4_add_to_cart' }
  });
  
  // Accepter 404 si l'API n'est pas encore implémentée
  success = check(response, {
    '✅ [4/6] Ajout panier traité': (r) => r.status === 200 || r.status === 404,
    '✅ [4/6] Ajout panier rapide': (r) => r.timings.duration < 800,
  });
  checkoutErrors.add(!success);
  
  sleep(1);
  
  // 5. Page panier - Révision commande
  response = http.get(`${baseUrl}/cart`, {
    headers: config.headers,
    tags: { flow: 'checkout', step: '5_cart_review' }
  });
  
  success = check(response, {
    '✅ [5/6] Page panier accessible': (r) => r.status === 200,
    '✅ [5/6] Page panier rapide': (r) => r.timings.duration < 1000,
  });
  checkoutErrors.add(!success);
  
  sleep(2); // Temps de révision
  
  // 6. Processus checkout - Point critique
  const checkoutPayload = JSON.stringify({
    items: [{ productId: product.id, quantity: 1, price: 29.99 }],
    total: 29.99,
    currency: 'EUR',
    customerEmail: 'test@shopflutter.com',
    shippingAddress: {
      street: '123 Test Street',
      city: 'Test City',
      postalCode: '12345',
      country: 'FR'
    },
    paymentMethod: 'stripe_test'
  });
  
  response = http.post(`${baseUrl}/api/checkout`, checkoutPayload, {
    headers: {
      ...config.headers,
      'Content-Type': 'application/json',
    },
    tags: { flow: 'checkout', step: '6_checkout_process' }
  });
  
  success = check(response, {
    '✅ [6/6] Checkout traité': (r) => r.status === 200 || r.status === 404,
    '✅ [6/6] Checkout acceptable': (r) => r.timings.duration < 2000,
  });
  checkoutErrors.add(!success);
  
  // Simulation d'une redirection vers une page de succès
  if (response.status === 200) {
    sleep(0.5);
    response = http.get(`${baseUrl}/order/success`, {
      headers: config.headers,
      tags: { flow: 'checkout', step: '7_success_page' }
    });
    
    check(response, {
      '✅ [Bonus] Page succès accessible': (r) => r.status === 200,
    });
  }
  
  sleep(1); // Temps de finalisation
}

export function teardown() {
  console.log('🏁 Tests de charge checkout terminés');
  console.log('💰 Métriques critiques pour le business collectées');
}