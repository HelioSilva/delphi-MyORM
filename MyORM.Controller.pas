unit MyORM.Controller;

interface

uses
//uViewInformacao,
MyORM.Controller.Inter,
MyORM.Atributos.Model,
MyORM.Atributos.DAO,
MyORM.Atributos,
MyORM.Constantes,
Classes, FireDAC.Comp.Client,
Vcl.Forms ,RTTI, System.TypInfo,  System.SysUtils ,
  cxDBLookupComboBox, cxTextEdit
 ;

type

TX25 = (Obrigatorio,Desabilitado);

TControllerModel = class(TInterfacedObject,TIControllerBase)

  public

     procedure onExitObrigatorio(ASender : TObject);
    //Retorna uma lista dos campos de busca
    function getFieldsSearch(ATabela:TTabela) : TListaBuscaORM ;

    function PegaNomeTab(AObjeto : TObject) : String ;
    function PegaNomeTab2_0(AObjeto         : TClassTabela) : String ;
    function PegaPKs(AObjeto : TObject)     : TResultArray ;
    function PegaPKs2(AObjeto : TClassTabela) : TResultArray ;
    function PegaNotNulls(AObjeto : TObject): TResultArray ;
    function PegaAutoInc(AObjeto : TObject) : String ;
    function PegaUniques(AObjeto : TObject) : TResultArray ;
    function PegaNoInserts(AObjeto:TObject) : TResultArray ;
    function PegaNoUpdates(AObjeto:TObject) : TResultArray ;

    function ZeraModel(AObjeto : TObject) : Boolean ;


    function PegaDisplayField(AObjeto : TObject;ANome : String) : String ;


    //Comandos MasterDetail
    function PegaMasterTable(AObjeto : TClassTabela) : String ;
    function PegaFieldMasterTable(AObjeto: TClassTabela) : String ;
    function PegaFieldDetail(AObjeto: TClassTabela): String ;


end;

  //Chamadas para funcões anonimas
  {Este abaixo é usado no DAO CRUD}
  function RttiAnonimoDAO(ATabela: TTabela ; Afuncao : TFuncaoAnonima):TResultORM;
  function IniciaRtti(    AObject: TObject ; AFuncao : TFuncaoAnonima):TValue ;
  function IniciaRtti2(   AObject: TClassTabela ; AFuncao : TFuncaoAnonima):TValue ;

  function MudaCorComponente(AObjeto:TObject; Tipo : TX25):Boolean;

  //----------------------------------------------------------------------------

implementation

uses
  System.StrUtils, Vcl.Graphics, cxCalc, Vcl.Dialogs;

function RttiAnonimoDAO(ATabela: TTabela ; Afuncao : TFuncaoAnonima):TResultORM;
var
 Contexto : TRttiContext ;
 ACampos: TCamposAnoni;
 ControllerModel : TControllerModel ;
begin
  ACampos.NomeTabela  := ControllerModel.PegaNomeTab(ATabela);
  ACampos.PKs         := ControllerModel.PegaPKs(ATabela) ;
  ACampos.AutoInc     := ControllerModel.PegaAutoInc(ATabela);
  ACampos.NotNulos    := ControllerModel.PegaNotNulls(ATabela);

  ACampos.NoInserts := ControllerModel.PegaNoInserts(ATabela) ;
  ACampos.NoUpdates := ControllerModel.PegaNoUpdates(ATabela) ;
  ACampos.Uniques   := ControllerModel.PegaUniques(ATabela) ;

  ACampos.Sep         := '' ;

  Contexto  := TRttiContext.Create;
  try
    ACampos.TipoRtti := Contexto.GetType( ATabela.ClassType );
    Result.rowReturn           := Afuncao(ACampos).AsInteger;
  finally
    Contexto.free;
  end;
end;

function IniciaRtti2(AObject:TClassTabela ; AFuncao:TFuncaoAnonima):TValue  ;
var
 ctx : TRttiContext ;
 atipo : TCamposAnoni ;
begin
  ctx := TRttiContext.Create ;
  try
   atipo.TipoRtti :=  ctx.GetType( TClass(AObject).ClassInfo );
   Result:= AFuncao(atipo);
  finally
   ctx.free ;
  end;

end;

function IniciaRtti(AObject:TObject ; AFuncao:TFuncaoAnonima):TValue  ;
var
 ctx : TRttiContext ;
 atipo : TCamposAnoni ;
