------
------
------
------
------
------
local Weapon = import('/lua/sim/Weapon.lua').Weapon --The one who fires proj
local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam --a variation of the standard proj 
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local ForkThread = ForkThread

--local _resume = ResumeThread --我他妈也不想这个原函数被继续使用，但它是被作为upvalue传递的，也就是说，它已经被处理完了，然后函数读取它被处理后的状态，如果把它设为nil，那这个状态就是无法被调用的
local ResumeThread = function(thread , deadkill , self)

	if thread and not deadkill then --双重保险，防止异步 --所以，同一个作用域下的函数可以交替运行，那么单独作用域的次级函数挂载得越多，越没法穿插，所以游戏越来越卡？
		ResumeThread(thread) --本地化的同名函数不会被当做upvalue，这很有意思，函数外部的参数是被认为是upvalue的
	else
		LOG('DESYNCED WARNING') --两个目标之间靠的太近的时候，新一轮的射击和旧目标的丢失相邻，甚至穿插，那么就会造成函数运行不同步，目前来看，没有别的BUG了
		if self then --If the self has been passed in	
			self.YetNotComplete = true
		end
	end

end

local CreateCollisionBeam = Class(CollisionBeam){

	--temp = {},

	__init = function(self , spec) --This self is reserved for the internal created instance ( in class.lua)
		CollisionBeam.__init(self , spec) --this is a moho function and without this the c game object won't be created
		self:SetParentWeapon(spec.Weapon)
		self.end_t = {}
		--self.temp['ends'] = {}  --avoid popping out no emitter found error
	end,

	GetArmy = function(self)
		if self.unit then
			return self.unit:GetArmy()
		else
			--LOG('WARNING: NO OWNER DETECTED') --There's also a GetArmy function designed for CollisionBeam class defined in MOHO library running immediately after the c_object of current game entity had been created , when there was nothing but for a simple c object in the about empty self table , as a manner to prepare for future uses of this game object 				--There's also a GetArmy function in moho.CollisionBeamEntity which runs immediately after creating a c_object as a role of compiling
			return 'WARNED ARMY'			--But I don't know how it works , thus I overwrite it . 
		end
	end,
	
	SetMainTexture = function(self , adaptive , name)
		local army = self:GetArmy()
		--LOG(army)
		local emt = CreateBeamEmitter(name, army)
		AttachBeamToEntity(emt, self, 0, army)
		self.main_t = emt
		if adaptive then
			self:SetBeamFx(emt , false)
		end
		-- if not de then
			-- self.temp['main'] = name
			-- self.temp['adaptive'] = adaptive		
		-- end
	end,
	
	SetEndTexture = function(self , endname , emtname)
		local army = self:GetArmy()
		--LOG(army)
		self.end_t[endname] = CreateAttachedEmitter(self, endname, army, emtname)
		-- if not de then
			-- self.temp['ends'][endname] = emtname
		-- end
	end,
	
	-- RedoEmitterCreation = function(self)
		-- self:SetMainTexture(self.temp['adaptive'] , self.temp['main'] , true)
		-- for k,v in self.temp['ends'] do --the k-v-for skips the 0-key field
			--LOG(k,v)
			-- self:SetEndTexture(k,v,true)
		-- end
	-- end, --Has bugs.Emitter not found , and not utterly deleted effects
	
	EEnable = function(self)
		--self:RedoEmitterCreation()
		self:Enable()
	end,
	
	EDisable = function(self)
		self:Disable()
		self.end_t[0]:Destroy()
		self.end_t[1]:Destroy()
		self.main_t:Destroy()
	end,
	
    OnEnable = function(self)
        --We have skipped the FX beam table so we must stop it from popping out noexisted error
    end,
}
-- spec.Weapon = <weapon to attach to>
-- spec.OtherBone = <bone of weapon's unit to attach to>
-- spec.CollisionCheckInterval = <interval in ticks>
-- spec.BeamBone = <which end of beam to attach>
 

