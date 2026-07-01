# 📱 Bad Wallet App

Une application mobile de gestion de portefeuille (Wallet) moderne et intuitive, développée avec **Flutter** pour le frontend et connectée à une API **Spring Boot** pour le backend.

Ce projet a été réalisé dans le cadre de l'évaluation finale du semestre de **Flutter (L3 S2 - 2026)**.

---

## ✨ Fonctionnalités Réalisées

* **Gestion du solde :** Visualisation en temps réel du solde du portefeuille.
* **Transferts d'argent :** Envoi rapide et sécurisé de fonds vers d'autres utilisateurs.
* **Paiement de factures :** Interface dédiée pour le règlement des factures (`bills_screen.dart`).
* **Historique des transactions :** Suivi complet des opérations effectuées.

---

## 🏗️ Architecture du Projet

Le projet respecte rigoureusement l'architecture **Feature-First**, garantissant une modularité optimale du code source :

```text
lib/
│
├── core/                  # Éléments partagés (constantes, thèmes)
│   └── constants.dart
│
├── features/              # Organisation par blocs de fonctionnalités
│   ├── auth/              # Authentification (login, splash)
│   ├── bills/             # Gestion et paiement des factures
│   ├── dashboard/         # Écran principal et état du wallet
│   ├── history/           # Historique des transactions
│   └── transfers/         # Effectuer un transfert
│
└── main.dart              # Point d'entrée de l'application