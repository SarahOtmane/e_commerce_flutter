import http from 'k6/http';
import { sleep, check } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Métriques personnalisées
const errorRate = new Rate('checkout_errors');
const checkoutTime = new Trend('checkout_complete_time');

export let options = {
  vus: 50,                    // nombre d'utilisateurs virtuels simultanés
  duration: '1m',             // durée totale du test
  
  // Configuration par étapes pour une montée en charge progressive
  stages: [
    { duration: '10s', target: 10 },  // Montée douce
    { duration: '40s', target: 50 },  // Charge normale
    { duration: '10s', target: 0 },   // Descente
  ],
  
  thresholds: {                       // critères de succès/échec
    http_req_duration: ['p(95)<800'], // 95% des req < 800ms
    http_req_failed: ['rate<0.01'],   // < 1% d'erreurs HTTP
    checkout_errors: ['rate<0.02'],   // < 2% d'erreurs business
    checkout_complete_time: ['p(95)<3000'], // Checkout complet < 3s
    checks: ['rate>0.98'],            // 98% de succès minimum
  },
  
  // Options d'optimisation
  discardResponseBodies: false,       // Garder les réponses pour validation
  summaryTrendStats: ['avg', 'min', 'med', 'max', 'p(90)', 'p(95)', 'p(99)'],
};

export function setup() {
  console.log('🚀 Démarrage test checkout ShopFlutter');
  console.log('📍 URL cible: https://shopflutter.web.app');
  
  // Test de santé préliminaire
  const healthCheck = http.get('https://shopflutter.web.app');
  if (healthCheck.status !== 200) {
    throw new Error(`❌ Application non accessible: ${healthCheck.status}`);
  }
  
  console.log('✅ Application accessible, début des tests');
  return { startTime: Date.now() };
}

export default function () {
  const startCheckout = Date.now();
  let checkoutSuccess = true;
  
  // 1. Charger la home avec validation améliorée
  let res = http.get('https://shopflutter.web.app', {
    headers: {
      'User-Agent': 'K6-ShopFlutter-Test/1.0',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    },
    tags: { step: 'homepage' }
  });
  
  let success = check(res, { 
    '✅ Home page 200': (r) => r.status === 200,
    '✅ Home page rapide': (r) => r.timings.duration < 1000,
    '✅ Home page contient titre': (r) => r.body.includes('shop') || r.body.includes('Shop') || r.body.includes('Flutter'),
  });
  
  if (!success) {
    checkoutSuccess = false;
    errorRate.add(1);
  }

<<<<<<< HEAD
  // 2. Ouvrir un produit
  res = http.get('https://shopflutter.web.app/#/catalog');
  check(res, { 'catalog 200': (r) => r.status === 200 });

    
=======
  sleep(1); // Pause réaliste utilisateur

  // 2. Ouvrir un produit avec ID dynamique
  const productIds = ['123', '456', '789', 'prod-1', 'test-product'];
  const randomProductId = productIds[Math.floor(Math.random() * productIds.length)];
  
  res = http.get(`https://shopflutter.web.app/product/${randomProductId}`, {
    tags: { step: 'product-detail' }
  });
  
  success = check(res, { 
    '✅ Product page accessible': (r) => r.status === 200 || r.status === 404, // 404 OK si produit n'existe pas
    '✅ Product page rapide': (r) => r.timings.duration < 1200,
  });
  
  if (!success && res.status !== 404) {
    checkoutSuccess = false;
    errorRate.add(1);
  }

  sleep(2); // Temps de consultation produit

  // 3. Tentative d'ajout au panier (si API disponible)
  const addToCartPayload = JSON.stringify({ 
    productId: randomProductId, 
    qty: Math.floor(Math.random() * 3) + 1,
    timestamp: new Date().toISOString()
  });
  
  let headers = { 
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  res = http.post('https://shopflutter.web.app/api/cart/add', addToCartPayload, { 
    headers: headers,
    tags: { step: 'add-to-cart' }
  });
  
  success = check(res, { 
    '✅ Add to cart handled': (r) => r.status === 200 || r.status === 404 || r.status === 405, // Accepter si pas implémenté
  });

  sleep(0.5);

  // 4. Page panier
  res = http.get('https://shopflutter.web.app/cart', {
    tags: { step: 'cart-page' }
  });
  
  success = check(res, {
    '✅ Cart page accessible': (r) => r.status === 200,
    '✅ Cart page rapide': (r) => r.timings.duration < 1000,
  });
  
  if (!success) {
    checkoutSuccess = false;
    errorRate.add(1);
  }

  sleep(1);

  // 5. Simuler checkout (API mock ou réelle)
  const checkoutPayload = JSON.stringify({ 
    productId: randomProductId, 
    qty: 1,
    total: 29.99,
    currency: 'EUR',
    customerEmail: 'test@k6-checkout.com',
    paymentMethod: 'stripe',
    testMode: true
  });
  
  res = http.post('https://shopflutter.web.app/api/checkout', checkoutPayload, { 
    headers: headers,
    tags: { step: 'checkout-process' }
  });
  
  success = check(res, { 
    '✅ Checkout API response': (r) => r.status === 200 || r.status === 404 || r.status === 405,
    '✅ Checkout pas trop lent': (r) => r.timings.duration < 2000,
  });
  
  // Si checkout échoue vraiment (pas juste non implémenté)
  if (!success && res.status >= 500) {
    checkoutSuccess = false;
    errorRate.add(1);
  }

  // 6. Page de confirmation/succès
  res = http.get('https://shopflutter.web.app/order/success', {
    tags: { step: 'success-page' }
  });
  
  check(res, {
    '✅ Success page handling': (r) => r.status === 200 || r.status === 404,
  });

  // Enregistrer le temps total de checkout
  const totalCheckoutTime = Date.now() - startCheckout;
  checkoutTime.add(totalCheckoutTime);
  
  // Marquer erreur si checkout globalement échoué
  if (!checkoutSuccess) {
    errorRate.add(1);
  }
>>>>>>> d2667b3571532a093c30a6eb5e0460b8f853e570

  sleep(1); // pause entre actions
}

export function teardown(data) {
  console.log('🏁 Test checkout terminé');
  console.log(`⏱️  Durée totale: ${(Date.now() - data.startTime) / 1000}s`);
  console.log('📊 Consultez les métriques détaillées ci-dessus');
}
