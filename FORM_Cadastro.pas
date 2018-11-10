unit FORM_Cadastro;

interface

uses
  MyORM.Atributos.Dao,
  MyORM.Dao.Firedac,MyORM.Controller,
  MyORM.Collections,

  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Rtti, Vcl.StdCtrls,StrUtils;

type


TFormFichaORM = class(TForm)
    Memo1: TMemo;
    btn: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private

    { Private declarations }
  public
    CamposBuscaORM : TListaBuscaORM ;
    procedure ActionButtonCRUD();

    { Public declarations }
  end;

var
  FormFichaORM: TFormFichaORM;


implementation

{$R *.dfm}

procedure TFormFichaORM.ActionButtonCRUD();
 var
 ctx : TRttiContext ;
 typ : TRttiType ;
 field : TRttiField ;
 prop : TRttiProperty ;

begin

ctx := TRttiContext.Create ;
try
  begin
  typ := ctx.GetType( Self.ClassType) ;
  for field in typ.GetFields do
    case AnsiIndexStr(field.Name , ['btnInsert','btnEdit','btnPost','btnCancel','btnDelete']) of
       0 :
       begin
         for prop in typ.GetProperties do
          if prop.Name = 'Enabled' then
          begin
           if InTransaction then
            prop.SetValue(Self.FindComponent(field.Name),Boolean(False))
            else
            prop.SetValue(Self.FindComponent(field.Name),Boolean(True));

          end;
       end;
       1 :
       begin
         for prop in typ.GetProperties do
          if prop.Name = 'Enabled' then
          begin
           if InTransaction then
            prop.SetValue(Self.FindComponent(field.Name),Boolean(False))
            else
            prop.SetValue(Self.FindComponent(field.Name),Boolean(True));

          end;
       end;
       2 :
       begin
         for prop in typ.GetProperties do
          if prop.Name = 'Enabled' then
          begin
           if InTransaction then
            prop.SetValue(Self.FindComponent(field.Name),Boolean(true))
            else
            prop.SetValue(Self.FindComponent(field.Name),Boolean(false));

          end;
       end;
       3 :
       begin
         for prop in typ.GetProperties do
          if prop.Name = 'Enabled' then
          begin
           if InTransaction then
            prop.SetValue(Self.FindComponent(field.Name),Boolean(true))
            else
            prop.SetValue(Self.FindComponent(field.Name),Boolean(false));

          end;
       end;
       4 :
       begin
         for prop in typ.GetProperties do
          if prop.Name = 'Enabled' then
          begin
           if InTransaction then
            prop.SetValue(Self.FindComponent(field.Name),Boolean(false))
            else
            prop.SetValue(Self.FindComponent(field.Name),Boolean(true));

          end;
       end;
    end;

  end;
finally
  ctx.Free ;
end;
end;


procedure TFormFichaORM.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   FinalizaInstance ;
end;

end.
