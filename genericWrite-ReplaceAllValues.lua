--[[
  Generic function to write a value to unknown variable type
  address - address to write to
  value   - value to write
  vt      - value type as vt* define (vtDword, vtSingle, etc.)
]]
function writeValue(address, value, vt)
  -- handle not having required arguments
  if not address or not value or not vt then return nil end
  local types = {
    [vtByte] = writeBytes,
    -- *smallInteger added in CE 6.7
    [vtWord] = writeSmallInteger or function(address, value) writeBytes(address, wordToByteTable(value)) end,
    [vtDword] = writeInteger,
    [vtQword] = writeQword,
    [vtSingle] = writeFloat,
    [vtDouble] = writeDouble,
    -- unsupported, require custom functions for one reason or another
    --[vtString]
    --[vtByteArray]
    --[vtGrouped],
    --[vtBinary],
  }
  local sizes = {
    [vtByte] = 1,
    [vtWord] = 2,
    [vtDword] = 4,
    [vtQword] = 8,
    [vtSingle] = 4,
    [vtDouble] = 8
  }
  local writeFunction = types[vt];
  if not writeFunction then return nil end
  local res = writeFunction(address, value)
  if res then return res end
  --[[
    if failed try making it writable and try again, unfortunately fullAccess will also make it executable as well...
    which can require the protectionflags to change to find it a second time... but to only make it writable
    would require creating a way to call VirtualProtect from lua, not particularly hard but.... maybe a little
    beyond the scope of this example, basically you'd use autoAssemble to setup a function which would take
    a pointer to the arguments in memory and call VirtualProect properly (of course, you'd need one for x86 and one for x64)
    and then have a lua function that would take the arguments, write them to some memory and use executeCode to
    call the assembled VirtualProect wrapper function with the address of that memory
  ]]
  fullAccess(address, sizes[vt])
  return writeFunction(address, value)
end


--[[
  function to scan for a value and replace all found instances of it
  findValue    - the value to find
  replaceValue - the value to replace the findValue with
  [findType]   - the value type of the value to find and write, defaults to 4 bytes / vtDword
  [protectionflags] - string to describe the type of memory to scan, options are
    W - writable, X - executable, C - copy on write, prefixed with
    + for required, - for not allowed, or * for ignored (same as not providing one)
    defaults to writable, non-executable, non-copy-on-write = "+W-X-C"
  [rounding] - rounding type, one of (in order of least values matched to most):
    rtRounded, rtExtremerounded, rtTruncated
    default: rtRounded
]]
function findValueAndReplace(findValue, replaceValue, findType, protectionflags, rounding)
  -- handle not having required arguments
  if not findValue or not replaceValue then return nil end
  -- default values
  findType = findType or vtDword
  protectionflags = protectionflags or "+W-X-C"
  rounding = rounding or rtRounded -- rtRounded is the most restrictive.

  -- do scan
  memscan = createMemScan()
  memscan.firstScan(soExactValue, findType, rounding, findValue, nil,
               "0", "7fffffffffffffff", protectionflags,
               fsmAligned,"4", false, false, false, false)
  memscan.OnScanDone = function(memscan)
    print('scan done')
    foundlist = createFoundList(memscan)
    foundlist.initialize()
    print(foundlist.Count)
    for i=0,foundlist.Count-1 do
      print('writing to', foundlist.Address[i])
      writeValue(foundlist.Address[i], replaceValue, findType)
    end
    sleep(50) -- not certain these are necessary but
    foundlist.deinitialize()
    foundlist.destroy()
    sleep(50) -- not certain these are necessary but
    memscan.destroy()
  end
  memscan.waitTillDone()
end
