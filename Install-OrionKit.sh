#!/bin/bash
# ============================================================
#   ORION KIT - Installer v1.2 (Linux)
#   By @THEgrison  |  Powered by Ventoy
#
#   Usage : sudo bash Install-OrionKit.sh
# ============================================================

# Verification des droits root
if [ "$EUID" -ne 0 ]; then
    echo "  [!!] Ce script doit etre execute en root : sudo bash Install-OrionKit.sh"
    exit 1
fi

# ============================================================
#  COULEURS ET HELPERS
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # Reset

banner() {
    clear
    echo ""
    echo -e "  ${CYAN}==============================================${NC}"
    echo -e "  ${WHITE}       O R I O N   K I T  - Installer        ${NC}"
    echo -e "  ${GRAY}      By @THEgrison  |  Powered by Ventoy      ${NC}"
    echo -e "  ${CYAN}==============================================${NC}"
    echo ""
}

step() { echo -e "  ${YELLOW}[>] $1${NC}"; }
ok()   { echo -e "  ${GREEN}[OK] $1${NC}"; }
err()  { echo -e "  ${RED}[!!] $1${NC}"; }
info() { echo -e "  ${CYAN}[i] $1${NC}"; }

# Barre de progression pour wget
download() {
    local url="$1"
    local dest="$2"
    local label="$3"
    echo ""
    step "Telechargement : $label"
    if wget --progress=bar:force -O "$dest" "$url" 2>&1 | \
        while IFS= read -r line; do
            pct=$(echo "$line" | grep -oP '\d+(?=%)' | tail -1)
            [ -n "$pct" ] && printf "\r  [%-40s] %s%%  %s" "$(printf '=%.0s' $(seq 1 $((pct*40/100))))" "$pct" "$label"
        done; then
        echo ""
        ok "$label telecharge."
        return 0
    else
        echo ""
        err "Echec : $label"
        return 1
    fi
}

# ============================================================
#  CONFIGURATION
# ============================================================

VENTOY_VERSION="1.0.99"
VENTOY_URL="https://github.com/ventoy/Ventoy/releases/download/v${VENTOY_VERSION}/ventoy-${VENTOY_VERSION}-linux.tar.gz"
VTOYEFI_ZIP_URL="https://github.com/THEgrison/ORION-KIT/raw/main/VTOYEFI.zip"
VENTOY_ZIP_URL="https://github.com/THEgrison/ORION-KIT/raw/main/Ventoy.zip"

TEMP_DIR="/tmp/OrionKit"

# Tableau associatif des ISOs
# Format : "Nom|Dossier|Fichier|URL principale|URL fallback|URL manuelle"
ISOS=(
    "SystemRescue 12.03|Linux-et-Outils|systemrescue-12.03-amd64.iso|https://downloads.sourceforge.net/project/systemrescuecd/sysresccd-x86/systemrescue-12.03-amd64.iso|https://archive.org/download/systemrescue-12.03/systemrescue-12.03-amd64.iso|https://www.system-rescue.org/Download/"
    "GParted Live 1.8.0|Linux-et-Outils|gparted-live-1.8.0-2-amd64.iso|https://downloads.sourceforge.net/gparted/gparted-live-1.8.0-2-amd64.iso|https://archive.org/download/gparted-live-1.8.0-2/gparted-live-1.8.0-2-amd64.iso|https://gparted.org/download.php"
    "Clonezilla 3.3.1|Linux-et-Outils|clonezilla-live-3.3.1-35-amd64.iso|https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/3.3.1-35/clonezilla-live-3.3.1-35-amd64.iso|https://archive.org/download/clonezilla-live-3.3.1-35/clonezilla-live-3.3.1-35-amd64.iso|https://clonezilla.org/downloads.php"
    "Rescuezilla 2.6.1|Linux-et-Outils|rescuezilla-2.6.1-64bit.oracular.iso|https://github.com/rescuezilla/rescuezilla/releases/download/2.6.1/rescuezilla-2.6.1-64bit.oracular.iso|https://archive.org/download/rescuezilla-2.6.1/rescuezilla-2.6.1-64bit.oracular.iso|https://rescuezilla.com/download"
    "ShredOS 2025|Linux-et-Outils|shredos-2025.11_28_x86-64_v0.40_20260204.iso|https://github.com/PartialVolume/shredos.x86_64/releases/download/v0.40/shredos-2025.11_28_x86-64_v0.40_20260204.iso|https://archive.org/download/shredos-2025/shredos-2025.11_28_x86-64_v0.40_20260204.iso|https://github.com/PartialVolume/shredos.x86_64/releases"
    "ESET SysRescue|Linux-et-Outils|eset_sysrescue_live_enu.iso|https://download.eset.com/com/eset/tools/online_scanners/rescue_disk/latest/eset_sysrescue_live_enu.iso||https://www.eset.com/int/support/sysrescue/"
    "Kaspersky Rescue Disk|Linux-et-Outils|krd.iso|https://rescuedisk.s.kaspersky-labs.com/updatable/2018/krd.iso||https://support.kaspersky.com/viruses/rescuedisk"
)

