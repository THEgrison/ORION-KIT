# 🔭 ORION KIT

<p align="center">
  <strong>Kit de dépannage multiboot clé en main</strong><br>
  By <a href="https://github.com/THEgrison">@THEgrison</a> — Powered by <a href="https://www.ventoy.net">Ventoy</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Ventoy-1.0.99-blue?style=flat-square" />
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-informational?style=flat-square" />
  <img src="https://img.shields.io/badge/ISOs-7%20auto%20%2B%201%20manuel-success?style=flat-square" />
  <img src="https://img.shields.io/badge/Licence-Open%20Source-lightgrey?style=flat-square" />
</p>

---

ORION KIT est une clé USB multiboot prête à l'emploi pour **diagnostiquer, réparer et récupérer** des systèmes Windows et Linux.  
Inspiré de Hiren's BootCD, il repose sur [Ventoy](https://www.ventoy.net) avec un thème personnalisé (fond Andromède).

---

## ⬇️ Télécharger l'installateur

> Choisissez votre système d'exploitation :

<p align="center">
  <a href="https://github.com/THEgrison/ORION-KIT/raw/main/Install-OrionKit.ps1">
    <img src="https://img.shields.io/badge/🪟%20Windows-Télécharger%20Install--OrionKit.ps1-0078D4?style=for-the-badge&logo=windows&logoColor=white" alt="Télécharger pour Windows" />
  </a>
  &nbsp;&nbsp;
  <a href="https://github.com/THEgrison/ORION-KIT/raw/main/Install-OrionKit.sh">
    <img src="https://img.shields.io/badge/🐧%20Linux-Télécharger%20Install--OrionKit.sh-E95420?style=for-the-badge&logo=linux&logoColor=white" alt="Télécharger pour Linux" />
  </a>
</p>

