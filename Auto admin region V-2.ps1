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
# Demander le nom d'utilisateur et le mot de passe à créer/modifier
$username = Read-Host "Entrez le nom d'utilisateur"
if ([string]::IsNullOrWhiteSpace($username)) {
    Write-Host "Nom d'utilisateur vide. Arrêt du script." -ForegroundColor Red
    Read-Host "Appuyez sur Entrée pour fermer"
    exit
}

$securePassword = Read-Host "Entrez le mot de passe" -AsSecureString
$passwordDefined = $securePassword.Length -gt 0


# BLOC 3 : VÉRIFICATION ET CRÉATION DU COMPTE
# Vérifie si le compte utilisateur existe déjà
$existingUser = Get-LocalUser -Name $username -ErrorAction SilentlyContinue

if ($existingUser) {
    # COMPTE EXISTE : Mettre à jour le mot de passe si un mot de passe a été saisi
    Write-Host "Le compte $username existe déjà" -ForegroundColor Yellow
    if ($passwordDefined) {
        $existingUser | Set-LocalUser -Password $securePassword -PasswordNeverExpires $true
        Write-Host "Mot de passe mis à jour" -ForegroundColor Green
    } else {
        Write-Host "Aucun mot de passe saisi" -ForegroundColor Yellow
    }
} else {
    # COMPTE N'EXISTE PAS : Créer un nouveau compte avec ou sans mot de passe
    if ($passwordDefined) {
        New-LocalUser -Name $username -Password $securePassword -AccountNeverExpires
        Write-Host "Compte $username créé avec mot de passe" -ForegroundColor Green
    } else {
        New-LocalUser -Name $username -NoPassword -AccountNeverExpires
        Write-Host "Compte $username créé sans mot de passe" -ForegroundColor Green
    }
}

# BLOC 4 : AJOUT AUX PRIVILÈGES ADMINISTRATEURS
# Ajoute l'utilisateur au groupe "Administrateurs" (ignore si déjà membre)
Add-LocalGroupMember -Group "Administrateurs" -Member $username -ErrorAction SilentlyContinue
Write-Host "$username est maintenant administrateur" -ForegroundColor Green

# BLOC 5 : DÉSACTIVATION DU COMPTE ADMINISTRATEUR INTÉGRÉ
# Désactive le compte "Administrateur" Windows natif
Disable-LocalUser -Name "Administrateur" -ErrorAction SilentlyContinue

# BLOC 6 : AFFICHAGE DU RÉSUMÉ D'EXÉCUTION
# Affiche les informations du compte créé/modifié
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ TERMINÉ" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Nom : $username" -ForegroundColor White
Write-Host "Mot de passe : $(if ($passwordDefined) { 'défini' } else { 'non défini' })" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

# BLOC 7 : PAUSE DE FERMETURE
# Pause l'exécution pour afficher les résultats (utile au double-clic)
Read-Host "Appuyez sur Entrée pour fermer"
shutdown /r /t 30 /f
Set-Location C:\Windows\System32\oobe
Start-Process msoobe.exe