-- img paths, imgs not included
local bottomimg = 'autorun/cheat3.png'
local sideimg = 'autorun/logo2.png'
local iconimg = 'autorun/logo2.png'

--[[ application icon ]]
local ico = createPicture()
ico.loadFromFile(iconimg)
MainForm.Icon = ico.Icon

--[[ bottom between advanced options and table extras ]]
img = createImage(MainForm.Panel4)
img.Align = alClient
img.Stretch = true
-- default to CE logo in case path doesn't exist it still shows something
img.Picture.assign(MainForm.Logo.Picture)
img.Picture.Height = MainForm.Panel4.Height
img.Picture.Width = MainForm.Panel4.Width
--load from file on your computer
img.loadImageFromFile(bottomimg)

--[[ right near add address manually button ]]
local panel = MainForm.Panel5
img = createImage(panel)
-- default to CE logo in case path doesn't exist it still shows something
img.Picture.assign(MainForm.Logo.Picture)
img.loadImageFromFile(sideimg)
img.Align   = alNone
img.Stretch = true
img.Anchors = '[akRight,akBottom]'
img.AnchorSideRight.Control  = img.Parent
img.AnchorSideRight.Side     = asrRight
img.AnchorSideBottom.Control = MainForm.btnAddAddressManually
img.AnchorSideBottom.Side    = asrBottom
img.BorderSpacing.Around     = 5

-- try to determine how much space is actually there and fit in it
local t    = createTimer()
t.Interval = 100
t.OnTimer  = function(t)
  local p     = MainForm.Panel8 -- alignment/lastdigits
  local minx  = p.clientToScreen(p.ClientWidth+15, 0)
  local maxx  = MainForm.clientToScreen(MainForm.ClientWidth, 0)
  local width = maxx - minx
  if not width then return end -- gui probably isn't visible yet so just wait
  img.Width   = width
  t.destroy() -- and done
end

