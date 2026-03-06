# ============================================================
#   ORION KIT - Installer v1.4 (Windows)
#   By @THEgrison  |  Powered by Ventoy
# ============================================================

#Requires -RunAsAdministrator

$Host.UI.RawUI.WindowTitle = "ORION KIT - Installer"

function Write-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  ==============================================" -ForegroundColor Cyan
    Write-Host "         O R I O N   K I T  - Installer        " -ForegroundColor White
    Write-Host "        By @THEgrison  |  Powered by Ventoy     " -ForegroundColor DarkGray
    Write-Host "  ==============================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step { param([string]$T); Write-Host "  [>] $T" -ForegroundColor Yellow }
function Write-OK   { param([string]$T); Write-Host "  [OK] $T" -ForegroundColor Green }
function Write-Err  { param([string]$T); Write-Host "  [!!] $T" -ForegroundColor Red }
function Write-Info { param([string]$T); Write-Host "  [i] $T"  -ForegroundColor Cyan }

function Write-Link {
    param([string]$Url, [string]$Label)
    # Lien cliquable dans les terminaux compatibles (Windows Terminal, VSCode, etc.)
    $esc = [char]27
    Write-Host "  $esc]8;;$Url$esc\$Label$esc]8;;$esc\" -ForegroundColor Cyan
}

function Download-WithProgress {
    param([string]$Url, [string]$Dest, [string]$Label)
    Write-Host ""
    Write-Step "Telechargement : $Label"
    $wc = New-Object System.Net.WebClient
    $script:lastPct = -1
    $wc.add_DownloadProgressChanged({
        param($s, $e)
        if ($e.ProgressPercentage -ne $script:lastPct) {
            $script:lastPct = $e.ProgressPercentage
            $w   = 40
            $f   = [math]::Floor($w * $e.ProgressPercentage / 100)
            $bar = "[" + ("=" * $f) + (" " * ($w - $f)) + "]"
            Write-Host "`r  $bar $($e.ProgressPercentage)%  $Label" -NoNewline -ForegroundColor Cyan
        }
    })
    try {
        $wc.DownloadFileTaskAsync($Url, $Dest).GetAwaiter().GetResult()
        Write-Host ""
        Write-OK "$Label telecharge."
    } catch {
        Write-Host ""
        Write-Err "Echec : $Label"
        throw
    }
}

# ============================================================
#  CONFIGURATION
# ============================================================

$VENTOY_VERSION  = "1.0.99"
$VENTOY_URL      = "https://github.com/ventoy/Ventoy/releases/download/v$VENTOY_VERSION/ventoy-$VENTOY_VERSION-windows.zip"
$VTOYEFI_ZIP_URL = "https://github.com/THEgrison/ORION-KIT/raw/main/VTOYEFI.zip"
$VENTOY_ZIP_URL  = "https://github.com/THEgrison/ORION-KIT/raw/main/Ventoy.zip"

$ISOS = @(
    @{ Name="SystemRescue 12.03";    Folder="Linux-et-Outils"; File="systemrescue-12.03-amd64.iso";                    Url="https://sourceforge.net/projects/systemrescuecd/files/sysresccd-x86/12.03/systemrescue-12.03-amd64.iso/download";                                   Fallback="https://archive.org/download/systemrescue-12.03/systemrescue-12.03-amd64.iso";                Manual="https://www.system-rescue.org/Download/" },
    @{ Name="GParted Live 1.8.0";    Folder="Linux-et-Outils"; File="gparted-live-1.8.0-2-amd64.iso";                  Url="https://downloads.sourceforge.net/gparted/gparted-live-1.8.0-2-amd64.iso";                                                               Fallback="https://archive.org/download/gparted-live-1.8.0-2/gparted-live-1.8.0-2-amd64.iso";           Manual="https://gparted.org/download.php" },
    @{ Name="Clonezilla 3.3.1";      Folder="Linux-et-Outils"; File="clonezilla-live-3.3.1-35-amd64.iso";              Url="https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/3.3.1-35/clonezilla-live-3.3.1-35-amd64.iso";                   Fallback="https://archive.org/download/clonezilla-live-3.3.1-35/clonezilla-live-3.3.1-35-amd64.iso";   Manual="https://clonezilla.org/downloads.php" },
    @{ Name="Rescuezilla 2.6.1";     Folder="Linux-et-Outils"; File="rescuezilla-2.6.1-64bit.oracular.iso";            Url="https://github.com/rescuezilla/rescuezilla/releases/download/2.6.1/rescuezilla-2.6.1-64bit.oracular.iso";                               Fallback="https://archive.org/download/rescuezilla-2.6.1/rescuezilla-2.6.1-64bit.oracular.iso";         Manual="https://rescuezilla.com/download" },
    @{ Name="ShredOS 2025";          Folder="Linux-et-Outils"; File="shredos-2025.11_28_x86-64_v0.40_20260204.iso";    Url="https://github.com/PartialVolume/shredos.x86_64/releases/download/v0.40/shredos-2025.11_28_x86-64_v0.40_20260204.iso";                   Fallback="https://archive.org/download/shredos-2025/shredos-2025.11_28_x86-64_v0.40_20260204.iso";      Manual="https://github.com/PartialVolume/shredos.x86_64/releases" },
    @{ Name="ESET SysRescue";        Folder="Linux-et-Outils"; File="eset_sysrescue_live_enu.iso";                     Url="https://download.eset.com/com/eset/tools/online_scanners/rescue_disk/latest/eset_sysrescue_live_enu.iso";                                 Fallback="";                                                                                             Manual="https://www.eset.com/int/support/sysrescue/" },
    @{ Name="Kaspersky Rescue Disk"; Folder="Linux-et-Outils"; File="krd.iso";                                         Url="https://rescuedisk.s.kaspersky-labs.com/updatable/2018/krd.iso";                                                                         Fallback="";                                                                                             Manual="https://support.kaspersky.com/viruses/rescuedisk" }
)

