ESX = exports.es_extended:getSharedObject()

Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

function drawTxtMorte(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

local Morto = false
local EseguiUnaVolta = false
local UccisoDaunPLayer = false
local PrimoTriggerGurdando = false
local IdKillerPlayer = 0
local SecondiMorte = 60
Citizen.CreateThread(function()
	local DeathReason, Killer, DeathCauseHash, Weapon
    while true do
		Citizen.Wait(1000)
        local ped = PlayerPedId()
		if Morto or GetEntityHealth(ped) <= 0 then
			Morto = true

			if IsPedInAnyVehicle(ped) then
                TaskLeaveVehicle(ped,GetVehiclePedIsIn(ped), 4160)
            end
            if not EseguiUnaVolta then 
                EseguiUnaVolta = true 
                if IsEntityDead(PlayerPedId()) then
                    Citizen.Wait(500)
                    local PedKiller = GetPedSourceOfDeath(PlayerPedId())
                    DeathCauseHash = GetPedCauseOfDeath(PlayerPedId())

                    if IsEntityAPed(PedKiller) and IsPedAPlayer(PedKiller) then
                        Killer = NetworkGetPlayerIndexFromPed(PedKiller)
                    elseif IsEntityAVehicle(PedKiller) and IsEntityAPed(GetPedInVehicleSeat(PedKiller, -1)) and IsPedAPlayer(GetPedInVehicleSeat(PedKiller, -1)) then
                        Killer = NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(PedKiller, -1))
                    end
                    
                    if (Killer == PlayerId()) then
						DeathReason = 'si è ucciso'
					elseif (Killer == nil) then
						DeathReason = 'è morto'
                    end
		
					if DeathReason ~= 'si è ucciso' and DeathReason ~= 'è morto' then 
						UccisoDaunPLayer = true 
						IdKillerPlayer = GetPlayerServerId(Killer)
					end 
                end
                Conteggio()
            end
			Citizen.CreateThread(function()
                while Morto do
                    Timer()
					SetPedToRagdoll(ped,1000,1000,0,0,0,0)
                    DisableAllControlActions(0)
                    EnableControlAction(0, 1)
                    EnableControlAction(0, 2)
                    EnableControlAction(0, Keys['G'], true)
                    EnableControlAction(0, Keys['H'], true)
                    EnableControlAction(0, Keys['T'], true)
                    EnableControlAction(0, Keys['E'], true)
                    EnableControlAction(0, Keys['N'], true)
                    EnableControlAction(0, Keys['DEL'], true)
                    EnableControlAction(0, Keys['F10'], true)
                    EnableControlAction(0, Keys['M'], true)
                    EnableControlAction(0, 176, true) -- ENTER key
                    Citizen.Wait(0)
                end
                EnableAllControlActions(0)
            end)
		end
	end
end)

function Timer()
	if SecondiMorte > 0 then 
		drawTxtMorte("RESPAWN DISPONIBILE TRA ~b~"..SecondiMorte.." ~w~SECONDI",4,0.5,0.90,0.50,255,255,255,190)
        if UccisoDaunPLayer and IdKillerPlayer ~= 0 then 
			TriggerEvent("wolfdev:spectplayer:death", IdKillerPlayer)
        end
	else
		drawTxtMorte("PREMI ~b~E ~w~PER RESPAWNARE IN CITTA'",4,0.5,0.87,0.50,255,255,255,190)

        if IsControlPressed(0, 38) then -- SHIFT E

            Morto = false
			IdKillerPlayer = 0
            SecondiMorte = 60
            EseguiUnaVolta = false
            UccisoDaunPLayer = false
            GuardandoPlayer = false
            PrimoTriggerGurdando = false
			TriggerEvent("wolfdev:revive")

        end
	end
end

function Conteggio()
	Citizen.CreateThread(function()
		while Morto do 
			if SecondiMorte > 0 then 
				SecondiMorte = SecondiMorte - 1
			end 
            Citizen.Wait(1000)
		end
	end)
end

function Revive(Coords, Heading)
    NetworkSetInSpectatorMode(false, GetPlayerPed(-1))
    FreezeEntityPosition(PlayerPedId(), false)
    SetEntityVisible(PlayerPedId(), true)
    SetEntityInvincible(PlayerPedId(), false)
    ClearPedBloodDamage(PlayerPedId())
    SetEntityCoordsNoOffset(PlayerPedId(), Coords.x, Coords.y, Coords.z, false, false, false, true)
    NetworkResurrectLocalPlayer(Coords.x, Coords.y, Coords.z, Heading, true, false)
    SetCanAttackFriendly(GetPlayerPed(-1), true, true)
	SetEntityCollision(GetPlayerPed(-1), true, true)	
    ClearPedTasksImmediately(PlayerPedId())
    SetEntityHealth(PlayerPedId(), GetPedMaxHealth(PlayerPedId()))
