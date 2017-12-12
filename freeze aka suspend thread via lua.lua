-- https://msdn.microsoft.com/en-us/library/windows/desktop/ms684335(v=vs.85).aspx 
-- https://msdn.microsoft.com/en-us/library/windows/desktop/ms686769(v=vs.85).aspx 
-- https://www.hellboundhackers.org/forum/need_value_of_windows_constants_for_python-22-15957_0.html 
local THREAD_ALL_ACCESS = 0x001F03FF 
local THREAD_SUSPEND_RESUME = 0x2 
local THREAD_TERMINATE = 0x1 
-- window's OpenThread API requires 3 args, excuteCode only allows 1 so 
-- create a "stub" which calls it via a nice lua function interface :) 
local function OpenThread(access, inherit, tid) 
  -- create asm stub if not already done 
  local stub = getAddressSafe('OpenThreadStub') 
  if not stub or stub == 0 then 
    local x86script = [[ 
    alloc(OpenThreadStub,1024) 
    registerSymbol(OpenThreadStub) 
    OpenThreadStub: 
      push ebp 
      mov ebp, esp 
      mov eax, [ebp+8] 
      push [eax] 
      push [eax+4] 
      push [eax+8] 
      call OpenThread // stdcall 
      mov esp, ebp 
      pop ebp 
      ret 4 // stdcall 
    ]] 
    local x64script = [[ 
    alloc(OpenThreadStub,1024) 
    registerSymbol(OpenThreadStub) 
    OpenThreadStub: 
      push rbp 
      mov rbp, rsp 
      mov rax, rcx 
      mov r8, [rax] 
      mov rdx, [rax+4] 
      mov rcx, [rax+8] 
      sub rsp, 20 // shadowspace 
      call OpenThread 
      add rsp, 20 
      mov rsp, rbp 
      pop rbp 
      ret 
    ]] 
    local success = autoAssemble(targetIs64Bit() and x64script or x86script) 
    assert(success, "Failed to create OpenThread stub") 
  end 

  -- now write params to memory and call it 
  local params = allocateMemory(12) 
  writeInteger(params, tid) 
  writeInteger(params+4, inherit and 1 or 0) 
  writeInteger(params+8, access) 
  local res = executeCode('OpenThreadStub', params) 
  deAlloc(params) 
  return res 
end 

-- get list of thread ids from CE 
sl = createStringlist() 
getThreadList(sl) 
--print('threads', sl.Count) 

-- select the first thread id 
local tid = tonumber(sl[0], 16) 

-- open a handle to that thread via create stub 
local thandle = OpenThread(THREAD_SUSPEND_RESUME, false, tid) 
assert(thandle and thandle ~= 0, 'failed to get thread handle for tid ' .. ('%X'):format(tid)) 

-- suspend thread 
local res = executeCode('SuspendThread', thandle) 
--print(res) 
--res = executeCode('ResumeThread', thandle) 
--print(res) 
-- free handle now that we no longer need it 
executeCode('CloseHandle', thandle) 
-- free memory used for thread list 
sl.destroy() 


--[[That'll suspend the first thread (sl[0]), if the thread ID is always '1780'
then you can replace creating the string list, and filling it with
getThreadList, with just tid = tonumber('1780', 16) or tid = 6016. If it
changes each time then you'll need to get it as I did above, though in your
image it's thread 2 so you'd use sl[1] instead of sl[0]
--]]
