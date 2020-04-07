-- https://github.com/moteus/lua-path/blob/master/lua/path.lua
function splitpath(P) if P then return string.match(P,"^(.-)[\\/]?([^\\/]*)$") end end
function basename(P) return P and select(2,splitpath(P)) end
function dirname(P) return P and splitpath(P) end

-- Modified from EXOR's code
local sd = MainForm.SaveDialog1
local od = MainForm.OpenDialog1
-- backup potential OnClose events so they can be called
-- we'll overright the current one later with our own
local OrigOnClose = {[sd] = sd.OnClose, [od] = od.OnClose}
-- pick the last opened file but if there isn't one try to fall back to last saved
function getPath() return od.Filename or sd.Filename end

-- timer to try and wait until table has been loaded... this can fail
-- eg. when you open a second table in CE and get the merge prompt
-- it will take longer for the user to pick yes/no and the default
-- 500 milliseconds checks the name before that happens and it loads
-- the new table and thus does not properly detect the possible name change
currentTableNameTimer = createTimer(mf)
currentTableNameTimer.Interval = 500
currentTableNameTimer.OnTimer = function (t)
  t.Enabled = false -- disable so it only runs once, but with the Interval delay
  local name = basename(getPath())
  print('current name is: ', name)
  -- potentially set global variable or call some other function etc.
end
-- function to enable timer so that the name is checked after a delay
function OnClose(sender)
  if OrigOnClose[sender] then origOnClose[sender]() end
  currentTableNameTimer.Enabled = true
end

sd.OnClose = OnClose
od.OnClose = OnClose



