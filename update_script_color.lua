-- autorun script to cause all enabled scripts text colors to turn green and disabled scripts to turn black
old_mrpe = onMemRecPostExecute
ON_COLOR = 0xAF00
OFF_COLOR = -1

local function updateColor(mr,state,success) if success then mr.Color = state and ON_COLOR or OFF_COLOR end end

function onMemRecPostExecute(mr, state, success)
  updateColor(mr,state,success)
  if old_mrpe then return old_mrpe(mr,state,success) else return true end
end
for i=0,AddressList.Count-1 do
  local mr = AddressList[i]
  if mr.Type == vtAutoAssembler then updateColor(mr, mr.Active, true) end
end

