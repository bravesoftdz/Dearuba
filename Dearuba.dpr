program Dearuba;
{$R *.res}

uses
  Windows,
  Sysutils,
  IniFiles,
  Dialogs,
  DearubaClass in 'DearubaClass.pas';

var
  IniFile: TIniFile;
  DearubaClass: TDearubaClass;

begin
  DearubaClass:=TDearubaClass.Create;
  DearubaClass.AddAllowNetwork(' '); {* Wired Connections *}
  {* Add Your Allow Networks Here *}
  IniFile:=TIniFile.Create(GetCurrentDir + '\Aruba.ini');
  DearubaClass.FUsername:=IniFile.ReadString('Aruba', 'Username', '');
  DearubaClass.FPassword:=IniFile.ReadString('Aruba', 'Password', '');
  if (DearubaClass.FUsername = '') or (DearubaClass.FPassword = '') then
  begin
    DearubaClass.FUsername:=Encode64(Inputbox('Dearuba', 'Enter Your Aruba Username:', ''));
    DearubaClass.FPassword:=Encode64(Inputbox('Dearuba', 'Enter Your Aruba Password:', ''));
    IniFile.WriteString('Aruba', 'Username', DearubaClass.FUsername);
    IniFile.WriteString('Aruba', 'Password', DearubaClass.FPassword);
  end;
  DearubaClass.FUsername:=Decode64(DearubaClass.FUsername);
  DearubaClass.FPassword:=Decode64(DearubaClass.FPassword);
  IniFile.Free;
  while true do
  begin
    try
      DearubaClass.CheckArubaNetworks;
    except
    end;
    Sleep(3000);
  end;

end.
