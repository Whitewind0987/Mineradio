!ifndef MUI_BGCOLOR
  !define MUI_BGCOLOR "FFFFFF"
!endif
!ifndef MUI_TEXTCOLOR
  !define MUI_TEXTCOLOR "111217"
!endif
!ifndef MUI_DIRECTORYPAGE_BGCOLOR
  !define MUI_DIRECTORYPAGE_BGCOLOR "FFFFFF"
!endif
!ifndef MUI_DIRECTORYPAGE_TEXTCOLOR
  !define MUI_DIRECTORYPAGE_TEXTCOLOR "111217"
!endif
!ifndef MUI_INSTFILESPAGE_COLORS
  !define MUI_INSTFILESPAGE_COLORS "3257F7 FFFFFF"
!endif
!ifndef MUI_FINISHPAGE_LINK_COLOR
  !define MUI_FINISHPAGE_LINK_COLOR "3257F7"
!endif
!ifndef MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE
!endif
!ifndef MUI_HEADERIMAGE_BITMAP_STRETCH
  !define MUI_HEADERIMAGE_BITMAP_STRETCH "FitControl"
!endif
!ifndef MUI_HEADERIMAGE_UNBITMAP_STRETCH
  !define MUI_HEADERIMAGE_UNBITMAP_STRETCH "FitControl"
!endif
!ifndef BUILD_UNINSTALLER
  !ifndef MUI_CUSTOMFUNCTION_GUIINIT
    !define MUI_CUSTOMFUNCTION_GUIINIT MineradioGuiInit
  !endif
!endif

!include LogicLib.nsh
!include FileFunc.nsh
!include StdUtils.nsh
!include nsDialogs.nsh
!include WinMessages.nsh

; Mineradio-W is the single canonical Windows installation folder name.
; Fresh installs and verified legacy upgrades both resolve to Mineradio-W, so
; path normalization is idempotent and never appends a second application
; folder. MINERADIO_LEGACY_INSTALL_FOLDER is retained as an identical alias so
; the existing marker/evidence safety checks remain untouched.
!define MINERADIO_INSTALL_FOLDER "Mineradio-W"
!define MINERADIO_LEGACY_INSTALL_FOLDER "Mineradio-W"
!define MINERADIO_INSTALL_MARKER ".mineradio-w-install-root"
!define MINERADIO_INSTALL_APP_ID "com.whitewind0987.mineradio.w"

!ifndef BUILD_UNINSTALLER
  Var MineradioWelcomePage
  Var MineradioHeroFont
  Var MineradioTitleFont
  Var MineradioBodyFont
  Var MineradioSmallFont
  Var MineradioDirectoryPage
  Var MineradioDirectoryInput
  Var MineradioRegisteredInstallDir
  Var MineradioLegacyInstallDir
  Var MineradioLegacyInstallAdopted
  Var MineradioInstallCommitted
  Var MineradioLegacyHKCUDisabled
  Var MineradioLegacyHKCUUninstallString
  Var MineradioLegacyHKCUQuietUninstallString
  Var MineradioLegacyHKLMDisabled
  Var MineradioLegacyHKLMUninstallString
  Var MineradioLegacyHKLMQuietUninstallString
  !define MUI_CUSTOMFUNCTION_ABORT MineradioRestoreLegacyUninstallRegistration
!endif

!macro customInit
  !ifndef BUILD_UNINSTALLER
    Call MineradioUsePreferredInstallDir
    ${If} ${Silent}
      Call MineradioValidateInstallDir
      Call MineradioDisableUnsafeOldUninstallers
    ${EndIf}
  !endif
!macroend

!macro customInstall
  !ifndef BUILD_UNINSTALLER
    StrCpy $MineradioInstallCommitted "1"
    Call MineradioDeleteAdoptedLegacyUninstallerFiles
  !endif
  ClearErrors
  FileOpen $0 "$INSTDIR\${MINERADIO_INSTALL_MARKER}" w
  ${IfNot} ${Errors}
    FileWrite $0 "Mineradio W install root$\r$\n"
    FileWrite $0 "appId=${MINERADIO_INSTALL_APP_ID}$\r$\n"
    FileClose $0
  ${EndIf}
!macroend

!macro customRemoveFiles
  Call un.MineradioRemoveInstalledFiles
!macroend

!macro customWelcomePage
  Page custom MineradioWelcomeShow
!macroend

!macro customInstallMode
  StrCpy $isForceCurrentInstall "1"
!macroend

!macro customPageAfterChangeDir
  Page custom MineradioDirectoryShow MineradioDirectoryLeave
!macroend

!macro customFinishPage
  !ifndef HIDE_RUN_AFTER_FINISH
    Function MineradioFinishStartApp
      ${If} ${isUpdated}
        StrCpy $1 "--updated"
      ${Else}
        StrCpy $1 ""
      ${EndIf}
      ${StdUtils.ExecShellAsUser} $0 "$launchLink" "open" "$1"
    FunctionEnd

    !define MUI_FINISHPAGE_RUN
    !define MUI_FINISHPAGE_RUN_FUNCTION "MineradioFinishStartApp"
  !endif
  !define MUI_PAGE_CUSTOMFUNCTION_SHOW MineradioTintCommonControls
  !insertmacro MUI_PAGE_FINISH
!macroend

!ifndef BUILD_UNINSTALLER
Function MineradioGuiInit
  System::Call 'dwmapi::DwmSetWindowAttribute(p $HWNDPARENT, i 20, *i 1, i 4) i .r0'
  System::Call 'dwmapi::DwmSetWindowAttribute(p $HWNDPARENT, i 19, *i 1, i 4) i .r0'
  Call MineradioTintCommonControls
FunctionEnd

