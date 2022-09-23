----
----
----
----
----
----
----
----
---- 
----
Callbacks.TheSecondConstructionPanel = function(data, units)
	if data.yes then
		IssueClearCommands(units)
	end
	local id = data.id
	local clicklocationtemp = data.pos 
	for k,v in units do
		IssueBuildMobile({v},clicklocationtemp,id,{})  
		--Thank you for expanding my brain XD --Although it looks like they're going to build units for each individual of them , in fact the buildings at the same location would be calculated as a single one , and thus they're synced in co-constructing
	end
end