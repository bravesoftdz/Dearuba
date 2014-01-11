unit DearubaClass;

interface

uses Windows, Sysutils, Classes, IdHttp;

type
  TDearubaClass = class(TObject)
  private
    FSSIDList: array of String;
  public
    FUsername, FPassword: String;

    procedure AddAllowNetwork(NetworkSSID: String);
    procedure CheckArubaNetworks;

    constructor Create;
  end;

function Encode64(S: string): string;
function Decode64(S: string): string;

const
  Codes64 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';

implementation

function Encode64(S: string): string;
var
  i: Integer;
  a: Integer;
  x: Integer;
  b: Integer;
begin
  Result:='';
  a:=0;
  b:=0;
  for i:=1 to Length(S) do
  begin
    x:=Ord(S[i]);
    b:=b * 256 + x;
    a:=a + 8;
    while a >= 6 do
    begin
      a:=a - 6;
      x:=b div (1 shl a);
      b:=b mod (1 shl a);
      Result:=Result + Codes64[x + 1];
    end;
  end;
  if a > 0 then
  begin
    x:=b shl (6 - a);
    Result:=Result + Codes64[x + 1];
  end;
end;

function Decode64(S: string): string;
var
  i: Integer;
  a: Integer;
  x: Integer;
  b: Integer;
begin
  Result:='';
  a:=0;
  b:=0;
  for i:=1 to Length(S) do
  begin
    x:=Pos(S[i], Codes64) - 1;
    if x >= 0 then
    begin
      b:=b * 64 + x;
      a:=a + 6;
      if a >= 8 then
      begin
        a:=a - 8;
        x:=b shr a;
        b:=b mod (1 shl a);
        x:=x mod 256;
        Result:=Result + chr(x);
      end;
    end
    else
      Exit;
  end;
end;

function Url_Encode(const Url: string): string;
var
  i: Integer;
begin
  Result:='';
  for i:=1 to Length(Url) do
  begin
    case Url[i] of
      'a' .. 'z', 'A' .. 'Z', '0' .. '9', '/', '.', '&', '-':
        Result:=Result + Url[i];
    else
      Result:=Result + '%' + UpperCase(IntToHex(Ord(Url[i]), 2));
    end;
  end;
end;

procedure TDearubaClass.AddAllowNetwork(NetworkSSID: String);
begin
  SetLength(FSSIDList, High(FSSIDList) + 2);
  FSSIDList[ High(FSSIDList)]:=NetworkSSID;
end;

procedure TDearubaClass.CheckArubaNetworks;
var
  bAuthNow: Boolean;
  HttpObject: TIdHttp;
  PostStrings: TStringList;
  RedirectLocation: String;
  i: Integer;
begin
  HttpObject:=TIdHttp.Create(nil);
  HttpObject.Request.UserAgent:='Mozilla/4.0';
  HttpObject.HTTPOptions:=[];
  HttpObject.ConnectTimeout:=10000;
  HttpObject.ReadTimeout:=30000;
  bAuthNow:=False;
  try
    HttpObject.Get('http://www.apple.com/library/test/success.html');
  except
    on E: Exception do
    begin
      if Pos('302', E.Message) > 0 then
      begin
        RedirectLocation:=UpperCase(HttpObject.Response.RawHeaders.Values['Location']);
        for i:=0 to High(FSSIDList) do
          if (Pos(UpperCase('essid=' + FSSIDList[i]), RedirectLocation) > 0) then
            bAuthNow:=True;
      end;
    end;
  end;
  if bAuthNow then
  begin
    OutputDebugString('[Dearuba] Authenticating Aruba...');
    PostStrings:=TStringList.Create;
    PostStrings.Text:='user=' + Url_Encode(FUsername) + '&password=' + Url_Encode(FPassword);
    HttpObject.Post('http://securelogin.arubanetworks.com/cgi-bin/login', PostStrings);
    PostStrings.Free;
    try
      HttpObject.Get('http://www.apple.com/library/test/success.html');
    except
      on E: Exception do
      begin
        if Pos('302', E.Message) > 0 then
        begin
          OutputDebugString('[Dearuba] Authentication Failed...');
          Messagebox(0, 'Invalid Username/Password. Exiting...', 'Auto Aruba', MB_ICONHAND);
          ExitProcess(0);
        end;
      end;
    end;
  end;
  HttpObject.Free;
end;

constructor TDearubaClass.Create;
begin
  SetLength(FSSIDList, 0);
  FUsername:='';
  FPassword:='';
end;

end.
