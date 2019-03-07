local panel = MainForm.Panel5
img = createImage(panel)
img.Picture.assign(MainForm.Logo.Picture)
--img.loadImageFromFile("autorun\\logo2.png")
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