end

RegisterCommand("kill", function()
	SetEntityHealth(PlayerPedId(), 0)
end)

RegisterNetEvent('wolfdev:revive:admin')
AddEventHandler('wolfdev:revive:admin', function()
	Morto = false
	IdKillerPlayer = 0
	SecondiMorte = 60
	EseguiUnaVolta = false
	UccisoDaunPLayer = false
	GuardandoPlayer = false
	PrimoTriggerGurdando = false
	local formattedCoords = GetEntityCoords(PlayerPedId())

    ESX.SetPlayerData('lastPosition', formattedCoords)

    TriggerServerEvent('esx:updateLastPosition', formattedCoords)

	SendNUIMessage({Azione = "ChiudiMenuKill"})

    Revive(formattedCoords, 0.0)
end)

RegisterNetEvent('wolfdev:revive')
AddEventHandler('wolfdev:revive', function()
    local formattedCoords = GetEntityCoords(PlayerPedId())

    ESX.SetPlayerData('lastPosition', formattedCoords)

    TriggerServerEvent('esx:updateLastPosition', formattedCoords)

	SendNUIMessage({Azione = "ChiudiMenuKill"})

    Revive(formattedCoords, 0.0)
    DoScreenFadeIn(3000)
end)

RegisterNetEvent('wolfdev:spectplayer:death')
AddEventHandler('wolfdev:spectplayer:death', function(id)
    if not PrimoTriggerGurdando and id ~= 0 then 
        PrimoTriggerGurdando = true
        local founded = false 
        local coords = GetEntityCoords(PlayerPedId(id))
		local spectating = true
        lastcoords = GetEntityCoords(PlayerPedId())
        FreezeEntityPosition(PlayerPedId(), true)
        Wait(1500)
        for _, i in ipairs(GetActivePlayers()) do
            if NetworkIsPlayerActive(i) and tonumber(GetPlayerServerId(i)) == tonumber(id) then
                founded = true
                local ped = GetPlayerPed(i)
                positionped = GetEntityCoords(ped)
                spectateped = ped
				spectating = true
                ESX.ShowNotification("Stai Guardando il Player con l'id: "..id)
                RequestCollisionAtCoord(positionped)
                NetworkSetInSpectatorMode(true, spectateped)
				ESX.TriggerServerCallback('wolfdev:prendiinfodiscord', function(nomediscord, iconadiscord)
					SendNUIMessage({
						Azione = "ApriMenuKill",
						Nome = nomediscord,
						Foto = iconadiscord,
						Id = id
					})
				end, id)
				TriggerServerEvent("wolfdev:daivita:second", id)
				while spectating do
					Wait(500)
					local cped = GetEntityCoords(spectateped)
					if cped.x == 0 and cped.y == 0 and cped.z == 0 then
						spectating = false
						Wait(300)
						NotificaCustom("Il giocatore non è più in game e tu sei uscito dalla modalità spettatore!")
						RequestCollisionAtCoord(positionped)
						NetworkSetInSpectatorMode(false, spectateped)
						FreezeEntityPosition(PlayerPedId(), false)
						SetEntityCoords(PlayerPedId(), lastcoords)
						SetEntityVisible(PlayerPedId(), true)
						SendNUIMessage({Azione = "ChiudiMenuKill"})
						lastcoords = nil
						positionped = nil
						spectateped = nil
					else
						TriggerServerEvent("wolfdev:daivita:second", id)
					end
				end
                break
            end
        end
        if not founded then
            ESX.ShowNotification("Non è possibile al momento guardare l'id "..id.." che ti ha ucciso!")
            FreezeEntityPosition(PlayerPedId(), false)
            SetEntityCoords(PlayerPedId(), lastcoords)
            SetEntityVisible(PlayerPedId(), true)
			SendNUIMessage({Azione = "ChiudiMenuKill"})
            lastcoords = nil
            spectating = false
        end
    end
end)

exports('CheckMorte',function()
	return Morto
end)

RegisterNetEvent('wolfdev:vita:death')
AddEventHandler('wolfdev:vita:death', function(mio)
	local player = PlayerPedId()
    local vita = math.floor((GetEntityHealth(player)-100)/(GetEntityMaxHealth(player)-100)*100)
	TriggerServerEvent("wolfdev:daivita:final", mio, vita)
end)

RegisterNetEvent('wolfdev:vita:reload:final')
AddEventHandler('wolfdev:vita:reload:final', function(vita)
	SendNUIMessage({
		Azione = "ApriMenuKillStatus",
		vita = vita
	})
end)