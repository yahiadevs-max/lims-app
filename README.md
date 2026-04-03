# 🧪 LIMS - Laboratory Information Management System

Une solution complète et moderne de gestion des laboratoires d'analyse.

![Node.js](https://img.shields.io/badge/Node.js-18+-green)
![Next.js](https://img.shields.io/badge/Next.js-14+-black)
![NestJS](https://img.shields.io/badge/NestJS-10+-red)
![MySQL](https://img.shields.io/badge/MySQL-8.0+-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Caractéristiques

### 🔐 Sécurité & Authentification
- JWT avec refresh tokens
- Authentification 2FA/TOTP
- Rôles et permissions
- Audit logs complet
- Rate limiting

### 📊 Gestion des Données
- Gestion complète des échantillons
- Suivi des analyses
- Résultats et rapports
- Génération de rapports (PDF, Excel, CSV)
- Export de données

### 🛠️ Fonctionnalités Avancées
- Dashboard analytique
- Contrôle de qualité
- Gestion des instruments
- Maintenance planifiée
- Notifications par email
- Intégration WebSocket en temps réel

### 📱 Multi-Platform
- Frontend React moderne
- Frontend Next.js performant
- API REST + GraphQL
- Mobile-responsive

## 🚀 Quick Start

### Avec Docker Compose (Recommandé)

```bash
git clone https://github.com/yahiadevs-max/lims-app.git
cd lims-app

# Copier les fichiers d'environnement
cp .env.example .env

# Démarrer les services
docker-compose up -d

# Initialiser la base de données
docker-compose exec mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} < migrations/schema.sql

# Seed les données de test
npm run seed
