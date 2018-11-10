unit MyORM.Atributos;

interface

uses Rtti, System.Generics.Collections;

type

TPeriodo = record
  dtInicial : TDate ;
  dtFinal   : TDate ;
end;

// Enumerado de rotas de transacao entre o Form e o Model
TInOut = (envia,recebe);

// Enumerado de tipos de Variaveis
TEnumVar = (tvString,tvFloat,tvDate,tvChecked,tvImage,tvIndexCombo);


TMyLiveBind = class
  private
    FNomeComponent: String;
    FNomeProperty: String;
    FTipo: TEnumVar;

    procedure SetNomeComponent(const Value: String);
    procedure SetNomeProperty(const Value: String);
    procedure SetTipo(const Value: TEnumVar);


  public
    property NomeProperty : String  read FNomeProperty write SetNomeProperty ;
    property NomeComponent: String  read FNomeComponent write SetNomeComponent  ;
    property Tipo : TEnumVar  read FTipo write SetTipo;

    constructor Create(ANomeProperty:String ; ANomeComponente: String ; ATipo: TEnumVar);

end;

// Atributos
TResultArray = array of string ;

TCamposAnoni = record
    PKs         : TResultArray;
    NomeTabela  : string;
    Sep         : string;
    AutoInc     : string;

    NoInserts : TResultArray ;
    NoUpdates : TResultArray ;
    Uniques   : TResultArray ;

    TipoRtti    : TRttiType;
    NotNulos    : TResultArray;
end;
 
TFuncaoAnonima = reference to function(ACampos: TCamposAnoni): TValue  ;


implementation



{ TMyLiveBind }

constructor TMyLiveBind.Create(ANomeProperty, ANomeComponente: String ; ATipo: TEnumVar);
begin
  FNomeProperty := ANomeProperty ;
  FNomeComponent := ANomeComponente ;
  FTipo := ATipo ;
end;

procedure TMyLiveBind.SetNomeComponent(const Value: String);
begin
  FNomeComponent := Value;
end;

procedure TMyLiveBind.SetNomeProperty(const Value: String);
begin
  FNomeProperty := Value;
end;

procedure TMyLiveBind.SetTipo(const Value: TEnumVar);
begin
  FTipo := Value;
end;

end.
