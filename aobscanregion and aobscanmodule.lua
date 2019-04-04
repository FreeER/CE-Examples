--https://forum.cheatengine.org/viewtopic.php?p=5747559#5747559
--[[ SETUP ]]-- 
function AOBScanAA(script) 
  local success,disableInfo = autoAssemble(script) 
  if not success then return nil, disableInfo end -- disableInfo is error message on failure 
  local addr = getAddress('luaAOBScanRegionSymbol') 
  autoAssemble(script, disableInfo) -- disable script and unregister symbol 
  return addr, 'success' 
end 

function AOBScanRegion(bytestr, start, stop) 
  local script = ([[ 
  [ENABLE] 
  aobscanregion(luaAOBScanRegionSymbol,%X,%X,%s) 
  registersymbol(luaAOBScanRegionSymbol) 
  [DISABLE] 
  unregistersymbol(luaAOBScanRegionSymbol) 
  ]]):format(getAddress(start), getAddress(stop), bytestr) 
  return AOBScanAA(script) 
end 

function AOBScanModule(bytestr, module) 
  local script = ([[ 
  [ENABLE] 
  aobscanmodule(luaAOBScanRegionSymbol,%s,%s) 
  registersymbol(luaAOBScanRegionSymbol) 
  [DISABLE] 
  unregistersymbol(luaAOBScanRegionSymbol) 
  ]]):format(module, bytestr) 
  return AOBScanAA(script) 
end 

--[[ TESTING ]]-- 

-- Tutorial step 1 load 
--local addr,msg = AOBScanRegion('8B 83 80040000', 0x00423000, 0x00424000) 
local addr,msg = AOBScanModule('8B 83 80040000', process) 

if addr then 
  print('0x%X'):format(addr) 
else 
  print(msg)
end 