Function MineradioTintCommonControls
  SetCtlColors $HWNDPARENT "111217" "FFFFFF"

  GetDlgItem $0 $HWNDPARENT 1
  ${If} $0 <> 0
    SetCtlColors $0 "111217" "FFFFFF"
  ${EndIf}
  GetDlgItem $0 $HWNDPARENT 2
  ${If} $0 <> 0
    SetCtlColors $0 "111217" "FFFFFF"
  ${EndIf}
  GetDlgItem $0 $HWNDPARENT 3
  ${If} $0 <> 0
    SetCtlColors $0 "111217" "FFFFFF"
  ${EndIf}

  GetDlgItem $0 $HWNDPARENT 1028
  ${If} $0 <> 0
    SetCtlColors $0 "4B5263" "FFFFFF"
  ${EndIf}
  GetDlgItem $0 $HWNDPARENT 1256
  ${If} $0 <> 0
    SetCtlColors $0 "4B5263" "FFFFFF"
  ${EndIf}
  GetDlgItem $0 $HWNDPARENT 1034
  ${If} $0 <> 0
    SetCtlColors $0 "" "FFFFFF"
  ${EndIf}
  GetDlgItem $0 $HWNDPARENT 1035
  ${If} $0 <> 0
    SetCtlColors $0 "" "FFFFFF"
  ${EndIf}
  GetDlgItem $0 $HWNDPARENT 1037
  ${If} $0 <> 0
    SetCtlColors $0 "111217" "FFFFFF"
  ${EndIf}
  GetDlgItem $0 $HWNDPARENT 1038
  ${If} $0 <> 0
    SetCtlColors $0 "4B5263" "FFFFFF"
  ${EndIf}
  GetDlgItem $0 $HWNDPARENT 1039
  ${If} $0 <> 0
    SetCtlColors $0 "" "FFFFFF"
  ${EndIf}

  FindWindow $0 "#32770" "" $HWNDPARENT
  ${If} $0 <> 0
    SetCtlColors $0 "111217" "FFFFFF"

    GetDlgItem $1 $0 1000
    ${If} $1 <> 0
      SetCtlColors $1 "111217" "FFFFFF"
    ${EndIf}
    GetDlgItem $1 $0 1001
    ${If} $1 <> 0
      SetCtlColors $1 "111217" "FFFFFF"
    ${EndIf}
    GetDlgItem $1 $0 1004
    ${If} $1 <> 0
      SetCtlColors $1 "3257F7" "FFFFFF"
    ${EndIf}
    GetDlgItem $1 $0 1006
    ${If} $1 <> 0
      SetCtlColors $1 "4B5263" "FFFFFF"
    ${EndIf}
    GetDlgItem $1 $0 1016
    ${If} $1 <> 0
      SetCtlColors $1 "4B5263" "FFFFFF"
    ${EndIf}
    GetDlgItem $1 $0 1019
    ${If} $1 <> 0
      SetCtlColors $1 "111217" "FFFFFF"
    ${EndIf}
    GetDlgItem $1 $0 1020
    ${If} $1 <> 0
      SetCtlColors $1 "4B5263" "FFFFFF"
    ${EndIf}
    GetDlgItem $1 $0 1023
    ${If} $1 <> 0
      SetCtlColors $1 "4B5263" "FFFFFF"
    ${EndIf}
    GetDlgItem $1 $0 1024
    ${If} $1 <> 0
      SetCtlColors $1 "4B5263" "FFFFFF"
    ${EndIf}
    GetDlgItem $1 $0 1027
    ${If} $1 <> 0
      SetCtlColors $1 "111217" "FFFFFF"
    ${EndIf}
    GetDlgItem $1 $0 1201
    ${If} $1 <> 0
      SetCtlColors $1 "111217" "FFFFFF"
    ${EndIf}
    GetDlgItem $1 $0 1202
    ${If} $1 <> 0
      SetCtlColors $1 "4B5263" "FFFFFF"
    ${EndIf}
    GetDlgItem $1 $0 1203
    ${If} $1 <> 0
      SetCtlColors $1 "111217" "FFFFFF"
    ${EndIf}
    GetDlgItem $1 $0 1204
    ${If} $1 <> 0
      SetCtlColors $1 "4B5263" "FFFFFF"
    ${EndIf}
  ${EndIf}
FunctionEnd

Function MineradioUsePreferredInstallDir
  ${GetParameters} $R0
  ClearErrors
  ${GetOptions} $R0 "/D=" $R1
  ${IfNot} ${Errors}
  ${AndIf} $R1 != ""
    StrCpy $INSTDIR "$R1"
  ${Else}
    ${If} $MineradioRegisteredInstallDir != ""
      StrCpy $INSTDIR "$MineradioRegisteredInstallDir"
    ${Else}
      Call MineradioUseRegisteredInstallDir
      Pop $R2
      ${If} $R2 != "1"
        IfFileExists "D:\*.*" 0 +2
        StrCpy $INSTDIR "D:\${MINERADIO_INSTALL_FOLDER}"
      ${EndIf}
    ${EndIf}
  ${EndIf}
  ${If} $MineradioLegacyInstallAdopted == "1"
  ${AndIf} $MineradioRegisteredInstallDir != ""
    StrCpy $INSTDIR "$MineradioRegisteredInstallDir"
  ${Else}
    Push "$INSTDIR"
    Call MineradioNormalizeInstallDirPreservingAdopted
    Pop $INSTDIR
  ${EndIf}
FunctionEnd

Function MineradioNormalizeInstallDir
  Exch $0
  Push "$0"
  Call MineradioTrimInstallDir
  Pop $0
  StrLen $1 "$0"
  ${If} $1 == 2
    StrCpy $2 "$0" 1 1
    ${If} $2 == ":"
      StrCpy $0 "$0\${MINERADIO_INSTALL_FOLDER}"
    ${EndIf}
  ${ElseIf} $1 == 3
    StrCpy $2 "$0" 1 1
    StrCpy $3 "$0" 1 2
    ${If} $2 == ":"
    ${AndIf} $3 == "\"
      StrCpy $0 "$0${MINERADIO_INSTALL_FOLDER}"
    ${EndIf}
  ${EndIf}

  ${GetFileName} "$0" $2
  ${If} $2 != "${MINERADIO_INSTALL_FOLDER}"
    StrCpy $0 "$0\${MINERADIO_INSTALL_FOLDER}"
  ${EndIf}
  Exch $0
