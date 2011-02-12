@echo off

  rem Make batch file for "biblatex-ieee"

  rem Default with no target is to give help   

  if not "%1" == "" goto :init

:help

  echo.
  echo  make clean        - delete all generated files
  echo  make ctan         - create an archive ready for CTAN
  echo  make doc          - typesets documentation
  echo  make tds          - create a TDS-ready archive

  goto :EOF

:init

  setlocal

  rem Master package name 

  set PACKAGE=biblatex-ieee

  rem The biblatex styles included

  set STYLES=ieee

  rem The file types for inclusion in the archive files: note that a CTAN
  rem archive should not contain "unpacked" files. Typeset files and their
  rem sources are not included here: they are dealt with separately

  set CTANFILES=bbx cbx pdf tex
  set TDSFILES=%CTANFILES%

  rem Files to typeset

  rem The settings for cleaning up after compilation are divided into two
  rem parts. AUXFILES are deleted after each (La)TeX run, CLEAN only
  rem when the user calls "make clean"

  set AUXFILES=aux bbl blg log out toc
  set CLEAN=pdf zip

  rem The file types for inclusion in the archive files: note that a CTAN
  rem archive should not contain "unpacked" files. Typeset files and their
  rem sources are not included here: they are dealt with separately

  set CTANFILES=bbx bib cbx pdf tex
  set TDSFILES=%CTANFILES%

  rem Locations for building archives

  set CTANROOT=ctan
  set CTANDIR=%CTANROOT%\%PACKAGE%
  set TDSROOT=tds

  cd /d "%~dp0"

:main

  if /i "%1" == "clean"        goto :clean
  if /i "%1" == "ctan"         goto :ctan
  if /i "%1" == "doc"          goto :doc
  if /i "%1" == "help"         goto :help
  if /i "%1" == "localinstall" goto :localinstall
  if /i "%1" == "tds"          goto :tds

  goto :help

:clean

  echo.
  echo Deleting files

  for %%I in (%CLEAN%) do (
    if exist *.%%I del /q *.%%I
  )

  for %%I in (%TXT%) do (
    if exist %%I del /q %%I
  )

:clean-aux

  for %%I in (%AUXFILES%) do (
    if exist *.%%I del /q *.%%I
  )

  goto :end

:ctan

  call :zip
  if errorlevel 1 goto :EOF

  call :tds
  if errorlevel 1 goto :EOF

  for %%I in (%CTANFILES%) do (
    xcopy /q /y *.%%I "%CTANDIR%\" > nul
  )
  xcopy /q /y README "%CTANDIR%\" > nul

  xcopy /q /y %PACKAGE%.tds.zip "%CTANROOT%\" > nul

  pushd "%CTANROOT%"
  %ZIPEXE% %ZIPFLAG% %PACKAGE%.zip .
  popd
  copy /y "%CTANROOT%\%PACKAGE%.zip" > nul

  rmdir /s /q %CTANROOT%

  goto :end

:doc 

  for %%I in (%STYLES%) do (
    echo biblatex-%%I
    pdflatex biblatex-%%I > nul
    bibtex8 --wolfgang biblatex-%%I > nul
    pdflatex biblatex-%%I > nul
  )

  if exist *-blx.bib del *-blx.bib

  goto :clean-aux

:file2tdsdir

  set TDSDIR=

  if /i "%~x1" == ".bbx" set TDSDIR=tex\latex\%PACKAGE%
  if /i "%~x1" == ".bib" set TDSDIR=doc\latex\%PACKAGE%
  if /i "%~x1" == ".cbx" set TDSDIR=tex\latex\%PACKAGE%
  if /i "%~x1" == ".pdf" set TDSDIR=doc\latex\%PACKAGE%
  if /i "%~x1" == ".tex" set TDSDIR=doc\latex\%PACKAGE%  

  goto :EOF

:tds

  call :zip
  if errorlevel 1 goto :EOF

  call :doc
  if errorlevel 1 goto :EOF

  echo.
  echo Creating archive

  for %%I in (%TDSFILES%) do (
    call :tds-int *.%%I
  )
  xcopy /q /y README "%TDSROOT%\doc\latex\%PACKAGE%\" > nul

  pushd "%TDSROOT%"
  %ZIPEXE% %ZIPFLAG% %PACKAGE%.tds.zip .
  popd
  copy /y "%TDSROOT%\%PACKAGE%.tds.zip" > nul

  rmdir /s /q "%TDSROOT%"

  goto :end

:tds-int

  call :file2tdsdir %1

  if defined TDSDIR (
    xcopy /q /y %1 "%TDSROOT%\%TDSDIR%\" > nul
  ) else (
    echo Unknown file type "%~x1"
  )

  goto :EOF

:zip 

  if not defined ZIPFLAG set ZIPFLAG=-r -q -X -ll

  if defined ZIPEXE goto :EOF

  for %%I in (zip.exe "%~dp0zip.exe") do (
    if not defined ZIPEXE if exist %%I set ZIPEXE=%%I
  )

  for %%I in (zip.exe) do (
    if not defined ZIPEXE set ZIPEXE="%%~$PATH:I"
  )

  if not defined ZIPEXE (
    echo.
    echo This procedure requires a zip program,
    echo but one could not be found.
    echo
    echo If you do have a command-line zip program installed,
    echo set ZIPEXE to the full executable path and ZIPFLAG to the
    echo appropriate flag to create an archive.
    echo.
  )

  goto :EOF

:end

  shift
  if not "%1" == "" goto :main