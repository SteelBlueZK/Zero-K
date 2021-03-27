--[[
//linear constant 65536

#include "constants.h"

piece	base, 
		tracks1, tracks2, tracks3, tracks4, 
		wheels1, wheels2, wheels3, wheels4, wheels5, wheels6,
		a1, a2, neck, turret, guns, aim, barrel1, flare1, barrel2, flare2;

static-var	tracks, isMoving, gun_2;

#define SIG_AIM					2
#define SIG_MOVE				1		//Signal to prevent multiple track motion

#define RESTORE_DELAY			3000
#define RECOIL_DISTANCE			[-12]
#define RECOIL_RESTORE_SPEED	[24]
#define TURRET_SPEED			<600>

#define WHEEL_SPIN_SPEED_L		<360>
#define WHEEL_SPIN_ACCEL_L		<10>
#define WHEEL_SPIN_DECEL_L		<30>
#define WHEEL_SPIN_SPEED_S		<540>
#define WHEEL_SPIN_ACCEL_S		<15>
#define WHEEL_SPIN_DECEL_S		<45>

#define TRACK_PERIOD			50

SmokeUnit(healthpercent, sleeptime, smoketype)

RockUnit(anglex, anglez)
{
	turn base to x-axis anglex speed <50.000000>;
	turn base to z-axis anglez speed <50.000000>;
	wait-for-turn base around z-axis;
	wait-for-turn base around x-axis;
	turn base to z-axis <0.000000> speed <20.000000>;
	turn base to x-axis <0.000000> speed <20.000000>;
}

HitByWeapon(Func_Var_1, Func_Var_2)
{
	turn base to z-axis Func_Var_2 speed <105.000000>;
	turn base to x-axis Func_Var_1 speed <105.000000>;
	wait-for-turn base around z-axis;
	wait-for-turn base around x-axis;
	turn base to z-axis <0.000000> speed <30.000000>;
	turn base to x-axis <0.000000> speed <30.000000>;
}

TrackControl() {
	while (isMoving) {
		++tracks;
		if (tracks == 2) {
			hide tracks1;
			show tracks2;
		} else if (tracks == 3) {
			hide tracks2;
			show tracks3;
		} else if (tracks == 4) {
			hide tracks3;
			show tracks4;
		} else {
			tracks = 1;
			hide tracks4;
			show tracks1;
		}
		sleep TRACK_PERIOD;
	}
}

Create()
{
	hide flare1;
	hide flare2;
	hide aim;
	hide tracks2;
	hide tracks3;
	hide tracks4;
	gun_2 = 0;
	isMoving = 0;
	tracks = 1;
	start-script SmokeUnit();
}

StartMoving() {
	signal SIG_MOVE;
	set-signal-mask SIG_MOVE;
	isMoving = 1;
	start-script TrackControl();
	spin wheels1 around x-axis speed WHEEL_SPIN_SPEED_L accelerate WHEEL_SPIN_ACCEL_L;
	spin wheels2 around x-axis speed WHEEL_SPIN_SPEED_L accelerate WHEEL_SPIN_ACCEL_L;
	spin wheels3 around x-axis speed WHEEL_SPIN_SPEED_L accelerate WHEEL_SPIN_ACCEL_L;
	spin wheels4 around x-axis speed WHEEL_SPIN_SPEED_S accelerate WHEEL_SPIN_ACCEL_S;
	spin wheels5 around x-axis speed WHEEL_SPIN_SPEED_S accelerate WHEEL_SPIN_ACCEL_S;
	spin wheels6 around x-axis speed WHEEL_SPIN_SPEED_S accelerate WHEEL_SPIN_ACCEL_S;
}

StopMoving() {
	signal SIG_MOVE;
	set-signal-mask SIG_MOVE;

	isMoving = 0;
	stop-spin wheels1 around x-axis decelerate WHEEL_SPIN_DECEL_L;
	stop-spin wheels2 around x-axis decelerate WHEEL_SPIN_DECEL_L;
	stop-spin wheels3 around x-axis decelerate WHEEL_SPIN_DECEL_L;
	stop-spin wheels4 around x-axis decelerate WHEEL_SPIN_DECEL_S;
	stop-spin wheels5 around x-axis decelerate WHEEL_SPIN_DECEL_S;
	stop-spin wheels6 around x-axis decelerate WHEEL_SPIN_DECEL_S;
}

RestoreAfterDelay()
{
	sleep RESTORE_DELAY;
	turn turret to y-axis 0 speed TURRET_SPEED;
	turn guns to x-axis 0 speed TURRET_SPEED;
	return (1);
}

AimWeapon1(heading, pitch)
{
	signal SIG_AIM;
	set-signal-mask SIG_AIM;
	turn turret to y-axis heading speed TURRET_SPEED;
	turn guns to x-axis <0.000000> - pitch speed TURRET_SPEED;
	wait-for-turn turret around y-axis;
	wait-for-turn guns around x-axis;
	start-script RestoreAfterDelay();
	return (1);
}

FireWeapon1()
{
	gun_2 = !gun_2;
	if( gun_2 ) {
		emit-sfx 1024 from flare1;
		move barrel1 to z-axis RECOIL_DISTANCE now;
		move barrel1 to z-axis 0 speed RECOIL_RESTORE_SPEED;
	} else {
		emit-sfx 1024 from flare2;
		move barrel2 to z-axis RECOIL_DISTANCE now;
		move barrel2 to z-axis 0 speed RECOIL_RESTORE_SPEED;
	}

}

AimFromWeapon1(piecenum) {
	piecenum = aim;
}

QueryWeapon1(piecenum)
{
	if (gun_2) piecenum = flare1;
	else piecenum = flare2;
}

Killed(severity, corpsetype)
{
	hide flare1;
	hide flare2;
	hide aim;
	if (severity < 25) {
		corpsetype = 1;
		explode base type BITMAPONLY | BITMAP5;
		explode a1 type BITMAPONLY | BITMAP4;
		explode a2 type BITMAPONLY | BITMAP3;
		explode neck type BITMAPONLY | BITMAP2;
		explode turret type BITMAPONLY | BITMAP1;
		explode barrel1 type BITMAPONLY | BITMAP5;
		explode barrel2 type BITMAPONLY | BITMAP4;
		return 1;
	} else if (severity < 50) {
		corpsetype = 1;
		explode base type BITMAPONLY | BITMAP5;
		explode a1 type BITMAPONLY | BITMAP4;
		explode a2 type BITMAPONLY | BITMAP3;
		explode neck type BITMAPONLY | BITMAP2;
		explode turret type FALL | BITMAP1;
		explode barrel1 type FALL | BITMAP5;
		explode barrel2 type FALL | BITMAP4;
		return 1;
	} else {
		corpsetype = 2;
		explode base type FALL | SMOKE | FIRE | EXPLODE_ON_HIT | BITMAP5;
		explode a1 type FALL | SMOKE | FIRE | EXPLODE_ON_HIT | BITMAP4;
		explode a2 type FALL | SMOKE | FIRE | EXPLODE_ON_HIT | BITMAP3;
		explode neck type FALL | SMOKE | FIRE | EXPLODE_ON_HIT | BITMAP2;
		explode turret type FALL | SMOKE | FIRE | EXPLODE_ON_HIT | BITMAP1;
		explode barrel1 type FALL | SMOKE | FIRE | EXPLODE_ON_HIT | BITMAP5;
		explode barrel2 type FALL | SMOKE | FIRE | EXPLODE_ON_HIT | BITMAP4;
		return 2;
	}
}
--]]
--includes

