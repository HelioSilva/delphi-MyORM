unit MyORM.Collections;

interface

uses
  MyORM.Atributos,
  MyORM.Atributos.Model,
  MyORM.Atributos.Dao,
  MyORM.Controller,
  MyORM.Dao.Firedac, System.Generics.Collections, Vcl.Forms, System.TypInfo,
  cxCalc, Firedac.Comp.Client, Data.DB, cxCheckBox, System.Classes,
  cxDropDownEdit;

//Funcoes HOMOLOGACAO
function Insert2_0(ATabela:TTabela):integer ;


// TRANSAÇÕES ================================
function InTransaction: Boolean;
function StartTransaction: Boolean;
// ===========================================

// MODELS ====================================
//function getFactoryLista(ATabela: TObject): TResultORM; overload;
//function getFactoryLista(ATabela: TObject; APrimary: Integer)
//  : TResultORM; overload;

function getFactoryLista2_0(ATabela: TClassTabela): TResultORM; Overload;
function getFactoryLista2_0(ATabela: TClassTabela ; APrimary: Integer):TResultORM;Overload ;
// ===========================================

function gerenciamentoFORM(AForm: TForm; AObject: TObject;
  AList: TObjectList<TMyLiveBind>; ATrafego: TInOut): Boolean;

function conexao(APath: String): Boolean;


function PuxaCamposBusca(ATabela: TTabela): TListaBuscaORM;
procedure FinalizaInstance;

function getPKClass(ATTabela: TTabela): String;
function getPKClass2_0(ATTabela: TClassTabela): String;

function verificaNotNull(ATabela: TTabela): Boolean;

procedure exibirLookupDisplay(AQueryPrincipal, AQueryLookup: TFDQuery;
  ATabela: TClassTabela; ATabelaLookup: TClassTabela);

/// <summary>
/// <para>
/// Método para inserir no Banco de dados. Validações já estão encapsuladas.
/// Parametro : Objeto Model
/// Retorno : quantidade de registros inseridos
/// </para>
/// </summary>
///
function ExecComandoSQL(AParams: String): Boolean;
function comandoSQL(AParams: String): TResultORM;

//*********** Essa chamada foi desativada pois o insert está herdada no model _insert
//function insertORM(ATabela: TTabela): TResultORM;
//function updateORM(ATabela: TTabela): TResultORM;
function deleteORM(ATabela: TTabela; ACondition: TList<TConditionSQL>)
  : TResultORM;
function deleteORM2_0(AObject: iTabela): Boolean;


function selectORM(ATabela: TObject; ACondition: TList<TConditionSQL>;
  AOrder: TList<TOrderBySQL>): TResultORM;
function selectORM2_0(ATabela: TClassTabela; ACondition: TList<TConditionSQL>;
  AOrder: TList<TOrderBySQL>): TResultORM;

function masterDetail(AQryMaster: TFDQuery; ATabela: TClassTabela;
  ADataSource: TDataSource): TResultORM;

 procedure formatarFieldsResultORM(ATabela : TClassTabela; AFDQuery : TFDQuery) ;

implementation

uses
  System.Rtti, Vcl.StdCtrls, Vcl.Dialogs, System.SysUtils;


procedure formatarFieldsResultORM(ATabela : TClassTabela; AFDQuery : TFDQuery) ;
var dao : TDaoFiredac ;
begin
  dao := TDaoFiredac.getInstancia ;
  if AFDQuery.Active then
   AFDQuery.Active := false ;


  dao.configuraFields2_0(ATabela,AFDQuery);

  AFDQuery.Active := true ;
end;

function Insert2_0(ATabela:TTabela):integer ;
var dao : TDaoFiredac ;
begin
  dao := TDaoFiredac.getInstancia ;
  Result := dao.Inserir2_0(ATabela);
end;

// ======================TRANSACOES================================
function StartTransaction: Boolean;
var
  Dao: TDaoFiredac;
begin
 try
   Dao.getInstancia.StartTransaction;
   Result := true ;  
 except
   Result := false ;
 end; 
end;

function InTransaction: Boolean;
var
  Dao: TDaoFiredac;
begin
  if Dao.getInstancia.InTransaction then
    result := true
  else
    result := false;
end;
// ================================================================

// ===========================MODELS===============================
function getPKClass(ATTabela: TTabela): String;
var
  control: TControllerModel;
  response: TResultArray;
  campo: String;
begin
  response := control.PegaPKs(ATTabela);
  for campo in response do
  begin
    result := campo;
  end;
end;

function getPKClass2_0(ATTabela: TClassTabela): String;
var
  control: TControllerModel;
  response: TResultArray;
  campo: String;
