Config = {}

-- ===========================================
-- SYSTEME DE MALADIES
-- ===========================================

-- Nombre minimum de joueurs connectes pour activer le systeme de maladies
Config.MinPlayersForDisease = 1

-- Nombre de joueurs qui peuvent attraper une maladie par cycle
Config.PlayersAffectedPerCycle = 1

-- Pourcentage de chance d'attraper une maladie (1 = 1%)
Config.DiseaseChance = 100

-- Intervalle de verification des maladies (en millisecondes)
Config.DiseaseCheckInterval = 5000 -- 5 secondes

-- Intervalle entre les animations de maladie (en millisecondes)
Config.AnimationInterval = 10000 -- 10 secondes

-- ===========================================
-- PHARMACIE
-- ===========================================

-- Position du PNJ pharmacien
Config.PharmacyPed = {
    coords = vector4(311.67, -1048.67, 29.53, 250.0), -- Hopital central
    model = 's_m_m_doctor_01'
}

-- Shops ox_inventory
Config.ShopPublic = 'pharmacie'           -- Pour les civils
Config.ShopAmbulance = 'pharmacie_ambulance' -- Pour les ambulanciers (prix reduits)

-- Job qui beneficie du shop reduit
Config.DiscountJob = 'ambulance'

-- ===========================================
-- ITEMS
-- ===========================================

-- Limites des medicaments (items)
Config.Items = {
    ['compress'] = {
        maxPerDay = 2 -- Limite par jour par joueur
    }
}

-- Quel item guerit quelle maladie
Config.Cures = {
    ['antivomitif'] = 'nausea',
    ['sirop_toux'] = 'cough'
}

-- Prop de medicament (attache a la main pendant l'utilisation)
Config.MedicineProp = {
    model = 'prop_cs_pills',           -- Modele du prop (pot de pilules)
    bone = 18905,                       -- BONETAG_L_PH_HAND (main gauche)
    offset = vector3(0.12, 0.01, 0.02), -- Position relative
    rotation = vector3(-90.0, 0.0, -40.0) -- Rotation relative
}

-- ===========================================
-- ANIMATIONS DE MALADIES
-- ===========================================

Config.DiseaseAnimations = {
    ['nausea'] = {
        dict = 'random@drunk_driver_1',
        anim = 'vomit_low',
        duration = 4000,
        speech = 'GENERIC_HI'
    },
    ['cough'] = {
        dict = 'timetable@gardener@smoking_joint',
        anim = 'idle_cough',
        duration = 2500,
        speech = 'GENERIC_HI'
    }
}
