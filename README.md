# ShopFlutter – Application E‑Commerce Complète

Une application e‑commerce Flutter Web (Android/iOS optionnel), MVVM/Clean, Firebase Auth, Stripe Payment, avec **CI/CD GitHub Actions** et **déploiement Web automatisé (Blue-Green)**.

---

## Table des matières

1. [Description](#description)  
2. [Fonctionnalités](#fonctionnalités)  
3. [Tech Stack](#tech-stack)  
4. [Installation et lancement](#installation-et-lancement)  
5. [Configuration](#configuration)  

---

## Description

**ShopFlutter** est un MVP e‑commerce développé en 5 jours en binôme. Il permet :  

- Catalogue produits interactif  
- Détail produit complet  
- Panier et checkout simplifié  
- Auth Firebase Email/Password  
- Déploiement Web automatisé via GitHub Actions et Firebase Hosting  

---

## Fonctionnalités

- Parcourir un catalogue avec recherche/filtre simple  
- Voir les détails d’un produit : images, prix, description  
- Ajouter/modifier produits dans le panier  
- Checkout mock + création de commande locale  
- Auth Email/Password Firebase (+ Google Sign-In optionnel)  
- Historique commandes et Profil (optionnel)  
- Adaptation plateforme (PWA Web, Android/iOS features)  

---

## Tech Stack

- **Front-end** : Flutter Web 3.35.4  
- **Backend / Auth** : Firebase (Auth, Firestore optionnel)  
- **Paiement** : Stripe  
- **State management** : Provider  
- **Routing** : go_router  
- **CI/CD** : GitHub Actions  
- **Déploiement** : Firebase Hosting (Blue-Green)  

---

## Installation et lancement

### Prérequis

- Flutter 3.35.4+  
- Firebase CLI  
- Node.js / npm  

### Lancer localement (Web)

```bash
flutter run -d chrome \
  --dart-define=FIREBASE_API_KEY_WEB=TA_FIREBASE_API_KEY_WEB \
  --dart-define=FIREBASE_AUTH_DOMAIN_WEB=TON_FIREBASE_AUTH_DOMAIN \
  --dart-define=FIREBASE_PROJECT_ID=TON_FIREBASE_PROJECT_ID \
  --dart-define=FIREBASE_STORAGE_BUCKET=TON_FIREBASE_STORAGE_BUCKET \
  --dart-define=FIREBASE_APP_ID_WEB=TON_FIREBASE_APP_ID_WEB \
  --dart-define=FIREBASE_MEASUREMENT_ID_WEB=TON_FIREBASE_MEASUREMENT_ID \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID_WEB=TON_FIREBASE_MESSAGING_SENDER_ID \
  --dart-define=STRIPE_PUBLISHABLE_KEY=TA_STRIPE_PUBLISHABLE_KEY
```

### Configuration
.env pour mobile :
```bash
# Stripe
publishableKey=pk_test_...
secretKey=sk_test_...

# Firebase Web
FIREBASE_API_KEY_WEB=...
FIREBASE_APP_ID_WEB=...
FIREBASE_MESSAGING_SENDER_ID_WEB=...
FIREBASE_PROJECT_ID=...
FIREBASE_AUTH_DOMAIN_WEB=...
FIREBASE_STORAGE_BUCKET=...
FIREBASE_MEASUREMENT_ID_WEB=...
```


URL live Web : https://shopflutter.web.app