begin
  response := control.PegaPKs2(ATTabela);
  for campo in response do
  begin
    result := campo;
  end;
end;

function getFactoryLista2_0(ATabela: TClassTabela): TResultORM;
var
 Conditions : TList<TConditionSQL> ;
 Order      : TList<TOrderBySQL> ;
 iteOrder : TOrderBySQL ;
 chavePrimaria : String ;
begin
  Conditions := TList<TConditionSQL>.Create;
  Order      := TList<TOrderBySQL>.Create;

  chavePrimaria :=  getPKClass2_0(ATabela) ;

  if chavePrimaria <> '' then
  begin
    iteOrder.campo := chavePrimaria ;
    iteOrder.order := [Asc];
    Order.Add(iteOrder) ;
  end;

  try
    Result := selectORM2_0(ATabela,Conditions,Order);
  finally
    Conditions.Free;
    Order.Free ;
  end;

end;

function getFactoryLista2_0(ATabela:TClassTabela; APrimary: Integer): TResultORM;
var
  condition: TConditionSQL;
  lista: TList<TConditionSQL>;
  orderBy : TList<TOrderBySQL> ;
begin

  condition.campo := getPKClass2_0(ATabela);
  condition.valor := APrimary;
  condition.tipo := [igual];

  lista := TList<TConditionSQL>.Create;
  orderBy := TList<TOrderBySQL>.Create ;
  lista.Add(condition);

  result := selectORM2_0(ATabela, lista, orderBy);

  lista.Free ;
  orderBy.Free ;

end;

// ================================================================
// ============================CRUD================================
function ExecComandoSQL(AParams: String): Boolean;
var
  Dao: TDaoFiredac;
begin
  Dao := TDaoFiredac.getInstancia ;
  Result :=  Dao.ExecSQL(AParams);
  Dao.Commit ;
end;

function comandoSQL(AParams: String): TResultORM;
var
  Dao: TDaoFiredac;
  resposta : TResultORM ;
  i: integer ;
begin
  Dao := TDaoFiredac.getInstancia ;

  resposta :=  Dao.ComandSQL(AParams);

    for I := 0 to resposta.qryReturn.Fields.Count-1 do
    begin
      if resposta.qryReturn.Fields[i] is TFloatField then
       TFloatField(resposta.qryReturn.Fields[i]).DisplayFormat := ',0.00';
    end;

  Result :=  resposta ;
  Dao.Commit;
end;

function selectORM(ATabela: TObject; ACondition: TList<TConditionSQL>;
  AOrder: TList<TOrderBySQL>): TResultORM;
var
  Dao: TDaoFiredac;
begin
  Result := Dao.getInstancia.Buscar(ATabela, ACondition, AOrder);
end;

function selectORM2_0(ATabela: TClassTabela; ACondition: TList<TConditionSQL>;
  AOrder: TList<TOrderBySQL>): TResultORM;
var
  Dao: TDaoFiredac;
begin
  Result := Dao.getInstancia.Buscar2_0(ATabela, ACondition, AOrder);
end;

function deleteORM(ATabela: TTabela; ACondition: TList<TConditionSQL>)
  : TResultORM;
var
  Dao: TDaoFiredac;
begin
  Dao.getInstancia;

  result.rowReturn := Dao.Excluir(ATabela, ACondition).rowReturn;
  Dao.Commit;
end;

function deleteORM2_0(AObject: iTabela): Boolean;
var
  Dao: TDaoFiredac;
begin
  Dao.getInstancia;

    Result := Dao.Excluir2_0(AObject);
    Dao.Commit;
end;

function masterDetail(AQryMaster: TFDQuery; ATabela: TClassTabela;
  ADataSource: TDataSource): TResultORM;
var
  Dao: TDaoFiredac;
begin
  Dao:= TDaoFiredac.getInstancia;

    result := Dao.BuscarDetail(AQryMaster, ATabela, ADataSource);
end;

// ================================================================
procedure FinalizaInstance;
var
  Dao: TDaoFiredac;
begin
 Dao := TDaoFiredac.getInstancia ;
   Dao.DestroyInstancia;
end;

function conexao(APath: String): Boolean;
var
  Dao: TDaoFiredac;
begin
  Dao := TDaoFiredac.getInstancia(APath)  ;

    if Dao.isConnection then
      result := true
    else
      result := false;

end;

function PuxaCamposBusca(ATabela: TTabela): TListaBuscaORM;
var
  control: TControllerModel;
begin
  result := control.getFieldsSearch(ATabela);
end;

function gerenciamentoFORM(AForm: TForm; AObject: TObject;
  AList: TObjectList<TMyLiveBind>; ATrafego: TInOut): Boolean;