FunctionEnd

Function MineradioNormalizeInstallDirPreservingAdopted
  Exch $0
  Push "$0"
  Call MineradioTrimInstallDir
  Pop $1

  ${If} $MineradioLegacyInstallAdopted == "1"
  ${AndIf} $MineradioLegacyInstallDir != ""
  ${AndIf} $1 == $MineradioLegacyInstallDir
    StrCpy $0 "$MineradioLegacyInstallDir"
  ${ElseIf} $MineradioLegacyInstallAdopted == "1"
  ${AndIf} $MineradioRegisteredInstallDir != ""
  ${AndIf} $1 == $MineradioRegisteredInstallDir
    StrCpy $0 "$MineradioRegisteredInstallDir"
  ${Else}
    StrCpy $R3 "$1"
    Push "$1"
    Call MineradioRegisteredInstallDirCanBeAdopted
    Pop $2
    ${If} $2 == "1"
      Push "$R3"
      Call MineradioAdoptRegisteredInstallDir
      StrCpy $0 "$INSTDIR"
    ${Else}
      Push "$R3"
      Call MineradioNormalizeInstallDir
      Pop $0
    ${EndIf}
  ${EndIf}

  Exch $0
FunctionEnd

Function MineradioTrimInstallDir
  Exch $0

  trim:
    StrLen $1 "$0"
    ${If} $1 > 3
      StrCpy $2 "$0" 1 -1
      ${If} $2 == "\"
        StrCpy $0 "$0" -1
        Goto trim
      ${EndIf}
    ${EndIf}

  Exch $0
FunctionEnd

Function MineradioInstallDirHasSupportedFinalComponent
  Exch $0
  StrCpy $1 "0"

  Push "$0"
  Call MineradioTrimInstallDir
  Pop $2
  ${If} $2 == ""
    Goto done
  ${EndIf}

  ${GetFileName} "$2" $3
  ${If} $3 == "${MINERADIO_INSTALL_FOLDER}"
    StrCpy $1 "1"
  ${ElseIf} $3 == "${MINERADIO_LEGACY_INSTALL_FOLDER}"
    StrCpy $1 "1"
  ${EndIf}

  done:
    StrCpy $0 "$1"
    Exch $0
FunctionEnd

Function MineradioInstallDirHasValidMarker
  Exch $0
  StrCpy $1 "0"

  IfFileExists "$0\${MINERADIO_INSTALL_MARKER}" 0 done
  ClearErrors
  FileOpen $2 "$0\${MINERADIO_INSTALL_MARKER}" r
  ${If} ${Errors}
    Goto done
  ${EndIf}

  readLoop:
    ClearErrors
    FileRead $2 $3
    ${If} ${Errors}
      Goto closeFile
    ${EndIf}
    StrCmp $3 "appId=${MINERADIO_INSTALL_APP_ID}$\r$\n" found
    StrCmp $3 "appId=${MINERADIO_INSTALL_APP_ID}$\n" found
    StrCmp $3 "appId=${MINERADIO_INSTALL_APP_ID}" found
    Goto readLoop

  found:
    StrCpy $1 "1"

  closeFile:
    FileClose $2

  done:
    StrCpy $0 "$1"
    Exch $0
FunctionEnd

Function MineradioLegacyInstallHasEvidence
  Exch $0
  StrCpy $1 "0"

  ${If} $0 == ""
    Goto done
  ${EndIf}

  Push "$0"
  Call MineradioTrimInstallDir
  Pop $2
  ${If} $2 == ""
    Goto done
  ${EndIf}

  ${GetFileName} "$2" $3
  ${If} $3 != "${MINERADIO_LEGACY_INSTALL_FOLDER}"
    Goto done
  ${EndIf}

  IfFileExists "$2\${PRODUCT_FILENAME}.exe" 0 done
  IfFileExists "$2\resources\app\package.json" evidence 0
  IfFileExists "$2\resources\app\server.js" evidence 0
  IfFileExists "$2\resources\app.asar" evidence 0
  Goto done

  evidence:
    StrCpy $1 "1"

  done:
    StrCpy $0 "$1"
    Exch $0
FunctionEnd

Function MineradioInstallDirIsVerifiedLegacyUpgradeTarget
  Exch $0
  StrCpy $1 "0"

  ${If} $MineradioLegacyInstallAdopted != "1"
    Goto done
  ${EndIf}

  ${If} $MineradioLegacyInstallDir == ""
    Goto done
  ${EndIf}

  Push "$0"
  Call MineradioTrimInstallDir
  Pop $2

  ${If} $2 != $MineradioLegacyInstallDir
    Goto done
  ${EndIf}

  Push "$2"
  Call MineradioLegacyInstallHasEvidence
  Pop $3
  ${If} $3 == "1"
    StrCpy $1 "1"
  ${EndIf}

  done:
    StrCpy $0 "$1"
    Exch $0
FunctionEnd

Function MineradioExistingInstallPathCanBeAdopted
  Exch $0
  StrCpy $1 "0"

  Push "$0"
  Call MineradioInstallDirHasValidMarker
  Pop $2
  ${If} $2 == "1"
    Push "$0"
    Call MineradioInstallDirHasSupportedFinalComponent
    Pop $2
    ${If} $2 == "1"
      StrCpy $1 "1"
      Goto done
    ${EndIf}
  ${EndIf}

  Push "$0"
  Call MineradioLegacyInstallHasEvidence
  Pop $2
  ${If} $2 == "1"
    StrCpy $1 "1"
  ${EndIf}

  done:
    StrCpy $0 "$1"
  Exch $0
FunctionEnd