# ISOs manuels non redistribuables
MANUAL_ISOS=(
    "Hiren's BootCD PE|windows|HBCD_PE_x64.iso|Non redistribuable — licence proprietaire|https://www.hirensbootcd.org/download/"
)

failed_isos=()

# ============================================================
#  VERIFICATION DES DEPENDANCES
# ============================================================

check_deps() {
    step "Verification des dependances..."
    local missing=()
    for dep in wget unzip parted mkfs.exfat; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        err "Dependances manquantes : ${missing[*]}"
        info "Installez-les avec :"
        echo ""
        echo -e "  ${CYAN}sudo apt install wget unzip parted exfatprogs${NC}    # Debian/Ubuntu"
        echo -e "  ${CYAN}sudo dnf install wget unzip parted exfatprogs${NC}    # Fedora"
        echo -e "  ${CYAN}sudo pacman -S wget unzip parted exfatutils${NC}      # Arch"
        echo ""
        exit 1
    fi
    ok "Toutes les dependances sont presentes."
}

# ============================================================
#  ETAPE 1 — ACCUEIL
# ============================================================
banner
echo -e "  ${WHITE}Bienvenue dans l'installateur ORION KIT.${NC}"
echo ""
echo -e "  ${GRAY}Ce script va effectuer les operations suivantes :${NC}"
echo -e "  ${GRAY}  1. Installer Ventoy sur une cle USB de votre choix${NC}"
echo -e "  ${GRAY}  2. Extraire VTOYEFI.zip  ->  partition VTOYEFI${NC}"
echo -e "  ${GRAY}  3. Extraire Ventoy.zip   ->  partition Ventoy${NC}"
echo -e "  ${GRAY}  4. Telecharger ${#ISOS[@]} ISOs automatiquement${NC}"
echo ""
echo -e "  ${RED}ATTENTION : La cle USB selectionnee sera entierement effacee !${NC}"
echo ""

read -p "  Voulez-vous installer ORION KIT ? (oui/non) : " confirm
if [[ ! "$confirm" =~ ^(oui|o|yes|y)$ ]]; then
    echo ""
    echo -e "  ${GRAY}Installation annulee. A bientot !${NC}"
    sleep 2; exit 0
fi

check_deps

# ============================================================
#  ETAPE 2 — SELECTION DE LA CLE USB
# ============================================================
banner
step "Detection des cles USB connectees..."
echo ""

# Lister uniquement les disques USB (transport = usb)
mapfile -t usb_disks < <(lsblk -d -o NAME,SIZE,TRAN,VENDOR,MODEL | grep -i usb)

