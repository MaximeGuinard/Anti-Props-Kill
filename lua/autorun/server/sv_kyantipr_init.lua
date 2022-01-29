if not SERVER then return end if CLIENT then return end
APA = (APA and APA.Settings) and APA or {Settings = {}} -- Do not remove.

APA.Settings = {
	--- Base AntiPK ---
	AntiPK 					= {1, "Régler ceci sur 1 activera Anti Prop Kill."},
	PhysgunNerf 			= {1, "Régler ceci à 1 limitera la vitesse du physgun."},
	BlockVehicleDamage 		= {1, "En réglant ceci à 1, les dommages au véhicule cesseront."},
	BlockExplosionDamage 	= {1, "Régler ceci sur 1 bloquera les dégâts d'explosion."},
	BlockWorldDamage 		= {1, "Mettre ceci à 1 bloquera les dégâts du monde."},
	--- Prop Control ---
	UnbreakableProps 		= {0, "Mettre ceci à 1 rendra les accessoires incassables. (Désactivé par défaut.)"},
	NoCollideVehicles 		= {0, "En réglant ceci à 1, les véhicules ne se heurteront pas aux joueurs."},
	NoThrow					= {0, "Mettre ceci à 1 empêchera les gens de lancer des accessoires."},
	--- Freezing ---
	StopMassUnfreeze		= {0, "Mettre ceci à 1 empêchera les gens de dégeler tous leurs accessoires en tapant deux fois R."},
	StopRUnfreeze			= {1, "Si vous définissez cette valeur sur 1, les utilisateurs ne pourront pas dégeler les accessoires en appuyant sur R."},
	FreezeOnHit 			= {1, "Mettre ceci à 1 gèlera les accessoires quand ils frappent un joueur. (A besoin d'AntiPK.)"},
	FreezeOnDrop 			= {1, "Régler ceci sur 1 gèlera les accessoires lorsqu'un joueur les lâchera. (Désactivé par défaut.)"},
	FreezeOnUnghost			= {1, "En réglant ceci à 1, les accessoires seront gelés."},
	FreezePassive			= {0, "Régler ceci sur 1 gèlera passivement les accessoires. (Désactivé par défaut.)"},
	--- Ghosting ---
	AntiPush 				= {1, "Régler ceci sur 1 activera Anti Prop Push (Ghosting)."},
	GhostSpawn				= {0, "Régler ceci sur 1 activera les images fantômes sur le spawn."},
	GhostFreeze				= {0, "Régler ceci sur 1 gèlera les fantômes."},
	UnGhostPassive			= {0, "En réglant ceci à 1, vous passerez les accessoires. (Désactivé par défaut.) (Nécessite AntiPush.)"},
	GhostsNoCollide			= {1, "En réglant ceci à 1, les fantômes seront nocturnes avec tout."},
}

APA.Settings.L = {
	Freeze = {"prop_physics", "gmod_button", "gmod_", "lawboard", "light", "lamp", "jail", "wire"},
	Black  = {"prop_physics", "gmod_", "money", "printer", "cheque", "light", "lamp", "wheel", "playx", "radio", "lawboard", "fadmin", "jail", "prop", "wire", "media"},
	White  = {"player", "npc", "weapon", "knife", "grenade", "prop_combine_ball", "npc_tripmine", "npc_satchel", "prop_door_", "trigger_", "env_"},
	Damage = { DMG_CRUSH, DMG_SLASH, DMG_CLUB, DMG_DIRECT, DMG_PHYSGUN, DMG_VEHICLE }
}

---------------------------------------------------------

local include = include
local function plugin(a)
	local a = tostring(a)
	MsgN('> '..a:gsub('^%l',string.upper))
	include('modules/apa/'..a..'.lua')
end