-- AdaptiveLaser_2 = Class(DefaultBeamWeapon){

	-- muzzles = {},

    -- OnCreate = function(self)
		-- DefaultBeamWeapon.OnCreate(self)
		-- self.Ready = false
		-- self.thread = ForkThread(function()
			-- SuspendCurrentThread() --It's valid to suspend ourselves. SuspendCurrentThread is always called inside a thread so to locate that thread precisely
			-- -- Executed the first time to set default state idle
			-- -- The subsequent resumes should be called to the following parts
			-- while not self.unit:IsDead() do
				-- for muzzle,__ in self.muzzles do
					-- DefaultBeamWeapon.PlayFxMuzzleSequence(self , muzzle)
					-- DefaultBeamWeapon.CreateProjectileAtMuzzle(self , muzzle)
				-- end
				-- SuspendCurrentThread() --Avoids accumulating executions when no newier commands are received
			-- end
			-- -- We should go back here . So I added a while loop
		-- end)
	-- end,
	
    -- CreateProjectileAtMuzzle = function(self, muzzle) --This function is called everytime the ROF reaches its end and turret had been set up properly . We use it only for the sake of information and we don't give a fuck about the og rof.
		-- if not self.Ready then
			-- if not self.LIFETIME then
				-- ResumeThread(self.thread)
			-- else --were there a running thread that is legacy from our last salvo , complete it
				-- ResumeThread(self.Rest)
			-- end
		-- end
		-- self.Ready = true
		-- self.muzzles[muzzle] = true
    -- end,
	
    -- PlayFxMuzzleSequence = function(self, muzzle)

    -- end,	
	
    -- BeamLifetimeThread = function(self, beam, lifeTime) --It starts since DefaultBeamWeapon.CreateProjectileAtMuzzle(self , muzzle)
		-- self.LIFETIME = CurrentThread() --Identify the running thread
		-- self.LIFETIME = nil --Identify the dead thread
    -- end,

	-- OnLostTargetCallback = function(self)
		-- if self.LIFETIME then	--were the beam yet not at its end let us make a copy of its rest parts
			-- KillThread(self.LIFETIME)
			-- self.Rest = ForkThread(function()
				-- SuspendCurrentThread()
				
			-- end)
		-- end
		-- self.Ready = false
	-- end,

    -- BeamType = Class(CollisionBeam) {
	
		-- FxImpactUnit = EffectTemplate.DefaultProjectileLandUnitImpact,
		-- FxImpactLand = {},
		-- FxImpactWater = EffectTemplate.DefaultProjectileWaterImpact,
		-- FxImpactUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
		-- FxImpactAirUnit = EffectTemplate.DefaultProjectileAirUnitImpact,
		
		-- FxBeam = {
			-- '/mods/SupremeWarfare4k/Contents/Effects/particle_cannon_beam_02_emit.bp'
		-- },
		
		-- FxBeamEndPoint = {
			-- '/effects/emitters/particle_cannon_end_01_emit.bp',
			-- '/effects/emitters/particle_cannon_end_02_emit.bp',
		-- },
		
		-- FxBeamEndPointScale = 1,
	-- },
	
	-- FxMuzzleFlash = {'/mods/SupremeWarfare4k/Contents/Effects/particle_cannon_muzzle_01_emit.bp'},
-- }


