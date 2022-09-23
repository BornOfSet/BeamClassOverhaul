

local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam
local EffectTemplate = import('/lua/EffectTemplates.lua')

ParticleFurnance = Class(DefaultBeamWeapon) {
    BeamType = Class(CollisionBeam) {
	
		FxImpactUnit = EffectTemplate.DefaultProjectileLandUnitImpact,
		FxImpactLand = {},
		FxImpactWater = EffectTemplate.DefaultProjectileWaterImpact,
		FxImpactUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
		FxImpactAirUnit = EffectTemplate.DefaultProjectileAirUnitImpact,
		
		FxBeam = {
			'/mods/SupremeWarfare4k/Contents/Effects/particle_cannon_beam_02_emit.bp'
		},
		
		FxBeamEndPoint = {
			'/effects/emitters/particle_cannon_end_01_emit.bp',
			'/effects/emitters/particle_cannon_end_02_emit.bp',
		},
		
		FxBeamEndPointScale = 1,
	},
    FxMuzzleFlash = {'/mods/SupremeWarfare4k/Contents/Effects/particle_cannon_muzzle_01_emit.bp'},
}
