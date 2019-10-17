unit MyORM.Atributos.Model;

interface

Uses MyORM.Atributos,Rtti,MyORM.Atributos.DAO,
System.SysUtils,DateUtils,Vcl.Dialogs,System.Generics.Collections;

type
iTabela = interface
  ['{EF34E754-43AA-41C6-8AAD-67B397BDA248}']
    function _insert : Boolean ;
    function _update : Boolean ;
    function _delete : Boolean ;
    function _getID : Integer  ;
    procedure getPopular_se(AResultORM:TResultORM);
end;

TTabela = class(TInterfacedObject,iTabela)
 protected
     procedure getPopular_se(AResultORM:TResultORM);
     function _getID : Integer  ;virtual;abstract;
 public
    function _insert : Boolean;virtual ;
    function _insertORM : TResultORM;virtual;
    function _update : Boolean ;virtual ;
    function _delete : Boolean ;

    constructor Create();Overload;
    constructor Create(ACod:integer);Overload;

end;

TClassTabela = class of TTabela ;

//Propriedades das Fields
TPropertyField  = (Unique, Required, NoInsert, NoUpdate, IsSearch);
TPropertyFields = set of TPropertyField ;

TNomeTabela = class(TCustomAttribute)
  private
    FNomeTabela: String;
    procedure SetNomeTabela(const Value: String);
  public
    constructor Create(ANomeTabela:String) ;
    property NomeTabela : String  read FNomeTabela write SetNomeTabela;
end;

TMasterDetail = class(TCustomAttribute)
  private
    FFieldDetail      : String ;
    FMasterTable: String;
    FFieldMasterDetail: String;
    procedure SetMasterTable(const Value: String);
    function  getFieldDetail: String;
    function  getFieldMasterDetail: String;
    function  getMasterTable: String;
    procedure SetFieldDetail(const Value: String);
    procedure SetFieldMasterDetail(const Value: String);
  public
    Constructor Create(AMasterTable,AFieldMasterTable,AFieldDetail : String);
     property MasterTable : String  read FMasterTable write SetMasterTable;
     property FieldMasterDetail : String  read FFieldMasterDetail write SetFieldMasterDetail;
     property FieldDetail : String  read FFieldDetail write SetFieldDetail;
end;

TLookupField = class(TCustomAttribute)
  private
    FLookupKey: String;
    FResultField: String;
    FkeyField: String;
    FDisplayLabel: String;
    FSize: Integer;
    FmodelLookup: TTabela;
    FnomeTabelaLookup: String;
    FColunaIndex : Integer ;


  public
    Constructor  Create(aNomeTabelaLookup, aKeyField,aLookupKey,aResultField,aDisplayLabel:String;aSize:Integer;aColuna:Integer=0);
    property nomeTabelaLookup : String  read FnomeTabelaLookup ;
    property modelLookup : TTabela  read FmodelLookup ;
    property keyField : String  read FkeyField ;
    property LookupKey : String  read FLookupKey ;
    property ResultField : String  read FResultField ;
    property Size : Integer  read FSize ;
    property DisplayLabel : String read FDisplayLabel;
    property ColunaIndex :integer  read FColunaIndex ;
end;

TCampos = class(TCustomAttribute)
  public
    function IsPK      : Boolean ; Virtual ;
    function IsAutoInc : Boolean ; Virtual ;
end;

TCamposProperty = class(TCustomAttribute)
  private
    FUnique   : Boolean ;
    FRequired : Boolean ;
    FNoInsert : Boolean ;
    FNoUpdate : Boolean ;
    FIsSearch : Boolean ;
  public
    Constructor Create(const AProperty:TPropertyFields);
    function isUnique   : boolean ;
    function isRequired : boolean ;
    function isNoInsert : boolean ;
    function isNoUpdate : boolean ;
    function isSearch   : boolean ;
end;

TCamposPK = class(TCampos)
  private
    FAutoInc: Boolean;
  public
    constructor Create(AAutoInc : Boolean);
    function IsPK : Boolean ; Override ;
    function IsAutoInc : Boolean ; Override ;
end;

TCamposInfo = class(TCustomAttribute)
    private
      FDisplayField : String ;
      FMaskField    : String ;
      FVisible      : Boolean ;
      FSize         : Integer ;

    public
      constructor Create(const NomeField:String;const Size:Integer = 0;const Mask : String = '';const Visible : Boolean = true) ;
      function getDisplayField : String ;
      function getMaskField : String ;
      function getVisibleField : Boolean ;
      function getSizeField : Integer ;