$MANUAL_ISOS = @(
    @{ Name="Hiren's BootCD PE"; File="HBCD_PE_x64.iso"; Folder="windows"; Reason="Non redistribuable — licence proprietaire"; Manual="https://www.hirensbootcd.org/download/" }
)

$TEMP = "$env:TEMP\OrionKit"

# ============================================================
#  ETAPE 1 — ACCUEIL
# ============================================================

Write-Banner
Write-Host "  Bienvenue dans l'installateur ORION KIT." -ForegroundColor White
Write-Host ""
Write-Host "  Ce script va effectuer les operations suivantes :" -ForegroundColor Gray
Write-Host "    1. Installer Ventoy sur une cle USB de votre choix" -ForegroundColor Gray
Write-Host "    2. Extraire VTOYEFI.zip  ->  partition VTOYEFI" -ForegroundColor Gray
Write-Host "    3. Extraire Ventoy.zip   ->  partition Ventoy" -ForegroundColor Gray
Write-Host "    4. Telecharger $($ISOS.Count) ISOs automatiquement" -ForegroundColor Gray
Write-Host ""
Write-Host "  ATTENTION : La cle USB selectionnee sera entierement effacee !" -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "  Voulez-vous installer ORION KIT ? (oui/non)"
if ($confirm -notin @("oui","o","yes","y")) {
    Write-Host "  Installation annulee. A bientot !" -ForegroundColor DarkGray
    Start-Sleep 2; exit 0
}

# ============================================================
#  ETAPE 2 — SELECTION DE LA CLE USB
# ============================================================

Write-Banner
Write-Step "Detection des cles USB connectees..."
Write-Host ""

$disks = Get-Disk | Where-Object { $_.BusType -eq "USB" }

if ($disks.Count -eq 0) {
    Write-Err "Aucune cle USB detectee."
    Write-Info "Branchez une cle USB et relancez le script."
    Read-Host "  Entree pour quitter"; exit 1
}

Write-Host "  Cles USB disponibles :" -ForegroundColor White
Write-Host ""
$i = 1
foreach ($d in $disks) {
    $gb   = [math]::Round($d.Size / 1GB, 1)
    $warn = if ($d.Size -lt 10GB) { "  << TROP PETITE (min 10 GB)" } else { "" }
    $col  = if ($d.Size -lt 10GB) { "DarkGray" } else { "Cyan" }
    Write-Host "  [$i] Disque $($d.Number) — $($d.FriendlyName) ($gb GB)$warn" -ForegroundColor $col
    $i++
}

Write-Host ""
$choice = Read-Host "  Entrez le numero de la cle a utiliser"
$idx    = [int]$choice - 1

if ($idx -lt 0 -or $idx -ge $disks.Count) {
    Write-Err "Choix invalide."; Read-Host "  Entree pour quitter"; exit 1
}

$sel    = $disks[$idx]
$diskNo = $sel.Number
$sizeGB = [math]::Round($sel.Size / 1GB, 1)

Write-Host ""
Write-Host "  Cle selectionnee : $($sel.FriendlyName) ($sizeGB GB)" -ForegroundColor Yellow

if ($sel.Size -lt 10GB) {
    Write-Err "Cette cle est trop petite ($sizeGB GB). Minimum requis : 10 GB."
    Read-Host "  Entree pour quitter"; exit 1
}