Function MineradioAdoptRegisteredInstallDir
  Exch $0
  Push "$0"
  Call MineradioTrimInstallDir
  Pop $1
  StrCpy $R3 "$1"

  Push "$R3"
  Call MineradioInstallDirHasValidMarker
  Pop $2
  ${If} $2 == "1"
    Push "$R3"
    Call MineradioInstallDirHasSupportedFinalComponent
    Pop $2
    ${If} $2 == "1"
      StrCpy $INSTDIR "$R3"
      StrCpy $MineradioRegisteredInstallDir "$R3"
      ${GetFileName} "$R3" $3
      ${If} $3 == "${MINERADIO_LEGACY_INSTALL_FOLDER}"
        StrCpy $MineradioLegacyInstallDir "$R3"
        StrCpy $MineradioLegacyInstallAdopted "1"
      ${EndIf}
      Goto done
    ${EndIf}
  ${EndIf}

  Push "$R3"
  Call MineradioLegacyInstallHasEvidence
  Pop $2
  ${If} $2 == "1"
    StrCpy $INSTDIR "$R3"
    StrCpy $MineradioRegisteredInstallDir "$R3"
    StrCpy $MineradioLegacyInstallDir "$R3"
    StrCpy $MineradioLegacyInstallAdopted "1"
  ${Else}
    Push "$R3"
    Call MineradioNormalizeInstallDir
    Pop $INSTDIR
    StrCpy $MineradioRegisteredInstallDir "$INSTDIR"
  ${EndIf}

  done:
    Pop $0
FunctionEnd

Function MineradioCanonicalInstallDirForAdoption
  Exch $0
  Push "$0"
  Call MineradioTrimInstallDir
  Pop $1
  StrCpy $R3 "$1"

  ${If} $R3 == ""
    StrCpy $0 ""
    Goto done
  ${EndIf}

  Push "$R3"
  Call MineradioInstallDirHasValidMarker
  Pop $2
  ${If} $2 == "1"
    Push "$R3"
    Call MineradioInstallDirHasSupportedFinalComponent
    Pop $2
    ${If} $2 == "1"
      StrCpy $0 "$R3"
      Goto done
    ${EndIf}
  ${EndIf}

  Push "$R3"
  Call MineradioLegacyInstallHasEvidence
  Pop $2
  ${If} $2 == "1"
    StrCpy $0 "$R3"
  ${Else}
    ${If} $MineradioLegacyInstallAdopted == "1"
    ${AndIf} $MineradioLegacyInstallDir != ""
    ${AndIf} $R3 == $MineradioLegacyInstallDir
      StrCpy $0 "$MineradioLegacyInstallDir"
    ${Else}
      Push "$R3"
      Call MineradioNormalizeInstallDir
      Pop $0
    ${EndIf}
  ${EndIf}

  done:
    Exch $0
FunctionEnd

Function MineradioInstallDirFromUninstallString
  Exch $0
  StrCpy $1 ""
  StrCpy $2 ""

  ${If} $0 == ""
    Goto done
  ${EndIf}

  StrCpy $3 "$0" 1 0
  ${If} $3 == '"'
    StrCpy $4 1
    quotedLoop:
      StrCpy $5 "$0" 1 $4
      ${If} $5 == ""
        Goto quotedDone
      ${EndIf}
      ${If} $5 == '"'
        Goto quotedDone
      ${EndIf}
      StrCpy $2 "$2$5"
      IntOp $4 $4 + 1
      Goto quotedLoop
    quotedDone:
  ${Else}
    StrCpy $4 0
    unquotedLoop:
      StrCpy $5 "$0" 1 $4
      ${If} $5 == ""
        Goto unquotedDone
      ${EndIf}
      ${If} $5 == " "
        Goto unquotedDone
      ${EndIf}
      StrCpy $2 "$2$5"
      IntOp $4 $4 + 1
      Goto unquotedLoop
    unquotedDone:
  ${EndIf}

  ${If} $2 != ""
    StrLen $4 "$2"
    parentLoop:
      ${If} $4 <= 0
        Goto done
      ${EndIf}
      IntOp $4 $4 - 1
      StrCpy $5 "$2" 1 $4
      ${If} $5 == "\"
        StrCpy $1 "$2" $4
        Goto done
      ${EndIf}
      Goto parentLoop
  ${EndIf}

  done:
    StrCpy $0 "$1"
    Exch $0
FunctionEnd

Function MineradioUseRegisteredInstallDir
  ReadRegStr $0 HKCU "Software\${APP_GUID}" InstallLocation
  Push "$0"
  Call MineradioExistingInstallPathCanBeAdopted
  Pop $1
  ${If} $1 == "1"
    Push "$0"
    Call MineradioAdoptRegisteredInstallDir
    Push "1"
    Return
  ${EndIf}

  ReadRegStr $0 HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" InstallLocation
  Push "$0"
  Call MineradioExistingInstallPathCanBeAdopted
  Pop $1
  ${If} $1 == "1"
    Push "$0"
    Call MineradioAdoptRegisteredInstallDir
    Push "1"
    Return
  ${EndIf}

  ReadRegStr $0 HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" UninstallString
  Push "$0"
  Call MineradioInstallDirFromUninstallString
  Pop $0
  Push "$0"
  Call MineradioExistingInstallPathCanBeAdopted
  Pop $1
  ${If} $1 == "1"
    Push "$0"
    Call MineradioAdoptRegisteredInstallDir
    Push "1"
    Return
  ${EndIf}

  ReadRegStr $0 HKLM "Software\${APP_GUID}" InstallLocation
  Push "$0"
  Call MineradioExistingInstallPathCanBeAdopted
  Pop $1
  ${If} $1 == "1"
    Push "$0"
    Call MineradioAdoptRegisteredInstallDir
    Push "1"
    Return
  ${EndIf}

  ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" InstallLocation
  Push "$0"
  Call MineradioExistingInstallPathCanBeAdopted
  Pop $1
  ${If} $1 == "1"
    Push "$0"
    Call MineradioAdoptRegisteredInstallDir
    Push "1"
    Return
  ${EndIf}

  ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" UninstallString
  Push "$0"
  Call MineradioInstallDirFromUninstallString
  Pop $0
  Push "$0"
  Call MineradioExistingInstallPathCanBeAdopted
  Pop $1
  ${If} $1 == "1"
    Push "$0"
    Call MineradioAdoptRegisteredInstallDir
    Push "1"
    Return
  ${EndIf}

  Push "0"
