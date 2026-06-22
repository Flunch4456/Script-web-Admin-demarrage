# Guide de Déploiement sur Debian 13

Ce guide vous explique comment déployer votre application Node.js sur un serveur Debian 13.

## 1. Préparation du serveur Debian

### Mise à jour du système
```bash
apt update
apt upgrade -y
```

### Installation de Node.js et npm
```bash
# Installer Node.js depuis le dépôt NodeSource (dernière version LTS)
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs npm

# Vérifier les installations
node --version
npm --version
```

### Installation des outils essentiels
```bash
apt install -y git curl wget nano htop
```

## 2. Préparation de l'application

### Cloner ou télécharger le projet
```bash
# Option 1 : Si vous utilisez Git
cd /home/username
git clone https://votre-repo.git admin-script-web
cd admin-script-web

# Option 2 : Ou copier les fichiers manuellement
mkdir -p /home/username/admin-script-web
# Copier vos fichiers dans ce dossier
```

### Installer les dépendances
```bash
cd /home/username/admin-script-web
npm install

# Pour la production, installer également PM2
sudo npm install -g pm2
```

## 3. Configuration avec PM2 (Gestionnaire de processus)

PM2 permettra à votre application de démarrer automatiquement et de redémarrer en cas de problème.

### Créer un fichier de configuration PM2
Créer un fichier `ecosystem.config.js` à la racine du projet:

```javascript
module.exports = {
  apps: [
    {
      name: 'admin-script-web',
      script: './index.js',
      instances: 'max',
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      error_file: './logs/err.log',
      out_file: './logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      max_restarts: 10,
      min_uptime: '10s'
    }
  ]
};
```

### Démarrer l'application avec PM2
```bash
cd /home/username/admin-script-web
pm2 start ecosystem.config.js
pm2 save
env PATH=$PATH:/usr/bin pm2 startup systemd -u root --hp /root
```

### Commandes PM2 utiles
```bash
pm2 list                    # Voir les processus actifs
pm2 logs                    # Voir les logs en temps réel
pm2 restart all             # Redémarrer l'app
pm2 stop all                # Arrêter l'app
pm2 delete all              # Supprimer tous les processus
```

## 4. Configuration de Nginx comme reverse proxy (Optionnel mais recommandé)

### Installation de Nginx
```bash
apt install -y nginx
```

### Créer le fichier de configuration
```bash
nano /etc/nginx/sites-available/admin-script-web
```

Ajouter cette configuration:

```nginx
upstream admin_script_web {
    server 127.0.0.1:3000;
}

server {
    listen 80;
    server_name votre-domaine.com www.votre-domaine.com;

    # Redirection HTTP vers HTTPS (optionnel)
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name votre-domaine.com www.votre-domaine.com;

    # Certificat SSL (voir section Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/votre-domaine.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/votre-domaine.com/privkey.pem;

    # Configuration SSL sécurisée
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://admin_script_web;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Cache et compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
    gzip_vary on;

    # Sécurité
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

### Activer la configuration
```bash
ln -s /etc/nginx/sites-available/admin-script-web /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

## 5. Configuration SSL avec Let's Encrypt

### Installation de Certbot
```bash
apt install -y certbot python3-certbot-nginx
```

### Obtenir un certificat SSL
```bash
certbot certonly --nginx -d votre-domaine.com -d www.votre-domaine.com
```

### Renouvellement automatique
```bash
systemctl enable certbot.timer
systemctl start certbot.timer
```

## 6. Gestion du pare-feu (UFW)

### Configuration de base
```bash
apt install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp        # SSH
ufw allow 80/tcp        # HTTP
ufw allow 443/tcp       # HTTPS
ufw enable
```

## 7. Surveillance et maintenance

### Vérifier les logs
```bash
pm2 logs                     # Logs de l'application
journalctl -u nginx          # Logs de Nginx
```

### Surveillance du système
```bash
htop                         # Utilisation des ressources
df -h                        # Espace disque
free -h                      # Mémoire RAM
```

### Sauvegardes
```bash
# Créer une sauvegarde du projet
tar -czf ~/admin-script-web-backup.tar.gz /home/username/admin-script-web
```

## 8. Dépannage

### L'application ne démarre pas
```bash
pm2 logs admin-script-web    # Vérifier les erreurs
node index.js                # Tester le démarrage manuel
```

### Nginx retourne une erreur 502
```bash
# Vérifier que l'application est en cours d'exécution
pm2 list
# Vérifier la configuration Nginx
sudo nginx -t
# Redémarrer Nginx
sudo systemctl restart nginx
```

### Port 3000 déjà utilisé
```bash
# Trouver le processus utilisant le port
lsof -i :3000
# Ou utiliser un port différent via la variable PORT
PORT=3001 pm2 start index.js
```

## 9. Commandes résumées pour un déploiement rapide

```bash
# 1. Mise à jour du système
apt update && apt upgrade -y

# 2. Installation de Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs npm

# 3. Cloner et installer
git clone https://votre-repo.git admin-script-web
cd admin-script-web
npm install
npm install -g pm2

# 4. Lancer l'application
pm2 start index.js --name "admin-script-web"
pm2 save
env PATH=$PATH:/usr/bin pm2 startup systemd -u root --hp /root

# 5. (Optionnel) Configurer Nginx
apt install -y nginx
# ... (suivre la section Nginx)
```

## Support et ressources

- [Documentation Node.js](https://nodejs.org/docs/)
- [Documentation PM2](https://pm2.keymetrics.io/)
- [Documentation Nginx](https://nginx.org/en/docs/)
- [Let's Encrypt](https://letsencrypt.org/)
