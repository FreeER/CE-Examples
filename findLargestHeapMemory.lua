local function getHeapForm()
  if not process then error('must be attached!', 2) end
  local mf = getMemoryViewForm()
  if mf.frmHeaps then return mf.frmHeaps
  else
    mf.Heaps1.doClick()
    mf.frmHeaps.hide()
    return mf.frmHeaps
  end
end

local function getHeapList()
  local hf = getHeapForm()
  local list = hf.ListView1.Items
  local tbl = {}
  for i=0,list.Count-1 do
    local addr, size = tonumber(list[i].Caption,16), tonumber(list[i].SubItems.Text)
    tbl[addr] = size
  end
  --tbl.n = n
  --setmetatable(tbl, {__len = function(t) return t.n end})
  return tbl, list.Count
end

local list,len = getHeapList()
local a,ms = 0,0
for addr, size in pairs(list) do
  if size > ms then ms,a = size,addr end
end

local function tohex(n) return ('%X'):format(n) end

print(tohex(a),ms,tohex(a+ms))