| Système | Fichier | Lien direct |
|---------|---------|-------------|
| 🪟 **Windows** 10/11 | `Install-OrionKit.ps1` | [⬇️ Télécharger](https://github.com/THEgrison/ORION-KIT/raw/main/Install-OrionKit.ps1) |
| 🐧 **Linux** (toute distro) | `Install-OrionKit.sh` | [⬇️ Télécharger](https://github.com/THEgrison/ORION-KIT/raw/main/Install-OrionKit.sh) |

---

## ✨ Fonctionnalités

- 🚀 **Installation entièrement automatisée** — scripts disponibles pour Windows et Linux
- 🎨 **Thème graphique custom** — fond Andromède (M31), menu centré, signature @THEgrison
- 📁 **Menu organisé par catégorie** — Linux & Outils / Windows
- 💾 **7 ISOs téléchargés automatiquement** depuis les sources officielles (+ fallback Archive.org)
- ⚡ **Compatible UEFI & Legacy BIOS**
- 🔒 **Aucun ISO modifié** — uniquement des sources officielles

---

## 🛠️ ISOs inclus

| # | Nom | Catégorie | Usage |
|---|-----|-----------|-------|
| 1 | SystemRescue 12.03 | Linux & Outils | Réparation système, MBR, NTFS |
| 2 | GParted Live 1.8.0 | Linux & Outils | Gestion des partitions |
| 3 | Clonezilla 3.3.1 | Linux & Outils | Sauvegarde & clonage de disques |
| 4 | Rescuezilla 2.6.1 | Linux & Outils | Clone graphique (interface GUI) |
| 5 | ShredOS 2025 | Linux & Outils | Effacement sécurisé de disques |
| 6 | ESET SysRescue | Linux & Outils | Antivirus offline |
| 7 | Kaspersky Rescue Disk | Linux & Outils | Nettoyage malwares offline |
| — | **Hiren's BootCD PE** ⚠️ | Windows | Suite complète d'outils Windows PE *(manuel)* |

> ⚠️ **Hiren's BootCD PE** n'est pas redistribuable (licence propriétaire). Il doit être ajouté manuellement — voir section [Avertissements](#%EF%B8%8F-avertissements).

---

## 📦 Installation

### Prérequis communs

| | Windows | Linux |
|---|---------|-------|
| **OS** | Windows 10 / 11 | Toute distro récente |
| **Privilèges** | Administrateur | root (`sudo`) |
| **Clé USB** | ≥ 10 GB (16 GB recommandé) | ≥ 10 GB (16 GB recommandé) |
| **Internet** | ✅ Requis | ✅ Requis |

---

### 🪟 Windows — `Install-OrionKit.ps1`

**Dépendances :** PowerShell 5.1+ (inclus dans Windows 10/11)

```powershell
# Option 1 : Clic droit sur Install-OrionKit.ps1 → "Exécuter avec PowerShell" (en admin)

# Option 2 : Depuis un terminal PowerShell admin
Set-ExecutionPolicy Bypass -Scope Process -Force
.
Install-OrionKit.ps1
```

---

### 🐧 Linux — `Install-OrionKit.sh`

**Dépendances :** `wget`, `unzip`, `parted`, `mkfs.exfat`

```bash
# Installer les dépendances si nécessaire :
sudo apt install wget unzip parted exfatprogs      # Debian / Ubuntu
sudo dnf install wget unzip parted exfatprogs      # Fedora
sudo pacman -S wget unzip parted exfatutils        # Arch

# Lancer l'installateur :
sudo bash Install-OrionKit.sh
```

---

### 🔄 Déroulement de l'installation (commun aux deux scripts)

1. Confirmation de l'installation
2. Détection et sélection de la clé USB (liste automatique + vérification taille ≥ 10 GB)
3. ⚠️ **Confirmation d'effacement irréversible**
4. Téléchargement et installation de Ventoy `1.0.99`
5. Extraction du thème ORION KIT (`VTOYEFI.zip` → partition EFI)
6. Extraction de la configuration (`Ventoy.zip` → partition principale)
7. Téléchargement des 7 ISOs (avec fallback automatique sur Archive.org)
8. Rapport final + instructions pour les ISOs non téléchargés

---

## 🗂️ Structure installée sur la clé

```
📀 Clé USB ORION KIT
│
├── 📁 VTOYEFI/                           ← Partition EFI Ventoy (FAT32)
│   ├── EFI/BOOT/                         ← Bootloaders UEFI
│   └── grub/
│       └── themes/
│           └── ventoy/
│               ├── background.png        ← Fond Andromède (M31)
│               └── theme.txt             ← Thème ORION KIT
│
└── 📁 Ventoy/                            ← Partition principale (exFAT)
    ├── ISOs/
    │   ├── Linux-et-Outils/
    │   │   ├── systemrescue-12.03-amd64.iso
    │   │   ├── gparted-live-1.8.0-2-amd64.iso
    │   │   ├── clonezilla-live-3.3.1-35-amd64.iso
    │   │   ├── rescuezilla-2.6.1-64bit.oracular.iso
    │   │   ├── shredos-2025.11_28_x86-64_v0.40_20260204.iso
    │   │   ├── eset_sysrescue_live_enu.iso
    │   │   └── krd.iso
    │   └── windows/
    │       └── HBCD_PE_x64.iso           ← À ajouter manuellement
    └── ventoy/
        └── ventoy.json                   ← Configuration du menu ORION KIT
```

---

## 🖥️ Aperçu du menu au boot

```
  ==============================================
         O R I O N   K I T
         By @THEgrison  |  Powered by Ventoy
  ==============================================

  [ Linux  ] SystemRescue  — Réparation système
  [ Linux  ] GParted       — Gestion partitions
  [ Linux  ] Clonezilla    — Sauvegarde / Clone
  [ Linux  ] Rescuezilla   — Clone GUI
  [ Outils ] ShredOS       — Effacement sécurisé
  [ Sécu.  ] ESET SysRescue
  [ Sécu.  ] Kaspersky Rescue Disk
  [ Windows] Hiren's BootCD PE

                Made By @THEgrison
                   Base Ventoy
```

---

## 📁 Contenu du repo

```
ORION-KIT/
├── Install-OrionKit.ps1    ← Installateur Windows (PowerShell)
├── Install-OrionKit.sh     ← Installateur Linux (Bash)
├── VTOYEFI.zip             ← Partition EFI + thème Andromède
├── Ventoy.zip              ← Config ventoy.json + structure dossiers
└── README.md
```

---

## ⚠️ Avertissements

- L'installation **efface intégralement** la clé USB sélectionnée — vérifiez bien votre choix
- **Hiren's BootCD PE** doit être ajouté manuellement (non redistribuable) :
  1. Téléchargez-le sur [hirensbootcd.org](https://www.hirensbootcd.org/download/)
  2. Placez le fichier `HBCD_PE_x64.iso` dans `ISOs/windows/` sur la partition Ventoy
- ORION KIT n'est **pas affilié** à Ventoy, ESET, Kaspersky, Hiren's ou tout autre éditeur mentionné
- Les ISOs téléchargés sont soumis à leurs **licences respectives**

---

## 📜 Licence

Projet personnel open-source — libre d'utilisation et de modification.

---

<p align="center">
  Made with ❤️ by <strong><a href="https://github.com/THEgrison">@THEgrison</a></strong> — Built on <a href="https://www.ventoy.net">Ventoy</a>
</p>
