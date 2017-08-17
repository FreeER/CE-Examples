setlocal
set msg=^"%*^"
set msg="%msg:"=%"

if not [%msg%] == [""] goto git
set /p msg="commit message: "
set msg=%msg:"=%
set msg=^"%msg%^"
:git
git add *
if [%errorlevel%] NEQ [0] goto nogit
git commit -m %msg%
if [%errorlevel%] == [0] git push origin
goto end
:nogit
echo You don't have git installed you git!
pause
:end