# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.9] - 2025-04-20

### Ajouté
- Nouvelle page d'accueil avec design inspiré d'Apple
- Menu mobile responsive avec animations
- Effets de parallaxe et animations subtiles
- Mise en page optimisée pour mobile
- Sections Features et Stats repensées
- Interface de gestion des QR codes avec personnalisation (couleur, taille) et export multi-formats
- Nouveau design des formulaires avec labels flottants et animations
- Layout manager avec navigation responsive et notifications
- Composants modaux améliorés utilisant Headless UI
- Intégration des icônes Lucide

### Modifié
- Amélioration de l'expérience utilisateur sur mobile
- Optimisation des performances d'animation
- Refonte du design des pages produits et QR codes
- Amélioration de l'expérience utilisateur des formulaires
- Migration vers le module Supabase officiel de Nuxt
- Optimisation des performances avec le chargement dynamique des composants

### Corrigé
- Problème de redéfinition du client Supabase
- Gestion des erreurs améliorée avec retours visuels
- Animations plus fluides des modaux et transitions
- Support mobile optimisé

### Technique
- Migration vers Nuxt 3.8.0
- Ajout des dépendances :
  - @headlessui/vue: ^1.7.23
  - lucide-vue-next: ^0.468.0
  - qrcode-vue3: ^1.7.1
  - html2canvas: ^1.4.1
- Typage TypeScript amélioré
- Structure du projet réorganisée

## [0.1.0] - 2024-01-20

### Ajouté
- Configuration initiale du projet
- Mise en place de Nuxt.js
- Intégration de Supabase
- Structure de base de données 