------
------
------
------
------
------
local EffectTemplate = import('/lua/EffectTemplates.lua') --used for beam effect
local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local ForkThread = ForkThread
local simpleresume = ResumeThread

--It's valid to fork a thread in another thread . But I do not fork a new thread so it still works for the original thread
local BeamLifeTime_WaitSeconds = function(self , time) --Can only run in a thread otherwise none will resume it
	-- self.Lasting = true
	local current = 0.1
	local unit = self.unit
	self.TurretReset = false
	while current <= time and not unit:IsDead() and not self.TurretReset do
		unit:SetWorkProgress(current / time)
		WaitSeconds(0.1) --Skip this one
		current = current + 0.1
		
	end
	--self.TurretReset = false --[[add]]--
	-- self.Lasting = false
	return time - current
end

local ROF_WaitSeconds = function(self , time)
	local current = 0.1
	local unit = self.unit
	while current <= time and not unit:IsDead() do
		unit:SetWorkProgress(1 - current / time)
		WaitSeconds(0.1)
		current = current + 0.1
		
	end
end

local SuspendCurrentThread = function(judge)
	if judge then
		SuspendCurrentThread()
		return not judge
	end
end

local ResumeThread = function(thread , judge , from)
	if thread and judge then
		ResumeThread(thread)
		--LOG(from)
		return not judge
	else
		if not judge and thread then
			--LOG('On Purpose Disabled' , from , judge , thread)
		else
			--LOG('WARNING: NO THREAD' , ' - - SOURCE:  ' , from)
		end
	end
end

AdaptiveLaser = Class(DefaultBeamWeapon){ 

	--try define your instanced local variables here :) ]]]-----[[[TRY DEFINE YOUR INSTANCED LOCAL VARIABLES HERE :( :( :(
	-- muzzles = {},	]]]-----
	-- threads = {},	]]]-----
	-- TurretSetup = false,
	-- TurretReset = true,
	-- Firing = false,
	-- Lasting = false,
	
	-- beam = false,

	OnCreate = function(self)
		
		DefaultBeamWeapon.OnCreate(self)
		--local
		self.threads = {}
		self.TurretSetup = false
		self.TurretReset = true
		self.Firing = false
		self.Lasting = false
		self.beam = false
		self.muzzle = false 
		self.unit:SetWorkProgress(1)
		self.threads['FiringEvent'] = ForkThread(function()
			while not self.unit:IsDead() do
				SuspendCurrentThread(true)
				--We are sure when this section gets called there must be already a not empty self.muzzles table otherwise it won't get called
				DefaultBeamWeapon.PlayFxMuzzleSequence(self , self.muzzle )
				DefaultBeamWeapon.CreateProjectileAtMuzzle(self , self.muzzle )
				--LOG(self)
			end
		end)
		self.threads['RateOfFireTimer'] = ForkThread(function()
			local rest = 0
			----LOG('fuck you ') --A thread runs automatically since created , to the suspend point
			while not self.unit:IsDead() do
				
					self.Firing = false
					SuspendCurrentThread(not self.TurretSetup)
				
				self.Firing = true
				do ResumeThread(self.threads['FiringEvent'] , not self.unit:IsDead() , 'RateOfFireTimer-fe') --Move this execution to a lower scope so that it won't be cross . We must secure the priority and the existence of BeamLifetimeThread
				end
				----LOG(self.TurretReset )
				
				rest = BeamLifeTime_WaitSeconds(self , 8) --The waiting time could be skipped if we resume the thread
				self.TurretReset = true --when it naturally ends
				--The game won't be autistic during a WaitSeconds . We can evaluate cases while waiting
				-- ResumeThread(self.threads['NaturalDeath'] , not self.unit:IsDead() , 'RateOfFireTimer-nd') --Technically we can pass the livestate boolen from WaitSeconds but I want it be compact
				if self.beam then --integrate with the flag
					--Don't worry about the dead problem because it gets dealed with in PlayFxBeamEnd
					self:PlayFxBeamEnd(self.beam)
					self.beam = false
				end
				ROF_WaitSeconds(self , 10 * (1 - rest / 8))
			end
		end)
	end,
	
	CreateProjectileAtMuzzle = function(self , muzzle) --muzzle is globally shared , so does CreateProjectileAtMuzzle
		self.muzzle = muzzle
		self.TurretSetup = true
		if not self.Firing then
			self.TurretReset = ResumeThread(self.threads['RateOfFireTimer'] , self.TurretReset , 'CreateProjectileAtMuzzle')
			--simpleresume(self.threads['RateOfFireTimer']) ---debug
		end
	end,

    PlayFxMuzzleSequence = function(self, muzzle)    end,	
	
	OnLostTargetCallback = function(self , from)
		-- if self.Lasting then --What we want is breaking the loop !
		self.TurretReset = true --The actual rof is slower than our new rof so if we disable this everytime target lost we cannot update it because we are  still firing
		-- end
		self.TurretSetup = false
		self.beam = false --It had been killed
	end,
	
	--Overwrite the default meta one
    BeamLifetimeThread = function(self, beam, lifeTime) --I suggest not to call this function from OnLostTargetCallback because there was already one doing that backstage
		-- self.threads['NaturalDeath'] = CurrentThread()
		-- SuspendCurrentThread(true)
		-- self:PlayFxBeamEnd(beam)
		self.beam = beam
    end,

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