FunctionEnd

Function MineradioRegisteredInstallDirCanBeAdopted
  Exch $0
  StrCpy $1 "0"

  ${If} $0 == ""
    Goto done
  ${EndIf}

  Push "$0"
  Call MineradioCanonicalInstallDirForAdoption
  Pop $2

  ${If} $MineradioRegisteredInstallDir != ""
    Push "$MineradioRegisteredInstallDir"
    Call MineradioCanonicalInstallDirForAdoption
    Pop $5
    ${If} $5 == $2
      StrCpy $1 "1"
      Goto done
    ${EndIf}
  ${EndIf}

  ReadRegStr $3 HKCU "Software\${APP_GUID}" InstallLocation
  Push "$3"
  Call MineradioExistingInstallPathCanBeAdopted
  Pop $4
  ${If} $4 == "1"
    Push "$3"
    Call MineradioCanonicalInstallDirForAdoption
    Pop $5
    ${If} $5 == $2
      StrCpy $1 "1"
      Goto done
    ${EndIf}
  ${EndIf}

  ReadRegStr $3 HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" InstallLocation
  Push "$3"
  Call MineradioExistingInstallPathCanBeAdopted
  Pop $4
  ${If} $4 == "1"
    Push "$3"
    Call MineradioCanonicalInstallDirForAdoption
    Pop $5
    ${If} $5 == $2
      StrCpy $1 "1"
      Goto done
    ${EndIf}
  ${EndIf}

  ReadRegStr $3 HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" UninstallString
  Push "$3"
  Call MineradioInstallDirFromUninstallString
  Pop $3
  Push "$3"
  Call MineradioExistingInstallPathCanBeAdopted
  Pop $4
  ${If} $4 == "1"
    Push "$3"
    Call MineradioCanonicalInstallDirForAdoption
    Pop $5
    ${If} $5 == $2
      StrCpy $1 "1"
      Goto done
    ${EndIf}
  ${EndIf}

  ReadRegStr $3 HKLM "Software\${APP_GUID}" InstallLocation
  Push "$3"
  Call MineradioExistingInstallPathCanBeAdopted
  Pop $4
  ${If} $4 == "1"
    Push "$3"
    Call MineradioCanonicalInstallDirForAdoption
    Pop $5
    ${If} $5 == $2
      StrCpy $1 "1"
      Goto done
    ${EndIf}
  ${EndIf}

  ReadRegStr $3 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" InstallLocation
  Push "$3"
  Call MineradioExistingInstallPathCanBeAdopted
  Pop $4
  ${If} $4 == "1"
    Push "$3"
    Call MineradioCanonicalInstallDirForAdoption
    Pop $5
    ${If} $5 == $2
      StrCpy $1 "1"
      Goto done
    ${EndIf}
  ${EndIf}

  ReadRegStr $3 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" UninstallString
  Push "$3"
  Call MineradioInstallDirFromUninstallString
  Pop $3
  Push "$3"
  Call MineradioExistingInstallPathCanBeAdopted
  Pop $4
  ${If} $4 == "1"
    Push "$3"
    Call MineradioCanonicalInstallDirForAdoption
    Pop $5
    ${If} $5 == $2
      StrCpy $1 "1"
      Goto done
    ${EndIf}
  ${EndIf}

  done:
    StrCpy $0 "$1"
    Exch $0
FunctionEnd

Function MineradioInstallDirIsEmpty
  Exch $0
  FindFirst $1 $2 "$0\*.*"
  StrCpy $3 "1"

  loop:
    StrCmp $2 "" done
    StrCmp $2 "." next
    StrCmp $2 ".." next
    StrCpy $3 "0"
    Goto done

  next:
    FindNext $1 $2
    Goto loop

  done:
    FindClose $1
    StrCpy $0 "$3"
    Exch $0
FunctionEnd

Function MineradioOldInstallPathNeedsQuarantine
  Exch $0
  StrCpy $1 "0"

  ${If} $0 == ""
    Goto done
  ${EndIf}

  Push "$0"
  Call MineradioTrimInstallDir
  Pop $2
  StrCpy $R3 "$2"
  ${If} $R3 == ""
    Goto done
  ${EndIf}

  Push "$R3"
  Call MineradioInstallDirHasValidMarker
  Pop $4
  ${If} $4 == "1"
    Push "$R3"
    Call MineradioInstallDirHasSupportedFinalComponent
    Pop $4
    ${If} $4 == "1"
      Goto done
    ${EndIf}
    StrCpy $1 "1"
    Goto done
  ${EndIf}

  Push "$R3"
  Call MineradioLegacyInstallHasEvidence
  Pop $4
  ${If} $4 == "1"
    Goto done
  ${EndIf}

  Push "$R3"
  Call MineradioNormalizeInstallDir
  Pop $3
  ${If} $R3 != $3
    StrCpy $1 "1"
    Goto done
  ${EndIf}

  StrCpy $1 "1"

  done:
    StrCpy $0 "$1"
    Exch $0
FunctionEnd

Function MineradioLegacyUninstallRegistrationShouldBeRemoved
  Exch $0
  StrCpy $1 "0"

  ${If} $0 == ""
    Goto done
  ${EndIf}

  Push "$0"
  Call MineradioTrimInstallDir
  Pop $2
  StrCpy $R3 "$2"
  ${If} $R3 == ""
    Goto done
  ${EndIf}

  Push "$R3"
  Call MineradioInstallDirHasValidMarker
  Pop $4
  ${If} $4 == "1"
    Goto done
  ${EndIf}

  Push "$R3"
  Call MineradioLegacyInstallHasEvidence
  Pop $4
  ${If} $4 == "1"
    StrCpy $1 "1"
  ${EndIf}

  done:
    StrCpy $0 "$1"
    Exch $0
