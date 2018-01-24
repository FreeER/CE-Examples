--from DB, incomplete
--https://pastebin.com/raw/NcPUe4XL
stdcallstub=nil

function initCallStub()
  --callstub is a function that takes a parameter containing the function to call and
  local ok, di
  stdcallstub=nil

  if targetIs64Bit() then
    ok, di=autoAssemble([[
alloc(callstub,4096)
callstub:
  //rcx contains the parameter pointer
  push rsi
  push rdi

  push rbp
  mov rbp,esp // F: rsp?



  mov r11,20 //this register will hold the parameter bytes needed (min 32)

  mov eax,[rcx+8] //parametercount (4 bytes)
  cmp eax,4
  ja short notmore
  sub rax,4
  mov r11,[rax*4+20] // F: lea?
notmore:
  sub rsp,r11
  mov rbp,rsp

  mov rax,rcx

  //setup the parameters

  lea rsi,[rax+c] //start of the parameter values. First 4 aren't really needed, but fuck it
  mov rdi,rbp
  mov r10,[rax+8] //paramcount
  mov ecx,r10

  db 48 //increase to 64-bit (6.7 is missing movsq)
  movsd //move paramcount*8 bytes from rsi to rdi

  //rsi now points at the parametertype list

  //now setup the first 4 registers
  //rcx,rdx,r8,r9

  cmp r10,1
  jb nomoreparams

  //set param1
  lea rdi,[rax+c] //rdi gets the param1 address
  mov rcx,[rdi] //param1 as int (just because)

  cmp byte [rsi],1 //float
  je short floatvalue1

  cmp byte [rsi],2 //double
  je short doublevalue1

  //else
  jmp short donevalue1

floatvalue1:
  movss xmm0,[rdi]
  jmp short donevalue1

doublevalue1:
  movsd xmm0,[rdi]

donevalue1:
  cmp r10,2
  jb short nomoreparams

  //set param2
  add rsi,1 //next paramtype (1 byte each)
  lea rdi,[rax+14] //rdi gets the param2 address
  mov rdx,[rdi]
  cmp byte [rsi],1 //float
  je short floatvalue2

  cmp byte [rsi],2 //double
  je short doublevalue2
  jmp short donevalue2

floatvalue2:
  movss xmm1,[rdi]
  jmp short donevalue2

doublevalue2:
  movsd xmm1,[rdi]

donevalue2:
  cmp r10,3
  jb short nomoreparams

  //set param3
  add rsi,1 //next paramtype (1 byte each)
  lea rdi,[rax+1c] //rdi gets the param3 address
  mov r8,[rdi]
  cmp byte [rsi],1 //float
  je short floatvalue3

  cmp byte [rsi],2 //double
  je short doublevalue3
  jmp short donevalue3

floatvalue3:
  movss xmm2,[rdi]
  jmp short donevalue3

doublevalue3:
  movsd xmm3,[rdi]

donevalue3:
  cmp r10,4
  jb short nomoreparams

  //set param4
  add rsi,1 //next paramtype (1 byte each)
  lea rdi,[rax+24] //rdi gets the param4 address
  mov rdx,[rdi]
  cmp byte [rsi],1 //float
  je short floatvalue4

  cmp byte [rsi],2 //double
  je short doublevalue4
  jmp short donevalue4

floatvalue4:
  movss xmm3,[rdi]
  jmp short donevalue4

doublevalue4:
  movsd xmm3,[rdi]

donevalue4:

nomoreparams:

  call [rax]

  mov rsp,rbp
  pop rbp
  pop rdi
  pop rsi
  ret
]])
    else
      ok, di=autoAssemble([[
alloc(callstub,4096)
callstub:
  push esi
  push edi
  push ebp
  mov ebp,esp

  mov eax,[ebp+4]
  mov ecx,[eax+4] //parametercount

  lea edx,[ecx*4] //the size the parameters take up in bytes
  sub esp,edx

  mov edi,esp
  lea esi,[eax+8] //start of the parameters
  rep movsd //copy ECX times 4 bytes

  call [eax] //eax+0 contains the function to call

  pop ebp
  pop edi
  pop esi
  ret 4 //ret 4 as the stub itself is called as a stdcall with 1 parameter
]])
  end

  if ok then
    stdcallstub={}
    stdcallstub.processid=getOpenedProcessID()
    stdcallstub.address=di.allocs.callstub.address
  end
