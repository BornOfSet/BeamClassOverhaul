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
local CDFParticleCannonWeapon = import('/mods/SupremeWarfare4k/Contents/Weapons/AdaptiveLaser.lua').AAAD

CybranMobileHackCenter = Class(CLandUnit) {
    Weapons = {
        MainGun = Class(CDFParticleCannonWeapon) {
		
		    OnCreate = function(self)
				CDFParticleCannonWeapon.OnCreate(self)
				local owner = self.unit
				AttachBeamEntityToEntity(owner , self.Blueprint.RackBones[1].MuzzleBones[1] , owner, self.Blueprint.RackBones[1].MuzzleBones[2] , owner.GetArmy(owner) , '/effects/emitters/particle_cannon_beam_01_emit.bp')
			end,
		
		},
    },
}

TypeClass = CybranMobileHackCenter