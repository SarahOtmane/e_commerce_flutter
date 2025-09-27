import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';
import { config, getRandomProduct, logTestStart } from './config.js';

// Métriques personnalisées
const errorRate = new Rate('errors');

export let options = {
  vus: config.loadTest.vus,
  duration: config.loadTest.duration,
  thresholds: config.thresholds,
  
  // Configuration des étapes (optionnel)
  stages: [
    { duration: config.loadTest.rampUp, target: config.loadTest.vus },
    { duration: config.loadTest.duration, target: config.loadTest.vus },
    { duration: config.loadTest.rampDown, target: 0 },
  ],
  
  // Collecte des métriques
  summaryTrendStats: ['avg', 'min', 'med', 'max', 'p(90)', 'p(95)', 'p(99)'],
};

export function setup() {
  logTestStart('Load Test Général - ShopFlutter');
}

export default function () {
  const baseUrl = config.baseUrl;
  
  // 1. Page d'accueil
  let response = http.get(`${baseUrl}/`, {
    headers: config.headers,
    tags: { type: 'page', name: 'homepage' }
  });
  
  let homePageOk = check(response, {
    '✅ Homepage status 200': (r) => r.status === 200,
    '✅ Homepage loads in <2s': (r) => r.timings.duration < 2000,
    '✅ Homepage contains title': (r) => r.body.includes('ShopFlutter') || r.body.includes('shop'),
  });
  errorRate.add(!homePageOk);
  
  sleep(1);
  
  // 2. Navigation vers le catalogue
  response = http.get(`${baseUrl}/catalogue`, {
    headers: config.headers,
    tags: { type: 'page', name: 'catalogue' }
  });
  
  let catalogueOk = check(response, {
    '✅ Catalogue status 200': (r) => r.status === 200,
    '✅ Catalogue loads in <3s': (r) => r.timings.duration < 3000,
  });
  errorRate.add(!catalogueOk);
  
  sleep(1);
  
  // 3. Consultation d'un produit aléatoire
  const product = getRandomProduct();
  response = http.get(`${baseUrl}/product/${product.id}`, {
    headers: config.headers,
    tags: { type: 'page', name: 'product_detail' }
  });
  
  let productOk = check(response, {
    '✅ Product detail status 200': (r) => r.status === 200,
    '✅ Product detail loads in <2s': (r) => r.timings.duration < 2000,
  });
  errorRate.add(!productOk);
  
  sleep(2);
  
  // 4. Tentative d'ajout au panier (simulation)
  const addToCartPayload = JSON.stringify({
    productId: product.id,
    quantity: Math.floor(Math.random() * 3) + 1
  });
  
  response = http.post(`${baseUrl}/api/cart/add`, addToCartPayload, {
    headers: {
      ...config.headers,
      'Content-Type': 'application/json',
    },
    tags: { type: 'api', name: 'add_to_cart' }
  });
  
  // Note: Accepter 404 si l'API n'existe pas encore
  let cartOk = check(response, {
    '✅ Add to cart success or expected 404': (r) => r.status === 200 || r.status === 404,
  });
  errorRate.add(!cartOk);
  
  sleep(1);
  
  // 5. Page panier
  response = http.get(`${baseUrl}/cart`, {
    headers: config.headers,
    tags: { type: 'page', name: 'cart' }
  });
  
  check(response, {
    '✅ Cart page accessible': (r) => r.status === 200,
  });
  
  sleep(2);
}

export function teardown() {
  console.log('🏁 Test de charge général terminé');
}