var
  comando: TFuncaoAnonima;
begin
  comando := function(ACampos: TCamposAnoni): TValue
    var
      propComponente: TRttiProperty;
      fie: TRttiField;
      i: Integer;

      ctx2: TRttiContext;
      propModel: TRttiProperty;
      attribModel: TCustomAttribute;
      typ2: TRttiType;

    begin
      ctx2 := TRttiContext.Create;

      for fie in ACampos.TipoRtti.GetFields do
        for i := 0 to AList.Count - 1 do
        begin

          if fie.Name = AList[i].NomeComponent then
          begin

            case AList[i].tipo of

              tvIndexCombo:
                begin

                  typ2 := ctx2.GetType(AObject.ClassType);
                  for propModel in typ2.GetProperties do
                    if propModel.Name = AList[i].NomeProperty then
                    begin
                      case ATrafego of
                        envia:
                          begin
                            case propModel.PropertyType.TypeKind of

                              tkInteger, tkInt64:
                                begin
                                  propModel.SetValue(AObject,
                                    TcxComboBox(AForm.FindComponent(fie.Name))
                                    .ItemIndex);
                                end;
                            end;
                          end;
                        recebe:
                          begin

                            case propModel.PropertyType.TypeKind of

                              tkInteger, tkInt64:
                                begin
                                  TcxComboBox(AForm.FindComponent(fie.Name))
                                    .ItemIndex := propModel.GetValue(AObject)
                                    .AsInteger;
                                end;

                            end;
                          end;
                      end;
                    end;
                end;

              tvChecked:
                begin

                  typ2 := ctx2.GetType(AObject.ClassType);
                  for propModel in typ2.GetProperties do
                    if propModel.Name = AList[i].NomeProperty then
                    begin
                      case ATrafego of
                        envia:
                          begin
                            case propModel.PropertyType.TypeKind of
                              tkString, tkChar, tkUString:
                                begin
                                  if TcxCheckBox(AForm.FindComponent(fie.Name)).Checked
                                  then
                                    propModel.SetValue(AObject, 'S')
                                  else
                                    propModel.SetValue(AObject, 'N');
                                end;
                              tkInteger, tkInt64:
                                begin
                                  if TcxCheckBox(AForm.FindComponent(fie.Name)).Checked
                                  then
                                    propModel.SetValue(AObject, 1)
                                  else
                                    propModel.SetValue(AObject, 0);
                                end;
                            end;
                          end;
                        recebe:
                          begin

                            case propModel.PropertyType.TypeKind of
                              tkString, tkChar, tkUString:
                                begin
                                  if propModel.GetValue(AObject).AsString = 'S'
                                  then
                                    TcxCheckBox(AForm.FindComponent(fie.Name))
                                      .Checked := true
                                  else
                                    TcxCheckBox(AForm.FindComponent(fie.Name))
                                      .Checked := false;
                                end;
                              tkInteger, tkInt64:
                                begin
                                  if propModel.GetValue(AObject).AsInteger = 1
                                  then
                                    TcxCheckBox(AForm.FindComponent(fie.Name))
                                      .Checked := true
                                  else
                                    TcxCheckBox(AForm.FindComponent(fie.Name))
                                      .Checked := false;
                                end;
                            end;

                          end;
                      end;
                    end;
                end;

              tvString:
                begin

                  for propComponente in ACampos.TipoRtti.GetProperties do
                    if (propComponente.Name = 'Caption') or
                      (propComponente.Name = 'Text') then
                    begin
                      typ2 := ctx2.GetType(AObject.ClassType);
                      for propModel in typ2.GetProperties do

                        if propModel.Name = AList[i].NomeProperty then
                        begin
                          case ATrafego of
                            envia:
                              begin
                                case propModel.PropertyType.TypeKind of
                                  tkInteger, tkInt64:
                                    begin
                                      if propComponente.GetValue
                                        (AForm.FindComponent(fie.Name)).ToString
                                        <> '' then
                                        propModel.SetValue(AObject,
                                        strtoint(propComponente.GetValue
                                        (AForm.FindComponent(fie.Name))
                                        .ToString));
                                    end;
                                  tkChar, tkString, tkUString:
                                    begin
                                      if propComponente.GetValue
                                        (AForm.FindComponent(fie.Name)).ToString
                                        <> '' then
                                        propModel.SetValue(AObject,
                                        propComponente.GetValue
                                        (AForm.FindComponent(fie.Name))
                                        .ToString);
                                    end;
                                end;
                              end;
                            recebe:
                              begin
                                propComponente.SetValue
                                  (AForm.FindComponent(fie.Name),
                                  propModel.GetValue(AObject).ToString);
                                for attribModel in propModel.GetAttributes do
                                begin
                                  if attribModel is TCamposInfo then
                                  begin
                                    if (attribModel as TCamposInfo)
                                      .getSizeField > 0 then
                                    begin
                                      TcxCalcEdit(AForm.FindComponent(fie.Name))
                                        .Properties.MaxLength :=
                                        (attribModel as TCamposInfo)
                                        .getSizeField;
                                    end;

                                  end;
                                  if attribModel is TCamposProperty then
                                  begin
                                    if (attribModel as TCamposProperty).isRequired
                                    then
                                      MudaCorComponente
                                        (AForm.FindComponent(fie.Name),
                                        obrigatorio);

                                    if (attribModel as TCamposProperty).isNoInsert
                                    then
                                      MudaCorComponente
                                        (AForm.FindComponent(fie.Name),
                                        Desabilitado);
                                  end;
                                end;
                              end;
                          end;
                        end;

                    end;
                end;

              tvFloat:
                begin
                  for propComponente in ACampos.TipoRtti.GetProperties do
                    if (propComponente.Name = 'Caption') then
                    begin
                      typ2 := ctx2.GetType(AObject.ClassType);
                      for propModel in typ2.GetProperties do
                        if propModel.Name = AList[i].NomeProperty then
                        begin
                          case ATrafego of
                            envia:
                              begin
                                case propModel.PropertyType.TypeKind of
                                  tkFloat:
                                    begin
                                      if propComponente.GetValue
                                        (AForm.FindComponent(fie.Name)).ToString
                                        <> '' then
                                        propModel.SetValue(AObject,
                                        strtoFloat
                                        (propComponente.GetValue
                                        (AForm.FindComponent(fie.Name))
                                        .ToString));
                                    end;
                                end;
                              end;
                            recebe:
                              begin
                                propComponente.SetValue
                                  (AForm.FindComponent(fie.Name),
                                  propModel.GetValue(AObject).ToString);
                                for attribModel in propModel.GetAttributes do
                                  if attribModel is TCamposProperty then
                                  begin
                                    if (attribModel as TCamposProperty).isRequired
                                    then
                                      MudaCorComponente
                                        (AForm.FindComponent(fie.Name),
                                        obrigatorio);
                                    if (attribModel as TCamposProperty).isNoInsert
                                    then
                                      MudaCorComponente
                                        (AForm.FindComponent(fie.Name),
                                        Desabilitado);
                                  end;
                              end;
                          end;
                        end;

                    end;
                end;
              tvDate:
                begin
                  for propComponente in ACampos.TipoRtti.GetProperties do
                    if (propComponente.Name = 'Caption') then
                    begin
                      typ2 := ctx2.GetType(AObject.ClassType);
                      for propModel in typ2.GetProperties do
                        if propModel.Name = AList[i].NomeProperty then
                        begin
                          case ATrafego of
                            envia:
                              begin
                                if propComponente.GetValue
                                  (AForm.FindComponent(fie.Name)).ToString <> ''
                                then
                                  propModel.SetValue(AObject,
                                    StrtoDate(propComponente.GetValue
                                    (AForm.FindComponent(fie.Name)).ToString));
                              end;
                            recebe:
                              begin
                                propComponente.SetValue
                                  (AForm.FindComponent(fie.Name),
                                  propModel.GetValue(AObject).ToString);
                                for attribModel in propModel.GetAttributes do
                                  if attribModel is TCamposProperty then
                                  begin
                                    if (attribModel as TCamposProperty).isRequired
                                    then
                                      MudaCorComponente
                                        (AForm.FindComponent(fie.Name),
                                        obrigatorio);
                                    if (attribModel as TCamposProperty).isNoInsert
                                    then
                                      MudaCorComponente
                                        (AForm.FindComponent(fie.Name),
                                        Desabilitado);
                                  end;
                              end;
                          end;
                        end;

                    end;
                end;
            end;
          end;
        end;
        
    end;

  IniciaRtti(AForm, comando);
end;

function verificaNotNull(ATabela: TTabela): Boolean;
var
  Dao: TDaoFiredac;
begin
  result := Dao.getInstancia.verificaNotNull(ATabela);
end;

procedure exibirLookupDisplay(AQueryPrincipal, AQueryLookup: TFDQuery;
  ATabela: TClassTabela; ATabelaLookup: TClassTabela);
var
  Dao: TDaoFiredac;
begin
  Dao.showLookupDisplay(AQueryPrincipal, AQueryLookup, ATabela, ATabelaLookup);
end;

end.