FunctionEnd

Function MineradioDisableUnsafeOldUninstallers
  StrCpy $2 "0"

  ReadRegStr $0 HKCU "Software\${APP_GUID}" InstallLocation
  Push "$0"
  Call MineradioOldInstallPathNeedsQuarantine
  Pop $1
  ${If} $1 == "1"
    DetailPrint "Skip unsafe legacy Mineradio W uninstaller: $0"
    StrCpy $2 "1"
  ${EndIf}

  ReadRegStr $0 HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" InstallLocation
  Push "$0"
  Call MineradioLegacyUninstallRegistrationShouldBeRemoved
  Pop $1
  ${If} $1 == "1"
    DetailPrint "Temporarily disable legacy Mineradio W uninstaller: $0"
    StrCpy $2 "1"
  ${EndIf}
  Push "$0"
  Call MineradioOldInstallPathNeedsQuarantine
  Pop $1
  ${If} $1 == "1"
    DetailPrint "Skip unsafe legacy Mineradio W uninstaller: $0"
    StrCpy $2 "1"
  ${EndIf}

  ReadRegStr $0 HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" UninstallString
  StrCpy $3 "$0"
  Push "$0"
  Call MineradioInstallDirFromUninstallString
  Pop $0
  Push "$0"
  Call MineradioLegacyUninstallRegistrationShouldBeRemoved
  Pop $1
  ${If} $1 == "1"
    DetailPrint "Temporarily disable legacy Mineradio W uninstaller: $0"
    StrCpy $2 "1"
  ${EndIf}

  ${If} $2 == "1"
  ${AndIf} $MineradioLegacyHKCUDisabled != "1"
    StrCpy $MineradioLegacyHKCUUninstallString "$3"
    ReadRegStr $MineradioLegacyHKCUQuietUninstallString HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" QuietUninstallString
    DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" UninstallString
    DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" QuietUninstallString
    StrCpy $MineradioLegacyHKCUDisabled "1"
  ${EndIf}

  StrCpy $2 "0"

  ReadRegStr $0 HKLM "Software\${APP_GUID}" InstallLocation
  Push "$0"
  Call MineradioOldInstallPathNeedsQuarantine
  Pop $1
  ${If} $1 == "1"
    DetailPrint "Skip unsafe legacy Mineradio W uninstaller: $0"
    StrCpy $2 "1"
  ${EndIf}

  ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" InstallLocation
  Push "$0"
  Call MineradioLegacyUninstallRegistrationShouldBeRemoved
  Pop $1
  ${If} $1 == "1"
    DetailPrint "Temporarily disable legacy Mineradio W uninstaller: $0"
    StrCpy $2 "1"
  ${EndIf}
  Push "$0"
  Call MineradioOldInstallPathNeedsQuarantine
  Pop $1
  ${If} $1 == "1"
    DetailPrint "Skip unsafe legacy Mineradio W uninstaller: $0"
    StrCpy $2 "1"
  ${EndIf}

  ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" UninstallString
  StrCpy $3 "$0"
  Push "$0"
  Call MineradioInstallDirFromUninstallString
  Pop $0
  Push "$0"
  Call MineradioLegacyUninstallRegistrationShouldBeRemoved
  Pop $1
  ${If} $1 == "1"
    DetailPrint "Temporarily disable legacy Mineradio W uninstaller: $0"
    StrCpy $2 "1"
  ${EndIf}

  ${If} $2 == "1"
  ${AndIf} $MineradioLegacyHKLMDisabled != "1"
    StrCpy $MineradioLegacyHKLMUninstallString "$3"
    ReadRegStr $MineradioLegacyHKLMQuietUninstallString HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" QuietUninstallString
    DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" UninstallString
    DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" QuietUninstallString
    StrCpy $MineradioLegacyHKLMDisabled "1"
  ${EndIf}
FunctionEnd

Function MineradioRestoreLegacyUninstallRegistration
  ${If} $MineradioInstallCommitted == "1"
    Return
  ${EndIf}

  ${If} $MineradioLegacyHKCUDisabled == "1"
    ${If} $MineradioLegacyHKCUUninstallString != ""
      WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" UninstallString "$MineradioLegacyHKCUUninstallString"
    ${EndIf}
    ${If} $MineradioLegacyHKCUQuietUninstallString != ""
      WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" QuietUninstallString "$MineradioLegacyHKCUQuietUninstallString"
    ${EndIf}
    StrCpy $MineradioLegacyHKCUDisabled "0"
  ${EndIf}

  ${If} $MineradioLegacyHKLMDisabled == "1"
    ${If} $MineradioLegacyHKLMUninstallString != ""
      WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" UninstallString "$MineradioLegacyHKLMUninstallString"
    ${EndIf}
    ${If} $MineradioLegacyHKLMQuietUninstallString != ""
      WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${UNINSTALL_APP_KEY}" QuietUninstallString "$MineradioLegacyHKLMQuietUninstallString"
    ${EndIf}
    StrCpy $MineradioLegacyHKLMDisabled "0"
  ${EndIf}
FunctionEnd

Function MineradioDeleteAdoptedLegacyUninstallerFiles
  ${If} $MineradioLegacyInstallAdopted == "1"
  ${AndIf} $MineradioRegisteredInstallDir != ""
    Delete "$MineradioRegisteredInstallDir\Uninstall Mineradio W.exe"
  ${EndIf}
FunctionEnd