begin
  ctx := TRttiContext.Create ;
  try
   atipo.TipoRtti :=  Ctx.GetType( AObject.ClassType );
   Result:= AFuncao(atipo);
  finally
   ctx.free ;
  end;

end;

procedure TControllerModel.onExitObrigatorio(ASender : TObject);
begin
  if (TcxCalcEdit(ASender).Text = '') then
  begin
    ShowMessage('Esse campo não pode ser nulo!');
  end;
end;

{ TControllerModel }

function TControllerModel.PegaDisplayField(AObjeto : TObject; ANome : String) : String ;
var
  comando : TFuncaoAnonima ;
begin
  comando :=
  function(ACampos: TCamposAnoni):TValue
  var
    prop : TRttiProperty ;
    AtribRtti : TCustomAttribute ;
  begin
     for prop in ACampos.TipoRtti.GetProperties do
      if prop.Name = ANome then
        for AtribRtti in Prop.GetAttributes do
          if AtribRtti is TCamposInfo then
             Result :=  (AtribRtti as TCamposInfo).getDisplayField ;
  end;

  Result := IniciaRtti(AObjeto,comando).ToString ;

end;

function TControllerModel.PegaFieldDetail(AObjeto: TClassTabela): String;
var
  Comando   : TFuncaoAnonima ;
  Resultado      : String ;
begin

  Comando := function(ACampos: TCamposAnoni):TValue
  var
    AtribRtti : TCustomAttribute ;
  begin

      for AtribRtti in ACampos.TipoRtti.GetAttributes do
        if AtribRtti is TMasterDetail then
          resultado :=  (AtribRtti as TMasterDetail).FieldDetail ;

  end;

  IniciaRtti2(AObjeto,Comando);
  Result := Resultado ;
end;

function TControllerModel.PegaFieldMasterTable(AObjeto: TClassTabela): String;
var
  Comando   : TFuncaoAnonima ;
  Resultado      : String ;
begin

  Comando := function(ACampos: TCamposAnoni):TValue
  var
    AtribRtti : TCustomAttribute ;
  begin
      for AtribRtti in ACampos.TipoRtti.GetAttributes do
        if AtribRtti is TMasterDetail then
          resultado :=  (AtribRtti as TMasterDetail).FieldMasterDetail ;

  end;

  IniciaRtti2(AObjeto,Comando);
  Result := Resultado ;
end;

function TControllerModel.PegaMasterTable(AObjeto: TClassTabela): String;
var
  Comando   : TFuncaoAnonima ;
  Resultado      : String ;
begin

  Comando := function(ACampos: TCamposAnoni):TValue
  var
    AtribRtti : TCustomAttribute ;
  begin
   // for PropRtti in ACampos.TipoRtti.GetProperties do
      for AtribRtti in ACampos.TipoRtti.GetAttributes  do
      begin
        if AtribRtti is TMasterDetail then
        begin

          resultado :=  (AtribRtti as TMasterDetail).MasterTable ;
          break;
        end;

      end;
  end;

  IniciaRtti2(AObjeto,Comando);
  Result := Resultado ;
end;

function TControllerModel.PegaNoInserts(AObjeto: TObject): TResultArray;
var
  Comando   : TFuncaoAnonima ;
  list      : TResultArray ;
begin

  Comando := function(ACampos: TCamposAnoni):TValue
  var
    PropRtti  : TRttiProperty ;
    AtribRtti : TCustomAttribute ;
    i         : Integer ;
  begin
    i:= 0 ;
    for PropRtti in ACampos.TipoRtti.GetProperties do
      for AtribRtti in PropRtti.GetAttributes do
        if AtribRtti is TCamposProperty then
          if (AtribRtti as TCamposProperty).isNoInsert then
          begin
            SetLength(list, i+1);
            list[i] :=  PropRtti.Name ;
            Inc(i);
          end;
  end;

  IniciaRtti(AObjeto,Comando);
  Result := list ;
end;

function TControllerModel.PegaNomeTab(AObjeto:TObject):String ;
var comando : TFuncaoAnonima ;
begin

  comando :=
  function(ACampos: TCamposAnoni):TValue
  var
    AtribRtti : TCustomAttribute ;
  begin
     for AtribRtti in ACampos.TipoRtti.GetAttributes do
     begin
       if AtribRtti is TNomeTabela then
       begin
         Result := (AtribRtti as TNomeTabela).NomeTabela ;
         Break ;
       end;
     end;
  end  ;

  Result := IniciaRtti(AObjeto,comando).ToString ;

