unit FORMficha;

interface

uses
  myORM.CONTROLLER.GENERICO,myORM.BASE.ATRIBUTOS,myORM.DAO.FIREDAC,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TFormFichaORM = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormFichaORM: TFormFichaORM;
  DAO : TDaoFiredac ;

implementation

{$R *.dfm}

procedure TFormFichaORM.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if Assigned(DAO) then
 begin
   DAO.RollBack ;
   DAO.FreeInstance ;
 end;
end;

end.
