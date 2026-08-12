unit hUGESettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, INIFiles, Constants, Forms, Dialogs;

const
  MAX_RECENT_FILES = 10;
  RECENT_FILES_SECTION = 'RecentFiles';

type

  { TTrackerSettings }

  TTrackerSettings = class
  private
    FDisplayRowNumbersAsHex: Boolean;
    FDisplayOrderRowNumbersAsHex: Boolean;
    FPreviewWhenBumping: Boolean;
    FPreviewWhenPlacing: Boolean;
    FDrawWaveformGrid: Boolean;
    FVerticalTabs: Boolean;
    SettingsFile: TINIFile;

    FPatternEditorFontSize: Integer;
    FUseScopes, FUseCustomKeymap: Boolean;

    FMIDIInputEnabled: Boolean;
    FMIDIInputDevice: String;

    FRecentFiles: TStringList;

    procedure SetDisplayOrderRowNumbersAsHex(AValue: Boolean);
    procedure SetDisplayRowNumbersAsHex(AValue: Boolean);
    procedure SetDrawWaveformGrid(AValue: Boolean);
    procedure SetVerticalTabs(AValue: Boolean);
    procedure SetPatternEditorFontSize(AValue: Integer);
    procedure SetPreviewWhenBumping(AValue: Boolean);
    procedure SetPreviewWhenPlacing(AValue: Boolean);
    procedure SetUseCustomKeymap(AValue: Boolean);
    procedure SetUseScopes(AValue: Boolean);
    procedure SetMIDIInputEnabled(AValue: Boolean);
    procedure SetMIDIInputDevice(const AValue: String);

    procedure WriteRecentFilesToIni;
  public
    property PatternEditorFontSize: Integer read FPatternEditorFontSize write SetPatternEditorFontSize;
    property UseScopes: Boolean read FUseScopes write SetUseScopes;
    property UseCustomKeymap: Boolean read FUseCustomKeymap write SetUseCustomKeymap;
    property PreviewWhenPlacing: Boolean read FPreviewWhenPlacing write SetPreviewWhenPlacing;
    property PreviewWhenBumping: Boolean read FPreviewWhenBumping write SetPreviewWhenBumping;
    property DisplayRowNumbersAsHex: Boolean read FDisplayRowNumbersAsHex write SetDisplayRowNumbersAsHex;
    property DisplayOrderRowNumbersAsHex: Boolean read FDisplayOrderRowNumbersAsHex write SetDisplayOrderRowNumbersAsHex;
    property DrawWaveformGrid: Boolean read FDrawWaveformGrid write SetDrawWaveformGrid;
    property VerticalTabs: Boolean read FVerticalTabs write SetVerticalTabs;
    property MIDIInputEnabled: Boolean read FMIDIInputEnabled write SetMIDIInputEnabled;
    property MIDIInputDevice: String read FMIDIInputDevice write SetMIDIInputDevice;

    property RecentFiles: TStringList read FRecentFiles;
    procedure PushRecentFile(const Path: String);
    procedure RemoveRecentFile(const Path: String);
    procedure ClearRecentFiles;

    constructor Create;
    destructor Destroy; override;
  end;

procedure InitializeTrackerSettings;

var
  TrackerSettings: TTrackerSettings = nil;

implementation

procedure SetupDirectoryParameter(Param: String; Default: String; out Variable: ShortString);
var
  S: String;
begin
  Variable := Default;

  S := Application.GetOptionValue(Param);
  if S <> '' then begin
    if not DirectoryExists(S) then
      ShowMessage('Specified '+Param+' does not exist. Using '+Default+' instead.')
    else
      Variable := S;
  end;
end;

procedure InitializeTrackerSettings;
var
  XDGConfigDir, XDGCacheDir, MacConfigDir, MacCacheDir: String;