APA.Settings.M = APA.Settings.M or {}
for k,v in next, APA.Settings do -- Build Cvars.
	if k ~= 'L' and k ~= 'M' then
		APA.Settings[k] = CreateConVar(string.lower("apa_"..tostring(k)), v[1], {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, v[2])
	end
end

APA.hasCPPI = CPPI and CPPI.GetVersion and CPPI.GetVersion() and true or false

function APA.initPlugin(plugin)
	local plugin = tostring(plugin)
	timer.Simple(0, function()
		APA.Settings.M = APA.Settings.M or {}
		APA.Settings.M[plugin:gsub('^%l',string.upper)] = true
	end)
end

cvars.AddChangeCallback(APA.Settings.PhysgunNerf:GetName(), function( v, o, n )
	APA.physgun_maxSpeed = APA.physgun_maxSpeed or GetConVar("physgun_maxSpeed"):GetInt()
	if tobool(n) then 
		RunConsoleCommand("physgun_maxSpeed", "975") 
	else
		RunConsoleCommand("physgun_maxSpeed", tostring(APA.physgun_maxSpeed))
	end
end)

cvars.AddChangeCallback(APA.Settings.AntiPK:GetName(), function(v, o, n)
	if not tobool(n) then
		for _,v in next, player.GetAll() do
			if IsValid(v) and (v:IsAdmin() or v:IsSuperAdmin()) then
				APA.Notify(v, "WARNING: KYAnticheat Disabled!", NOTIFY_ERROR, 3.5, 1)
			end
		end
	end
end)

hook.Add("PostGamemodeLoaded", "APAntiLOAD", function()
	MsgN("KY Anticheat Loading...")
	APA.hasCPPI = CPPI and CPPI.GetVersion and CPPI.GetVersion() and true or false
	if not APA.hasCPPI then
		MsgC( Color(255, 0, 0), "\n\n---------------------------------------------------------------") 
		MsgC( Color( 255, 0, 0 ), "\n| [KYANTIPR] Prop Protection not installed? |")
		MsgC( Color(255, 0, 0), "\n---------------------------------------------------------------\n")
		ErrorNoHalt("[KYANTIPR] CPPI not found, KyAnticheat will be heavily limited.")  MsgN("\n") 
	end

	include('sv_kyantipr.lua')

	timer.Simple(0, function()
		if APA.Settings.PhysgunNerf:GetBool() then
			APA.physgun_maxSpeed = APA.physgun_maxSpeed or GetConVar("physgun_maxSpeed"):GetInt() 
			RunConsoleCommand("physgun_maxSpeed", "950") 
		end

		MsgN('\n-------------------------')
		MsgN('|KYANTIPR - Plugins Called|')
		APA.Settings.M = APA.Settings.M or {}
		local plugins, _ = file.Find('modules/apa/*.lua','LUA')
		for _,v in next, plugins do
			if v then
				v = string.gsub(tostring(v),'%.lua','')
				APA.Settings.M[v:gsub('^%l',string.upper)] = false
				plugin(v)
			end
		end
		MsgN('|KYANTIPR - Plugins Loaded|')
		MsgN('-------------------------')
		MsgN('KYANTIPR is ready to go!')
	end)
end)

util.AddNetworkString("APAnti AlertNotice")

function APA.Notify(ply, str, ctype, time, alert, moreinfo)
	if alert >= 1 or tobool(alert) then alert = 1 end

	if not IsValid(ply) then return end
	if not (ply.IsPlayer and ply:IsPlayer()) then return end
	if not str then return end
	if not ctype then ctype = 1 end

	str,ctype,time,alert = tostring(str),tonumber(ctype),tonumber(time),tonumber(alert)

	if moreinfo then
		for k,v in next, moreinfo do if( type(v) != "string" ) then moreinfo[k] = nil end end
	else moreinfo = {} end

	net.Start("APAnti AlertNotice")
		net.WriteString(str)
		net.WriteFloat(ctype)
		net.WriteFloat(time)
		net.WriteFloat(alert)
		net.WriteTable(moreinfo)
	net.Send(ply)
end