# Verifier que la cle n'est pas le disque systeme
$sysDisk = Get-Partition | Where-Object { $_.DriveLetter -eq $env:SystemDrive[0] } |
           Select-Object -ExpandProperty DiskNumber -First 1
if ($diskNo -eq $sysDisk) {
    Write-Err "Impossible de selectionner le disque systeme !"
    Read-Host "  Entree pour quitter"; exit 1
}

Write-Host ""
Write-Host "  !! AVERTISSEMENT — EFFACEMENT IRREVERSIBLE !!" -ForegroundColor Red
Write-Host "  Toutes les donnees sur '$($sel.FriendlyName)' ($sizeGB GB) seront perdues." -ForegroundColor Red
Write-Host ""
$final = Read-Host "  Tapez 'oui' pour confirmer"
if ($final -notin @("oui","o","yes","y")) {
    Write-Host "  Annule." -ForegroundColor DarkGray; Start-Sleep 2; exit 0
}

# ============================================================
#  ETAPE 3 — INSTALLATION DE VENTOY
# ============================================================

Write-Banner
New-Item -ItemType Directory -Force -Path $TEMP | Out-Null
Download-WithProgress -Url $VENTOY_URL -Dest "$TEMP\ventoy.zip" -Label "Ventoy $VENTOY_VERSION"
Expand-Archive -Path "$TEMP\ventoy.zip" -DestinationPath "$TEMP\ventoy_install" -Force
Write-OK "Ventoy extrait."

$ventoyExe = Get-ChildItem "$TEMP\ventoy_install" -Recurse -Filter "Ventoy2Disk.exe" | Select-Object -First 1
if (-not $ventoyExe) { Write-Err "Ventoy2Disk.exe introuvable."; Read-Host "Entree"; exit 1 }

Write-Step "Installation sur le Disque $diskNo ($($sel.FriendlyName))..."
$proc = Start-Process -FilePath $ventoyExe.FullName `
    -ArgumentList "-I -g \\.\PhysicalDrive$diskNo" `
    -Wait -PassThru -NoNewWindow

if ($proc.ExitCode -ne 0) { Write-Err "Echec Ventoy (code $($proc.ExitCode))."; Read-Host "Entree"; exit 1 }

Write-OK "Ventoy $VENTOY_VERSION installe."
Write-Info "Attente reconnaissance des partitions..."
Start-Sleep 4

# ============================================================
#  ETAPE 4 — DETECTION DES PARTITIONS
# ============================================================

Write-Banner
Write-Step "Detection des partitions..."

foreach ($p in (Get-Partition -DiskNumber $diskNo -ErrorAction SilentlyContinue)) {
    if (-not $p.DriveLetter) {
        $p | Add-PartitionAccessPath -AssignDriveLetter -ErrorAction SilentlyContinue
    }
}
Start-Sleep 3

$vtoyefiDrive = $null
$ventoyDrive  = $null
foreach ($vol in (Get-Volume)) {
    if ($vol.FileSystemLabel -eq "VTOYEFI") { $vtoyefiDrive = "$($vol.DriveLetter):" }
    if ($vol.FileSystemLabel -eq "Ventoy")  { $ventoyDrive  = "$($vol.DriveLetter):" }
}

if ($vtoyefiDrive) { Write-OK "VTOYEFI : $vtoyefiDrive" } else { Write-Err "Partition VTOYEFI introuvable." }
if ($ventoyDrive)  { Write-OK "Ventoy  : $ventoyDrive"  } else { Write-Err "Partition Ventoy introuvable."  }
if (-not $vtoyefiDrive -or -not $ventoyDrive) { Read-Host "Entree"; exit 1 }

# ============================================================
#  ETAPE 5 — EXTRACTION DES ZIPS ORION KIT
# ============================================================

Write-Banner
try {
    Download-WithProgress -Url $VTOYEFI_ZIP_URL -Dest "$TEMP\VTOYEFI.zip" -Label "VTOYEFI.zip"
    Expand-Archive -Path "$TEMP\VTOYEFI.zip" -DestinationPath $vtoyefiDrive -Force
    Write-OK "Theme applique sur $vtoyefiDrive"
} catch { Write-Err "Echec VTOYEFI.zip" }

try {
    Download-WithProgress -Url $VENTOY_ZIP_URL -Dest "$TEMP\Ventoy.zip" -Label "Ventoy.zip"
    Expand-Archive -Path "$TEMP\Ventoy.zip" -DestinationPath $ventoyDrive -Force
    Write-OK "Configuration appliquee sur $ventoyDrive"
} catch { Write-Err "Echec Ventoy.zip" }

