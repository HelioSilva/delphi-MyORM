unit MyORM.INI;
interface
uses
  Classes, SysUtils, IniFiles, Windows;

const
  csIniTipoSection = 'Tipo';
  csIniConexaoSection = 'Conexao';

  {Section: Tipo}
  csIniTipoEncoding = 'Encoding';

  {Section: Conexao}
  csIniConexaoSGBD = 'SGBD';
  csIniConexaoDriverID = 'DriverID';
  csIniConexaoServer = 'Server';
  csIniConexaoDatabase = 'Database';
  csIniConexaoUser_Name = 'User_Name';
  csIniConexaoPassword = 'Password';
  csIniConexaoPorta = 'Porta';

type
  TIniOptions = class(TObject)
  private
    {Section: Tipo}
    FTipoEncoding: string;

    {Section: Conexao}
    FConexaoSGBD: string;
    FConexaoDriverID: string;
    FConexaoServer: string;
    FConexaoDatabase: string;
    FConexaoUser_Name: string;
    FConexaoPassword: string;
    FConexaoPorta: Integer;
  public
    procedure LoadSettings(Ini: TIniFile);
    procedure SaveSettings(Ini: TIniFile);
    
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);

    {Section: Tipo}
    property TipoEncoding: string read FTipoEncoding write FTipoEncoding;

    {Section: Conexao}
    property ConexaoSGBD: string read FConexaoSGBD write FConexaoSGBD;
    property ConexaoDriverID: string read FConexaoDriverID write FConexaoDriverID;
    property ConexaoServer: string read FConexaoServer write FConexaoServer;
    property ConexaoDatabase: string read FConexaoDatabase write FConexaoDatabase;
    property ConexaoUser_Name: string read FConexaoUser_Name write FConexaoUser_Name;
    property ConexaoPassword: string read FConexaoPassword write FConexaoPassword;
    property ConexaoPorta: Integer read FConexaoPorta write FConexaoPorta;
  end;

var
  IniOptions: TIniOptions = nil;

implementation

procedure TIniOptions.LoadSettings(Ini: TIniFile);
begin
  if Ini <> nil then
  begin
    {Section: Tipo}
    FTipoEncoding := Ini.ReadString(csIniTipoSection, csIniTipoEncoding, 'UTF8');

    {Section: Conexao}
    FConexaoSGBD := Ini.ReadString(csIniConexaoSection, csIniConexaoSGBD, 'Firebird');
    FConexaoDriverID := Ini.ReadString(csIniConexaoSection, csIniConexaoDriverID, 'FB');
    FConexaoServer := Ini.ReadString(csIniConexaoSection, csIniConexaoServer, '127.0.0.1');
    FConexaoDatabase := Ini.ReadString(csIniConexaoSection, csIniConexaoDatabase, '');
    FConexaoUser_Name := Ini.ReadString(csIniConexaoSection, csIniConexaoUser_Name, 'SYSDBA');
    FConexaoPassword := Ini.ReadString(csIniConexaoSection, csIniConexaoPassword, 'masterkey');
    FConexaoPorta := Ini.ReadInteger(csIniConexaoSection, csIniConexaoPorta, 0);
  end;
end;

procedure TIniOptions.SaveSettings(Ini: TIniFile);
begin
  if Ini <> nil then
  begin
    {Section: Tipo}
    Ini.WriteString(csIniTipoSection, csIniTipoEncoding, FTipoEncoding);

    {Section: Conexao}
    Ini.WriteString(csIniConexaoSection, csIniConexaoSGBD, FConexaoSGBD);
    Ini.WriteString(csIniConexaoSection, csIniConexaoDriverID, FConexaoDriverID);
    Ini.WriteString(csIniConexaoSection, csIniConexaoServer, FConexaoServer);
    Ini.WriteString(csIniConexaoSection, csIniConexaoDatabase, FConexaoDatabase);
    Ini.WriteString(csIniConexaoSection, csIniConexaoUser_Name, FConexaoUser_Name);
    Ini.WriteString(csIniConexaoSection, csIniConexaoPassword, FConexaoPassword);
    Ini.WriteInteger(csIniConexaoSection, csIniConexaoPorta, FConexaoPorta);
  end;
end;

procedure TIniOptions.LoadFromFile(const FileName: string);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FileName);
  try
    LoadSettings(Ini);
  finally
    Ini.Free;
  end;
end;

procedure TIniOptions.SaveToFile(const FileName: string);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FileName);
  try
    SaveSettings(Ini);
  finally
    Ini.Free;
  end;
end;

initialization
  IniOptions := TIniOptions.Create;

finalization
  IniOptions.Free;

end.