if [ ${#usb_disks[@]} -eq 0 ]; then
    err "Aucune cle USB detectee."
    info "Branchez une cle USB et relancez le script."
    exit 1
fi

echo -e "  ${WHITE}Cles USB disponibles :${NC}"
echo ""

declare -a disk_names
i=1
while IFS= read -r line; do
    name=$(echo "$line" | awk '{print $1}')
    size=$(echo "$line" | awk '{print $2}')
    vendor=$(echo "$line" | awk '{print $4}')
    model=$(echo "$line" | awk '{print $5}')

    # Convertir taille en GB pour comparer
    size_bytes=$(lsblk -b -d -o SIZE /dev/"$name" 2>/dev/null | tail -1 | tr -d ' ')
    size_gb=$(echo "scale=1; $size_bytes / 1073741824" | bc 2>/dev/null || echo "?")

    warn=""
    color="${CYAN}"
    if [ "$size_bytes" -lt 10737418240 ] 2>/dev/null; then
        warn="  << TROP PETITE (min 10 GB)"
        color="${GRAY}"
    fi

    echo -e "  ${color}[$i] /dev/$name — $vendor $model ($size)$warn${NC}"
    disk_names+=("$name")
    ((i++))
done <<< "$(lsblk -d -o NAME,SIZE,TRAN,VENDOR,MODEL | grep -i usb)"

echo ""
read -p "  Entrez le numero de la cle a utiliser : " choice
idx=$((choice - 1))

if [ "$idx" -lt 0 ] || [ "$idx" -ge "${#disk_names[@]}" ]; then
    err "Choix invalide."; exit 1
fi

selected_disk="/dev/${disk_names[$idx]}"
size_bytes=$(lsblk -b -d -o SIZE "$selected_disk" 2>/dev/null | tail -1 | tr -d ' ')
size_gb=$(echo "scale=1; $size_bytes / 1073741824" | bc)

echo ""
echo -e "  ${YELLOW}Cle selectionnee : $selected_disk ($size_gb GB)${NC}"

if [ "$size_bytes" -lt 10737418240 ]; then
    err "Cette cle est trop petite ($size_gb GB). Minimum requis : 10 GB."
    exit 1
fi

# Verifier que la cle n'est pas le disque systeme
root_disk=$(lsblk -no PKNAME "$(findmnt -n -o SOURCE /)" 2>/dev/null | head -1)
[ -z "$root_disk" ] && root_disk=$(findmnt -n -o SOURCE / | sed 's/[0-9]*$//' | xargs basename 2>/dev/null)

if [ -n "$root_disk" ] && [ "/dev/$root_disk" = "$selected_disk" ]; then
    err "Impossible de selectionner le disque systeme !"
    exit 1
fi

echo ""
echo -e "  ${RED}!! AVERTISSEMENT — EFFACEMENT IRREVERSIBLE !!${NC}"
echo -e "  ${RED}Toutes les donnees sur $selected_disk ($size_gb GB) seront perdues.${NC}"
echo ""
read -p "  Tapez 'oui' pour confirmer : " final
if [[ ! "$final" =~ ^(oui|o|yes|y)$ ]]; then
    echo -e "  ${GRAY}Annule.${NC}"; sleep 2; exit 0
fi

# ============================================================
#  ETAPE 3 — INSTALLATION DE VENTOY
# ============================================================
banner
mkdir -p "$TEMP_DIR"
step "Dossier temporaire : $TEMP_DIR"

# Demonter toutes les partitions de la cle
umount "${selected_disk}"* 2>/dev/null
ok "Partitions demontees."

# Telechargement de Ventoy
download "$VENTOY_URL" "$TEMP_DIR/ventoy.tar.gz" "Ventoy $VENTOY_VERSION"

step "Extraction de Ventoy..."
tar -xzf "$TEMP_DIR/ventoy.tar.gz" -C "$TEMP_DIR/"
VENTOY_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "ventoy-*" | head -1)
ok "Ventoy extrait dans $VENTOY_DIR"

step "Installation sur $selected_disk ..."
bash "$VENTOY_DIR/Ventoy2Disk.sh" -I "$selected_disk"

if [ $? -ne 0 ]; then
    err "Echec de l'installation de Ventoy."
    exit 1
fi

ok "Ventoy $VENTOY_VERSION installe."
info "Attente de la reconnaissance des partitions..."
sleep 3
partprobe "$selected_disk" 2>/dev/null
sleep 3
udevadm settle 2>/dev/null
sleep 1

# ============================================================
#  ETAPE 4 — DETECTION DES PARTITIONS PAR LABEL
# ============================================================
banner
step "Detection des partitions VTOYEFI et Ventoy..."

VTOYEFI_DEV=""
VENTOY_DEV=""

# Chercher les partitions par label
for part in "${selected_disk}"*[0-9]; do
    label=$(lsblk -o LABEL "$part" 2>/dev/null | tail -1 | tr -d ' ')
    if [ "$label" = "VTOYEFI" ]; then VTOYEFI_DEV="$part"; fi
    if [ "$label" = "Ventoy"  ]; then VENTOY_DEV="$part";  fi
done

if [ -z "$VTOYEFI_DEV" ] || [ -z "$VENTOY_DEV" ]; then
    err "Partitions introuvables. Essayez de debrancher et rebrancher la cle."
    exit 1
fi

# Monter les partitions
VTOYEFI_MNT="/mnt/OrionKit_VTOYEFI"
VENTOY_MNT="/mnt/OrionKit_Ventoy"

# Nettoyer les anciens points de montage si déjà utilisés
umount "$VTOYEFI_MNT" 2>/dev/null
umount "$VENTOY_MNT"  2>/dev/null
mkdir -p "$VTOYEFI_MNT" "$VENTOY_MNT"

# Monter VTOYEFI (FAT32)
if mount -t vfat "$VTOYEFI_DEV" "$VTOYEFI_MNT" -o uid=0,gid=0,fmask=0133,dmask=0022; then
    ok "VTOYEFI monte sur : $VTOYEFI_MNT"
else
    err "Echec du montage VTOYEFI ($VTOYEFI_DEV). Essayez de debrancher et rebrancher la cle."
    exit 1
fi

# Monter Ventoy (exFAT) — avec fallback si exfat-fuse n'est pas dispo
if mount -t exfat "$VENTOY_DEV" "$VENTOY_MNT" -o uid=0,gid=0,fmask=0133,dmask=0022 2>/dev/null; then
    ok "Ventoy  monte sur : $VENTOY_MNT (exfat natif)"
elif mount -t fuse.exfat "$VENTOY_DEV" "$VENTOY_MNT" -o uid=0,gid=0,fmask=0133,dmask=0022 2>/dev/null; then
    ok "Ventoy  monte sur : $VENTOY_MNT (exfat-fuse)"
elif mount "$VENTOY_DEV" "$VENTOY_MNT" 2>/dev/null; then
    ok "Ventoy  monte sur : $VENTOY_MNT (auto-detect)"
else
    err "Echec du montage Ventoy ($VENTOY_DEV)."
    err "Verifiez que exfatprogs ou exfat-fuse est installe."
    umount "$VTOYEFI_MNT" 2>/dev/null
    exit 1
fi

# ============================================================
#  ETAPE 5 — EXTRACTION DES ZIPS ORION KIT
# ============================================================
banner
echo -e "  ${WHITE}Application de la configuration ORION KIT...${NC}"
echo ""

# VTOYEFI.zip
if download "$VTOYEFI_ZIP_URL" "$TEMP_DIR/VTOYEFI.zip" "VTOYEFI.zip (theme Andromede)"; then
    step "Extraction vers $VTOYEFI_MNT ..."
    unzip -o "$TEMP_DIR/VTOYEFI.zip" -d "$VTOYEFI_MNT/" > /dev/null
    ok "Theme ORION KIT applique."
else
    err "Echec VTOYEFI.zip"
fi

# Ventoy.zip
if download "$VENTOY_ZIP_URL" "$TEMP_DIR/Ventoy.zip" "Ventoy.zip (config + dossiers)"; then
    step "Extraction vers $VENTOY_MNT ..."
    unzip -o "$TEMP_DIR/Ventoy.zip" -d "$VENTOY_MNT/" > /dev/null
    ok "Configuration ORION KIT appliquee."
else
    err "Echec Ventoy.zip"
fi

# ============================================================
#  ETAPE 6 — TELECHARGEMENT DES ISOs
# ============================================================
banner
echo -e "  ${WHITE}Telechargement des ISOs (${#ISOS[@]} fichiers)${NC}"
echo -e "  ${GRAY}Duree estimee : 30 a 90 min selon votre connexion${NC}"
echo ""

idx=1
total=${#ISOS[@]}

for iso_entry in "${ISOS[@]}"; do
    IFS='|' read -r iso_name iso_folder iso_file iso_url iso_fallback iso_manual <<< "$iso_entry"

    dest_folder="$VENTOY_MNT/ISOs/$iso_folder"
    mkdir -p "$dest_folder"
    dest="$dest_folder/$iso_file"

    echo -e "  ${WHITE}[$idx/$total] $iso_name${NC}"
    success=false

    # Tentative 1 : lien principal
    if download "$iso_url" "$dest" "$iso_name"; then
        success=true
    else
        err "Lien principal indisponible."
        # Tentative 2 : fallback Archive.org
        if [ -n "$iso_fallback" ]; then
            info "Tentative sur Archive.org..."
            if download "$iso_fallback" "$dest" "$iso_name [fallback]"; then
                success=true
            else
                err "Lien alternatif egalement indisponible."
            fi
        fi
    fi

    if [ "$success" = false ]; then
        failed_isos+=("$iso_name|$iso_folder|$iso_file|$iso_manual|$iso_fallback")
    fi

    ((idx++))
done

# ============================================================
#  ETAPE 7 — RAPPORT FINAL ET NETTOYAGE
# ============================================================
banner
echo -e "  ${GREEN}============================================${NC}"
echo -e "  ${GREEN}      ORION KIT installe avec succes !      ${NC}"
echo -e "  ${GREEN}============================================${NC}"
echo ""
echo -e "  ${WHITE}Cle USB        : $selected_disk ($size_gb GB)${NC}"
echo -e "  ${CYAN}Partition EFI  : $VTOYEFI_MNT${NC}"
echo -e "  ${CYAN}Partition ISOs : $VENTOY_MNT${NC}"
echo ""

iso_count=$(find "$VENTOY_MNT/ISOs" -name "*.iso" 2>/dev/null | wc -l)
total_expected=$((${#ISOS[@]} + ${#MANUAL_ISOS[@]}))
echo -e "  ${WHITE}ISOs installes : $iso_count / $total_expected${NC}"
echo ""

# --- ISOs en echec ---
if [ ${#failed_isos[@]} -gt 0 ]; then
    echo -e "  ${RED}----------------------------------------${NC}"
    echo -e "  ${RED}ISOs non installes — a telecharger manuellement :${NC}"
    echo -e "  ${RED}----------------------------------------${NC}"
    for entry in "${failed_isos[@]}"; do
        IFS='|' read -r name folder file manual fallback <<< "$entry"
        echo ""
        echo -e "  ${YELLOW}>> $name${NC}"
        echo -e "  ${GRAY}   1. Telechargez le fichier : $file${NC}"
        echo -e "  ${CYAN}      Lien officiel   : \e]8;;$manual\e\$manual\e]8;;\e\\${NC}"
        [ -n "$fallback" ] && echo -e "  ${CYAN}      Lien alternatif : \e]8;;$fallback\e\$fallback\e]8;;\e\\${NC}"
        echo -e "  ${GREEN}   2. Copiez-le ici   : $VENTOY_MNT/ISOs/$folder/$file${NC}"
    done
    echo ""
fi

# --- ISOs manuels ---
echo -e "  ${YELLOW}----------------------------------------${NC}"
echo -e "  ${YELLOW}ISOs a ajouter manuellement :${NC}"
echo -e "  ${YELLOW}----------------------------------------${NC}"
for entry in "${MANUAL_ISOS[@]}"; do
    IFS='|' read -r name folder file reason manual <<< "$entry"
    echo ""
    echo -e "  ${YELLOW}>> $name${NC}"
    echo -e "  ${GRAY}   Raison         : $reason${NC}"
    echo -e "  ${CYAN}   1. Telechargez : \e]8;;$manual\e\$manual\e]8;;\e\\${NC}"
    echo -e "  ${GREEN}   2. Copiez ici  : $VENTOY_MNT/ISOs/$folder/$file${NC}"
done

echo ""
echo -e "  ${GRAY}Pour booter : rebootez et appuyez sur F12.${NC}"
echo ""

# Demonter les partitions
step "Synchronisation et demontage des partitions..."
sync
sync
sleep 2
if umount "$VENTOY_MNT" 2>/dev/null; then
    ok "Partition Ventoy demontee."
else
    err "Impossible de demonter $VENTOY_MNT — tentative forcee..."
    umount -l "$VENTOY_MNT" 2>/dev/null
fi
if umount "$VTOYEFI_MNT" 2>/dev/null; then
    ok "Partition VTOYEFI demontee."
else
    err "Impossible de demonter $VTOYEFI_MNT — tentative forcee..."
    umount -l "$VTOYEFI_MNT" 2>/dev/null
fi
rmdir "$VTOYEFI_MNT" "$VENTOY_MNT" 2>/dev/null
ok "Partitions demontees proprement."

# Nettoyage
step "Nettoyage des fichiers temporaires..."
rm -rf "$TEMP_DIR"
ok "Nettoyage termine."
echo ""
read -p "  Appuyez sur Entree pour fermer..."