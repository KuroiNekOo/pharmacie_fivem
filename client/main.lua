local ESX = exports['es_extended']:getSharedObject()

local currentDisease = nil
local pharmacyPed = nil
local currentProp = nil

-- ===========================================
-- FONCTIONS PROP MEDICAMENT
-- ===========================================

local function attachMedicineProp()
    local propConfig = Config.MedicineProp
    local model = joaat(propConfig.model)

    print('[PHARMACIE] Chargement du modele:', propConfig.model, 'Hash:', model)

    lib.requestModel(model)

    if not HasModelLoaded(model) then
        print('[PHARMACIE] ERREUR: Modele non charge!')
        return
    end

    print('[PHARMACIE] Modele charge avec succes')

    local playerPed = PlayerPedId()
    local boneIndex = GetPedBoneIndex(playerPed, propConfig.bone)
    local coords = GetEntityCoords(playerPed)

    print('[PHARMACIE] Bone index:', boneIndex)

    currentProp = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)

    print('[PHARMACIE] Prop cree:', currentProp, 'Existe:', DoesEntityExist(currentProp))

    if not DoesEntityExist(currentProp) then
        print('[PHARMACIE] ERREUR: Prop non cree!')
        SetModelAsNoLongerNeeded(model)
        return
    end

    AttachEntityToEntity(
        currentProp,
        playerPed,
        boneIndex,
        propConfig.offset.x,
        propConfig.offset.y,
        propConfig.offset.z,
        propConfig.rotation.x,
        propConfig.rotation.y,
        propConfig.rotation.z,
        true, true, false, true, 1, true
    )

    print('[PHARMACIE] Prop attache a la main')

    -- Liberer le modele de la RAM
    SetModelAsNoLongerNeeded(model)
end

local function removeMedicineProp()
    if currentProp and DoesEntityExist(currentProp) then
        DeleteEntity(currentProp)
        currentProp = nil
    end
end

-- ===========================================
-- CREATION DU PNJ PHARMACIEN
-- ===========================================

CreateThread(function()
    local pedData = Config.PharmacyPed
    local model = joaat(pedData.model)

    -- Charger le modele
    lib.requestModel(model)

    -- Creer le PNJ
    pharmacyPed = CreatePed(0, model, pedData.coords.x, pedData.coords.y, pedData.coords.z - 1.0, pedData.coords.w, false, true)

    -- Configurer le PNJ
    FreezeEntityPosition(pharmacyPed, true)
    SetEntityInvincible(pharmacyPed, true)
    SetBlockingOfNonTemporaryEvents(pharmacyPed, true)

    -- Liberer le modele
    SetModelAsNoLongerNeeded(model)

    -- Ajouter ox_target sur le PNJ
    exports.ox_target:addLocalEntity(pharmacyPed, {
        {
            name = 'pharmacie_shop',
            icon = 'fas fa-pills',
            label = 'Acheter des medicaments',
            onSelect = function()
                local playerData = ESX.GetPlayerData()
                local shopName = Config.ShopPublic

                -- Si le joueur a le job ambulance, ouvrir le shop reduit
                if playerData.job and playerData.job.name == Config.DiscountJob then
                    shopName = Config.ShopAmbulance
                end

                -- Ouvrir le shop ox_inventory
                exports.ox_inventory:openInventory('shop', { type = shopName, id = 1 })
            end
        }
    })
end)

-- ===========================================
-- UTILISATION DES MEDICAMENTS
-- ===========================================

exports('useItem', function(data, slot)
    local itemName = slot.name
    local curesDisease = Config.Cures[itemName]

    -- Si l'item ne guerit aucune maladie
    if not curesDisease then
        return false
    end

    -- Attacher le prop de medicament
    attachMedicineProp()

    -- Progress circle avec animation
    local success = lib.progressCircle({
        duration = data.client.usetime or 2000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = data.client.anim.dict,
            clip = data.client.anim.clip
        }
    })

    -- Retirer le prop dans tous les cas
    removeMedicineProp()

    if not success then
        return false
    end

    -- Retirer l'item via serveur
    TriggerServerEvent('pharmacie:server:consumeItem', itemName, slot.slot)

    -- Si le joueur n'est pas malade ou n'a pas la bonne maladie
    if not currentDisease or currentDisease ~= curesDisease then
        lib.notify({
            title = 'Pharmacie',
            description = 'Ce medicament n\'a aucun effet sur vous',
            type = 'error'
        })
        return false
    end

    -- Guerir le joueur
    currentDisease = nil

    lib.notify({
        title = 'Pharmacie',
        description = 'Vous vous sentez mieux !',
        type = 'success'
    })

    return false
end)

-- ===========================================
-- SYSTEME DE MALADIES
-- ===========================================

-- Recevoir la maladie du serveur
RegisterNetEvent('pharmacie:client:setDisease', function(disease)
    currentDisease = disease

    -- Lancer le thread d'animation
    CreateThread(function()
        while currentDisease do
            Wait(Config.AnimationInterval)

            if currentDisease then
                local playerPed = PlayerPedId()
                local animData = Config.DiseaseAnimations[currentDisease]

                if animData then
                    -- Charger le dictionnaire d'animation
                    lib.requestAnimDict(animData.dict)

                    -- Bloquer les mouvements si necessaire
                    if animData.freeze then
                        FreezeEntityPosition(playerPed, true)
                    end

                    -- Activer l'effet visuel pendant l'animation
                    if animData.screenEffect then
                        AnimpostfxPlay(animData.screenEffect, 0, true)
                    end

                    -- Jouer l'animation avec le flag configure
                    local flag = animData.flag or 51
                    TaskPlayAnim(playerPed, animData.dict, animData.anim, 8.0, -8.0, animData.duration, flag, 0, false, false, false)

                    -- Jouer le son
                    if animData.speech then
                        PlayAmbientSpeech1(playerPed, animData.speech, "SPEECH_PARAMS_FORCE_NORMAL")
                    end

                    -- Attendre la fin de l'animation
                    Wait(animData.duration)

                    -- Arreter l'effet visuel
                    if animData.screenEffect then
                        AnimpostfxStop(animData.screenEffect)
                    end

                    -- Debloquer les mouvements
                    if animData.freeze then
                        FreezeEntityPosition(playerPed, false)
                        ClearPedTasks(playerPed)
                    end
                end
            end
        end
    end)
end)
