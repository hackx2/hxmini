@echo off

set PATH=C:\Program Files\7zip;%PATH%
del /q release.zip
rmdir /s /q release
mkdir release
copy LICENSE release\
copy haxelib.json release\
copy README.md release\
copy .gitignore release\
copy extraParams.hxml release\
mkdir release\mini
xcopy mini\*.hx release\mini\ /E /I /Y
xcopy .resources release\.resources /E /I /Y
pushd release
7za a -tzip ..\release.zip *
popd
haxelib submit release.zip
del /q release.zip
rmdir /s /q release
pause