-- AdaptiveLaser_2 = Class(DefaultBeamWeapon){

	-- muzzles = {},

    -- OnCreate = function(self)
		-- DefaultBeamWeapon.OnCreate(self)
		-- self.Ready = false
		-- self.timer = ForkThread(function()
			-- SuspendCurrentThread() --Start it when we are firing
			-- while not self.unit:IsDead() do
				-- ::RESET::
				-- if not self.Ready then --It must be ready since this thread is resumed from local CreateProjectileAtMuzzle which set ready to true
					-- SuspendCurrentThread() --Start next time with ResumeThread(self.thread)
				-- end
				-- ResumeThread(self.thread) --This might be automatically killed right after losing target
				-- WaitSeconds(1) --Beam last time
				-- if self.LIFETIME then 
					-- ResumeThread(self.LIFETIME) --Destroy the beam
				-- else --We have no target this time
					-- goto RESET
				-- end
				-- WaitSeconds(2) --ROF
			-- end
		-- end)
		-- self.thread = ForkThread(function()
			-- SuspendCurrentThread() --It's valid to suspend ourselves. SuspendCurrentThread is always called inside a thread so to locate that thread precisely
			-- --Executed the first time to set default state idle
			-- --The subsequent resumes should be called to the following parts
			-- while not self.unit:IsDead() do
				-- for muzzle,__ in self.muzzles do
					-- DefaultBeamWeapon.PlayFxMuzzleSequence(self , muzzle)
					-- DefaultBeamWeapon.CreateProjectileAtMuzzle(self , muzzle)
				-- end
				-- SuspendCurrentThread() --Avoids accumulating executions when no newier commands are received
			-- end
			-- --We should go back here . So I added a while loop
		-- end)
	-- end,
	
    -- CreateProjectileAtMuzzle = function(self, muzzle) --This function is called everytime the ROF reaches its end and turret had been set up properly . We use it only for the sake of information and we don't give a fuck about the og rof.
		-- if not self.Ready then
			-- --ResumeThread(self.thread) --We finally chose to call it from timer so it's easy to invoke the next salvo immediately after rof time ran out
			-- ResumeThread(self.timer)
		-- end
		-- self.Ready = true
		-- self.muzzles[muzzle] = true
    -- end,
	
    -- PlayFxMuzzleSequence = function(self, muzzle)

    -- end,	
	
    -- BeamLifetimeThread = function(self, beam, lifeTime) --Convert this thread to a identifier of beam last time deciding when to cease even if target not lost
		-- self.LIFETIME = CurrentThread()
		-- SuspendCurrentThread()
		-- self:PlayFxBeamEnd(beam) --An upvalue of disabling the current beam . We can decide when to start it
		-- self.LIFETIME = nil
		
    -- end,

	-- OnLostTargetCallback = function(self) --We do not need to define when to cease here because it automatically kills the beam once target lost
		-- if self.LIFETIME then --If it has reached its end then we have nothing to do . If enemy died before we fire then we have nothing to do
			-- KillThread(self.LIFETIME) --Make no mistake of continuing the last one during the present one
			-- self.LIFETIME = nil
		-- end
		-- self.Ready = false --Put the Ready to false to start next salvo when it's possible
	-- end,

    -- BeamType = Class(CollisionBeam) {
	
		-- FxImpactUnit = EffectTemplate.DefaultProjectileLandUnitImpact,
		-- FxImpactLand = {},
		-- FxImpactWater = EffectTemplate.DefaultProjectileWaterImpact,
		-- FxImpactUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
		-- FxImpactAirUnit = EffectTemplate.DefaultProjectileAirUnitImpact,
		
		-- FxBeam = {
			-- '/mods/SupremeWarfare4k/Contents/Effects/particle_cannon_beam_02_emit.bp'
		-- },
		
		-- FxBeamEndPoint = {
			-- '/effects/emitters/particle_cannon_end_01_emit.bp',
			-- '/effects/emitters/particle_cannon_end_02_emit.bp',
		-- },
		
		-- FxBeamEndPointScale = 1,
	-- },
	
	-- FxMuzzleFlash = {'/mods/SupremeWarfare4k/Contents/Effects/particle_cannon_muzzle_01_emit.bp'},
-- }





