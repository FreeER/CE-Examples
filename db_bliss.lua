-- https://imgur.com/a/N9Y0A
-- https://pastebin.com/W7wiy85w
if sc==nil then
  sc=getScreenCanvas()
end

myt=createThread(function(t)

  local w=getScreenWidth()
  local h=getScreenHeight()

  while t.Terminated==false do
    local x=math.random(w)
    local y=math.random(h)

    sc.Font.Color=math.random(0xff) +  (math.random(0xff)<<8) +  (math.random(0xff) << 16)
    sc.textOut(x,y,"WEEEEEE")
  end
  print("yay")
end)

q=createTimer()
q.Interval=5*60*1000 --because I am an asshole
q.OnTimer=function(t)
  myt.terminate()
  t.destroy()
end
