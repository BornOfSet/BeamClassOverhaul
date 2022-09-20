#****************************************************************************
#**
#**  File     :  /cdimage/units/URL0202/URL0202_script.lua
#**  Author(s):  John Comes, David Tomandl, Jessica St. Croix
#**
#**  Summary  :  Cybran Heavy Tank Script
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local CLandUnit = import('/lua/cybranunits.lua').CLandUnit
local CDFParticleCannonWeapon = import('/mods/SupremeWarfare4k/Contents/Weapons/AdaptiveLaser.lua').AdaptiveLaser_2

CybranLaserTank_2 = Class(CLandUnit) {
    Weapons = {
        MainGun = Class(CDFParticleCannonWeapon) {
		
		    OnCreate = function(self)
				CDFParticleCannonWeapon.OnCreate(self)
				local owner = self.unit
				--AttachBeamEntityToEntity(owner , self.Blueprint.RackBones[1].MuzzleBones[1] , owner, self.Blueprint.RackBones[1].MuzzleBones[2] , owner.GetArmy(owner) , '/effects/emitters/particle_cannon_beam_01_emit.bp')
			end,
		
		},
    },
	
	
	OnLostTarget = function(self , weapon) --This OnLostTarget makes it possible to go outside complex states pile and see effects directly
		weapon:OnLostTargetCallback()
	end
}

TypeClass = CybranLaserTank_2