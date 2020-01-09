# get-cmder

Script for Windows to download [cmder full](https://cmder.net/) and configure it,
including the installation of [GNU Make](https://www.gnu.org/software/make/).

## Usage

### Install cmder from scratch

1. Download or clone this repo
2. Run `get-cmder.bat`, this will take a while since it downloads `cmder full`, which is about 100MB.
3. When asked choose whether to use conda or not, and if you want to use conda select the Anaconda installation folder.
4. If you want to add the context menu (right click menu) entry `Open Cmder Here` just run `AddCmderContextMenueEntry.reg`, which will sett the appropriate registry keys and thus add cmder. To remove it again run `RemoveCmderContextMenueEntry.reg`.

### Reconfigure cmder i.e. after an update

This assumes that you installed cmder to the path `%USERPROFILE%/cmder`, i.e. with `Install cmder from scratch`.

1. Download or clone this repo
2. When asked choose whether to use conda or not, and if you want to use conda select the Anaconda installation folder.
3. If you want to add the context menu (right click menu) entry `Open Cmder Here` just run `AddCmderContextMenueEntry.reg`, which will sett the appropriate registry keys and thus add cmder. To remove it again run `RemoveCmderContextMenueEntry.reg`.

### Install GNU Make into a standalone installation of [Git Bash for Windows](https://gitforwindows.org/)

1. Download or clone this repo
2. Run `install_make_git_bash_standalone.bat`
