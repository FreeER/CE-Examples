setlocal
set msg=^"%*^"
set msg="%msg:"=%"

if not [%msg%] == [""] goto git
set /p msg="commit message: "
set msg=%msg:"=%
set msg=^"%msg%^"
:git
git add *
git commit -m %msg%
if [%errorlevel%] == [0] git push origin