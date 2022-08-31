-- hard coded dynamic addresses for tutorial step 9 during testing. 
local addresses = {players={'016C32DC','08FD007C'},enemies={'08FF686C','09010084'}} 

local sf = createStructureForm(addresses.players[1],'players group','PlayerStruct') 
local players = sf.Group[0] 
for i=2, #addresses.players do -- add rest (other) players 
  players.addColumn().AddressText = addresses.players[i] 
end 

local enemies = sf.addGroup() 
enemies.name = 'enemies group' 
for k,addr in ipairs(addresses.enemies) do -- add all enemies 
  enemies.addColumn().AddressText = addr 
end
