local CLandUnit = import('/lua/cybranunits.lua').CLandUnit
local CDFParticleCannonWeapon = import('/mods/SupremeWarfare4k/Contents/Weapons/ParticleFurnance.lua').ParticleFurnance

---@class URL0202 : CLandUnit
CybranMicrowaveTank = Class(CLandUnit) {
    Weapons = {
        MainGun = Class(CDFParticleCannonWeapon) {
		
			CreateProjectileAtMuzzle = function(self, muzzle)
				for k,v in self.Beams do 
					v.Beam:Enable()
				end
			end,
			
			PlayFxBeamEnd = function(self, beam)
				for k, v in self.Beams do
                    v.Beam:Disable()
                end
			end,
			
		},
    },	
}

TypeClass = CybranMicrowaveTank