AdaptiveLaser_2 = Class(DefaultBeamWeapon){

	muzzles = {},
	--LIFETIME = {}, --compatibility with multiple muzzles. --Who gives a fuck 

    OnCreate = function(self)
		DefaultBeamWeapon.OnCreate(self)
		self.unit:SetWorkProgress(1)
		self.Ready = false
		self.timer = ForkThread(function()
			SuspendCurrentThread() --Start it when we are firing
			while not self.unit:IsDead() do
				while true do
					if not self.Ready and not self.LIFETIME then --It must be ready since this thread is resumed from local CreateProjectileAtMuzzle which set ready to true
					--Secure we won't encounter with a endless loop
					--We should not stop during firing
					--'or'  is bugged , meaning we won't be able to get into the next salvo since having get out of it
					--self.LIFETIME is always false so the thread is always suspended if it's 'or' rule
					--TODO . Magical bug here of angel restriction
						SuspendCurrentThread() --Start next time with ResumeThread(self.thread)
					end
					ResumeThread(self.thread) --This might be automatically killed right after losing target
					WaitSeconds(3.6) --Beam last time --不精确，只是反复读取15，而不是根据当前流逝计算剩余，为了平衡性，请将它减小
					self.YetNotComplete = false
					if self.LIFETIME or self.Ready then 
						ResumeThread(self.LIFETIME , self.unit:IsDead(), self) --Destroy the beam --Desynced bug here . Too sensitive
						--你这个既然都被OnlostCallback kill掉了，那原来的激光它肯定也被IdleState连带着Destroy了，没有必要Destroy它第二次
						--除了nil的情形，它还可能在单位被杀死，其所有线程被立即结束的时候继续呼叫该线程，所以要阻止
						break
					else --We have no target this time
						--self.LIFETIME is always nil
					end
				end
				if not self.YetNotComplete then
					ForkThread(function()
						local unit = self.unit --upvalue
						local rof = 7.2
						local clockTime = math.round(10 * rof)
						local totalTime = clockTime
						while clockTime >= 0 and
							  not self:BeenDestroyed() and
							  not unit.Dead do
							unit:SetWorkProgress(1 - clockTime / totalTime)
							clockTime = clockTime - 1
							WaitSeconds(0.1)

						end
					end)
					self.waitingROF = true
					WaitSeconds(3.6) --ROF --ResumeThread将强制打断当前的coroutine.yield。所以，如果在射击的时候强行打断，它就自动跳过持续时间，来到我们现在这个位置——强行进行ROF
					self.waitingROF = false --事实上，我发现，Desynced发生的时候，其实更多是强行打断当前射击，然后进入ResumeThread（LIFETIME），发现改变目标后，它被强制结束了。其实并非什么“异步”，抱歉，是我文化水平那么低
				else
					self.waitingROF = true
					WaitSeconds(1.8) --ROF --Add a new flag here to restrict the next salvo's last time TODO
					self.waitingROF = false --
				end
			end
		end)
		self.thread = ForkThread(function()
			SuspendCurrentThread() --It's valid to suspend ourselves. SuspendCurrentThread is always called inside a thread so to locate that thread precisely
			--Executed the first time to set default state idle
			--The subsequent resumes should be called to the following parts
			while not self.unit:IsDead() do
				for muzzle,__ in self.muzzles do
					DefaultBeamWeapon.PlayFxMuzzleSequence(self , muzzle)
					DefaultBeamWeapon.CreateProjectileAtMuzzle(self , muzzle)
					break --TODO . USE ONLY ONE MUZZLE PLS
				end
				SuspendCurrentThread() --Avoids accumulating executions when no newier commands are received
			end
			--We should go back here . So I added a while loop
		end)
	end,
	
    CreateProjectileAtMuzzle = function(self, muzzle) --This function is called everytime the ROF reaches its end and turret had been set up properly . We use it only for the sake of information and we don't give a fuck about the og rof.
		if not self.Ready and not self.waitingROF then --我对Waitseconds和while循环深恶痛绝，但却不能避免使用它们
			--ResumeThread(self.thread) --We finally chose to call it from timer so it's easy to invoke the next salvo immediately after rof time ran out
			ResumeThread(self.timer)
		end
		self.Ready = true
		self.muzzles[muzzle] = true
    end,
	
    PlayFxMuzzleSequence = function(self, muzzle)

    end,	
	
    BeamLifetimeThread = function(self, beam, lifeTime) --Convert this thread to a identifier of beam last time deciding when to cease even if target not lost
		self.LIFETIME = CurrentThread()
		SuspendCurrentThread()
		self:PlayFxBeamEnd(beam) --An upvalue of disabling the current beam . We can decide when to start it
		self.LIFETIME = nil
    end,

	OnLostTargetCallback = function(self) --We do not need to define when to cease here because it automatically kills the beam once target lost
		if self.LIFETIME then --If it has reached its end then we have nothing to do . If enemy died before we fire then we have nothing to do
			KillThread(self.LIFETIME) --Make no mistake of continuing the last one during the present one
			self.LIFETIME = nil
			--We need to let the timer know it's invalid to resume the beamlifetime thread here
			--正常来讲，这个地方对timer没有鸡巴毛影响，但问题是如果你点的太快，它就会插在timer运行的间隙中执行，然后造成条件判断前后不同步
		end
		self.Ready = false --Put the Ready to false to start next salvo when it's possible
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








AdaptiveLaser_3 = Class(DefaultBeamWeapon){
  --TODO:BeamLifetime , RackRecoilDistance
	muzzles = {},

    OnCreate = function(self)
		DefaultBeamWeapon.OnCreate(self)
		self.TurretSetup = false
		ForkThread(function()
			local unit = self.unit
			local rof = self:GetWeaponRoF()
			while not unit:IsDead() do
				while not self.TurretSetup do
					WaitSeconds(0.5)
				end
				for k,v in self.muzzles do
					DefaultBeamWeapon.PlayFxMuzzleSequence(self , k)
					DefaultBeamWeapon.CreateProjectileAtMuzzle(self , k)
				end
				while self.TurretSetup do
					WaitSeconds(0.5)
				end
				WaitSeconds(rof)
			end		
		end)
	end,
	
	-- OnFire = function(self)  --OnFire is always overwritten by States . It has no point to define our own OnFire 
		
	-- end,
	
    CreateProjectileAtMuzzle = function(self, muzzle) --This is called via OnFire and is the only one we can access to get access to the OnFire here
		self.TurretSetup = true
		self.muzzles[muzzle] = true
    end,
	
    PlayFxMuzzleSequence = function(self, muzzle) --So that we won't  accumulate effects
		--It is equivalent to create proj both above and here 
    end,	
	
    BeamLifetimeThread = function(self, beam, lifeTime) --Now it does nothing

    end,

	OnLostTargetCallback = function(self)
		--LOG('#########')  --I remember there was a time I made it possible to penetrate and damage multiple enemies with a single blade . I lost that codes
		self.TurretSetup = false
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
	
    --FxMuzzleFlash = {'/mods/SupremeWarfare4k/Contents/Effects/particle_cannon_muzzle_02_emit.bp'},
}













AdaptiveLaser = Class(Weapon){ --BUG

	Beams = {},
	of = false,
	ap = false,
	s = true,

    OnCreate = function(self)
        Weapon.OnCreate(self)
		for i = 1,2 do --MuzzleBones
			self.Beams[i] = self:CreateCollisionBeam(self.Blueprint.RackBones[1].MuzzleBones[i])
			self.Beams[i]:SetMainTexture(true, '/mods/SupremeWarfare4k/Contents/Effects/particle_cannon_beam_02_emit.bp')
			self.Beams[i]:SetEndTexture(0 , '/mods/SupremeWarfare4k/Contents/Effects/particle_cannon_muzzle_02_emit.bp')
			self.Beams[i]:SetEndTexture(1 , '/mods/SupremeWarfare4k/Contents/Effects/unknown_energy_entity.bp')
			self.Beams[i]:EDisable()
			self.s = true
		end
    end,

	OnGotTarget = function(self)
		Weapon.OnGotTarget(self)
		--LOG('SET')
		self:OnFire()
	end,
		
	OnFire = function(self)  --A properly set up turret gives it the potential possiblity to be called . It is authentically called only if it had received a info from ROF listener which was waiting for the next turn.
		self.ap = true
		if not self.of then
			ForkThread(function()
				local rof =  1 / self.Blueprint.RateOfFire
				while not self.unit:IsDead() do
					WaitSeconds(rof)
					if self.ap and self.s == true then
						Weapon.OnFire(self)  --I want to trigger Onfire as usual 
						self.s = false
						for i = 1,2 do
							self.Beams[i]:EEnable()
							self.Beams[i]:SetMainTexture(true, '/mods/SupremeWarfare4k/Contents/Effects/particle_cannon_beam_02_emit.bp')
							self.Beams[i]:SetEndTexture(0 , '/mods/SupremeWarfare4k/Contents/Effects/particle_cannon_muzzle_02_emit.bp')
							self.Beams[i]:SetEndTexture(1 , '/mods/SupremeWarfare4k/Contents/Effects/unknown_energy_entity.bp')
						end
					end
				end
			end)
			self.of = true
		end
		
	end,
	
	OnLostTarget = function(self)
		Weapon.OnLostTarget(self)
		for i = 1,2 do
			self.Beams[i]:EDisable()
			self.s = true
		end
		self.ap = false
	end,

	CreateCollisionBeam = function(weapon,muzzle)
		local beam = CreateCollisionBeam({
			Weapon = weapon,	
			OtherBone = muzzle, 
			CollisionCheckInterval = 1, --higher value less damage. Actualy , this parameter controls how many times the damage will be calculated as applied in 1 second . Similiar to DOT	
		})
		return beam
	end,
	

}



Scalpel = Class(Weapon){

    OnCreate = function(self)
        Weapon.OnCreate(self)
		self.Muzzle_1 = self.Blueprint.RackBones[1].MuzzleBones[1]
		self.Muzzle_2 = self.Blueprint.RackBones[1].MuzzleBones[2]
    end,

	OnGotTarget = function(self)
		Weapon.OnGotTarget(self)
		--LOG('SET')
		local army = self.unit:GetArmy()
		local beam = CreateCollisionBeam(
			{
				Weapon = self,
				OtherBone = self.Muzzle_2,
				CollisionCheckInterval = 10, -- Keep the checkinterval as usual otherwise it will do less damage than what's writen in BP , when the value reaches too high
			}
		)
		local Emitter = CreateBeamEmitter('/mods/SupremeWarfare4k/Contents/Effects/particle_cannon_beam_02_emit.bp', army)
		AttachBeamToEntity(Emitter, beam, 0, army) --1 means invert 0 means normal
		
		beam = CreateCollisionBeam(
			{
				Weapon = self,
				OtherBone = self.Muzzle_1,
				CollisionCheckInterval = 10, -- Keep the checkinterval as usual otherwise it will do less damage than what's writen in BP , when the value reaches too high
			}
		)
		Emitter = CreateBeamEmitter('/mods/SupremeWarfare4k/Contents/Effects/particle_cannon_beam_02_emit.bp', army)
		AttachBeamToEntity(Emitter, beam, 0, army) --1 means invert 0 means normal
	end,
		
	OnFire = function(self)
		Weapon.OnFire(self)
		--LOG('FIRE')
	end,
	
	OnLostTarget = function(self)
		Weapon.OnLostTarget(self)
		--LOG('LOST')
	end,

}


AAAD = Class(Weapon){

    OnCreate = function(self)
        Weapon.OnCreate(self)
		self.Army = self.unit:GetArmy()
		self.Muzzle = self.Blueprint.RackBones[1].MuzzleBones[1]
    end,

	OnGotTarget = function(self)
		Weapon.OnGotTarget(self)
		--LOG('SET')
	end,
		
	OnFire = function(self)
		Weapon.OnFire(self) 
		local beamentity = self:CreateNewBeam() --Set rof to 0 so he fires only once and this effect acting at a distance won't be overlapped with the same effects
		beamentity.Army = self.Army
		self.AAAD(beamentity)
	end,
	
	OnLostTarget = function(self)
		Weapon.OnLostTarget(self)
		--LOG('LOST')
	end,

	CreateNewBeam = function(weapon)
		local beam = CreateCollisionBeam({
			Weapon = weapon,
			OtherBone = weapon.Muzzle,
			CollisionCheckInterval = 1, --higher value less damage
		})
		return beam
	end, 
	
	AAAD = function(collisionbeam)
		--local emt = CreateAttachedEmitter( self:GetCurrentTarget(), 0, self.Army, '/mods/SupremeWarfare4k/Contents/Effects/unknown_energy_entity.bp')
		return CreateAttachedEmitter(collisionbeam, 1, collisionbeam.Army, '/mods/SupremeWarfare4k/Contents/Effects/unknown_energy_entity.bp') --So what 0 and 1 mean here are basically which end of the beam panel . The 0 side is its starting end , the 1 side is its finishing end
	end
}
