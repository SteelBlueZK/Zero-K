unitDef = {
  unitname              = [[jumpblackhole]],
  name                  = [[Placeholder]],
  description           = [[Jumpy Black Hole Launcher]],
  acceleration          = 0.4,
  brakeRate             = 0.4,
  buildCostEnergy       = 500,
  buildCostMetal        = 500,
  builder               = false,
  buildPic              = [[JUMPRIOT.png]],
  buildTime             = 500,
  canAttack             = true,
  canGuard              = true,
  canMove               = true,
  canPatrol             = true,
  canstop               = [[1]],
  category              = [[LAND FIREPROOF]],
  corpse                = [[DEAD]],

  customParams          = {
    canjump        = [[1]],
    helptext       = [[Black hole launching jumpbot.]],
  },

  explodeAs             = [[BIG_UNITEX]],
  footprintX            = 2,
  footprintZ            = 2,
  iconType              = [[jumpjetriot]],
  idleAutoHeal          = 5,
  idleTime              = 1800,
  leaveTracks           = true,
  mass                  = 157,
  maxDamage             = 900,
  maxSlope              = 36,
  maxVelocity           = 2,
  maxWaterDepth         = 22,
  minCloakDistance      = 75,
  movementClass         = [[KBOT2]],
  noAutoFire            = false,
  noChaseCategory       = [[FIXEDWING SATELLITE GUNSHIP SUB TURRET UNARMED]],
  objectName            = [[freaker.s3o]],
  script		        = [[jumpriot.lua]],
  seismicSignature      = 4,
  selfDestructAs        = [[BIG_UNITEX]],
  selfDestructCountdown = 1,

  sfxtypes              = {

    explosiongenerators = {
      [[custom:PILOT]],
      [[custom:PILOT2]],
      [[custom:RAIDMUZZLE]],
      [[custom:VINDIBACK]],
    },

  },

  side                  = [[CORE]],
  sightDistance         = 605,
  smoothAnim            = true,
  trackOffset           = 0,
  trackStrength         = 8,
  trackStretch          = 1,
  trackType             = [[ComTrack]],
  trackWidth            = 22,
  turnRate              = 1400,
  upright               = true,
  workerTime            = 0,

 weapons             = {

    {
      def                = [[BLACK_HOLE]],
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING HOVER SWIM LAND SHIP GUNSHIP]],
    },

  },


  weaponDefs          = {

    BLACK_HOLE = {
      name                    = [[Black Hole Launcher]],
      accuracy                = 350,
      areaOfEffect            = 300,
	  avoidFeature            = false,
      avoidFriendly           = false,
      burnblow                = true,
      collideFeature          = false,
      collideFriendly         = false,
      craterBoost             = 100,
      craterMult              = 2,
	  
      damage                  = {
        default = 0,
      },

      explosionGenerator      = [[custom:black_hole]],
      explosionSpeed          = 50,
      impulseBoost            = 250,
      impulseFactor           = -2,
	  intensity               = 0.9,
      interceptedByShieldType = 1,
      myGravity               = 0.1,
      projectiles             = 1,
      range                   = 550,
      reloadtime              = 18,
      rgbColor                = [[0.05 0.05 0.05]],
      size                    = 16,
      soundHit                = [[weapon/cannon/wolverine_hit]],
      soundStart              = [[weapon/cannon/wolverine_fire]],
      soundStartVolume        = 6000,
      soundHitVolume          = 6000,
      startsmoke              = [[1]],
      targetMoveError         = 0,
      turret                  = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 320,
    },

  },


  featureDefs           = {

    DEAD  = {
      description      = [[Wreckage - Placeholder]],
      blocking         = false,
      category         = [[heaps]],
      damage           = 900,
      energy           = 0,
      featureDead      = [[HEAP]],
      featurereclamate = [[SMUDGE01]],
      footprintX       = 2,
      footprintZ       = 2,
      height           = [[4]],
      hitdensity       = [[100]],
      metal            = 200,
      object           = [[m-5_dead.s3o]],
      reclaimable      = true,
      reclaimTime      = 200,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },

	
    HEAP  = {
      description      = [[Debris - Placeholder]],
      blocking         = false,
      category         = [[heaps]],
      damage           = 900,
      energy           = 0,
      featurereclamate = [[SMUDGE01]],
      footprintX       = 2,
      footprintZ       = 2,
      hitdensity       = [[100]],
      metal            = 100,
      object           = [[debris2x2c.s3o]],
      reclaimable      = true,
      reclaimTime      = 100,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },

  },

}

return lowerkeys({ jumpblackhole = unitDef })