end;
// ------------------------- FIM DOS ATRIBUTOS MODEL ---------------------------
// -----------------------------------------------------------------------------

implementation

uses MyORM.Dao.Firedac,MyORM.Collections, Vcl.ExtCtrls, Data.DB,
  System.Classes;

{ TNomeTabela }
constructor TNomeTabela.Create(ANomeTabela: String);
begin
  FNomeTabela := ANomeTabela;
end;

procedure TNomeTabela.SetNomeTabela(const Value: String);
begin
  FNomeTabela := Value;
end;

{ TCamposPK }
constructor TCamposPK.Create(AAutoInc: Boolean);
begin
  FAutoInc := AAutoInc ;
end;

function TCamposPK.IsAutoInc: Boolean;
begin
  Result := FAutoInc ;
end;

function TCamposPK.IsPK: Boolean;
begin
  result := true ;
end;

{ TCampos }
function TCampos.IsAutoInc: Boolean;
begin
 Result := false ;
end;

function TCampos.IsPK: Boolean;
begin
  result := false ;
end;

{ TCamposInfo }
constructor TCamposInfo.Create(const NomeField: String;  const Size:Integer;
  const Mask: String; const Visible: Boolean);
begin
  FDisplayField := NomeField ;
  FMaskField    := Mask ;
  FVisible      := Visible ;
  FSize := Size ;
end;

function TCamposInfo.getDisplayField: String;
begin
  Result := FDisplayField ;
end;

function TCamposInfo.getMaskField: String;
begin
  Result := FMaskField ;
end;

function TCamposInfo.getSizeField: Integer;
begin
  Result := FSize ;
end;

function TCamposInfo.getVisibleField: Boolean;
begin
  Result := FVisible ;
end;

{ TCamposProperty }

constructor TCamposProperty.Create(const AProperty: TPropertyFields);
begin
 if TPropertyField.Unique   in AProperty then
    FUnique:=true;
 if TPropertyField.Required in AProperty then
    FRequired := true;
 if TPropertyField.NoInsert in AProperty then
    FNoInsert := true ;
 if TPropertyField.NoUpdate in AProperty then
    FNoUpdate := true ;
 if TPropertyField.IsSearch in AProperty then
    FIsSearch := true ;
end;

function TCamposProperty.isNoInsert: boolean;
begin
  Result := FNoInsert ;
end;

function TCamposProperty.isNoUpdate: boolean;
begin
  Result := FNoUpdate ;
end;

function TCamposProperty.isRequired: boolean;
begin
  Result := FRequired ;
end;

function TCamposProperty.isSearch: boolean;
begin
  Result := FIsSearch ;
end;

function TCamposProperty.isUnique: boolean;
begin
  Result := FUnique ;
end;

{ TMasterDetail }

constructor TMasterDetail.Create(AMasterTable, AFieldMasterTable,
  AFieldDetail: String);
begin
  FMasterTable      := AMasterTable ;
  FFieldMasterDetail := AFieldMasterTable ;
  FFieldDetail      := AFieldDetail ;
end;

function TMasterDetail.getFieldDetail: String;
begin
  Result := FFieldDetail ;
end;

function TMasterDetail.getFieldMasterDetail: String;
begin
  Result := FFieldMasterDetail ;
end;

function TMasterDetail.getMasterTable: String;
begin
  Result := FMasterTable ;
end;

procedure TMasterDetail.SetFieldDetail(const Value: String);
begin
  FFieldDetail := Value;
end;

procedure TMasterDetail.SetFieldMasterDetail(const Value: String);
begin
  FFieldMasterDetail := Value;
end;

procedure TMasterDetail.SetMasterTable(const Value: String);
begin
  FMasterTable := Value;
end;

{ TLookupField }

constructor TLookupField.Create(aNomeTabelaLookup,aKeyField,aLookupKey,aResultField,aDisplayLabel:String;aSize:Integer;aColuna:Integer=0);
begin
  FnomeTabelaLookup := aNomeTabelaLookup ;
  FkeyField := aKeyField ;
  FLookupKey := aLookupKey ;
  FResultField := aResultField ;
  FDisplayLabel := aDisplayLabel ;
  FSize := aSize ;
  FColunaIndex := aColuna ;
