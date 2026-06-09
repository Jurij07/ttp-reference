# Top Tier Providence — Roblox Spiel

Ein Cultivation-RPG für Roblox. Dieses Repo enthält den **Spielcode** (Lua/Luau,
über Rojo nach Roblox Studio synchronisiert) sowie eine **HTML-Referenz** der
Spieldaten (`index.html`, `project-overview.html`).

---

## 🚀 In Studio starten (Rojo)

1. **Rojo-Server starten** im Projekt-Ordner (dort wo `default.project.json` liegt):
   ```
   C:\Users\j\Downloads\rojo\rojo.exe serve
   ```
2. In **Roblox Studio** → Tab **Plugins** → **Rojo** → **Connect**.
3. **Play** drücken (F5). Das HUD erscheint, NPCs stehen vor dir.

> **DataStore:** Zum Speichern muss in Studio
> *Game Settings → Security → "Enable Studio Access to API Services"* aktiv sein.
> Ohne diese Einstellung läuft das Spiel trotzdem — nur ohne Speicherung
> (In-Memory-Modus). Umschaltbar über `Config.USE_DATASTORE`.

---

## 🎮 Was funktioniert (erster Stand)

| Feature | Beschreibung |
|---|---|
| **Providence Roll** | Beim ersten Join werden Aptitude, Physique, Connate & Dao gewürfelt |
| **Cultivation** | 26 Realms, EXP-Formel & Stage-Ups aus der Referenz |
| **Meditation** | Button unten links → passives EXP-Farmen |
| **Breakthrough** | Bei Stage-Max automatischer Aufstieg in den nächsten Realm |
| **Combat** | NPCs anklicken → Schaden, Gegenangriff, EXP + Stones beim Kill |
| **Lifespan** | Lebensspanne sinkt langsam; bei 0 beginnt ein neues Leben |
| **HUD** | Realm/Stage/EXP, HP, Stones/Karma/Kills, Providence, Toasts |
| **Speichern** | DataStore mit sicherem In-Memory-Fallback |
| **Reroll** | Providence neu würfeln (5 kostenlose Rerolls) |

---

## 📁 Projektstruktur

```
default.project.json        Rojo-Mapping
src/
├── shared/                 → ReplicatedStorage
│   ├── Config.lua          Alle Stellschrauben (Raten, Spawn, Start-Werte)
│   ├── Net.lua             RemoteEvent/Function-Helfer
│   └── GameData/
│       ├── CultivationData.lua   26 Realms, EXP-Formel, Lifespan, Combat-Stats
│       ├── AptitudeData.lua      9 Aptitude-Grade + Roll
│       ├── ProvidenceData.lua    Physique / Connate / Dao + Rolls
│       └── NPCData.lua           Gegner (R1+R2 komplett, R3-R9 TODO)
├── server/                 → ServerScriptService
│   ├── Bootstrap.server.lua      Startet alle Services
│   └── Services/
│       ├── DataManager.lua       Laden/Speichern der Spielerdaten
│       ├── ProvidenceService.lua Roll + Stat-Multiplikatoren
│       ├── CultivationService.lua EXP, Stages, Breakthrough, Meditation, Lifespan
│       ├── CombatService.lua     Schaden, Belohnung, HP-Regen
│       └── NPCService.lua        Spawnt Welt-NPCs mit Klick-Kampf
└── client/                 → StarterPlayer/StarterPlayerScripts
    └── UIController.client.lua    Komplettes HUD per Code
```

---

## 🔜 Nächste Schritte (offen)

- NPC-Daten **Realm 3-9** in `NPCData.lua` ergänzen (Schema steht, Werte aus `index.html`)
- Echte NPC-Modelle & Animationen statt blockiger Platzhalter
- Karten/Zonen pro Realm
- Quest-, Item-, Shop- & Sect-Systeme (Daten teils in der Referenz vorhanden)
- Dungeon-System (3 Floors, Cooldown)
