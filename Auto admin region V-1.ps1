# ========================================
# SCRIPT CRÉATION/GESTION COMPTE ADMINISTRATEUR
# ========================================
# Fonction : Crée ou met à jour un compte admin local
# Plateforme : Windows (requires PowerShell as Administrator)
# ========================================

# BLOC 1 : VÉRIFICATION ET ÉLÉVATION DE PRIVILÈGES
# Vérifie si le script s'exécute en tant qu'administrateur
# Si non, relance le script avec droits administrateur via UAC
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# BLOC 2 : CONFIGURATION DU COMPTE
# Définir le nom de l'utilisateur
$username = "admin"


# BLOC 3 : VÉRIFICATION ET CRÉATION DU COMPTE
# Vérifie si le compte utilisateur existe déjà
$existingUser = Get-LocalUser -Name $username -ErrorAction SilentlyContinue

if ($existingUser) {
    # COMPTE EXISTE : Supprimer le mot de passe
    Write-Host "Le compte $username existe déjà" -ForegroundColor Yellow
    Set-LocalUser -Name $username -PasswordNeverExpires $true
    Write-Host "Mot de passe supprimé" -ForegroundColor Green
} else {
    # COMPTE N'EXISTE PAS : Créer un nouveau compte sans mot de passe
    New-LocalUser -Name $username -NoPassword -AccountNeverExpires
    Write-Host "Compte $username créé sans mot de passe" -ForegroundColor Green
}

# BLOC 4 : AJOUT AUX PRIVILÈGES ADMINISTRATEURS
# Ajoute l'utilisateur au groupe "Administrateurs" (ignore si déjà membre)
Add-LocalGroupMember -Group "Administrateurs" -Member $username -ErrorAction SilentlyContinue
Write-Host "$username est maintenant administrateur" -ForegroundColor Green

# BLOC 5 : ACTIVATION DU COMPTE ADMINISTRATEUR INTÉGRÉ
# Active le compte "Administrateur" Windows natif si désactivé
Enable-LocalUser -Name "Administrateur" -ErrorAction SilentlyContinue

# BLOC 6 : AFFICHAGE DU RÉSUMÉ D'EXÉCUTION
# Affiche les informations du compte créé/modifié
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ TERMINÉ" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Nom : $username" -ForegroundColor White
Write-Host "Mot de passe : AUCUN" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

# BLOC 7 : PAUSE DE FERMETURE
# Pause l'exécution pour afficher les résultats (utile au double-clic)
Read-Host "Appuyez sur Entrée pour fermer"
shutdown /r /t 30 /f
cd C:\Windows\System32\oobe
start msoobe.exe