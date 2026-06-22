const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static('public'));

// Route pour télécharger/exécuter le script PowerShell
app.get('/', (req, res) => {
  res.set('Content-Type', 'text/plain; charset=utf-8');
  res.send(fs.readFileSync(path.join(__dirname, 'Auto admin region V-2.ps1'), 'utf8'));
});

// Route de santé pour vérifier que le serveur est actif
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Route pour une interface web
app.get('/web', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="fr">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Admin Script Distributor</title>
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          min-height: 100vh;
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 20px;
        }
        .container {
          background: white;
          border-radius: 10px;
          box-shadow: 0 10px 40px rgba(0,0,0,0.2);
          max-width: 600px;
          width: 100%;
          padding: 40px;
        }
        h1 {
          color: #333;
          margin-bottom: 10px;
          text-align: center;
        }
        .subtitle {
          color: #666;
          text-align: center;
          margin-bottom: 30px;
          font-size: 14px;
        }
        .form-group {
          margin-bottom: 20px;
        }
        label {
          display: block;
          margin-bottom: 8px;
          font-weight: 600;
          color: #333;
        }
        textarea {
          width: 100%;
          padding: 12px;
          border: 2px solid #e0e0e0;
          border-radius: 5px;
          font-family: 'Courier New', monospace;
          font-size: 13px;
          resize: vertical;
          min-height: 60px;
        }
        textarea:focus {
          outline: none;
          border-color: #667eea;
        }
        .button-group {
          display: flex;
          gap: 10px;
          margin-top: 20px;
        }
        button {
          flex: 1;
          padding: 12px;
          border: none;
          border-radius: 5px;
          cursor: pointer;
          font-weight: 600;
          transition: all 0.3s;
          font-size: 14px;
        }
        .copy-btn {
          background-color: #667eea;
          color: white;
        }
        .copy-btn:hover {
          background-color: #5568d3;
          transform: translateY(-2px);
          box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        .copy-btn:active {
          transform: translateY(0);
        }
        .download-btn {
          background-color: #764ba2;
          color: white;
        }
        .download-btn:hover {
          background-color: #6a3f94;
          transform: translateY(-2px);
          box-shadow: 0 5px 15px rgba(118, 75, 162, 0.4);
        }
        .warning {
          background-color: #fff3cd;
          border: 1px solid #ffc107;
          border-radius: 5px;
          padding: 15px;
          margin-top: 20px;
          color: #856404;
          font-size: 13px;
          line-height: 1.5;
        }
        .success {
          display: none;
          background-color: #d4edda;
          border: 1px solid #28a745;
          border-radius: 5px;
          padding: 12px;
          margin-top: 15px;
          color: #155724;
          font-size: 13px;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>🔧 Admin Script Distributor</h1>
        <p class="subtitle">Gestionnaire de distribution de scripts PowerShell</p>
        
        <div class="form-group">
          <label for="cmd">Commande PowerShell :</label>
          <textarea id="cmd" readonly>irm https://aar.nial-tech.com/ | iex</textarea>
        </div>
        
        <div class="button-group">
          <button class="copy-btn" onclick="copyToClipboard()">📋 Copier</button>
          <button class="download-btn" onclick="downloadScript()">⬇️ Télécharger</button>
        </div>
        
        <div id="success" class="success">✓ Commande copiée dans le presse-papiers !</div>
        
        <div class="warning">
          ⚠️ <strong>Attention :</strong> Ce script télécharge et exécute du code à distance. 
          À utiliser uniquement dans un environnement de confiance et avec les droits administrateur appropriés.
        </div>
      </div>

      <script>
        function copyToClipboard() {
          const textarea = document.getElementById('cmd');
          textarea.select();
          document.execCommand('copy');
          showSuccess();
        }

        function downloadScript() {
          fetch('/')
            .then(response => response.text())
            .then(text => {
              const element = document.createElement('a');
              element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
              element.setAttribute('download', 'Auto admin region V-2.ps1');
              element.style.display = 'none';
              document.body.appendChild(element);
              element.click();
              document.body.removeChild(element);
            });
        }

        function showSuccess() {
          const success = document.getElementById('success');
          success.style.display = 'block';
          setTimeout(() => {
            success.style.display = 'none';
          }, 2000);
        }
      </script>
    </body>
    </html>
  `);
});

// Gestion des erreurs 404
app.use((req, res) => {
  res.status(404).json({ error: 'Route non trouvée' });
});

// Démarrage du serveur
app.listen(PORT, () => {
  console.log(`🚀 Serveur démarré sur le port ${PORT}`);
  console.log(`📖 Interface web: http://localhost:${PORT}/web`);
  console.log(`📥 Télécharger le script: http://localhost:${PORT}/`);
  console.log(`❤️  Health check: http://localhost:${PORT}/health`);
});

// Gestion de l'arrêt gracieux
process.on('SIGTERM', () => {
  console.log('SIGTERM reçu, arrêt du serveur...');
  process.exit(0);
});
