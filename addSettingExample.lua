-- Simplified Setting Page example based on 
-- https://github.com/cheat-engine/cheat-engine/blob/master/Cheat%20Engine/bin/autorun/bigendian.lua

-- Constants
local CustomFormName    = 'FreeERSettings' -- do not translate
local CustomFormCaption = 'FreeER' -- can be translated, is passed to translate function

-- get settings
local sf = getSettingsForm()

-- try to find your custom page incase multiple scripts use it
local CustomTypesPage = nil
for i = 0, sf.SettingsPageControl.PageCount-1 do
  if sf.SettingsPageControl.Page[i].Name == CustomFormName then
    CustomTypesPage = s.SettingsPageControl.Page[i]
  end
end

-- if it wasn't found then this is the first script that cares so add it
if CustomTypesPage == nil then
  -- create new tab/page and set name and caption
  CustomTypesPage = sf.SettingsPageControl.addTab()
  CustomTypesPage.Name = CustomFormName
  CustomTypesPage.Caption = translate(CustomFormCaption)

  -- insert near the 4th (0 based) setting tab, default would be the unrandomizer
  local insertNode = sf.SettingsTreeView.Items[3]
  local node = sf.SettingsTreeView.Items.insert(insertNode, CustomTypesPage.Caption)
  -- used to determine what to display apparently... without it set the page doesn't change
  node.data = userDataToInteger(CustomTypesPage)

  local checkboxes = createPanel(CustomTypesPage)
  checkboxes.Align = 'alTop'
  checkboxes.Name  = 'Checkboxes'

  local other = createPanel(CustomTypesPage)
  other.Align = 'alTop'
  other.Name  = 'Other'

  -- I don't know how to autoposition stuff and I don't want to manually do so right now...
  -- so, yeah this looks terrible.

  -- apparently this exists and is a listbox where each item is a checkbox
  local clb = createCheckListBox(checkboxes)
  clb.Align = 'alTop'
  clb.Name  = 'List'
  clb.Items.add('example')

  local cb = createComboBox(other)
  cb.Align = 'alTop'
  cb.Name  = 'ComboBox'
  cb.Items.add('combo 1')
  cb.Items.add('combo 2')

  local lbl   = createLabel(other)
  lbl.Align   = 'alBottom'
  lbl.Name    = 'Label'
  lbl.Caption = 'This is MyLabel'

  local edit   = createEdit(other)
  edit.Name    = 'EditBox'
  edit.Align   = 'alBottom'
  edit.Text    = 'You can edit me!'
  edit.Caption = 'something'
end

-- access via .name
local list = CustomTypesPage.Checkboxes.List
-- if using same comboboxes etc. and just adding options then they'd be added here.
list.Items.add('example2')

-- add some code to run when settings are closed
local oldOnClose = sf.OnClose
sf.OnClose = function(sender)
  -- run original handler
  local result = caHide
  if oldOnClose ~= nil then
    result = oldOnClose(sender)
  end
  -- if closing and saving then do whatever with the potentially new settings
  if (result == caHide) and (sender.ModalResult == mrOK) then
    -- print checkbox state from checkboxlist, no way to get captions as of 4/20 afaik
    for i = 0, list.Items.Count-1 do print('Checkbox', i, tostring(list.Checked[i])) end
    
    -- recreate local variable from names because scope
    local cb = CustomTypesPage.Other.ComboBox
    local i  = cb.ItemIndex
    -- index is -1 if nothing was selected
    if i >= 0 then print(cb.Items[i]) else print('No combo item selected') end

    print(CustomTypesPage.Other.EditBox.Text)
  end
  return result
end