# ============================================================
#  ETAPE 6 — TELECHARGEMENT DES ISOs
# ============================================================

Write-Banner
Write-Host "  Telechargement des ISOs ($($ISOS.Count) fichiers)" -ForegroundColor White
Write-Host "  Duree estimee : 30 a 90 min selon votre connexion" -ForegroundColor DarkGray
Write-Host ""

$failedISOs = @()
$idx = 1

foreach ($iso in $ISOS) {
    $destFolder = "$ventoyDrive\ISOs\$($iso.Folder)"
    New-Item -ItemType Directory -Force -Path $destFolder | Out-Null
    $dest = "$destFolder\$($iso.File)"

    Write-Host "  [$idx/$($ISOS.Count)] $($iso.Name)" -ForegroundColor White
    $success = $false

    try {
        Download-WithProgress -Url $iso.Url -Dest $dest -Label $iso.Name
        $success = $true
    } catch {
        Write-Err "Lien principal indisponible."
        if ($iso.Fallback -ne "") {
            Write-Info "Tentative sur Archive.org..."
            try {
                Download-WithProgress -Url $iso.Fallback -Dest $dest -Label "$($iso.Name) [fallback]"
                $success = $true
            } catch {
                Write-Err "Lien alternatif egalement indisponible."
            }
        }
    }

    if (-not $success) { $failedISOs += $iso }
    $idx++
}

# ============================================================
#  ETAPE 7 — RAPPORT FINAL ET NETTOYAGE
# ============================================================

Write-Banner
Write-Host "  ============================================" -ForegroundColor Green
Write-Host "        ORION KIT installe avec succes !      " -ForegroundColor Green
Write-Host "  ============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Cle USB        : $($sel.FriendlyName) ($sizeGB GB)" -ForegroundColor White
Write-Host "  Partition EFI  : $vtoyefiDrive" -ForegroundColor Cyan
Write-Host "  Partition ISOs : $ventoyDrive"  -ForegroundColor Cyan
Write-Host ""

$isoCount = (Get-ChildItem "$ventoyDrive\ISOs" -Recurse -Filter "*.iso" -ErrorAction SilentlyContinue).Count
$total    = $ISOS.Count + $MANUAL_ISOS.Count
Write-Host "  ISOs installes : $isoCount / $total" -ForegroundColor White
Write-Host ""

# --- ISOs en echec ---
if ($failedISOs.Count -gt 0) {
    Write-Host "  ----------------------------------------" -ForegroundColor Red
    Write-Host "  ISOs non installes — a telecharger manuellement :" -ForegroundColor Red
    Write-Host "  ----------------------------------------" -ForegroundColor Red
    foreach ($f in $failedISOs) {
        Write-Host ""
        Write-Host "  >> $($f.Name)" -ForegroundColor Yellow
        Write-Host "     1. Telechargez le fichier : $($f.File)" -ForegroundColor Gray
        Write-Host "        Lien officiel  : " -ForegroundColor Gray -NoNewline
        Write-Link -Url $f.Manual -Label $f.Manual
        if ($f.Fallback -ne "") {
            Write-Host "        Lien alternatif: " -ForegroundColor Gray -NoNewline
            Write-Link -Url $f.Fallback -Label $f.Fallback
        }
        Write-Host "     2. Copiez-le ici : $ventoyDrive\ISOs\$($f.Folder)\$($f.File)" -ForegroundColor Green
    }
    Write-Host ""
}

# --- ISOs manuels ---
Write-Host "  ----------------------------------------" -ForegroundColor Yellow
Write-Host "  ISOs a ajouter manuellement :" -ForegroundColor Yellow
Write-Host "  ----------------------------------------" -ForegroundColor Yellow
foreach ($m in $MANUAL_ISOS) {
    Write-Host ""
    Write-Host "  >> $($m.Name)" -ForegroundColor Yellow
    Write-Host "     Raison         : $($m.Reason)" -ForegroundColor Gray
    Write-Host "     1. Telechargez : " -ForegroundColor Gray -NoNewline
    Write-Link -Url $m.Manual -Label $m.Manual
    Write-Host "     2. Copiez ici  : $ventoyDrive\ISOs\$($m.Folder)\$($m.File)" -ForegroundColor Green
}

Write-Host ""
Write-Host "  Pour booter : rebootez et appuyez sur F12." -ForegroundColor Gray
Write-Host ""

Write-Step "Nettoyage des fichiers temporaires..."
Remove-Item -Recurse -Force -Path $TEMP -ErrorAction SilentlyContinue
Write-OK "Nettoyage termine."

Write-Host ""
Read-Host "  Appuyez sur Entree pour fermer"