begin
  {$ifdef MSWINDOWS}
  SetupDirectoryParameter('conf_dir', '.', ConfDir);
  SetupDirectoryParameter('cache_dir', '.', CacheDir);
  SetupDirectoryParameter('runtime_dir', '.', RuntimeDir);
  {$endif}

  {$if defined(LINUX) or defined(FREEBSD) or defined(OPENBSD)}
  XDGConfigDir := GetEnvironmentVariable('XDG_CONFIG_HOME');
  if XDGConfigDir = '' then
    XDGConfigDir := ConcatPaths([GetUserDir, '.config', 'hUGETracker']);

  XDGCacheDir := GetEnvironmentVariable('XDG_CACHE_HOME');
  if XDGCacheDir = '' then
    XDGCacheDir := ConcatPaths([GetUserDir, '.cache', 'hUGETracker']);

  if not DirectoryExists(XDGConfigDir) then ForceDirectories(XDGConfigDir);
  if not DirectoryExists(XDGCacheDir) then ForceDirectories(XDGCacheDir);

  SetupDirectoryParameter('conf_dir', XDGConfigDir, ConfDir);
  SetupDirectoryParameter('cache_dir', XDGCacheDir, CacheDir);
  SetupDirectoryParameter('runtime_dir', '.', RuntimeDir);
  {$endif}

  {$ifdef DARWIN}
    MacConfigDir := ConcatPaths([GetUserDir, '.config', 'hUGETracker']);
    MacCacheDir := ConcatPaths([GetUserDir, '.cache', 'hUGETracker']);

    if not DirectoryExists(MacConfigDir) then ForceDirectories(MacConfigDir);
    if not DirectoryExists(MacCacheDir) then ForceDirectories(MacCacheDir);

    SetupDirectoryParameter('conf_dir', MacConfigDir, ConfDir);
    SetupDirectoryParameter('cache_dir', MacCacheDir, CacheDir);

    {$ifdef DEVELOPMENT}
      SetupDirectoryParameter('runtime_dir', '../../..', RuntimeDir);
    {$else}
      SetupDirectoryParameter('runtime_dir', '../Resources', RuntimeDir);
    {$endif}
  {$endif}

  TrackerSettings := TTrackerSettings.Create;
end;

{ TTrackerSettings }

procedure TTrackerSettings.SetPatternEditorFontSize(AValue: Integer);
begin
  FPatternEditorFontSize := AValue;
  SettingsFile.WriteInteger('hUGETracker', 'fontsize', AValue);
end;

procedure TTrackerSettings.SetDisplayRowNumbersAsHex(AValue: Boolean);
begin
  FDisplayRowNumbersAsHex:=AValue;
  SettingsFile.WriteBool('hUGETracker', 'DisplayRowNumbersAsHex', AValue);
end;

procedure TTrackerSettings.SetDrawWaveformGrid(AValue: Boolean);
begin
  FDrawWaveformGrid:=AValue;
  SettingsFile.WriteBool('hUGETracker', 'DrawWaveformGrid', AValue);
end;

procedure TTrackerSettings.SetVerticalTabs(AValue: Boolean);
begin
  FVerticalTabs:=AValue;
  SettingsFile.WriteBool('hUGETracker', 'VerticalTabs', AValue);
end;

procedure TTrackerSettings.SetDisplayOrderRowNumbersAsHex(AValue: Boolean);
begin
  FDisplayOrderRowNumbersAsHex:=AValue;
  SettingsFile.WriteBool('hUGETracker', 'DisplayOrderRowNumbersAsHex', AValue);
end;

procedure TTrackerSettings.SetPreviewWhenBumping(AValue: Boolean);
begin
  FPreviewWhenBumping:=AValue;
  SettingsFile.WriteBool('hUGETracker', 'PreviewWhenBumping', AValue);
end;

procedure TTrackerSettings.SetPreviewWhenPlacing(AValue: Boolean);
begin
  FPreviewWhenPlacing:=AValue;
  SettingsFile.WriteBool('hUGETracker', 'PreviewWhenPlacing', AValue);
end;

procedure TTrackerSettings.SetUseCustomKeymap(AValue: Boolean);
begin
  FUseCustomKeymap := AValue;
  SettingsFile.WriteBool('hUGETracker', 'CustomKeymap', AValue);
end;

procedure TTrackerSettings.SetUseScopes(AValue: Boolean);
begin
  FUseScopes := AValue;
  SettingsFile.WriteBool('hUGETracker', 'ScopesOn', AValue);
end;

procedure TTrackerSettings.SetMIDIInputEnabled(AValue: Boolean);
begin
  FMIDIInputEnabled := AValue;
  SettingsFile.WriteBool('hUGETracker', 'MIDIInputEnabled', AValue);
end;

