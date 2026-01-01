local ESX = exports['es_extended']:getSharedObject()

-- ===========================================
-- LIMITE D'ACHAT PAR JOUR (KVP)
-- ===========================================

-- Fonction pour obtenir la cle KVP
local function getPurchaseKey(identifier, itemName)
    local today = os.date('%Y-%m-%d')
    return ('pharmacie:%s:%s:%s'):format(identifier, itemName, today)
end

-- Fonction pour obtenir le nombre d'achats aujourd'hui
local function getPurchaseCount(identifier, itemName)
    local key = getPurchaseKey(identifier, itemName)
    return GetResourceKvpInt(key) or 0
end

-- Fonction pour incrementer le nombre d'achats
local function addPurchase(identifier, itemName, count)
    local key = getPurchaseKey(identifier, itemName)
    local current = GetResourceKvpInt(key) or 0
    SetResourceKvpInt(key, current + count)
end

-- Event pour retirer un item apres utilisation
RegisterNetEvent('pharmacie:server:consumeItem', function(itemName, slotId)
    local src = source
    exports.ox_inventory:RemoveItem(src, itemName, 1, nil, slotId)
end)

-- Hook ox_inventory pour limiter les achats
exports.ox_inventory:registerHook('buyItem', function(payload)
    local itemName = payload.itemName
    local itemConfig = Config.Items[itemName]

    -- Si pas de limite configuree, autoriser l'achat
    if not itemConfig or not itemConfig.maxPerDay then
        return true
    end

    local xPlayer = ESX.GetPlayerFromId(payload.source)
    if not xPlayer then return false end

    -- Les ambulanciers n'ont pas de limite
    if xPlayer.job.name == Config.DiscountJob then
        return true
    end

    local identifier = xPlayer.getIdentifier()
    local currentCount = getPurchaseCount(identifier, itemName)
    local maxPerDay = itemConfig.maxPerDay

    -- Verifier si la limite est atteinte
    if currentCount + payload.count > maxPerDay then
        TriggerClientEvent('ox_lib:notify', payload.source, {
            title = 'Pharmacie',
            description = ('Limite journaliere atteinte (%d/%d).'):format(currentCount, maxPerDay),
            type = 'error'
        })
        return false
    end

    -- Enregistrer l'achat
    addPurchase(identifier, itemName, payload.count)
    return true
end)

-- ===========================================
-- SYSTEME DE MALADIES
-- ===========================================

-- Liste des maladies disponibles
local diseaseList = {}
for diseaseName, _ in pairs(Config.DiseaseAnimations) do
    table.insert(diseaseList, diseaseName)
end

-- Labels des maladies pour les notifications
--!!! A changer avec les locales de Nova !!!--
local diseaseLabels = {
    ['nausea'] = 'Nausee',
    ['cough'] = 'Toux'
}

-- Thread principal pour le systeme de maladies
CreateThread(function()
    while true do
        Wait(Config.DiseaseCheckInterval)

        local players = ESX.GetExtendedPlayers()
        local playerCount = #players

        -- Verifier si assez de joueurs connectes
        if playerCount >= Config.MinPlayersForDisease then
            -- Tirage au sort : chance d'activer les maladies ce cycle
            local roll = math.random(1, 100)

            if roll <= Config.DiseaseChance then
                -- Selectionner aleatoirement X joueurs
                local shuffled = {}
                for i, player in ipairs(players) do
                    shuffled[i] = player
                end

                -- Melanger la liste (Fisher-Yates)
                for i = #shuffled, 2, -1 do
                    local j = math.random(1, i)
                    shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
                end

                -- Affecter les joueurs (maximum = Config.PlayersAffectedPerCycle)
                local toAffect = math.min(Config.PlayersAffectedPerCycle, playerCount)

                for i = 1, toAffect do
                    local targetPlayer = shuffled[i]
                    local playerId = targetPlayer.source

                    -- Choisir une maladie aleatoire
                    local disease = diseaseList[math.random(1, #diseaseList)]
                    local diseaseLabel = diseaseLabels[disease] or disease

                    -- Notification ox_lib orange avec nom de la maladie
                    TriggerClientEvent('ox_lib:notify', playerId, {
                        title = 'Pharmacie',
                        description = 'Vous etes atteint de : ' .. diseaseLabel,
                        type = 'warning',
                        duration = 5000
                    })

                    -- Envoyer la maladie au client pour les animations
                    TriggerClientEvent('pharmacie:client:setDisease', playerId, disease)
                end

                return
            end
        end
    end
end)
