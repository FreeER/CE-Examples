--##### Conversion Calculator Lua Script for Cheat Engine
--##### Author: FreeER (based on https://github.com/cheat-engine/cheat-engine/issues/243 by rcg4u)
--##### Github: https://github.com/FreeER
--##### Website: https://www.facebook.com/groups/CheatTheGame
--##### YouTube: https://www.youtube.com/channel/UCLy60mbqc3rSvh42jkpCDxw

-- START OF USER CONFIG --
local useGroupMenu = true
-- END OF CONFIG --

-- START OF EXT TEMPLATE CONFIG --
local extGroupMenuCaption = 'FreeER\'s Extensions'
local extItemCaption = 'Conversion Calculator'
local requiredVersion = 6.4 -- requirement for inputQuery
-- START OF EXT TEMPLATE CONFIG --

if getCEVersion() < requiredVersion then
    error(("%s requires CE >= %d, update CE!"):format(extItemCaption, requiredVersion))
end

-- menu code --
local mf = getMainForm()
local mm = mf.Menu
local extMenu = nil

if useGroupMenu then
  -- look for existing group menu
  for i=0,mm.Items.Count-1 do
      if mm.Items.Item[i].Caption == extGroupMenuCaption then
          extMenu = mm.Items.Item[i]
          break
      end
  end
  if not extMenu then -- not found so create it
      extMenu = createMenuItem(mm)
      extMenu.Caption = extGroupMenuCaption
      mm.Items.add(extMenu)
  end
else
  extMenu = mm.Items
end

local extMenuItem = createMenuItem(extMenu)
extMenuItem.Caption = extItemCaption
extMenu.add(extMenuItem)
-- menu code --

local function saveDissectCode(dc)
  local fd = createSaveDialog(nil)
  fd.Filter = 'DisectCode|*.DC|All Files|*.*'
  local picked = fd.Execute()
  if not picked then return false end
  dc.saveToFile(fd.FileName)
  fd.destroy()
end

local function loadDissectCode(dc)
  local fd = createOpenDialog(nil)
  fd.Filter = 'DisectCode|*.DC|All Files|*.*'
  local picked = fd.Execute()
  if not picked then return false end
  dc.loadFromFile(fd.FileName)
  fd.destroy()
end

local conversionForm = createForm(false)
conversionForm.onClose = function(sender)
  -- not sure if sender is form or the x button...
  conversionForm.hide()
end

local mainLabel = createLabel(conversionForm)
mainLabel.Caption = 'Value'
local mainEdit = createEdit(conversionForm)
mainEdit.Top = mainLabel.Top + mainLabel.Height + 5

local hex=1
local signed=2
local unsigned=3
local octal=4
local binary=5
local ascii=6
local unicode=7
local num = unicode

local editBoxes = {}
local peb = mainEdit
for i=1,num do
  local eb = createEdit(conversionForm)
  eb.Top = peb.Top + peb.Height + 5
  eb.Width = conversionForm.Width
  editBoxes[i] = eb
  peb = eb
end
conversionForm.Height = peb.Top + peb.Height

local function toBits(num,bits)
    -- returns a table of bits, most significant first.
    bits = bits or math.max(1, select(2, math.frexp(num)))
    local t = {} -- will contain the bits        
    for b = bits, 1, -1 do
        t[b] = math.fmod(num, 2)
        num = math.floor((num - t[b]) / 2)
    end
    return t
end

mainEdit.OnChange = function()
  local num = tonumber(mainEdit.Text)

  local memstream = createMemoryStream()
  memstream.write(dwordToByteTable(num))
  local mem = memstream.Memory
  print(mem, '-', readIntegerLocal(mem)) -- duh!
  -- hm.... not working as I'd hoped.

  editBoxes[hex].Text = num and ('%X'):format(num) or 'invalid'
  editBoxes[signed].Text = tostring(readIntegerLocal(mem, true))
  editBoxes[unsigned].Text = tostring(readIntegerLocal(mem, not true))
  editBoxes[octal].Text = ('%o'):format(num) or 'invalid' -- might only be lowercase o
  local bits = toBits(num, 32)
  bits = table.concat(bits) -- keep forgetting concat doesn't take a separator in lua...
  editBoxes[binary].Text = bits:gsub('(%d%d%d%d)', '%1 ')

  editBoxes[ascii].Text = readStringLocal(mem, 10)
  editBoxes[unicode].Text = readStringLocal(mem, 10, true)
  memstream.destroy()
end

extMenuItem.OnClick = function()
  conversionForm.show()
end
