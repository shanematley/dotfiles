@echo off
REM Note: do not try installing into the vim subdirectory here. Vundle overwrites the git repo!
if not exist %USERPROFILE%\vimfiles\bundle mkdir %USERPROFILE%\vimfiles\bundle
git clone https://github.com/gmarik/Vundle.vim.git %USERPROFILE%\vimfiles\bundle\Vundle.vim
cd %USERPROFILE%\vimfiles\bundle
gvim +PluginInstall