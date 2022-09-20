----directory----
local path = '/mods/SupremeWarfare4k/Contents/UI/TheSecondConstruction_UICreatedAfterHook/'

----significant operators imported from external sources----
local CreateText = import('/lua/maui/text.lua').Text 

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
	Left = 450, 
	Top = 60, 
	Bottom = 200,
	Right = 1500
}
   
----actions----
Text = CreateText(GetFrame(0))
for k,v in Position do
	Text[k]:Set(v)
end
Text:SetFont('Arial',20) --Oh well . You must have font and larger depth otherwise text would not come out
Text:SetColor('ffFFFFFF')
Text:SetText('Silent')
--('To play with this mod , you should keep in mind the followings : \n 1. Click the close button to get the unit list . \n 2.Select a number of engineers/ACU/SACUs to get the access to the construction queue . \n 3.Press Shift and then click an icon to add a building-command to the current queue . \n 4.Simply clicking the icon will stop the engineers from any current activities and force them to execute the building-command \n 5.Eventually , you should choose and right click a spare place')
Text.Depth:Set(30)