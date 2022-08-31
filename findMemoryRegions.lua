local function getMemoryRegionForm()
  if not process then error('must be attached!', 2) end
  local mf = getMemoryViewForm()
  if mf.formMemoryRegions then return mf.formMemoryRegions
  else
    mf.MemoryRegions1.doClick()
    mf.formMemoryRegions.hide()
    return mf.formMemoryRegions
  end
end

local function getMemoryRegionList()
  local hf = getMemoryRegionForm()
  local list = hf.ListView1.Items
  local tbl = {}
  for i=0,list.Count-1 do
    local e = list[i]
    local si = e.SubItems
    local info = {addr=e.Caption,perms=si[0],state=si[1],protect=si[2],type=si[3],size=si[4],extra=si[5]}
    tbl[#tbl+1] = info  end
  --tbl.n = n
  --setmetatable(tbl, {__len = function(t) return t.n end})
  return tbl, list.Count
end

local list = getMemoryRegionList()
local private = {}
for k,v in ipairs(list) do
  if v.type == 'Private' then
    private[#private+1] = v
  end
end

-- print 3rd
local function select(tbl,n)
  if n == 1 then n = nil end
  local k,v = next(tbl,n-1)
  return v
end

local info = select(private,3)
if serpent then
  print(serpent.block(info))
else
  print(info.addr,info.size)
end

