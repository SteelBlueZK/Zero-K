unitDef = {
  unitname            = [[jumpaa]],
  name                = [[Toad]],
  description         = [[Heavy Anti-Air Jumper]],
  acceleration        = 0.18,
  brakeRate           = 0.2,
  buildCostMetal      = 1500,
  buildPic            = [[jumpaa.png]],
  canMove             = true,
  category            = [[LAND]],
  collisionVolumeOffsets = [[0 0 0]],
  collisionVolumeScales  = [[30 48 30]],
  collisionVolumeType    = [[cylY]],
  corpse              = [[DEAD]],

  customParams        = {
    canjump            = 1,
    jump_range         = 300,
    jump_speed         = 10,
    jump_reload        = 5,
    jump_from_midair   = 0,
    modelradius    = [[15]],
  },

  explodeAs           = [[BIG_UNITEX]],
  footprintX          = 2,
  footprintZ          = 2,
  iconType            = [[jumpjetaa]],
  idleAutoHeal        = 5,
  idleTime            = 1800,
  leaveTracks         = true,
  maxDamage           = 3500,
  maxSlope            = 36,
  maxVelocity         = 2.017,
  maxWaterDepth       = 22,
  minCloakDistance    = 75,
  movementClass       = [[KBOT2]],
  moveState           = 0,
  noChaseCategory     = [[TERRAFORM LAND SINK TURRET SHIP SATELLITE SWIM FLOAT SUB HOVER]],
  objectName          = [[hunchback.s3o]],
  script              = [[jumpaa.lua]],
  selfDestructAs      = [[BIG_UNITEX]],
  sightDistance       = 1200,
  trackOffset         = 0,
  trackStrength       = 8,
  trackStretch        = 1,
  trackType           = [[ComTrack]],
  trackWidth          = 28,
  turnRate            = 1400,
  upright             = true,

  weapons             = {

    {
      def                = [[SLOWFLAK]],
      --badTargetCategory  = [[GUNSHIP]],
      onlyTargetCategory = [[GUNSHIP FIXEDWING]],
    },

    {
      def                = [[EMG]],
      --badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING GUNSHIP]],
    },

    {
      def                = [[EMG]],
      --badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING GUNSHIP]],
    },

	{
	  def                = [[MISSILE]],
	  onlyTargetCategory = [[FIXEDWING]],
	},

  },


  weaponDefs          = {

    EMG           = {
      name                    = [[Anti-Air Autocannon]],
      accuracy                = 1024,--see sprayangle
      alphaDecay              = 0.7,
      areaOfEffect            = 8,
	  burst                   = 3,
	  burstRate               = 1/30,
      canattackground         = false,
      craterBoost             = 0,
      craterMult              = 0,
      cylinderTargeting       = 1,

      customParams              = {
        isaa = [[1]],

        light_camera_height = 1600,
        light_color = [[0.9 0.86 0.45]],
        light_radius = 140,
      },

      damage                  = {
        default = 0.1,
        planes  = 10,
        subs    = 0.5,
      },

      explosionGenerator      = [[custom:ARCHPLOSION]],
      impactOnly              = true,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      intensity               = 0.8,
      interceptedByShieldType = 1,
      proximityPriority       = 4,
      range                   = 1200,
      reloadtime              = .1,
      rgbColor                = [[1 0.95 0.4]],
      separation              = 1.5,
      soundStart              = [[weapon/cannon/brawler_emg]],
	  sprayAngle              = 1024,
      stages                  = 10,
      sweepfire               = false,
      tolerance               = 8192,
      turret                  = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 1500,
    },


    LASER         = {
      name                    = [[Anti-Air Purple Laser Burst]],
      areaOfEffect            = 12,
      beamDecay               = 0.736,
      beamTime                = 1/30,
      beamttl                 = 15,
      canattackground         = false,
      coreThickness           = 0.5,
      craterBoost             = 0,
      craterMult              = 0,
      cylinderTargeting       = 1,

      customParams              = {
        isaa = [[1]],
        timeslow_damagefactor = 1500,
        timeslow_smartretarget = 0.45,
        light_color = [[0.7 0.1 0.9]],
        light_radius = 120,
      },

      damage                  = {
        default = .1,
        planes  = 1,
        subs    = 0.94,
      },

      explosionGenerator      = [[custom:flash_teal7]],
      fireStarter             = 100,
      impactOnly              = true,
      impulseFactor           = 0,
      interceptedByShieldType = 1,
      laserFlareSize          = 3.25,
      minIntensity            = 1,
      noSelfDamage            = true,
      range                   = 820,
      reloadtime              = 8,
      rgbColor                = [[0.7 0.1 0.9]],
      soundStart              = [[weapon/laser/rapid_laser]],
      soundStartVolume        = 4,
      thickness               = 2.165,
      tolerance               = 8192,
      turret                  = true,
      weaponType              = [[BeamLaser]],
      weaponVelocity          = 2200,
    },

	 MISSILE = {
      name                    = [[AA Homing Missiles]],
      areaOfEffect            = 8,
      avoidFeature            = true,
	  burst                   = 8,
	  burstRate               = .15,
	  burnblow                = true,
      cegTag                  = [[missiletrailyellow]],
      craterBoost             = 0,
      craterMult              = 0,

      customParams        = {
	    isaa = [[1]],
        light_camera_height = 2000,
        light_radius = 200,
      },

      damage                  = {
        default = 6.5,
		planes  = 65,
        subs    = 1,
      },

      explosionGenerator      = [[custom:FLASH2]],
      fireStarter             = 70,
      flightTime              = 4,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 2,
      model                   = [[wep_m_frostshard.s3o]],
      range                   = 800,
      reloadtime              = 3,
      smokeTrail              = true,
      soundHit                = [[explosion/ex_med17]],
      soundStart              = [[weapon/missile/missile_fire11]],
      startVelocity           = 50,
      texture2                = [[lightsmoketrail]],
      tolerance               = 8000,
      tracks                  = true,
      turnRate                = 16000,
      turret                  = true,
      weaponAcceleration      = 300,
      weaponType              = [[MissileLauncher]],
      weaponVelocity          = 1500,
    },

	SLOWFLAK = {
      name                    = [[Anti-Air Flack Pulse]],
      accuracy                = 64,
      areaOfEffect            = 350,
      burnblow                = true,
      canattackground         = false,
      cegTag                  = [[flak_trail]],
      craterBoost             = 0,
      craterMult              = 0,
      cylinderTargeting       = 1,

      customParams              = {
        timeslow_damagefactor = 10,
        timeslow_smartretarget = 0.45,
        isaa = [[1]],
        light_radius = 0,
      },

      damage                  = {
        default = 10,
        planes  = 100,
        subs    = 5,
      },

      edgeEffectiveness       = 0.75,
      explosionGenerator      = "custom:riotballplus2_purple_limpet",
      impulseBoost            = 0,
      impulseFactor           = 0,
      interceptedByShieldType = 1,
      noSelfDamage            = true,
      range                   = 700,
      reloadtime              = 15,
      size                    = 4,
      soundHit                = "weapon/aoe_aura",
      soundStart              = [[weapon/flak_fire]],
      turret                  = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 750,
    },

  },


  featureDefs         = {

    DEAD  = {
      blocking         = true,
      featureDead      = [[HEAP]],
      footprintX       = 4,
      footprintZ       = 4,
      object           = [[hunchback_dead.s3o]],
    },


    HEAP  = {
      blocking         = false,
      footprintX       = 4,
      footprintZ       = 4,
      object           = [[debris4x4c.s3o]],
    },

  },

}

return lowerkeys({ jumpaa = unitDef })
