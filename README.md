# Admin Script Web

Application Node.js/Express pour la distribution et l'exécution de scripts PowerShell.

## 🚀 Démarrage rapide

### Installation locale
```bash
# Installer les dépendances
npm install

# Lancer l'application en développement
npm start

# Ou directement avec Node
node index.js
```

L'application sera accessible à `http://localhost:3000`

### Interface web
- **Accueil** : http://localhost:3000/
- **Interface graphique** : http://localhost:3000/web
- **Health check** : http://localhost:3000/health

## 📋 Structure du projet

```
admin-script-web/
├── index.js                    # Fichier principal de l'application
├── Auto admin region V-2.ps1  # Script PowerShell à distribuer
├── package.json               # Dépendances et configuration npm
├── package-lock.json          # Lock file pour npm
├── ecosystem.config.js        # Configuration PM2 pour production
├── .env.example              # Variables d'environnement (exemple)
├── .gitignore                # Fichiers à ignorer dans Git
├── nginx.conf                # Configuration Nginx (reverse proxy)
├── DEBIAN_SETUP.md           # Guide de déploiement sur Debian 13
└── README.md                 # Ce fichier
```

## 📦 Dépendances

- **Node.js** : v18+ recommandé
- **npm** : v9+
- **Express** : v5.x (framework web)

## 🔧 Configuration

### Variables d'environnement
Copier `.env.example` en `.env` et configurer selon vos besoins:

```bash
cp .env.example .env
```

Options disponibles :
- `NODE_ENV` : `development` ou `production`
- `PORT` : Port d'écoute (défaut: 3000)
- `LOG_LEVEL` : Niveau de logging (defaut: info)

## 🌐 Déploiement

Consulter le fichier `DEBIAN_SETUP.md` pour un guide complet de déploiement sur **Debian 13** incluant:

- Installation de Node.js et npm
- Gestion des processus avec PM2
- Configuration de Nginx en reverse proxy
- Configuration SSL avec Let's Encrypt
- Surveillance et maintenance

### Déploiement rapide
```bash
# Cloner le projet
git clone https://votre-repo.git
cd admin-script-web

# Installer les dépendances
npm install

# Installer PM2 globalement
sudo npm install -g pm2

# Démarrer l'application
pm2 start ecosystem.config.js

# Sauvegarder la configuration PM2
pm2 save
pm2 startup
```

## 📊 API Endpoints

### GET `/`
Retourne le contenu du script PowerShell brut.

**Réponse :** `text/plain`
```powershell
irm https://aar.nial-tech.com/ | iex
```

### GET `/web`
Interface web graphique pour la distribution du script.

**Réponse :** `text/html`

### GET `/health`
Endpoint de vérification de l'état du serveur.

**Réponse :** `application/json`
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

## 📝 Logging

Les logs sont configurés dans `ecosystem.config.js`:
- **Logs de sortie** : `logs/out.log`
- **Logs d'erreur** : `logs/err.log`

Consulter les logs en temps réel:
```bash
pm2 logs admin-script-web
```

## 🔐 Sécurité

### Bonnes pratiques implémentées
- ✅ Headers de sécurité (X-Frame-Options, X-Content-Type-Options, etc.)
- ✅ Gzip compression
- ✅ SSL/TLS avec Let's Encrypt
- ✅ Reverse proxy Nginx
- ✅ Redirection HTTP → HTTPS
- ✅ Rate limiting (peut être ajouté si nécessaire)

### Recommandations supplémentaires
- Utiliser HTTPS en production
- Configurer un pare-feu (UFW)
- Mettre à jour régulièrement les dépendances : `npm audit fix`
- Utiliser des variables d'environnement pour les données sensibles

## 🐛 Dépannage

### L'application ne démarre pas
```bash
# Vérifier les erreurs
node index.js

# Ou avec PM2
pm2 logs admin-script-web
```

### Port déjà utilisé
```bash
# Chercher le processus utilisant le port
sudo lsof -i :3000

# Ou lancer sur un autre port
PORT=3001 npm start
```

### Mise à jour des dépendances
```bash
# Vérifier les mises à jour disponibles
npm outdated

# Mettre à jour les dépendances
npm update

# Ou installer une version spécifique
npm install express@latest
```

## 📚 Ressources

- [Node.js Documentation](https://nodejs.org/docs/)
- [Express.js Guide](https://expressjs.com/)
- [PM2 Documentation](https://pm2.keymetrics.io/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Let's Encrypt](https://letsencrypt.org/)

## 📄 Licence

ISC

## 👤 Auteur

Admin Script Web

## 🤝 Contribution

Les contributions sont bienvenues ! Pour contribuer:

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit les modifications (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Créer une Pull Request

---

**Note** : Ce script télécharge et exécute du code à distance. À utiliser uniquement dans un environnement de confiance avec les droits administrateur appropriés.
