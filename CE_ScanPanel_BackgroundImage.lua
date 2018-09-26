img = createImage(MainForm.Panel5)
img.Width = MainForm.Panel5.Width
img.Height = MainForm.Panel5.Height
img.Stretch = true
-- test with CE logo
img.Picture.assign(MainForm.Logo.Picture)

-- load from file on your computer
img.loadImageFromFile("C:\\Users\\HJP19\\Pictures\\random pics\\_a855a16b774c4bd4_fda79c2a36a1f0ee.jpg")
