import http from 'k6/http';
import { sleep, check } from 'k6';

export let options = {
  vus: 50,              // nombre d'utilisateurs virtuels simultanés
  duration: '1m',       // durée totale du test
  thresholds: {         // critères de succès/échec
    http_req_duration: ['p(95)<800'], // 95% des req < 800ms
    http_req_failed: ['rate<0.01'],   // < 1% d'erreurs
  },
};

export default function () {
  // 1. Charger la home
  let res = http.get('https://shopflutter.web.app');
  check(res, { 'home 200': (r) => r.status === 200 });

  // 2. Ouvrir un produit
  res = http.get('https://shopflutter.web.app/#/catalog');
  check(res, { 'catalog 200': (r) => r.status === 200 });

    

  sleep(1); // pause entre actions
}
