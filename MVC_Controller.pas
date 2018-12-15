unit MVC_Controller;

interface

uses
 Data.DB, MyORM.Atributos.Model ;

type
TAtualizaDataSource = procedure(Datasource:TDataSource) of object ;

TClassRecord = class

end;

TControllerMyORM = class;



TControllerMyORM = class
    protected
      FModelFactory : TClassTabela ;
      FEvento :  TAtualizaDataSource;
       FDataSource : TDataSource ;
       FDataSourceItens : TDataSource ;
    private


        constructor Create(Evento:TAtualizaDataSource;Model:TClassTabela);
        destructor  Destroy();Override;




    public


     //CRUD BASICO
        function read():TControllerMyORM ; virtual; abstract;
        function create_update(Value:TClassRecord):TControllerMyORM ;  virtual; abstract;
        function delete(Value:integer):TControllerMyORM ;  virtual; abstract;

    //Functions of Views
        procedure InsertView ;  virtual; abstract;
        procedure UpdateView(Value:integer);  virtual; abstract;

        procedure AtualizaEventos ;
   function imprimirListagem:boolean; virtual; abstract;

   class function New(EventoDatasource:TAtualizaDataSource;AModel:TClassTabela):TControllerMyORM;


end;



implementation

{ TControllerMyORM }

procedure TControllerMyORM.AtualizaEventos;
begin
   FEvento(FDataSource);
end;

constructor TControllerMyORM.Create(Evento: TAtualizaDataSource;
  Model: TClassTabela);
begin

  inherited Create ;
  FEvento := Evento ;
  FModelFactory := Model ;

  FDataSource := TDataSource.Create(nil);

end;

destructor TControllerMyORM.Destroy;
begin
  if Assigned(FModelFactory) then
   TTabela(FModelFactory).Free ;

  inherited;
end;

class function TControllerMyORM.New(EventoDatasource: TAtualizaDataSource;
  AModel: TClassTabela): TControllerMyORM;
begin
  Result :=  self.Create(EventoDatasource,AModel) ;
end;

end.
