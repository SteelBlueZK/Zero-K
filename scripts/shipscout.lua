include "constants.lua"

local base = piece 'base'
local turret = piece 'turret'
local wake1 = piece 'wake1'
local wake2 = piece 'wake2'
local missile = piece 'missile'
local firepoint = piece 'firepoint'
local doorl = piece 'doorl'
local doorr = piece 'doorr'
-- unused piece: hull

local smokePiece = {base}

--Speed variables


-- Signal definitions
local SIG_WAKE = 1
local SIG_SPEED = 2
local SIG_ACCEL = 4


function script.Create()
	StartThread(GG.Script.SmokeUnit, unitID, smokePiece)
	Turn(turret, x_axis, math.rad(-90), math.rad(10000))
	Turn(doorl, z_axis, math.rad(-100), math.rad(240))
	Turn(doorr, z_axis, math.rad(100), math.rad(240))
	Move(turret, y_axis, 20, 16)
end

local function LimitAcceleration()
	Signal(SIG_ACCEL)
	SetSignalMask(SIG_ACCEL)
	Spring.SetUnitRulesParam(unitID, "selfMaxAccelerationChange", .25, LOS_ACCESS)
	Sleep(100)
	Spring.SetUnitRulesParam(unitID, "selfMaxAccelerationChange", 1, LOS_ACCESS)
	
end

local function SpeedControl()
	Signal(SIG_SPEED)
	SetSignalMask(SIG_SPEED)
	while true do
		Sleep(33)
		--check speed
		_,_,_,currentspeed = Spring.GetUnitVelocity(unitID)
		local var = function() if currentspeed < 4 then return 10-2.25*(4-currentspeed) else return 10 end end
		local magic = var()--magic is 1 at 0 speed, at 4+ speed magic is at 10
		Spring.SetUnitRulesParam(unitID, "selfTurnSpeedChange", magic, LOS_ACCESS)
		if currentspeed >= 3.96 then
			StartThread(LimitAcceleration)
		end
		GG.UpdateUnitAttributes(unitID)
		Spring.Echo(currentspeed)
	end
end

local function WakeControl()
	Signal(SIG_WAKE)
	SetSignalMask(SIG_WAKE)
	while true do
		if(not Spring.GetUnitIsCloaked(unitID)) then
			EmitSfx(wake1, 2)
			EmitSfx(wake2, 2)
		end
		Sleep(150)
	end
end

local function shootyThingo()
	Sleep(33)
	Move(turret, y_axis, 0,40)
	Hide(missile)
	Sleep(1000)
	Move(turret, y_axis, 20, 40)
	Show(missile)
end


function script.Shot()
	StartThread(shootyThingo)
end

function script.StartMoving()
	StartThread(WakeControl)
	StartThread(SpeedControl)
end

function script.StopMoving()
	Signal(SIG_WAKE+SIG_SPEED)
end

function script.AimWeapon(num, heading, pitch)
	return true
end

function script.AimFromWeapon()
	return missile
end

function script.QueryWeapon()
	return firepoint
end

function script.BlockShot(num, targetID)
	-- This causes poor behaviour if there is nothing nearby which needs disarming, so OKP for Skeeter is default set to 'off' in \LuaRules\Gadgets\unit_overkill_prevention.lua
	if GG.OverkillPrevention_CheckBlockDisarm(unitID, targetID, 180, 20, 120) then --less than 1 second - timeout, 3 seconds - disarmTimer
		return true
	end
	if GG.OverkillPrevention_CheckBlock(unitID, targetID, 45, 20) then
		return true
	end
	return false
end

function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage/maxHealth
	if severity <= .25 then
		Explode(base, SFX.NONE)
		Explode(turret, SFX.NONE)
		Explode(wake1, SFX.NONE)
		Explode(wake2, SFX.NONE)
		return 1
	elseif severity <= .50 then
		Explode(base, SFX.NONE)
		Explode(turret, SFX.SHATTER)
		Explode(wake1, SFX.FALL + SFX.EXPLODE)
		Explode(wake2, SFX.FALL + SFX.EXPLODE)
		return 1
	elseif severity <= .99 then
		Explode(base, SFX.NONE)
		Explode(turret, SFX.SHATTER)
		Explode(wake1, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(wake2, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		return 2
	else
		Explode(base, SFX.NONE)
		Explode(turret, SFX.SHATTER)
		Explode(wake1, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		Explode(wake2, SFX.FALL + SFX.SMOKE + SFX.FIRE + SFX.EXPLODE)
		return 2
	end
end
