unit MVC_Controller;

interface

uses
 Data.DB, MyORM.Atributos.Model ;

type
TAtualizaDataSource = procedure(Datasource:TDataSource) of object ;

TClassRecord = class

end;

iMyORM_Controller = interface


  procedure AtualizaEventos ;

   //CRUD BASICO
        function read():iMyORM_Controller ;
        function create_update(Value:TClassRecord):iMyORM_Controller ;
        function delete(Value:integer):iMyORM_Controller ;

   //Functions of Views
        procedure InsertView ;
        procedure UpdateView(Value:integer);

   function imprimirListagem:boolean;

end;

TControllerMyORM = class( TInterfacedObject, iMyORM_Controller )
    private
      FModelFactory : TClassTabela ;
      FDataSource : TDataSource ;
      FEvento :  TAtualizaDataSource;

        constructor Create(Evento:TAtualizaDataSource;Model:TClassTabela);
        destructor  Destroy();Override;

         procedure AtualizaEventos ;


    public

     //CRUD BASICO
        function read():iMyORM_Controller ; virtual; abstract;
        function create_update(Value:TClassRecord):iMyORM_Controller ;  virtual; abstract;
        function delete(Value:integer):iMyORM_Controller ;  virtual; abstract;

    //Functions of Views
        procedure InsertView ;  virtual; abstract;
        procedure UpdateView(Value:integer);  virtual; abstract;

   function imprimirListagem:boolean; virtual; abstract;

   class function New(EventoDatasource:TAtualizaDataSource;AModel:TClassTabela):iMyORM_Controller;


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

end;

destructor TControllerMyORM.Destroy;
begin
  if Assigned(FModelFactory) then
   TTabela(FModelFactory).Free ;

  inherited;
end;

class function TControllerMyORM.New(EventoDatasource: TAtualizaDataSource;
  AModel: TClassTabela): iMyORM_Controller;
begin
  Result := self.Create(EventoDatasource,AModel) ;
end;

end.
