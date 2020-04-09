--
-- defcon.lua
-- Defcon Level for MRP
--
-- Created by CoollDave#0627 on 4/7/2020
-- Copyright © 2020 CoollDave#0627. All rights reserved.
--

AddCSLuaFile()

EXERCISE_TERMS = {"COCKED PISTOL", "FAST PACED", "ROUND HOUSE", "DOUBLE TAKE", "FADE OUT"}

if SERVER then

	util.AddNetworkString("defcon")
	local level = 5
	local oldLevel = 5
	local annouce = false
	local annouceTime = 9
	
	function ChangeLevel(newLevel)
		
		if annouce or newLevel == level then
			return false
		end
		
		oldLevel = level

		level = newLevel
		
		print("DEFCON level changed from " .. oldLevel .. " to " .. level .. ".") -- Console logging

		net.Start("defcon")
		net.WriteInt(level, 4) -- DEFCON Level
		net.WriteInt(oldLevel, 4) -- OLD DEFCON Level
		net.WriteBit(false) -- Not annouce?
		net.WriteBit(false) -- Setup panel?
		net.Broadcast()
		
		annouce = true 

		timer.Simple(annouceTime, function()

			net.Start("defcon")
			net.WriteInt(level, 4) -- DEFCON Level
			net.WriteInt(oldLevel, 4) -- OLD DEFCON Level
			net.WriteBit(true) -- Not annouce?
			net.WriteBit(false) -- Setup panel?
			net.Broadcast()

			annouce = false
		end)
		
		return true
	end	
	
	hook.Add("PlayerSay", "defcon", function(ply, text)

		if ply:IsAdmin() or ply:IsSuperAdmin() then
			local t = string.Explode(" ", text)

			if t and t[1] and t[2] then
				local cmd=t[1]:lower()
				local t2 = tonumber(t[2])

				if cmd=="!defcon" and (t2 == 5 or t2 == 4 or t2 == 3 or t2 == 2 or t2 == 1) then
					ChangeLevel(t2)

					return ""
				end

			end

		end

	end)
	
	concommand.Add("defcon", function(ply, cmd, args) 

		local arg = tonumber(args[1])

		if not (arg == "5" or arg == 4 or arg == 3 or arg == 2 or arg == 1) then
			print("ERROR: Bad argument for defcon.  Try an integer 1-5.")  -- Error reporting for console users

		elseif not IsValid(ply) or (ply and ply:IsAdmin() or ply:IsSuperAdmin()) then
			ChangeLevel(arg)
		end

	end)
	
	hook.Add("PlayerInitialSpawn", "defcon", function(ply)

		net.Start("defcon")
		net.WriteInt(level, 4) -- DEFCON Level
		net.WriteInt(oldLevel, 4) -- OLD DEFCON Level
		net.WriteBit(true) -- Not annouce?
		net.WriteBit(true) -- Setup panel?
		net.Broadcast()
	end)

elseif CLIENT then

	surface.CreateFont( "annoucebig", {
		font = "CloseCaption_Bold",
		size = 52,
		weight = 700,
		antialias = true,
	})
	
	--local snd
	
	local defconPanel
	local img_defcon

	net.Receive("defcon", function(len)

		local readyLevel = net.ReadInt(4)
		local oldReadyLevel = net.ReadInt(4)
		local tempAnnounce = tobool(net.ReadBit())
		local createPanel = tobool(net.ReadBit())

		if defconSound then
			defconSound:Stop()
		end

		if createPanel then
			-- Container panel
			defconPanel = vgui.Create("DPanel")
			defconPanel:SetSize(154, 123)
			defconPanel:SetDrawBackground(false)
			defconPanel:SetPos(21*ScrW()/24, ScrH()/24)

			-- Image load
			img_defcon = vgui.Create("DImage", defconPanel)
			img_defcon:SetSize(defconPanel:GetSize())
			img_defcon:SetImage("defcon/defcon" .. readyLevel .. ".png")

		end
		
		if tempAnnounce then
			hook.Remove("HUDPaint", "annoucebig")		

			img_defcon:SetImage("defcon/defcon" .. readyLevel .. ".png")
			return
		end

		hook.Add("HUDPaint", "annoucebig", function()

			if readyLevel > oldReadyLevel and oldReadyLevel == 1 then
				defconSound = CreateSound(LocalPlayer(), "defcon/downdefcon1.mp3")
			elseif readyLevel > oldReadyLevel then 
				defconSound = CreateSound(LocalPlayer(), "defcon/downdefcon234.mp3")
			else
				defconSound = CreateSound(LocalPlayer(), "defcon/updefcon" .. readyLevel .. ".mp3")
			end

			defconSound:Play()

			img_defcon:SetImage("defcon/offdefcon" .. readyLevel .. ".png")

			draw.SimpleText("We are moving to:", "annoucebig", ScrW()/2, ScrH()/14, Color(255,56,56,150), TEXT_ALIGN_CENTER)
			draw.SimpleText("DEFCON " .. readyLevel, "annoucebig", ScrW()/2, ScrH()/8, Color(255,56,56,150), TEXT_ALIGN_CENTER)
			draw.SimpleText("\"" .. EXERCISE_TERMS[readyLevel] .. "\"", "annoucebig", ScrW()/2, ScrH()/6+5, Color(255,56,56,150), TEXT_ALIGN_CENTER)
		end)
		
	end)

end

print("defcon.lua started successfully! ")
