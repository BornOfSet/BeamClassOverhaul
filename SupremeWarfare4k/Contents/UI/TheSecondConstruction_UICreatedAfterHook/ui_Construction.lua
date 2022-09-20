local path = '/mods/SupremeWarfare4k/Contents/UI/TheSecondConstruction_UICreatedAfterHook/'


local CreateWindow = import('/lua/maui/window.lua').Window
local Button = import('/lua/maui/button.lua').Button
local UIFile = import('/lua/ui/uiutil.lua').UIFile
local GetClickPosition = import('/lua/ui/game/commandmode.lua').ClickListener
local textbox = import(path .. 'reminder.lua').Text

local CreateButton = Class(Button){

    IconTextures = function(self, texture, path)
		self:SetTexture(texture)
		self.mNormal = texture 
        self.mActive = path .. 'dk.jpg'
        self.mHighlight = path .. 'hl.jpg'
        self.mDisabled = texture
		self.Depth:Set(10)
    end,
	
	OnClick = function(self, modifiers)
		local selection = GetSelectedUnits()
		if selection then 
			local engs = EntityCategoryFilterDown(categories.ENGINEER,selection)
			if engs[1] then
				textbox:SetText('Construction is going to begin . Units are waiting orders . Choose a place to put the building')
				ForkThread(
					function()
						local cpos = GetClickPosition()
						local flag = IsKeyDown('Shift')
						LOG('cpos DEBUG',cpos[1])
						cpos[1] = nil
						while not cpos[1] do
							WaitSeconds(0.1)
						end
						if flag then
							textbox:SetText('Roger. Construction is scheduled . (Shift == true) ')
						else
							textbox:SetText('Roger. Units are moving。(Shift == false) ')
						end
						SimCallback({Func = 'TheSecondConstructionPanel',Args = {id = self.correspondedID, pos = cpos[1], yes = not flag}},true)
						WaitSeconds(2)
						textbox:SetText('Silent')
					end
				)
			end			
		end
	end
}


local UI
local existed = {}



local function SetBtnTextures(ui, id)
	local location = '/icons/units/' .. id .. '_icon.dds'
	ui:IconTextures(UIFile(location, true),path)
end

local function arrayPosition(Position, existed, parent)
	if existed[1] then
		return existed[2]
	else
		local pos = {}
		for k,v in Position do
			pos[k] = parent[k][1]
		end
		pos.Height = pos.Top - pos.Bottom
		pos.Width = pos.Right - pos.Left
		existed[4] = pos.Left
		existed[1] = true
		return pos
	end
end

local function array(pos, total, Image, existed)
	if existed[3] then
		pos.Height = pos.Height / total
		pos.Width = pos.Width / total
		existed[3] = false 
	end
	local right = pos.Left + pos.Width
	local bottom = pos.Top - pos.Height
	Image.Top:Set(pos.Top) 
	Image.Bottom:Set(bottom)
	Image.Left:Set(pos.Left)
	Image.Right:Set(right)
	if right > pos.Right then
		right = existed[4]
		pos.Top = bottom
	end
	pos.Left = right
	return pos
end

local function linkup(pos, existed)
	existed[2] = pos
end

local function increasedBorder(ui, scale)
	ui.Top:Set(ui.Top[1] - scale - 15)
	ui.Left:Set(ui.Left[1] - scale + 5)
	ui.Right:Set(ui.Right[1] + scale + 20)
	ui.Bottom:Set(ui.Bottom[1] + scale + 15)
end

----parameters----
local Border = {
    tl = path .. 'mini-map_brd_ul.dds',
    tr = path .. 'mini-map_brd_ur.dds', 
    tm = path .. 'mini-map_brd_horz_um.dds',     
	ml = path .. 'mini-map_brd_vert_l.dds',
    m = path .. 'mini-map_brd_m.dds',
    mr = path .. 'mini-map_brd_vert_r.dds',
    bl = path .. 'mini-map_brd_ll.dds',
    bm = path .. 'mini-map_brd_lm.dds', 
    br = path .. 'mini-map_brd_lr.dds',
    borderColor = 'ff099950',
}
	
local Position = {
	Left = 50, 
	Top = 180, 
	Bottom = 360, 
	Right = 240
}
   
----actions----
UI = CreateWindow(GetFrame(0),'Construction',nil,false,false,false,false,'Construction',Position,Border) 
for i, v in Position do 
	UI[i]:Set(v)
end
UI.Images = {} 

UI._closeBtn.OnClick = function(control)
	for k,v in UI.Images do
		if k and v then v:Destroy() end 
	end
	local data = EntityCategoryGetUnitList(categories.TECH1 * categories.AEON) 
	local x = table.getn(data)
	x = math.sqrt(x) 
	existed[3] = true
	for c,id in data do
		UI.Images[c] = CreateButton(UI) 
		linkup(array(arrayPosition(Position,existed,UI),x,UI.Images[c],existed),existed) 
		SetBtnTextures(UI.Images[c],id) 
		UI.Images[c].correspondedID = id
	end
	increasedBorder(UI,15)
	existed = {}
end

