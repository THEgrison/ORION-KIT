# 🔭 ORION KIT

> **Kit de dépannage multiboot clé en main — By @THEgrison | Base Ventoy**

ORION KIT est une clé USB multiboot prête à l'emploi pour diagnostiquer, réparer et récupérer des systèmes Windows et Linux. Inspiré de Hiren's BootCD, il repose sur [Ventoy](https://www.ventoy.net) avec un thème personnalisé.

---

## ✨ Fonctionnalités

- 🚀 **Installation automatique** via script PowerShell (`Install-OrionKit.ps1`)
- 🎨 **Thème graphique custom** — fond Andromède, menu centré, signature @THEgrison
- 📁 **Menu organisé par catégorie** — Linux & Outils / Windows
- 💾 **7 ISOs inclus** — téléchargés automatiquement depuis les sources officielles
- ⚡ **Compatible UEFI & Legacy BIOS**
- 🔒 **Aucun ISO modifié** — uniquement des sources officielles

---

## 🛠️ ISOs inclus

| Nom | Catégorie | Usage |
|-----|-----------|-------|
| SystemRescue 12.03 | Linux & Outils | Réparation système, MBR, NTFS |
| GParted Live 1.8.0 | Linux & Outils | Gestion des partitions |
| Clonezilla 3.3.1 | Linux & Outils | Sauvegarde & clonage de disques |
| Rescuezilla 2.6.1 | Linux & Outils | Clone graphique (interface GUI) |
| ShredOS 2025 | Linux & Outils | Effacement sécurisé de disques |
| ESET SysRescue | Linux & Outils | Antivirus offline |
| Kaspersky Rescue Disk | Linux & Outils | Nettoyage malwares offline |
| Hiren's BootCD PE | Windows | Suite complète d'outils Windows PE |

---

## 📦 Installation

### Prérequis
- Windows 10/11
- PowerShell 5.1+
- Clé USB **≥ 10 GB** (16 GB recommandé)
- Droits administrateur
- Connexion Internet

### Lancer l'installateur

```powershell
# Clic droit sur Install-OrionKit.ps1 → Exécuter avec PowerShell (en admin)
# Ou depuis PowerShell admin :
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Install-OrionKit.ps1
```

Le script vous guidera étape par étape :
1. Confirmation d'installation
2. Sélection de la clé USB (liste automatique)
3. Vérification de la taille minimale (10 GB)
4. Installation de Ventoy
5. Extraction de la config ORION KIT
6. Téléchargement des ISOs

---

## 🗂️ Structure installée sur la clé

```
📀 Clé USB ORION KIT
│
├── 📁 VTOYEFI/                         ← Partition EFI Ventoy (FAT32)
│   ├── EFI/BOOT/                       ← Bootloaders UEFI
│   └── grub/
│       └── themes/
│           └── ventoy/
│               ├── background.png      ← Fond Andromède (M31)
│               └── theme.txt           ← Thème ORION KIT
│
└── 📁 Ventoy/                          ← Partition principale (exFAT)
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
    │       └── HBCD_PE_x64.iso
    ├── Tools/
    │   ├── WinPE-ADK/
    │   │   ├── adksetup.exe
    │   │   └── adkwinpesetup.exe
    │   └── photorec_7-1_fr_441909_32.tar.bz2
    └── ventoy/
        └── ventoy.json                 ← Config menu ORION KIT
```

---

## 🖥️ Aperçu du menu au boot

```
  ==============================================
         O R I O N   K I T
  ==============================================

  [ Linux ] SystemRescue - Reparation
  [ Linux ] GParted - Partitions
  [ Linux ] Clonezilla - Clonage
  [ Linux ] Rescuezilla - Clone GUI
  [ Outils ] ShredOS - Effacement
  [ Securite ] ESET SysRescue
  [ Securite ] Kaspersky Rescue
  [ Windows ] Hirens BootCD PE

                Made By @THEgrison
                   Base Ventoy
```

---

## 📁 Contenu du repo

```
ORION-KIT/
├── Install-OrionKit.ps1    ← Script d'installation automatique
├── VTOYEFI.zip             ← Partition EFI + thème Andromède
├── Ventoy.zip              ← Config ventoy.json + structure dossiers
└── README.md
```

---

## ⚠️ Avertissements

- L'installation **efface intégralement** la clé USB sélectionnée
- Hiren's BootCD PE doit être ajouté manuellement (non redistribuable) — téléchargez-le sur [hirensbootcd.org](https://www.hirensbootcd.org) et placez-le dans `ISOs/windows/`
- ORION KIT n'est pas affilié à Ventoy, ESET, Kaspersky ou tout autre éditeur mentionné

---

## 📜 Licence

Projet personnel open-source — libre d'utilisation et de modification.
Les ISOs téléchargés sont soumis à leurs licences respectives.

---

<p align="center">
  Made by <strong>@THEgrison</strong> — Built on Ventoy
</p>