end;

function TControllerModel.PegaNomeTab2_0(AObjeto:TClassTabela):String ;
var comando : TFuncaoAnonima ;
begin

  comando :=
  function(ACampos: TCamposAnoni):TValue
  var
    AtribRtti : TCustomAttribute ;
  begin
     for AtribRtti in ACampos.TipoRtti.GetAttributes do
     begin
       if AtribRtti is TNomeTabela then
       begin
         Result := (AtribRtti as TNomeTabela).NomeTabela ;
         Break ;
       end;
     end;
  end  ;

  Result := IniciaRtti2(AObjeto,comando).ToString ;

end;

function TControllerModel.PegaAutoInc(AObjeto : TObject) : String ;
var comando : TFuncaoAnonima ;
begin

  comando := function(ACampos: TCamposAnoni):TValue
  var
    PropRtti : TRttiProperty ;
    AtribRtti : TCustomAttribute ;
  begin
    for PropRtti in ACampos.TipoRtti.GetProperties do
      for AtribRtti in PropRtti.GetAttributes do
        if AtribRtti is TCamposPK then
           if (AtribRtti as TCamposPK).IsAutoInc then
           begin
             Result := PropRtti.Name ;
             Break ;
           end;
  end;

  Result := IniciaRtti(AObjeto,comando).ToString ;

end;

function TControllerModel.PegaNotNulls(AObjeto : TObject) : TResultArray ;
var
  Comando   : TFuncaoAnonima ;
  list      : TResultArray ;
begin

  Comando := function(ACampos: TCamposAnoni):TValue
  var
    PropRtti  : TRttiProperty ;
    AtribRtti : TCustomAttribute ;
    i         : Integer ;
  begin
    i:= 0 ;
    for PropRtti in ACampos.TipoRtti.GetProperties do
      for AtribRtti in PropRtti.GetAttributes do
        if AtribRtti is TCamposProperty then
          if (AtribRtti as TCamposProperty).isRequired then
          begin
            SetLength(list, i+1);
            list[i] :=  PropRtti.Name ;
            Inc(i);
          end;
  end;

  IniciaRtti(AObjeto,Comando);
  Result := list ;

end;

function TControllerModel.PegaNoUpdates(AObjeto: TObject): TResultArray;
var
  Comando   : TFuncaoAnonima ;
  list      : TResultArray ;
begin

  Comando := function(ACampos: TCamposAnoni):TValue
  var
    PropRtti  : TRttiProperty ;
    AtribRtti : TCustomAttribute ;
    i         : Integer ;
  begin
    i:= 0 ;
    for PropRtti in ACampos.TipoRtti.GetProperties do
      for AtribRtti in PropRtti.GetAttributes do
        if AtribRtti is TCamposProperty then
          if (AtribRtti as TCamposProperty).isNoUpdate then
          begin
            SetLength(list, i+1);
            list[i] :=  PropRtti.Name ;
            Inc(i);
          end;
  end;

  IniciaRtti(AObjeto,Comando);
  Result := list ;
end;

function TControllerModel.PegaPKs2(AObjeto : TClassTabela) : TResultArray ;
var
  comando   : TFuncaoAnonima ;
  list      : TResultArray ;
begin

  comando :=  function(ACampos: TCamposAnoni):TValue
  var
    PropRtti  : TRttiProperty ;
    AtribRtti : TCustomAttribute ;
    i         : Integer ;
  begin
   i:= 0 ;

  for PropRtti in ACampos.TipoRtti.GetProperties do
    for AtribRtti in PropRtti.GetAttributes do
      if AtribRtti is TCampos then
         if (AtribRtti as TCampos).IsPK then
         begin
           SetLength(list, i+1);
           list[i] := PropRtti.Name ;
           Inc(i);
         end;
  end;

  IniciaRtti2(AObjeto,comando);
  Result := list ;
end;

function TControllerModel.PegaPKs(AObjeto : TObject) : TResultArray ;
var
  comando   : TFuncaoAnonima ;
  list      : TResultArray ;
