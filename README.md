# Pharmacie

Systeme de maladies aleatoires et pharmacie.

## Dependances

- es_extended
- ox_lib
- ox_inventory
- ox_target

## Fonctionnalites

- Systeme de maladies aleatoires (nausee, toux) avec animations
- PNJ pharmacien avec shop ox_inventory
- Prix reduits pour les ambulanciers
- Limite d'achat journaliere par joueur (configurable)
- Medicaments qui guerissent les maladies

---

## Configuration ox_inventory

### items.lua

Ajouter dans `ox_inventory/data/items.lua` :

```lua
-- ========================================
-- PHARMACIE
-- ========================================

['antivomitif'] = {
    label = 'Anti-vomitif',
    weight = 100,
    stack = true,
    close = true,
    consume = 1,
    description = 'Soulage les nausees et les vomissements',
    client = {
        anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
        usetime = 3000,
        export = 'pharmacie.useItem'
    }
},

['sirop_toux'] = {
    label = 'Sirop pour la toux',
    weight = 150,
    stack = true,
    close = true,
    consume = 1,
    description = 'Calme la toux et degage les voies respiratoires',
    client = {
        anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
        usetime = 3000,
        export = 'pharmacie.useItem'
    }
},

['compress'] = {
    label = 'Compresse',
    weight = 50,
    stack = true,
    close = true,
    consume = 1,
    description = 'Compresse sterile pour les soins',
    client = {
        anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
        usetime = 2000,
    }
},
```

### shops.lua

Ajouter dans `ox_inventory/data/shops.lua` :

```lua
-- ========================================
-- PHARMACIE
-- ========================================

pharmacie = {
    name = 'Pharmacie',
    inventory = {
        { name = 'antivomitif', price = 150 },
        { name = 'sirop_toux', price = 120 },
        { name = 'compress', price = 50 },
    },
    locations = {
        vec3(311.67, -1048.67, 29.53)
    }
},

pharmacie_ambulance = {
    name = 'Pharmacie (Ambulancier)',
    inventory = {
        { name = 'antivomitif', price = 75 },
        { name = 'sirop_toux', price = 60 },
        { name = 'compress', price = 25 },
    },
    locations = {
        vec3(311.67, -1048.67, 29.53)
    }
},
```

> **Note:** Les `locations` sont necessaires pour que ox_inventory accepte d'ouvrir le shop.
> Desactivez l'interaction E de ox_inventory avec `setr inventory:target false` dans votre server.cfg pour eviter les doublons avec ox_target.

---

## Configuration du script

Voir `config.lua` pour configurer :

- Position du PNJ pharmacien
- Intervalle et chance des maladies
- Limite d'achat journaliere par item
- Job beneficiant des prix reduits

---

## Items et maladies

| Item | Guerit |
|------|--------|
| `antivomitif` | Nausee |
| `sirop_toux` | Toux |
| `compress` | Aucune maladie (soin general) |

---

## Installation

1. Placer le dossier `pharmacie` dans `resources/[local]/`
2. Ajouter les items dans `ox_inventory/data/items.lua`
3. Ajouter les shops dans `ox_inventory/data/shops.lua`
4. Ajouter `setr inventory:target true` dans `server.cfg` (optionnel)
5. Ajouter `ensure pharmacie` dans `server.cfg`
6. Redemarrer le serveur