end

function _executeStdCallCode(floattype,chartype, address, ...)
  local arg=table.pack(...)

  local varcount=arg.n

  if (stdcallstub==nil) or (stdcallstub.processid~=getOpenedProcessID()) then
    initCallStub()
  end

  if (stdcallstub==nil) then error('Failed to create stub') end

  --allocate space for the parameters
  local paramblock
  if targetIs64Bit() then
    local m=createMemoryStream()
    local typelist={}
    local stringlist={}

    m.write(qwordToByteTable(address))
    m.write(dwordToByteTable(varcount))

    local i
    for i=1,varcount do
      if type(arg[i])=='number' then
        if math.type(arg[i])=='integer' then
          m.write(qwordToByteTable(arg[i]))
          typelist[i]=0
        else
          if math.type(arg[i])=='number' then
            if (floatype==0) then
              m.write(floatToByteTable(arg[i]))
              m.write({0,0,0,0})
              typelist[i]=1
            else
              m.write(doubleToByteTable(arg[i]))
              typelist[i]=2
            end
          end
        end
      else
        if type(arg[i])=='string' then
          --fill in the address later
          local si={}
          si.pos=m.Position
          si.string=arg[i]
          table.insert(stringlist,si)
-------------------
          typelist[i]=0 --intvalue holding the string address
-------------------
          m.write({0,0,0,0,0,0,0,0})
        end
      end
    end

    for i=1,#stringlist do
      stringlist[i].mempos=m.Position

      if chartype==0 then
        m.write(stringToByteTable(stringlist[i].string))
        m.write({0})
      else
        m.write(wideStringToByteTable(stringlist[i].string))
        m.write({0,0})
      end
    end

    for i=1,#stringlist do
      m.Position=stringlist[i].pos
      m.write(qwordToByteTable(stringlist[i].mempos))
    end

    paramblock=allocateMemory(m.Size) --allocate memory in target process

    copyMemory(m.Memory, m.Size, paramblock, 2) --2: copy from CE memory to target process
  else
    local m=createMemoryStream()
    local stringlist={}

    m.write(dwordToByteTable(address))
    m.write(dwordToByteTable(varcount))
    local varcount2=varcount --adjust for double types
    for i=1,varcount do
      if type(arg[i])=='number' then
        if math.type(arg[i])=='integer' then
          m.write(dwordToByteTable(arg[i]))
        else
          if math.type(arg[i])=='number' then
            if floattype==0 then
              m.write(floatToByteTable(arg[i]))
            else
              m.write(doubleToByteTable(arg[i]))

              --adjust paramcount
              local oldpos=m.Position
              varcount2=varcount2+1
              m.write(dwordToByteTable(varcount2))
              m.Position=oldpos
            end
          end
        end
      else
        if type(arg[i])=='string' then
          --fill in the address later
          local si={}
          si.pos=m.Position
          si.string=arg[i]
          table.insert(stringlist,si)

          m.write({0,0,0,0})
        end
      end
    end

    for i=1,#stringlist do
      stringlist[i].mempos=m.Position

      if chartype==0 then
        m.write(stringToByteTable(stringlist[i].string))
        m.write({0})
      else
        m.write(wideStringToByteTable(stringlist[i].string))
        m.write({0,0})
      end

    end

    for i=1,#stringlist do
      m.Position=stringlist[i].pos
      m.write(dwordToByteTable(stringlist[i].mempos))
    end
  end

  local result=executeCode(stdcallstub.address,paramblock)
  return deAlloc(paramblock)
end

function executeStdCallCode(address, ...) --default. single,1 bytechars
  return _executeStdCallCode(0,0,address, ...)
end

function executeStdCallCodeDouble(address, ...) -- double,1 bytechars
  return _executeStdCallCode(1,0,address, ...)
end

function executeStdCallCodeWide(address, ...) --single,2 byte chars
  return _executeStdCallCode(0,1,address, ...)
end

function executeStdCallCodeWideDouble(address, ...) --double, 2 byte chars
  return _executeStdCallCode(1,1,address, ...)
end