end;

{ TTabela }
constructor TTabela.Create;
begin
  Inherited Create ;
end;

constructor TTabela.Create(ACod: integer);
var
  condition: TConditionSQL;
  lista: TList<TConditionSQL>;
  orderBy : TList<TOrderBySQL> ;
  res : TResultORM ;
begin

  condition.campo := getPKClass(Self);
  condition.valor := ACod;
  condition.tipo := [igual];

  lista := TList<TConditionSQL>.Create;
  orderBy := TList<TOrderBySQL>.Create ;
  lista.Add(condition);

  res := selectORM( Self, lista, orderBy);
  Inherited Create() ;

  Self.getPopular_se(res);

  lista.Free ;
  orderBy.Free ;

end;

procedure TTabela.getPopular_se(AResultORM: TResultORM);
var
cxt : TRttiContext ;
tip : TRttiType ;
attri : TCustomAttribute ;
prop : TRttiProperty ;
AtribRtti : TCustomAttribute ;
image : TImage ;
stream : TStream ;
begin
 cxt := TRttiContext.Create;
 tip := cxt.GetType(Self.ClassInfo);

 for prop in tip.GetProperties do
 begin
    if (Prop.Name <> 'RefCount') then
    begin
        for AtribRtti in Prop.GetAttributes do
        begin
          if AtribRtti is TCamposProperty then
          begin
             prop.PropertyType.TypeKind ;
             case prop.PropertyType.TypeKind of

                tkInteger,tkInt64:
                     prop.SetValue(self,AResultORM.qryReturn.FieldByName(prop.Name).AsInteger);
                tkString, tkUString , tkChar {Tipos para postGreSQL},tkWideChar,tkWideString, tkAnsiString:
                     prop.SetValue(self,AResultORM.qryReturn.FieldByName(prop.Name).AsString);
                tkFloat :
                  begin
                     if CompareText(Prop.PropertyType.Name, 'TDate') = 0 then
                       prop.SetValue(self,AResultORM.qryReturn.FieldByName(prop.Name).AsDateTime)
                     else
                     if CompareText(Prop.PropertyType.Name, 'TTime') = 0 then
                       prop.SetValue(self,AResultORM.qryReturn.FieldByName(prop.Name).AsDateTime)
                     else
                     if CompareText(Prop.PropertyType.Name, 'TDateTime') = 0 then
                       prop.SetValue(self,AResultORM.qryReturn.FieldByName(prop.Name).AsDateTime)
                     else
                       prop.SetValue(self,AResultORM.qryReturn.FieldByName(prop.Name).AsFloat);
                  end;
                tkClass :
                  begin
//                    image := TImage.Create(nil);
//                    image.Picture.Assign( TGraphicField(AResultORM.qryReturn.FieldByName(prop.Name)) );


                    stream := TMemoryStream.Create;
                    TBlobField(AResultORM.qryReturn.FieldByName(prop.Name)).SaveToStream(stream);
                    stream.Position := 0 ;



                    prop.SetValue(self,stream);
                  end;


              end;

          end;
        end;


    end ;

 end;
end;


function TTabela._delete: Boolean;
var
  Dao: TDaoFiredac;
begin
  Dao := TDaoFiredac.getInstancia;

    Result := Dao.Excluir2_0(self);
    Dao.Commit;
end;


function TTabela._insert: boolean;
var
  Dao: TDaoFiredac;
begin

  Dao := TDaoFiredac.getInstancia;

  if Dao.verificaNotNull(self) then
  begin
    result := Dao.Inserir(self).rowReturn > 0;
  end;

  if result then
    Dao.Commit;
end;

function TTabela._insertORM: TResultORM;
var
  Dao: TDaoFiredac;
begin

  Dao := TDaoFiredac.getInstancia;

  if Dao.verificaNotNull(self) then
  begin
    result := Dao.Inserir(self);
  end;

  if result.rowReturn > 0  then
    Dao.Commit;
end;



function TTabela._update: Boolean;
var
  Dao: TDaoFiredac;
begin
  Dao:= TDaoFiredac.getInstancia;
    Result := Dao.Salvar(Self).rowReturn > 0;
    Dao.Commit;

end;

end.