include "constants.lua"
include "rockPiece.lua"
local dynamicRockData
include "trackControl.lua"
include "pieceControl.lua"

--piece variables

local base = piece('base')
local tracks1, tracks2, tracks3, tracks4 = piece('tracks1', 'tracks2', 'tracks3', 'tracks4')
local wheels1, wheels2, wheels3, wheels4, wheels5, wheels6 = piece('wheels1', 'wheels2', 'wheels3', 'wheels4', 'wheels5', 'wheels6')
local a1, a2, neck, turret, guns, aim, barrel1, flare1, barrel2, flare2 = piece('a1', 'a2', 'neck', 'turret', 'guns', 'aim', 'barrel1', 'flare1', 'barrel2', 'flare2')

--local variables

local tracks, isMoving, gun_2
local SIG_AIM = 2
local SIG_MOVE = 1		--Signal to prevent multiple track motion

local RESTORE_DELAY = 3000
local RECOIL_DISTANCE = -12
local RECOIL_RESTORE_SPEED = 24
local TURRET_SPEED = 600
local WHEEL_SPIN_ACCEL_L = math.rad(10)
local WHEEL_SPIN_SPEED_L = math.rad(360)
local WHEEL_SPIN_DECEL_L = math.rad(30)
local WHEEL_SPIN_SPEED_S = math.rad(540)
local WHEEL_SPIN_ACCEL_S = math.rad(15)
local WHEEL_SPIN_DECEL_S = math.rad(45)

--localised spring functions


--local functions
local function TrackControl()
	while isMoving do
		tracks = tracks + 1
		if (tracks == 2) then
			Hide(tracks1)
			Show(tracks2)
		elseif (tracks == 3) then
			Hide(tracks2)
			Show(tracks3)
		elseif (tracks == 4) then
			Hide(tracks3)
			Show(tracks4)
		else
			tracks = 1
			Hide(tracks4)
			Show(tracks1)
		end
		Sleep(50)
	end
end
--unit script functions

function script.Create()
	Hide(flare1)
	Hide(flare2)
	Hide(aim)
	Hide(tracks2)
	Hide(tracks3)
	Hide(tracks4)
	gun_2 = 0
	isMoving = 0
	tracks = 1
	StartThread(GG.Script.SmokeUnit, unitID, base)
end

function script.StartMoving()
	Signal(SIG_MOVE)
	isMoving = 1
	StartThread(TrackControl)
	Spin(wheels1, x-axis, WHEEL_SPIN_SPEED_L, WHEEL_SPIN_ACCEL_L)
	Spin(wheels2, x-axis, WHEEL_SPIN_SPEED_L, WHEEL_SPIN_ACCEL_L)
	Spin(wheels3, x-axis, WHEEL_SPIN_SPEED_L, WHEEL_SPIN_ACCEL_L)
	Spin(wheels4, x-axis, WHEEL_SPIN_SPEED_S, WHEEL_SPIN_ACCEL_S)
	Spin(wheels5, x-axis, WHEEL_SPIN_SPEED_S, WHEEL_SPIN_ACCEL_S)
	Spin(wheels6, x-axis, WHEEL_SPIN_SPEED_S, WHEEL_SPIN_ACCEL_S)
end

function script.StopMoving()
	
end

function script.RockUnit(x,z)
	
end

function script.HitByWeapon(x, z, weaponDefID, damage)
	
end

function RestoreAfterDelay()
	
end

function script.AimWeapon1()
	return true
end

function script.FireWeapon1()
	return true
end

function script.AimFromWeapon1()
	return flare1
end

function script.QueryWeapon1()
	return flare1
end

function script.Killed()
	
end
