--[[ 
  --https://forum.cheatengine.org/viewtopic.php?p=5741165#5741165
  --edit: note untested. so probably typos and other really obviously wrong errors lol 
  required: instr, outstr 
  config is a table of optional options :) 
  optional: ok (ignore length), wide (wide strings), syntaxcheck (only scan for bytes and do length check), 
    select (nil=first, -1 = all, otherwise index) 
    size (nil, 1=pre, 2=post, or address) 
    protectionflags, alignmenttype, alignmentparam (see AOBScan for details) 
]] 
function replaceString(instr, outstr, config) 
  if not instr or not outstr or type(instr) ~= 'string' or type(outstr) ~= 'string' then 
    error('replaceString: need two strings!',2) 
  end 
  config = config or {} 
  if not config.ok and #outstr > #instr then 
    error('replaceString: new string is longer than original!', 2) 
  end 
  
  local inbytes = (config.wide and wideStringToByteTable or stringToByteTable)(instr) 
  local inaob = {} -- AOBScan has no overload for byte table... 
  for _,byte in ipairs(inbytes) do inaob[#inaob+1] = ('%x'):format(byte) end 
  inaob = table.concat(inaob, ' ') 
  local protectionflags = config.protectionflags or '' 
  local alignmenttype = config.alignmenttype or 0 
  local alignmentparam = config.alignmentparam 
  local res = AOBScan(inaob, protectionflags, alignmenttype, alignmentparam) 
  if not res then error('replaceStr: no results found for ' .. instr, 2) end 
  if syntaxcheck then res.destroy(); return end 
  
  local outbytes = (config.wide and wideStringToByteTable or stringToByteTable)(outstr) 
  local function handlesize(addr) 
    if config.size == nil then return end 
    local address = GetAddressSafe(addr) 
    local size = #outstr * (config.wide and 2 or 1) 
    if not address then error('replaceString: got invalid address to write size at', 2) 
    elseif config.size == 1 then writeDword(address-4, size) 
    elseif config.size == 2 then writeDword(address+size, size) 
    else writeDword(config.size, size) end 
  end 
  if config.select == nil then 
    writeBytes(res[0], outbytes) 
    handlesize(res[0]) 
 elseif config.select > -1 then 
    if res.Count < config.select then error('replaceStr: index out of range! Found results: ' .. res.Count) end 
    writeBytes(res[config.select], outbytes) 
    handlesize(res[config.select]) 
  else 
    for i=0,res.Count-1 do 
      writeBytes(res[i], outbytes) 
      handlesize(res[i]) 
    end 
  end 
  res.destroy() 
end
