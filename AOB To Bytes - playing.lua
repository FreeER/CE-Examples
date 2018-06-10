function AOBToBytes(aob)
  -- convert non-hex character to * _if_ it is not a space
  local s = aob:gsub('%X', function(c) return c~=' ' and '*' or c end)
  -- replace single *s by two and remove all spaces for easy parsing
  s = s:gsub(' %* ', '**'):gsub(' ','')

  local b = {}
  for c in s:gmatch('..') do
    -- write bytes accepts numbers > 255 as wild cards
    -- with spaces removed anything that's not a hex number
    -- should be *s which should be treated as wild cards
    b[#b+1] = tonumber(c, 16) or 256
  end
  return b
end

-- serpent module does not come with CE, but it's easy to add in autorun with a simple change from return {} to serpent = {}
--[[
print(serpent.block(AOBToBytes"10 11 12 ? 14 15"))
print(serpent.block(AOBToBytes"10 11 12 ?? 14 15"))
print(serpent.block(AOBToBytes"101112??1415"))
print(serpent.block(AOBToBytes"10 11 12 z 14 15"))
print(serpent.block(AOBToBytes"101112zz1415"))
--]]
print('4f 96 02 00 08 00 1c 96 07 00 08 06 07 ?? 00 00 00 4f 96 02 00 08 00 1c 96 ?? 00 08 07')

-- print always adds newline and io.write doesn't work (stdout rather than the strings object presumably)
function printNoNewline(newstr)
  newstr = tostring(newstr)
  local lines = getLuaEngine().mOutput.lines
  local l = lines[lines.Count-1]
  -- try to account for print('') to create a new line adding spaces
  -- by removing the first two characters if the line is nothing but spaces
  -- if that's not the case go ahead and add a separating space at the end
  if not l:find('%S') then l = l:sub(3) else l = l .. ' ' end
  -- change last line to new fixed and appended line
  lines[lines.Count-1] = l .. newstr
end

print('') -- add a new line
for _,b in ipairs(AOBToBytes'4f 96 02 00 08 00 1c 96 07 00 08 06 07 ?? 00 00 00 4f 96 02 00 08 00 1c 96 ?? 00 08 07') do
  printNoNewline(b > 255 and '??' or ('%.2x'):format(b)) -- append byte to last line, with ?? for values > 255 for alignment
end
