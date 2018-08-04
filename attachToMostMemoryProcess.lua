local function getMemory(procname)
  local cmd = ('tasklist /FI "IMAGENAME eq %s" /NH'):format(procname)
  local h = io.popen(cmd)
  local res = h:read('*a')
  h:close()

  local list = {}
  local factorTable = {M=1024*1024,K=1024,G=1024*1024*1024,B=1}
  for info in res:gmatch('[^\n]+') do
    local pid, mem = info:match('.+%s(%d+)%s+.+%s+%d+%s+(.+)')
    local pid = tonumber(pid)
    local mfactor = factorTable[mem:sub(-1)] or 1
    local num = mem:sub(1,-2):gsub(',', '')
    local nmem = tonumber(num) * mfactor / 1024
    list[pid] = nmem
  end
  return list
end

local function findmax(list)
  local maxPID, maxMem = 0, 0
  for pid, mem in pairs(list) do
    if mem > maxMem then
      maxMem = mem
      maxPID = pid
    end
  end
  return maxPID, maxMem
end

openProcess(findmax(getMemory('chrome.exe')))