procedure TTrackerSettings.SetMIDIInputDevice(const AValue: String);
begin
  FMIDIInputDevice := AValue;
  SettingsFile.WriteString('hUGETracker', 'MIDIInputDevice', AValue);
end;

procedure TTrackerSettings.WriteRecentFilesToIni;
var
  I: Integer;
begin
  // Rewrite the whole section so removed / reordered entries don't leak.
  SettingsFile.EraseSection(RECENT_FILES_SECTION);
  for I := 0 to FRecentFiles.Count-1 do
    SettingsFile.WriteString(
      RECENT_FILES_SECTION,
      'Recent'+IntToStr(I+1),
      FRecentFiles[I]);
end;

procedure TTrackerSettings.PushRecentFile(const Path: String);
var
  Normalized: String;
  ExistingIdx: Integer;
begin
  if Trim(Path) = '' then Exit;

  Normalized := ExpandFileName(Path);

  ExistingIdx := FRecentFiles.IndexOf(Normalized);
  if ExistingIdx = 0 then Exit; // Already at top — nothing to do
  if ExistingIdx > 0 then
    FRecentFiles.Delete(ExistingIdx);

  FRecentFiles.Insert(0, Normalized);

  while FRecentFiles.Count > MAX_RECENT_FILES do
    FRecentFiles.Delete(FRecentFiles.Count-1);

  WriteRecentFilesToIni;
end;

procedure TTrackerSettings.RemoveRecentFile(const Path: String);
var
  Normalized: String;
  Idx: Integer;
begin
  if Trim(Path) = '' then Exit;
  Normalized := ExpandFileName(Path);
  Idx := FRecentFiles.IndexOf(Normalized);
  if Idx < 0 then Exit;
  FRecentFiles.Delete(Idx);
  WriteRecentFilesToIni;
end;

procedure TTrackerSettings.ClearRecentFiles;
begin
  FRecentFiles.Clear;
  SettingsFile.EraseSection(RECENT_FILES_SECTION);
end;

constructor TTrackerSettings.Create;
var
  I: Integer;
  Path: String;
begin
  SettingsFile := TINIFile.Create(ConcatPaths([ConfDir, 'options.ini']));

  FPatternEditorFontSize := SettingsFile.ReadInteger('hUGETracker', 'fontsize', 12);
  FUseScopes := SettingsFile.ReadBool('hUGETracker', 'ScopesOn', False);
  FUseCustomKeymap := SettingsFile.ReadBool('hUGETracker', 'CustomKeymap', False);
  FPreviewWhenPlacing := SettingsFile.ReadBool('hUGETracker', 'PreviewWhenPlacing', True);
  FPreviewWhenBumping := SettingsFile.ReadBool('hUGETracker', 'PreviewWhenBumping', False);
  FDisplayRowNumbersAsHex := SettingsFile.ReadBool('hUGETracker', 'DisplayRowNumbersAsHex', False);
  FDisplayOrderRowNumbersAsHex := SettingsFile.ReadBool('hUGETracker', 'DisplayOrderRowNumbersAsHex', False);
  FDrawWaveformGrid := SettingsFile.ReadBool('hUGETracker', 'DrawWaveformGrid', False);
  FVerticalTabs := SettingsFile.ReadBool('hUGETracker', 'VerticalTabs', False);
  FMIDIInputEnabled := SettingsFile.ReadBool('hUGETracker', 'MIDIInputEnabled', False);
  FMIDIInputDevice := SettingsFile.ReadString('hUGETracker', 'MIDIInputDevice', '');

  FRecentFiles := TStringList.Create;
  for I := 1 to MAX_RECENT_FILES do begin
    Path := SettingsFile.ReadString(RECENT_FILES_SECTION, 'Recent'+IntToStr(I), '');
    if Trim(Path) = '' then Continue;

    Path := ExpandFileName(Path);
    // Defensive dedupe on load — the file may have been edited by hand,
    // or an older build may have written the same path twice.
    if FRecentFiles.IndexOf(Path) < 0 then
      FRecentFiles.Add(Path);
  end;
end;

destructor TTrackerSettings.Destroy;
begin
  FRecentFiles.Free;
  SettingsFile.Free;
  inherited Destroy;
end;

finalization
  if Assigned(TrackerSettings) then TrackerSettings.Free;

end.

