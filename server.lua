ESX = exports.es_extended:getSharedObject()

ESX.RegisterServerCallback('wolfdev:prendiinfodiscord', function(source, cb, id)
    local playerId = id
    local discord = ""

    for m, n in ipairs(GetPlayerIdentifiers(playerId)) do
        if n:match("discord") then
           discord = string.gsub(n, 'discord:', '')
           break
        end
    end

    PerformHttpRequest('https://discord.com/api/users/'..discord, function(statusCode, resultData, headers)
        if statusCode == 200 then
            local userInfo = json.decode(resultData) 
            local username = userInfo.display_name
            local avatar = userInfo.avatar 

            local avatarUrl = 'https://cdn.discordapp.com/avatars/' .. discord .. '/' .. avatar .. '.png'

            cb(username, avatarUrl)
        else
            print('Errore nella richiesta all\'API di Discord:', statusCode)
            cb((GetPlayerName(id) or "unknown"), "https://cdn.discordapp.com/attachments/963899883201388594/1152647401379725372/user.png")
        end
    end, 'GET', '', {
        ['Authorization'] = 'Bot '..Config.TokenDiscord
    })
end)

RegisterNetEvent('wolfdev:daivita:second')
AddEventHandler('wolfdev:daivita:second', function(id)
    TriggerClientEvent("wolfdev:vita:death", id, source)
end)

RegisterNetEvent('wolfdev:daivita:final')
AddEventHandler('wolfdev:daivita:final', function(mio, vita)
    TriggerClientEvent("wolfdev:vita:reload:final", mio, vita)
end)

RegisterCommand("revive",function (src,arg)
    if src ~= nil or src ~= 0 then
        local xPlayer = ESX.GetPlayerFromId(src) 
        if isAdmin(xPlayer) then 
            if arg[1] ~= nil then 
                TriggerClientEvent("wolfdev:revive:admin", arg[1])
                TriggerClientEvent("esx:showNotification", arg[1], "Sei stato curato da uno staff!")
            else
                TriggerClientEvent("wolfdev:revive:admin", src)
            end
        else
            TriggerClientEvent("esx:showNotification", src, "Non sei uno staff!")
        end
    else
        local xPlayer = ESX.GetPlayerFromId(arg[1])

        if xPlayer then 
            TriggerClientEvent("wolfdev:revive", arg[1])
            TriggerClientEvent("esx:showNotification", arg[1], "Sei stato curato da uno staff!")
        else
            print("^4[Wolf Development]^0 Player non esistente!")
        end
    end
end)

function isAdmin(xPlayer)
	for k,v in ipairs(Config.Staff) do
		if xPlayer.getGroup() == v then 
			return true 
		end
	end
	return false
end