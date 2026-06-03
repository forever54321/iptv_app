[Setup]
AppName=IPTV Player
AppVersion=1.0.0
AppPublisher=IPTV App
DefaultDirName={autopf}\IPTV Player
DefaultGroupName=IPTV Player
OutputDir={#SourcePath}
OutputBaseFilename=IPTV_Player_Setup
SetupIconFile={#SourcePath}..\windows\runner\resources\app_icon.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\iptv_app.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourcePath}..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\IPTV Player"; Filename: "{app}\iptv_app.exe"
Name: "{group}\{cm:UninstallProgram,IPTV Player}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\IPTV Player"; Filename: "{app}\iptv_app.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\iptv_app.exe"; Description: "{cm:LaunchProgram,IPTV Player}"; Flags: nowait postinstall skipifsilent
