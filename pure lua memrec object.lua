-- note written purely for fun/education lol
-- prompted by someone asking how to use AA scripts with encodeFunction

-- the logical way!
--[[
  mr = AddressList.createMemoryRecord()
  mr.Type = vtAutoAssembler
  mr.Script = [=[
    [ENABLE]
    [DISABLE]
  ]=]
  local function getHotkeyValueForCharacter(character) return character:upper():byte(1) end
  mr.createHotkey({VK_F3}, mrhActivate)
  mr.createHotkey({getHotkeyValueForCharacter('l')}, mrhDeactivate)
  mr.createHotkey({getHotkeyValueForCharacter('3'), getHotkeyValueForCharacter('P')}, mrhToggleActivation)
  -- mr hotkeys still do not have any given enable/disable functionality...
  return mr
]]

-- The FUN way! lol
-- library/module code
local AAScriptFactoryMetaTable = {}
AAScriptFactoryMetaTable.__index = AAScriptFactoryMetaTable
AAScriptFactoryMetaTable.enable = function(self)
  local success, extra = autoAssemble(self.script)
  if not success then return false, extra end
  self.enabled = true
  self.disableInfo = extra
  return true, self.disableInfo
end
AAScriptFactoryMetaTable.disable = function(self)
  if not self.enabled then
    return true, 'not enabled'
  elseif not self.shouldHaveDisableInfo then
    return nil, 'script did not have disable section, can not disable!'
  elseif not self.disableInfo then
    return false, 'disable info missing... could not disable'
  end
  local success, errorMsg = autoAssemble(self.script, self.disableInfo)
  if not success then return false, errorMsg end
  self.enabled = false
  self.disableInfo = nil
  return true, 'disabled successfully'
end
AAScriptFactoryMetaTable.toggle = function(self)
  if self.enabled then return self:disable() else return self:enable() end
end
AAScriptFactoryMetaTable.disableHotkey = function(self, index)
  local hkinfo
  if type(index) == 'number' then
    hkinfo = self.hotkeys[index]
  elseif type(index) == 'table' then
    for k,v in pairs(self.hotkeys) do
      if v.thefunction == index.thefunction then
        hkinfo = v
        break
      end
    end
  end
  if not hkinfo then return nil end
  -- hotkeys do not have an enabled/disabled property so remove keys to disable
  hkinfo.hk.setKeys{}
end
AAScriptFactoryMetaTable.enableHotkey = function(self, index)
  local hkinfo
  if type(index) == 'number' then
    hkinfo = self.hotkeys[index]
  elseif type(index) == 'table' then
    for k,v in pairs(self.hotkeys) do
      if v.thefunction == index.thefunction then
        hkinfo = v
        break
      end
    end
  end
  if not hkinfo then return nil end
  hkinfo.hk.setKeys(unpack(hkinfo.keys)) -- reset keys to enable
  return true
end
AAScriptFactoryMetaTable.enableAllHotkeys = function(self, index)
  for k,v in pairs(self.hotkeys) do self:enableHotkey(k) end
end
AAScriptFactoryMetaTable.disableAllHotkeys = function(self, index)
  for k,v in pairs(self.hotkeys) do self:disableHotkey(k) end
end
AAScriptFactoryMetaTable.addHotkey = function(self, hotkeyInfo)
  if not type(hotkeyInfo) == 'table' or not type(hotkeyInfo[1]) == 'function' then
    return false, "invalid hotkey info {function, keys...}"
  end
  local hk = createHotkey(unpack(hotkeyInfo))
  if not hk then return false, 'failed to create hotkey' end
  local hki = {}
  hki.hk = hk
  hki.thefunction = hotkeyInfo[1]
  if type(hotkeyInfo[2]) == 'table' then
    hki.keys = hotkeyInfo[2]
  else
    table.remove(hotkeyInfo,1)
    hki.keys = hotkeyInfo
  end
  table.insert(self.hotkeys, hki)
  return #self.hotkeys
end
-- TODO (improvement) make hotkey an object so it's more contained (and add enabled property)

local function AAScriptFactory(script, ...)
  local aa = {}
  setmetatable(aa, AAScriptFactoryMetaTable)
  aa.script = script
  aa.hotkeys = {}
  aa.enabled = false
  aa.disableInfo = nil
  local function checkForDisable(scriptString)
    -- TODO (potential optimization) check if simply lowercasing the full script and find [disable] is faster
    local lines = scriptString:gmatch('[^\r\n]+')
    for line in lines do print(line) if line:lower():match('%s*%[disable%]') then return true end end
    return false
  end
  aa.shouldHaveDisableInfo = checkForDisable(script)

  local args = {...}
  print(tostring('args'), tostring(args), #args)
  for k,v in pairs(args) do aa:addHotkey(v) end
  return aa
end
-- if actually used as a module then return table of stuff that should be accessible
--return {['AAScriptFactory']=AAScriptFactory}

-- usage code
--AAScriptFactory = require('modulename')['AAScriptFactory'] -- require module
-- ^ atypical require, but I don't wannt to actually prefix the function below
-- and it's the only thing actually exported by the module so...
local myscript
myscript = (function()
  local aaScript = [[
  [ENABLE]
  [DISABLE]
  ]]
  local function getHotkeyValueForCharacter(character) return character:upper():byte(1) end
  local hotkeys = {
    {function(hk) print('enabling') myscript:enable() end, VK_F3},
    {function(hk) print('disabling') myscript:disable() end, getHotkeyValueForCharacter('l')},
    {function(hk)
      print('toggling')
      myscript:toggle()
      print(tostring(myscript.enabled))
    end, {getHotkeyValueForCharacter('3'), getHotkeyValueForCharacter('P')}},
  }
  return AAScriptFactory(aaScript, unpack(hotkeys))
end)()
return myscript
