-- print(package.path)
-- will include ...\My Cheat Tables\*.lua
-- as well as TrainerOrigin\*.lua (if trainerorigin is set, ie. trainer or launched from CT)

-- http://lua-users.org/wiki/ModulesTutorial
local function private()
    print("in private function")
end

local function foo()
    print("Hello World!")
end

local function bar()
    private()
    foo() -- do not prefix function call with module
end

return {
  foo = foo,
  bar = bar,
}
