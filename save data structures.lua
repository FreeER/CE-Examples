-- http://forum.cheatengine.org/viewtopic.php?p=5732108#5732108
--[[
It'll ask for a file to save the memory to, the address of the memory to copy and the size. Then you change the save variable to false and run it again and it'll ask you to reopen the file and it'll print the address it allocated and copied the values to. Note that the values are in hex (you can use symbols for the address or pretty much whatever else CE allows since it's using a CE function to parse it) and sizes are in hex. Note that the size of the struct is the last offset + the size of the last element, so if the last element is a pointer at offset 28 then the size is either 2C for 32 bit or 30 for 64 bit (you can just use 30 and copy an extra 4 bytes in the case of x86). 

Once you've reloaded the values you can use the structure dissect filter extension (CEEnhancer) to filter out what's changed (or what hasn't).
]]
local save = true 
if save then 
  local od = createSaveDialog() 
  od.DefaultExt = 'mem' 
  od.Filter = 'Mem (*.mem)|*.MEM' 
  od.InitialDir = os.getenv("userprofile") .. "\\Desktop" 
  local cancled = not od.Execute() 
  local FileName = od.FileName 
  od.destroy() 
  if cancled then return end 

  local addr = getAddressSafe(inputQuery('Address','Address','')) 
  if not addr then print('canceling'); return end 
  local size = tonumber(inputQuery('size','size',''),16) 
  if not size then print('canceling'); return end 

  local written = writeRegionToFile(FileName, addr, size) 
  if written ~= size then 
    print(("Warning: Write was incomplete! Asked for 0x%X wrote 0x%X."):format(size, written)) 
  end 
else 
  local od = createOpenDialog() 
  od.Filter = 'Mem (*.mem)|*.MEM|All (*.*)|*.*' 
  od.InitialDir = os.getenv("userprofile") .. "\\Desktop" 
  local cancled = not od.Execute() 
  local FileName = od.FileName 
  od.destroy() 
  if cancled then return end 

  local file = io.open(FileName) 
  if not file then print("Failed to open file"); return end 
  local size = file:seek("end")    -- get file size 
  file:close() 

  local mem = allocateMemory(size) 
  if not mem then print('Failed to allocate memory'); return end 

  local read = readRegionFromFile(FileName, mem) 
  print(("Loaded 0x%X bytes into %x"):format(read,mem)) 
  if read ~= size then 
    print(("Warning: incorrect read, filesize is 0x%X but read 0x%X"):format(size, read)) 
  end 
end 