begin

  comando :=  function(ACampos: TCamposAnoni):TValue
  var
    PropRtti  : TRttiProperty ;
    AtribRtti : TCustomAttribute ;
    i         : Integer ;
  begin
   i:= 0 ;

  for PropRtti in ACampos.TipoRtti.GetProperties do
    for AtribRtti in PropRtti.GetAttributes do
      if AtribRtti is TCampos then
         if (AtribRtti as TCampos).IsPK then
         begin
           SetLength(list, i+1);
           list[i] := PropRtti.Name ;
           Inc(i);
         end;
  end;

  IniciaRtti(AObjeto,comando);
  Result := list ;


end;

function TControllerModel.PegaUniques(AObjeto: TObject): TResultArray;
var
  Comando   : TFuncaoAnonima ;
  list      : TResultArray ;
begin

  Comando := function(ACampos: TCamposAnoni):TValue
  var
    PropRtti  : TRttiProperty ;
    AtribRtti : TCustomAttribute ;
    i         : Integer ;
  begin
    i:= 0 ;
    for PropRtti in ACampos.TipoRtti.GetProperties do
      for AtribRtti in PropRtti.GetAttributes do
        if AtribRtti is TCamposProperty then
          if (AtribRtti as TCamposProperty).isUnique then
          begin
            SetLength(list, i+1);
            list[i] :=  PropRtti.Name ;
            Inc(i);
          end;
  end;

  IniciaRtti(AObjeto,Comando);
  Result := list ;
end;

function TControllerModel.ZeraModel(AObjeto: TObject): Boolean;
var
  comando : TFuncaoAnonima ;
begin
  comando :=  function(ACampos: TCamposAnoni):TValue
  var
    PropRtti  : TRttiProperty ;
  begin

    for PropRtti in ACampos.TipoRtti.GetProperties do
      case PropRtti.PropertyType.TypeKind of
        tkInt64,
        tkInteger : begin
                      PropRtti.SetValue(AObjeto, 0 );
                    end;
        tkChar ,
        tkString ,
        tkUString : begin
                      PropRtti.SetValue(AObjeto, '' );
                    end;

        tkFloat :   begin
                      PropRtti.SetValue(AObjeto, 0 );
                    end;
      end;
  end;

  IniciaRtti(AObjeto,comando);
end;

function TControllerModel.getFieldsSearch(ATabela: TTabela): TListaBuscaORM;
var
  comando  : TFuncaoAnonima ;
  list : TListaBuscaORM ;
  display : String ;
begin
 comando :=  function(ACampos: TCamposAnoni):TValue
  var
    PropRtti  : TRttiProperty ;
    AtribRtti : TCustomAttribute ;
    i         : Integer ;
  begin
    i := 1 ;

    for PropRtti in ACampos.TipoRtti.GetProperties do
      for AtribRtti in PropRtti.GetAttributes do
        if AtribRtti is TCamposProperty then
        begin

          if ((AtribRtti as TCamposProperty).isSearch)  then
          begin
            SetLength(list , i);
            list[i-1].field := PropRtti.Name ;

            display := PegaDisplayField(ATabela,PropRtti.Name) ;

              if display <> '(empty)' then
              list[i-1].displayField := display
              else
              list[i-1].displayField := PropRtti.Name ;


            list[i-1].operador := [like] ;
            i:= i + 1 ;

            display := '' ;
          end;

        end;

  end;

  IniciaRtti(ATabela,comando);
  Result := list ;

end;

function MudaCorComponente(AObjeto:TObject; Tipo : TX25):Boolean;
var
  Comando   : TFuncaoAnonima ;
  control : TControllerModel;
begin

  Comando := function(ACampos: TCamposAnoni):TValue
  var
    PropRtti  : TRttiProperty ;
  begin

    for PropRtti in ACampos.TipoRtti.GetProperties do
    begin
      case Tipo of
        Obrigatorio:
                begin
                 if PropRtti.Name = 'Style' then
                 begin
                  TcxCalcEdit(AObjeto).Style.BorderColor := ColorObrigatorio;
                  TcxCalcEdit(AObjeto).OnExit := control.onExitObrigatorio ;
                  end;

                end;
        Desabilitado:
                begin
                    if PropRtti.Name = 'Enabled' then
                     TcxCalcEdit(AObjeto).Enabled := false ;
                end;

     end;
    end;

  end;

  IniciaRtti(AObjeto,Comando);

end;


end.
