[Setup]
AppName=Hirviurheilu Offline
AppVersion=1.4.0
DefaultDirName={pf}\Hirviurheilu
DefaultGroupName=Hirviurheilu
OutputBaseFilename=HirviurheiluOffline-asennus

[Icons]
Name: "{group}\Hirviurheilu Offline"; Filename: "{app}\hirviurheilu.exe"
Name: "{group}\Poista Hirviurheilu Offline"; Filename: "{uninstallexe}"
Name: "{commondesktop}\Hirviurheilu Offline"; Filename: "{app}\hirviurheilu.exe"

[Languages]
Name: "fi"; MessagesFile: "compiler:Languages\Finnish.isl"

[Messages]
WelcomeLabel2=Olet asentamassa koneellesi ohjelmaa [name/ver]. %n%n****** T�RKE��! ****** %nMik�li Hirviurheilu Offline on t�ll� hetkell� k�ynniss�, SULJE SE ENNEN KUIN ALOITAT P�IVITYKSEN. (Jos olet asentamassa ohjelmaa ensimm�ist� kertaa, voit jatkaa normaalisti.)

[InstallDelete]
Type: filesandordirs; Name: "{app}\lib"
Type: filesandordirs; Name: "{app}\src\public"
Type: filesandordirs; Name: "{app}\src\vendor"
Type: filesandordirs; Name: "{app}\src\tmp"