Function MineradioValidateInstallDir
  Push "$INSTDIR"
  Call MineradioNormalizeInstallDirPreservingAdopted
  Pop $INSTDIR

  ; Verified markerless legacy in-place upgrade exception.
  ; This must be evaluated before the generic non-empty unowned-directory rejection.
  Push "$INSTDIR"
  Call MineradioInstallDirIsVerifiedLegacyUpgradeTarget
  Pop $0
  ${If} $0 == "1"
    Goto valid
  ${EndIf}

  Push "$INSTDIR"
  Call MineradioRegisteredInstallDirCanBeAdopted
  Pop $3

  IfFileExists "$INSTDIR\*.*" 0 valid

  Push "$INSTDIR"
  Call MineradioInstallDirHasValidMarker
  Pop $0
  ${If} $0 == "1"
    Goto valid
  ${EndIf}

  ${If} $3 == "1"
    Goto valid
  ${EndIf}

  Push "$INSTDIR"
  Call MineradioInstallDirIsEmpty
  Pop $0
  ${If} $0 == "1"
    Goto valid
  ${EndIf}

  MessageBox MB_ICONSTOP|MB_OK "为避免卸载时误删其它文件，Mineradio W 不能安装到已有文件的非专属目录。请选择一个空文件夹，或选择上级目录让安装器创建 Mineradio W 子文件夹。$\r$\n$\r$\n当前路径：$INSTDIR"
  Abort

  valid:
FunctionEnd

Function MineradioWelcomeShow
  Call MineradioUsePreferredInstallDir

  nsDialogs::Create 1018
  Pop $MineradioWelcomePage
  ${If} $MineradioWelcomePage == error
    Abort
  ${EndIf}

  SetCtlColors $MineradioWelcomePage "111217" "FFFFFF"
  CreateFont $MineradioHeroFont "Microsoft YaHei UI" 24 700
  CreateFont $MineradioTitleFont "Microsoft YaHei UI" 11 700
  CreateFont $MineradioBodyFont "Microsoft YaHei UI" 9 400
  CreateFont $MineradioSmallFont "Microsoft YaHei UI" 8 400

  ${NSD_CreateLabel} 22u 20u 82u 10u "MINERADIO W"
  Pop $0
  SendMessage $0 ${WM_SETFONT} $MineradioSmallFont 1
  SetCtlColors $0 "3257F7" "FFFFFF"

  ${NSD_CreateLabel} 22u 42u 226u 30u "Mineradio W 安装"
  Pop $0
  SendMessage $0 ${WM_SETFONT} $MineradioHeroFont 1
  SetCtlColors $0 "111217" "FFFFFF"

  ${NSD_CreateLabel} 22u 78u 36u 2u ""
  Pop $0
  SetCtlColors $0 "" "3257F7"

  ${NSD_CreateLabel} 22u 96u 238u 24u "为这台电脑安装 Mineradio W。默认安装到 D:\Mineradio-W，下一步可以自由选择其它位置。"
  Pop $0
  SendMessage $0 ${WM_SETFONT} $MineradioBodyFont 1
  SetCtlColors $0 "4B5263" "FFFFFF"

  ${NSD_CreateLabel} 22u 130u 238u 12u "默认位置：$INSTDIR"
  Pop $0
  SendMessage $0 ${WM_SETFONT} $MineradioTitleFont 1
  SetCtlColors $0 "3257F7" "FFFFFF"

  nsDialogs::Show
FunctionEnd

Function MineradioDirectoryBrowse
  nsDialogs::SelectFolderDialog "选择 Mineradio W 安装文件夹" "$INSTDIR"
  Pop $0
  ${If} $0 != error
  ${AndIf} $0 != ""
    Push "$0"
    Call MineradioNormalizeInstallDirPreservingAdopted
    Pop $0
    StrCpy $INSTDIR "$0"
    SendMessage $MineradioDirectoryInput ${WM_SETTEXT} 0 "STR:$INSTDIR"
  ${EndIf}
FunctionEnd

Function MineradioDirectoryShow
  Call MineradioUsePreferredInstallDir

  nsDialogs::Create 1018
  Pop $MineradioDirectoryPage
  ${If} $MineradioDirectoryPage == error
    Abort
  ${EndIf}

  SetCtlColors $MineradioDirectoryPage "111217" "FFFFFF"
  CreateFont $MineradioTitleFont "Microsoft YaHei UI" 15 700
  CreateFont $MineradioBodyFont "Microsoft YaHei UI" 9 400
  CreateFont $MineradioSmallFont "Microsoft YaHei UI" 8 500

  ${NSD_CreateLabel} 22u 12u 238u 20u "选择安装位置"
  Pop $0
  SendMessage $0 ${WM_SETFONT} $MineradioTitleFont 1
  SetCtlColors $0 "111217" "FFFFFF"

  ${NSD_CreateLabel} 22u 40u 238u 24u "你可以使用默认路径，也可以选择其它磁盘或文件夹。安装器会自动创建缺失的目录。"
  Pop $0
  SendMessage $0 ${WM_SETFONT} $MineradioBodyFont 1
  SetCtlColors $0 "4B5263" "FFFFFF"

  ${NSD_CreateLabel} 22u 76u 238u 10u "安装目录"
  Pop $0
  SendMessage $0 ${WM_SETFONT} $MineradioSmallFont 1
  SetCtlColors $0 "3257F7" "FFFFFF"

  ${NSD_CreateText} 22u 94u 178u 15u "$INSTDIR"
  Pop $MineradioDirectoryInput
  SendMessage $MineradioDirectoryInput ${WM_SETFONT} $MineradioBodyFont 1
  SetCtlColors $MineradioDirectoryInput "111217" "FFFFFF"

  ${NSD_CreateBrowseButton} 210u 93u 50u 17u "浏览..."
  Pop $0
  SendMessage $0 ${WM_SETFONT} $MineradioSmallFont 1
  ${NSD_OnClick} $0 MineradioDirectoryBrowse

  ${NSD_CreateLabel} 22u 122u 238u 12u "默认推荐：D:\Mineradio-W；选盘符会自动建文件夹。"
  Pop $0
  SendMessage $0 ${WM_SETFONT} $MineradioSmallFont 1
  SetCtlColors $0 "6B7280" "FFFFFF"

  nsDialogs::Show
FunctionEnd

