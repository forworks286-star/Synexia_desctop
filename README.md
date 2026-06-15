# Synexia Desktop — Logiciel Manager

---

## Différence avec l'application mobile

| | Mobile (Stockiste) | Desktop (Manager) |
|---|---|---|
| Scan QR | ✅ | ❌ |
| Dashboard complet | ❌ | ✅ |
| Validation factures | ❌ | ✅ |
| Rapports PDF | ❌ | ✅ |
| Navigation | Bottom bar | Sidebar |

---

## Changer le serveur

`lib/core/config/app_config.dart` — 1 seule ligne :
```dart
static const String _baseUrl = 'http://IP_SERVEUR:8000';
```

---

## Méthode 1 — GitHub.dev + Codemagic

```
1. Créer un nouveau repo GitHub : "Synexia-Desktop"
2. Uploader tous les fichiers de ce ZIP dans le repo
3. Aller sur codemagic.io → connecter le nouveau repo
4. Start new build → APK généré automatiquement
```

## Méthode 2 — VS Code local (Windows/Linux)

```bash
# Activer le support desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop

# Installer et lancer
flutter pub get
flutter run -d windows    # ou -d linux

# Build final .exe
flutter build windows --release
```

## Méthode 3 — GitHub.dev uniquement (modifications sans build local)

```
1. Ouvrir github.dev/votre-repo/Synexia-Desktop
2. Modifier les fichiers directement
3. Committer → Codemagic rebuild automatique
```

---

## Stack

Flutter · GetX · Dio · FastAPI · PostgreSQL · fl_chart
