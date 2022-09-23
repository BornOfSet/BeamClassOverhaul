------
------
------
------
------
------
local WeaponFile = import('/lua/sim/DefaultWeapons.lua')
local DefaultProjectileWeapon = WeaponFile.DefaultProjectileWeapon

DesyncedSalvo = Class(DefaultProjectileWeapon){


	OnCreate = function(self) --ε=(´ο｀*)))唉，我是很想让代码精简，但最终我发现，微调的东西越加越多。属实印证了这话：那么多参数，只有游戏开发者才知道它们为什么是必要的，而不是玩家和modders
		DefaultProjectileWeapon.OnCreate(self)
		local bp = self:GetBlueprint()
		local rrd = -bp.RackRecoilDistance
		local rof = bp.RateOfFire
		local r_sum = table.getn(bp.RackBones)
		local r_speed = bp.Rspeed
		local r_in = bp.Rinterval
				
		self.rackbones = bp.RackBones --给予每个实例单独的储存空间
		self.interval = 1/rof * r_sum
		self.rinterval = r_in --我真的不想再冗杂化self表了
		self.RackRecoilReturnSpeed = rrd / self.interval * r_speed --TODO：回复后应该等待更久的时间进行下一发炮击
		self.LongRecoilRack = {}
		
	end,

    PlayFxRackReloadSequence = function(self) --在每次炮击结束后触发的高级回调函数
        --local bp = self:GetBlueprint() --TODO：单独储存bp，不要每次调用函数都触发该行为
		local const = self.CurrentRackSalvoNumber --定义在更高级的DefaultProjectileWeapon中的数据
		self:PlayRackRecoil(self.rackbones[const].RackBone,const) --RackBone是实际操作的骨骼，const是用来访问Slider缓存的
    end,
	
    PlayRackRecoil = function(self, RackBone,const) --从高级函数手动触发的自定义低级函数
        local bp = self:GetBlueprint()
        local slider = CreateSlider(self.unit, RackBone)
        self.LongRecoilRack[const] = slider
        slider:SetPrecedence(11)
        slider:SetGoal(0, 0, bp.RackRecoilDistance)
        slider:SetSpeed(-1)
        self:ForkThread(self.PlayRackRecoilReturn,const)
    end,
	
    PlayRackRecoilReturn = function(self,const) --后坐力回复
		WaitSeconds(0.5 * self.rinterval ) --稍微停顿一下，给予力量感
        self.LongRecoilRack[const]:SetGoal(0, 0, 0)
        self.LongRecoilRack[const]:SetSpeed(self.RackRecoilReturnSpeed)  
		WaitSeconds(self.interval-0.5 * self.rinterval )  --回复结束
		self.LongRecoilRack[const]:Destroy()
		self.LongRecoilRack[const] = nil
    end,
}