Function MineradioDirectoryLeave
  ${NSD_GetText} $MineradioDirectoryInput $0
  ${If} $0 == ""
    MessageBox MB_ICONEXCLAMATION|MB_OK "请选择安装文件夹。"
    Abort
  ${EndIf}
  Push "$0"
  Call MineradioNormalizeInstallDirPreservingAdopted
  Pop $0
  StrCpy $INSTDIR "$0"
  SendMessage $MineradioDirectoryInput ${WM_SETTEXT} 0 "STR:$INSTDIR"
  Call MineradioValidateInstallDir
  Call MineradioDisableUnsafeOldUninstallers
FunctionEnd

Function .onInstFailed
  Call MineradioRestoreLegacyUninstallRegistration
FunctionEnd
!endif

!ifdef BUILD_UNINSTALLER
!macro customUnInit
  Call un.MineradioValidateUninstallDir
!macroend

Function un.MineradioTrimInstallDir
  Exch $0

  trim:
    StrLen $1 "$0"
    ${If} $1 > 3
      StrCpy $2 "$0" 1 -1
      ${If} $2 == "\"
        StrCpy $0 "$0" -1
        Goto trim
      ${EndIf}
    ${EndIf}

  Exch $0
FunctionEnd

Function un.MineradioInstallDirHasSupportedFinalComponent
  Exch $0
  StrCpy $1 "0"

  Push "$0"
  Call un.MineradioTrimInstallDir
  Pop $2
  ${If} $2 == ""
    Goto done
  ${EndIf}

  ${un.GetFileName} "$2" $3
  ${If} $3 == "${MINERADIO_INSTALL_FOLDER}"
    StrCpy $1 "1"
  ${ElseIf} $3 == "${MINERADIO_LEGACY_INSTALL_FOLDER}"
    StrCpy $1 "1"
  ${EndIf}

  done:
    StrCpy $0 "$1"
    Exch $0
FunctionEnd

Function un.MineradioInstallDirHasValidMarker
  Exch $0
  StrCpy $1 "0"

  IfFileExists "$0\${MINERADIO_INSTALL_MARKER}" 0 done
  ClearErrors
  FileOpen $2 "$0\${MINERADIO_INSTALL_MARKER}" r
  ${If} ${Errors}
    Goto done
  ${EndIf}

  readLoop:
    ClearErrors
    FileRead $2 $3
    ${If} ${Errors}
      Goto closeFile
    ${EndIf}
    StrCmp $3 "appId=${MINERADIO_INSTALL_APP_ID}$\r$\n" found
    StrCmp $3 "appId=${MINERADIO_INSTALL_APP_ID}$\n" found
    StrCmp $3 "appId=${MINERADIO_INSTALL_APP_ID}" found
    Goto readLoop

  found:
    StrCpy $1 "1"

  closeFile:
    FileClose $2

  done:
    StrCpy $0 "$1"
    Exch $0
FunctionEnd

Function un.MineradioValidateUninstallDir
  Push "$INSTDIR"
  Call un.MineradioTrimInstallDir
  Pop $0
  Push "$0"
  Call un.MineradioInstallDirHasSupportedFinalComponent
  Pop $1
  ${If} $1 != "1"
    MessageBox MB_OK|MB_ICONSTOP "当前卸载路径不是 Mineradio W 专属目录，已阻止卸载以避免误删其它文件。$\r$\n$\r$\n当前路径：$INSTDIR"
    SetErrorLevel 2
    Quit
  ${EndIf}
  StrCpy $INSTDIR "$0"

  Push "$INSTDIR"
  Call un.MineradioInstallDirHasValidMarker
  Pop $0
  ${If} $0 != "1"
    MessageBox MB_OK|MB_ICONSTOP "无法确认当前目录属于 Mineradio W，已阻止卸载以避免误删其它文件。$\r$\n$\r$\n当前路径：$INSTDIR"
    SetErrorLevel 2
    Quit
  ${EndIf}
FunctionEnd

Function un.MineradioRemoveInstalledFiles
  SetOutPath $TEMP

  Delete "$INSTDIR\${PRODUCT_FILENAME}.exe"
  Delete "$INSTDIR\Mineradio-W.exe"
  Delete "$INSTDIR\Uninstall Mineradio W.exe"
  Delete "$INSTDIR\Uninstall ${PRODUCT_FILENAME}.exe"
  Delete "$INSTDIR\uninstallerIcon.ico"
  Delete "$INSTDIR\${MINERADIO_INSTALL_MARKER}"

  Delete "$INSTDIR\chrome_100_percent.pak"
  Delete "$INSTDIR\chrome_200_percent.pak"
  Delete "$INSTDIR\chrome_crashpad_handler.exe"
  Delete "$INSTDIR\d3dcompiler_47.dll"
  Delete "$INSTDIR\dawn.dll"
  Delete "$INSTDIR\dawn_proc.dll"
  Delete "$INSTDIR\dawn_native.dll"
  Delete "$INSTDIR\dawn_platform.dll"
  Delete "$INSTDIR\dxcompiler.dll"
  Delete "$INSTDIR\dxil.dll"
  Delete "$INSTDIR\ffmpeg.dll"
  Delete "$INSTDIR\icudtl.dat"
  Delete "$INSTDIR\libEGL.dll"
  Delete "$INSTDIR\libGLESv2.dll"
  Delete "$INSTDIR\LICENSE.electron.txt"
  Delete "$INSTDIR\LICENSES.chromium.html"
  Delete "$INSTDIR\resources.pak"
  Delete "$INSTDIR\snapshot_blob.bin"
  Delete "$INSTDIR\v8_context_snapshot.bin"
  Delete "$INSTDIR\vk_swiftshader.dll"
  Delete "$INSTDIR\vk_swiftshader_icd.json"
  Delete "$INSTDIR\vulkan-1.dll"

  Delete "$INSTDIR\resources\app-update.yml"
  Delete "$INSTDIR\resources\elevate.exe"
  Delete "$INSTDIR\resources\app.asar"
  RMDir /r "$INSTDIR\resources\app"
  RMDir "$INSTDIR\resources"
  RMDir /r "$INSTDIR\locales"
  RMDir /r "$INSTDIR\swiftshader"

  RMDir "$INSTDIR"
FunctionEnd
!endif
