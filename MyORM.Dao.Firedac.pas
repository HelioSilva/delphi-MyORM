unit MyORM.Dao.Firedac;

interface

uses
  MyORM.Dao.Inter,
  MyORM.Atributos,
  MyORM.Atributos.Model,
  MyORM.Atributos.DAO,
  MyORM.INI,
  MyORM.Controller,
  Rtti,
  System.SysUtils,
  FireDAC.Stan.Intf,  FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf,      FireDAC.Phys.Intf,  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,  FireDAC.Stan.Async,   FireDAC.Phys,       FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI,    FireDAC.Phys.IBBase,  FireDAC.Phys.FB,    FireDAC.Comp.Client,
  FireDAC.Phys.PG,
  Data.DB,
  System.Generics.Collections, System.Classes,
  FireDAC.Phys.IBDef, FireDAC.Phys.IBWrapper,System.UITypes,System.DateUtils;

type
  RRecordModel  = record

  end;

  TDaoFiredac = class(TInterfacedObject,IDaoBase)
    strict private
      constructor Create(Arq : String);
    private
      FSGDB_Postgresql : boolean ;
      FDatabase  : TFDConnection ;
      FTransacao : TFDTransaction ;

      procedure ConfigParametro(AQuery: TFDQuery; AProp: TRttiProperty; ACampo: string;  ATabela: TTabela);
      function  CreateQuery():TFDQuery;
      procedure DestroyQuery(AQuery:TFDquery);
      procedure FechaQuery(AQuery:TFDQuery) ;
      function  ExecutaQuery(AQuery:TFDQuery) : integer  ;
      function  OpenQuery(AQuery:TFDQuery) : integer ;

      procedure configuraFields(ATabela : TObject; AFDQuery : TFDQuery) ;

      //Firedac Recovery
       procedure eventRecover (ASender, AInitiator: TObject; AException: Exception; var AAction: TFDPhysConnectionRecoverAction);

      //Designer Pattern -> Padrao Singleton
      class var FInstancia : TDaoFiredac ;
      class var OpenModeCreate : boolean ;

    //------------------------------------------------------------------------------
    public
      procedure configuraFields2_0(ATabela : TClassTabela; AFDQuery : TFDQuery) ;

      procedure OnOpenMode();
      procedure OFFOpenMode();

      //Crud DAO
      function Inserir2_0(ATabela:TTabela):integer ;
      function Inserir(ATabela:TTabela): TResultORM ;
      function Salvar(ATabela:TTabela) : TResultORM ;
      function Excluir(ATabela:TTabela; ACondition : TList<TConditionSQL>): TResultORM ;
      function Excluir2_0(AModel:iTabela) : Boolean ;
      function Buscar(ATabela: TObject; ACondition : TList<TConditionSQL> ; AOrder : TList<TOrderBySQL> ): TResultORM ;
      function Buscar2_0(ATabela: TClassTabela; ACondition : TList<TConditionSQL> ; AOrder : TList<TOrderBySQL> ): TResultORM ;
      function BuscarDetail(AMasterQuery:TFDQuery ; ATabela: TClassTabela; ADataSourceMaster : TDataSource) : TResultORM ;
      function ComandSQL(AComandoSQL : String ): TResultORM ;
      function ExecSQL(AComandoSQL : String ): Boolean ;


      function getFDConnection():TFDConnection;

      {TODO -oHelio -cGERAL : Colocar esse metodo no CONTROLLER }
      function VerificaNotNull(ATabela: TTabela) : Boolean ;
      procedure showLookupDisplay(AFDPrincipal:TFDQuery;AFDLookup:TFDQuery;ATabela:TClassTabela;ATabelaLookup:TClassTabela) ;


      function  isConnection : Boolean ;
      function  InTransaction : Boolean ;
      procedure StartTransaction ;
      procedure Commit ;
      procedure RollBack ;

      //Designer Pattern -> Padrao Singleton - Toda chamada externa será feita por aqui
      class function   getInstancia(pathArquivo : String) : TDaoFireDac ; overload ;
      class function   getInstancia() : TDaoFireDac ; overload ;
      class procedure  DestroyInstancia ;
      //------------------------------------------------------------------------


  end;

implementation



uses
  System.TypInfo, Vcl.Dialogs;

{ TDaoFiredac }
function TDaoFiredac.ExecSQL(AComandoSQL : String ): Boolean ;
var
 Qry : TFDQuery ;
begin
    Qry :=  CreateQuery;
    FechaQuery(Qry) ;
    with Qry do
    begin
        SQL.Add(AComandoSQL) ;
    end;
    if ExecutaQuery(Qry) > 0 then
     Result := true
    else
     Result := False ;
end;

function TDaoFiredac.ComandSQL(AComandoSQL : String ): TResultORM ;
var
 Qry : TFDQuery ;
begin
    Qry :=  CreateQuery;
    FechaQuery(Qry) ;
    Qry.FetchOptions.Mode := fmAll ;
    with Qry do
    begin
        SQL.Add(AComandoSQL) ;
        Result.rowReturn := OpenQuery(Qry) ;
        Result.qryReturn:= Qry;
    end;

end;

function TDaoFiredac.Buscar(ATabela: TObject;
                            ACondition : TList<TConditionSQL>  ;
                            AOrder :     TList<TOrderBySQL>   ): TResultORM;
var
  Campo: string;
  ctx : TRttiContext ;
  typ : TRttiType ;
  PropRtti: TRttiProperty;
  Sep : String ;
  I: integer;
  controllerModel : TControllerModel ;
  Qry : TFDQuery ;
begin
  ctx := TRttiContext.Create ;
  try
    typ := ctx.GetType( ATabela.ClassType ) ;
    Qry :=  CreateQuery;
    FechaQuery(Qry) ;
    with Qry do
    begin
      // Select ALL
      SQL.Add('Select * from ' + controllerModel.PegaNomeTab(ATabela));

      // Condições
      if ACondition.Count > 0 then
      begin
        SQL.Add(' Where ') ;
        Sep := '' ;
        for I := 0 to ACondition.Count-1 do
        begin
          SQL.Add(Sep);
          if ACondition[i].tipo = [igual] then
          SQL.Add(Trim(ACondition[i].campo)+'='+''''+Trim(ACondition[i].valor)+'''' ) ;

          if ACondition[i].tipo = [like] then
          SQL.Add(Trim(ACondition[i].campo)+' like '+'''%'+Trim(ACondition[i].valor)+'%''' ) ;

          Sep := ' and ';
        end;
      end;

      // Ordenação
      if AOrder.Count > 0 then
      begin
       SQL.Add('Order BY ') ;
       Sep := ' ' ;
       for I := 0 to AOrder.Count-1 do
       begin
        if AOrder[i].order = [Asc] then
         SQL.Add(AOrder[i].campo+' Asc');

        if AOrder[i].order = [Desc] then
         SQL.Add(AOrder[i].campo+' Desc');
       end;
      end;


        configuraFields(TTabela(ATabela),Qry);
        Result.rowReturn := OpenQuery(Qry) ;
        Result.qryReturn:= Qry;
    end;
  finally
    ctx.Free ;
  end;
end;

function TDaoFiredac.Buscar2_0(ATabela: TClassTabela;
                            ACondition : TList<TConditionSQL>  ;
                            AOrder :     TList<TOrderBySQL>   ): TResultORM;
var
  Campo: string;
  ctx : TRttiContext ;
  typ : TRttiType ;
  PropRtti: TRttiProperty;
  Sep : String ;
  I: integer;
  controllerModel : TControllerModel ;
  Qry : TFDQuery ;
begin
  ctx := TRttiContext.Create ;
  try
    typ := ctx.GetType( TClass(ATabela).ClassInfo ) ;
    Qry :=  CreateQuery;
    FechaQuery(Qry) ;
    with Qry do
    begin
      // Select ALL
      SQL.Add('Select * from ' + controllerModel.PegaNomeTab2_0(ATabela));

      // Condições
      if ACondition.Count > 0 then
      begin
        SQL.Add(' Where ') ;
        Sep := '' ;
        for I := 0 to ACondition.Count-1 do
        begin
          SQL.Add(Sep);
          if ACondition[i].tipo = [igual] then
          SQL.Add(Trim(ACondition[i].campo)+'='+''''+Trim(ACondition[i].valor)+'''' ) ;

          if ACondition[i].tipo = [like] then
          SQL.Add(Trim(ACondition[i].campo)+' like '+'''%'+Trim(ACondition[i].valor)+'%''' ) ;

          Sep := ' and ';
        end;
      end;

      // Ordenação
      if AOrder.Count > 0 then
      begin
       SQL.Add('Order BY ') ;
       Sep := ' ' ;
       for I := 0 to AOrder.Count-1 do
       begin
        if AOrder[i].order = [Asc] then
         SQL.Add(AOrder[i].campo+' Asc');

        if AOrder[i].order = [Desc] then
         SQL.Add(AOrder[i].campo+' Desc');
       end;
      end;


        configuraFields2_0(ATabela,Qry);
        Result.rowReturn := OpenQuery(Qry) ;
        Result.qryReturn:= Qry;
    end;
  finally
    ctx.Free ;
  end;
end;

function TDaoFiredac.BuscarDetail(AMasterQuery:TFDQuery ;ATabela: TClassTabela; ADataSourceMaster : TDataSource): TResultORM;
var
  controllerModel : TControllerModel ;
  QryDetail : TFDQuery ;
begin

    QryDetail := CreateQuery;
    FechaQuery(QryDetail);

    with QryDetail do
    begin
      // Select ALL
      SQL.Add('Select * from ' + controllerModel.PegaNomeTab2_0(ATabela)+
      ' where '+controllerModel.PegaFieldDetail(ATabela)+' = :'+controllerModel.PegaFieldMasterTable(ATabela));


        configuraFields2_0(ATabela,QryDetail);
    end;

        QryDetail.MasterSource   := ADataSourceMaster ;
        QryDetail.MasterFields   := controllerModel.PegaFieldMasterTable(ATabela);
        QryDetail.IndexFieldNames:= controllerModel.PegaFieldDetail(ATabela);
        QryDetail.DetailFields   := controllerModel.PegaFieldDetail(ATabela);


     Result.rowReturn :=  OpenQuery(QryDetail);
     Result.qryReturn:= QryDetail;
end;

procedure TDaoFiredac.Commit;
begin
  {TODO -oHelio -cGeneral : Verificar o InTransation}
  if InTransaction then
    FInstancia.FTransacao.Commit ;
end;

procedure TDaoFiredac.ConfigParametro(AQuery: TFDQuery; AProp: TRttiProperty;
  ACampo: string; ATabela: TTabela);
begin
  with AQuery do
  begin
    if AProp.PropertyType.ToString = 'TStream' then
    begin
      ParamByName(ACampo).LoadFromStream(AProp.GetValue(ATabela).asType<TStream>,ftBlob);
    end
    else
    case AProp.PropertyType.TypeKind of
      tkInt64,
      tkInteger :
      begin
        ParamByName(ACampo).AsInteger := AProp.GetValue(ATabela).AsInteger ;
      end;
      tkChar ,
      tkString ,
      tkUString :
      begin
        ParamByName(ACampo).AsString := AProp.GetValue(ATabela).AsString ;
      end;
      tkFloat :
      begin
        if CompareText(AProp.PropertyType.Name, 'TDate') = 0 then
        begin
         if FormatDateTime('dd.mm.yyyy',AProp.GetValue(ATabela).AsType<TDateTime>) <> '30.12.1899' then
          ParamByName(ACampo).AsString := FormatDateTime('dd.mm.yyyy',AProp.GetValue(ATabela).AsType<TDateTime>)
         else
          ParamByName(ACampo).Clear;
        end
        else
        if CompareText(AProp.PropertyType.Name, 'TDateTime') = 0  then
        begin
          if FormatDateTime('dd.mm.yyyy',AProp.GetValue(ATabela).AsType<TDateTime>) <> '30.12.1899' then
          ParamByName(ACampo).AsString := FormatDateTime('dd.mm.yyyy H:M',AProp.GetValue(ATabela).AsType<TDateTime>)
         else
          ParamByName(ACampo).Clear;
        end
        else
        if CompareText(AProp.PropertyType.Name, 'TTime') = 0 then
         ParamByName(ACampo).AsString := FormatDateTime('hh:nn:ss',AProp.GetValue(ATabela).AsType<TDateTime>)
        else
         ParamByName(ACampo).AsFloat := AProp.GetValue(ATabela).AsType<Double> ;
      end;
      tkVariant :
      begin
        ParamByName(ACampo).AsFloat := AProp.GetValue(ATabela).AsVariant ;
      end;
    else
     raise Exception.Create('Tipo do campo não conhecido!'+AProp.PropertyType.ToString);
    end;
  end;
end;

procedure TDaoFiredac.configuraFields(ATabela : TObject; AFDQuery : TFDQuery);
var
ctx : TRttiContext ;
typ : TRttiType ;
PropRtti : TRttiProperty ;
AtribRtti : TCustomAttribute ;
oo : TField ;
isLookup : boolean;
begin
  ctx := TRttiContext.Create;
  try
    typ := ctx.GetType(ATabela.ClassType) ;

    AFDQuery.Fields.Clear ;

    for PropRtti in typ.GetProperties do
    begin

     if PropRtti.Name = 'RefCount' then
     begin

     end
     else
     begin

       case PropRtti.PropertyType.TypeKind of
         tkInt64,tkInteger:
          oo := TIntegerField.Create(AFDQuery);


         tkString,tkChar,tkUString,tkWideString:
         begin
          if FSGDB_Postgresql then
             oo:= TWideStringField.Create(AFDQuery)
          else
             oo := TStringField.Create(AFDQuery);

         end;

         tkFloat :
          begin
           if CompareText(PropRtti.PropertyType.Name, 'TDate') = 0 then
             oo := TDateField.Create(AFDQuery)
           else
           if CompareText(PropRtti.PropertyType.Name, 'TTime') = 0 then
             oo := TTimeField.Create(AFDQuery)
           else
           if CompareText(PropRtti.PropertyType.Name, 'TDateTime') = 0 then
             oo := TSQLTimeStampField.Create(AFDQuery)
           else
             oo := TFloatField.Create(AFDQuery) ;
          end;


       end;

       if PropRtti.PropertyType.ToString = 'TStream' then
       begin
            oo := TBlobField.Create(AFDQuery);
       end;

        for AtribRtti in PropRtti.GetAttributes do
        begin

          if AtribRtti is TCamposInfo then
          begin
            if (AtribRtti as TCamposInfo).getSizeField > 0 then
               oo.Size := (AtribRtti as TCamposInfo).getSizeField ;

            oo.DisplayLabel := (AtribRtti as TCamposInfo).getDisplayField  ;

            if PropRtti.PropertyType.TypeKind = tkFloat then
            begin
              TFloatField(oo).DisplayFormat :=  (AtribRtti as TCamposInfo).getMaskField ;
            end;

            if (AtribRtti as TCamposInfo).getVisibleField = false then
             oo.Visible :=  false ;

             oo.Index := AFDQuery.IndexFieldCount ;

          end;

          if AtribRtti is TLookupField then
          begin
            isLookup := true ;
          end;

        end;

        if not isLookup then
        begin
              oo.FieldName := PropRtti.Name;
              oo.Name := AFDQuery.Name + oo.FieldName ;
              oo.DataSet := AFDQuery ;
        end
        else
        begin
          oo.Destroy ;
        end;
     end;
    end;
  finally
    ctx.Free;
  end;

end;

procedure TDaoFiredac.configuraFields2_0(ATabela: TClassTabela; AFDQuery: TFDQuery);
var
  ctx : TRttiContext ;
  typ : TRttiType ;
  PropRtti : TRttiProperty ;
  AtribRtti : TCustomAttribute ;
  oo : TField ;
  isLookup : boolean;
begin
  ctx := TRttiContext.Create;
  try
    typ := ctx.GetType(TClass(ATabela).ClassInfo) ;

    AFDQuery.Fields.Clear ;

    for PropRtti in typ.GetProperties do
    begin

     if PropRtti.Name = 'RefCount' then
     begin

     end
     else
     begin

       case PropRtti.PropertyType.TypeKind of
        tkInt64,tkInteger:
          oo := TIntegerField.Create(AFDQuery);
        tkString, tkUString , tkChar,tkWideString:
        begin
         if FSGDB_Postgresql then
             oo:= TWideStringField.Create(AFDQuery)
          else
             oo := TStringField.Create(AFDQuery);
        end;


        tkFloat :
          begin
           if CompareText(PropRtti.PropertyType.Name, 'TDate') = 0 then
             oo := TDateField.Create(AFDQuery)
           else
           if CompareText(PropRtti.PropertyType.Name, 'TTime') = 0 then
             oo := TTimeField.Create(AFDQuery)
           else
           if CompareText(PropRtti.PropertyType.Name, 'TDateTime') = 0 then
             oo := TSQLTimeStampField.Create(AFDQuery)
           else
             oo := TFloatField.Create(AFDQuery) ;
          end;


       end;

       if PropRtti.PropertyType.ToString = 'TStream' then
       begin
            oo := TBlobField.Create(AFDQuery);
       end;

        for AtribRtti in PropRtti.GetAttributes do
        begin


          if AtribRtti is TCamposInfo then
          begin
            if (AtribRtti as TCamposInfo).getSizeField > 0 then
             oo.Size := (AtribRtti as TCamposInfo).getSizeField ;

            oo.DisplayLabel := (AtribRtti as TCamposInfo).getDisplayField  ;

            if PropRtti.PropertyType.TypeKind = tkFloat then
            begin
              TFloatField(oo).DisplayFormat :=  (AtribRtti as TCamposInfo).getMaskField ;
            end;

            if (AtribRtti as TCamposInfo).getVisibleField = false then
             oo.Visible :=  false ;

             oo.Index := AFDQuery.IndexFieldCount ;

          end;

          if AtribRtti is TLookupField then
          begin
            isLookup := true ;
          end;

        end;

        if not isLookup then
        begin
          oo.FieldName := PropRtti.Name;
          oo.Name := AFDQuery.Name + oo.FieldName ;
          oo.DataSet := AFDQuery ;
        end
        else
        begin
          oo.Destroy ;
        end;
     end;
    end;
  finally

    ctx.Free;
  end;
end;

constructor TDaoFiredac.Create(Arq : String);
var
  oDef: IFDStanConnectionDef;
  ini : TIniOptions ;
  oParams: TFDPhysIBConnectionDefParams; // MSSQL connection params
  FDPhysPGDriverLink1  : TFDPhysPgDriverLink ;
begin
  inherited Create ;

  ini := TIniOptions.Create ;
  ini.LoadFromFile(Arq);

  // Informações para conexão com o banco de dados
  oDef        := FDManager.ConnectionDefs.AddConnectionDef;
  if oDef.Name = '' then  
  oDef.Name   := ini.ConexaoSGBD;

  oParams     := TFDPhysIBConnectionDefParams(oDef.Params);



  oParams.DriverID         := ini.ConexaoDriverID;
  if ini.ConexaoServer <> '' then
    oParams.Protocol := ipTCPIP
  else
    oParams.Protocol := ipLocal ;

  oParams.Server           := ini.ConexaoServer;
  oParams.Database         := ini.ConexaoDatabase;
  oParams.UserName         := ini.ConexaoUser_Name;
  oParams.Password         := ini.ConexaoPassword;

  if ini.ConexaoDriverID = 'PG' then
  begin
    FSGDB_Postgresql := true ;
    FDPhysPGDriverLink1  := TFDPhysPgDriverLink.Create(nil);
    oParams.Port             := ini.ConexaoPorta ;
   // FDPhysPGDriverLink1.VendorLib := 'C:\Program Files\PostgreSQL\10\bin\libpq.dll';
  end;


//  if ini.ConexaoDriverID = 'PG' then
 // oParams.MetaDefSchema := 'Public' ;

  oDef.MarkPersistent;

  FDatabase       := TFDConnection.Create(nil);
  FTransacao      := TFDTransaction.Create(nil);

  FTransacao.Options.AutoCommit       := false ;
  FTransacao.Options.AutoStop         := false ;
  FTransacao.Options.AutoStart        := true  ;
  FTransacao.Options.DisconnectAction := xdNone ;

  FDatabase.Transaction := FTransacao ;
  FTransacao.Connection := FDatabase  ;

  FDatabase.ConnectionDefName := oDef.Name;

  if OpenModeCreate = true  then
    FDatabase.Params.Add('OpenMode=OpenOrCreate');

  FDatabase.Connected := True;


  oDef.Clear ;
  ini.Free ;

end;

function TDaoFiredac.CreateQuery():TFDQuery;
var
 Aquery : TFDQuery ;
begin

  Aquery := TFDQuery.Create(FInstancia.FDatabase) ;
  Aquery.Connection  := FInstancia.FDatabase ;
  AQuery.Transaction := FInstancia.FTransacao ;

  Result := Aquery ;
end;

class procedure TDaoFiredac.DestroyInstancia;
begin
 if FInstancia.InTransaction then
       FInstancia.FTransacao.Rollback ;


  if Assigned(FInstancia) then
  begin
      FInstancia.FDatabase.Free;
      FInstancia.FTransacao.Free;
      FreeAndNil(FInstancia);
  end;
end;

procedure TDaoFiredac.DestroyQuery(AQuery: TFDquery);
begin
  AQuery.Free ;
end;

procedure TDaoFiredac.eventRecover(ASender, AInitiator: TObject;
  AException: Exception; var AAction: TFDPhysConnectionRecoverAction);
var
  iRes: Integer;
begin
  iRes := MessageDlg('Connection is lost. Offline - yes, Retry - ok, Fail - Cancel',
    mtConfirmation, [mbYes, mbOK, mbCancel], 0);
  case iRes of
  mrYes:    AAction := faOfflineAbort;
  mrOk:     AAction := faRetry;
  mrCancel: AAction := faFail;
  end;

end;

function TDaoFiredac.Excluir(ATabela: TTabela; ACondition : TList<TConditionSQL>): TResultORM;
var
  Comando: TFuncaoAnonima;
  Qry : TFDQuery ;
  Sep : String ;

begin

  Comando := function(ACampos: TCamposAnoni): TValue
  var
    Campo: string;
    PropRtti: TRttiProperty;
      i : integer ;
  begin
    Qry :=  CreateQuery;
    FechaQuery(Qry) ;
    try
      with Qry do
      begin
        sql.Add('Delete from ' + ACampos.NomeTabela);
        sql.Add('Where');

      // Condições
      if ACondition.Count > 0 then
      begin
        Sep := '' ;
        for I := 0 to ACondition.Count-1 do
        begin
          if ACondition[i].tipo = [igual] then
          SQL.Add(Trim(ACondition[i].campo)+'='+Trim(ACondition[i].valor)+ Sep ) ;

          if ACondition[i].tipo = [like] then
          SQL.Add(Trim(ACondition[i].campo)+' like '+'''%'+Trim(ACondition[i].valor)+'%'''+ Sep ) ;

          Sep := 'and';
        end;
      end;

       try
        Result:= ExecutaQuery(Qry);
       except
          on E: exception do
          begin
          if Pos('FK',E.message) > 0 then
          raise Exception.Create('Registro com relacionamento em outras tabelas. Não foi possível excluir.');
          end;
       end;

      end;
    finally
      DestroyQuery(Qry);
    end;

  end;

  //reflection da tabela e execução da query preparada acima.
  Result := RttiAnonimoDAO(ATabela, Comando);

end;

function TDaoFiredac.Excluir2_0(AModel: iTabela): Boolean;
var
  Qry : TFDQuery ;
  controllerModel : TControllerModel ;
  pks : TResultArray ;
  resposta : integer ;
begin
 Qry :=  CreateQuery ;
 FechaQuery(Qry);
 pks := controllerModel.PegaPKs(AModel as TObject);

 try
    with Qry do
      begin
        sql.Add('Delete from ' + controllerModel.PegaNomeTab(AModel as TObject));
        sql.Add('Where ');
        SQL.Add(' '+PKs[0]+' = '+IntToStr(AModel._getID) ) ;

              try
                resposta:= ExecutaQuery(Qry);
              except
                  on E: exception do
                  begin
                  if Pos('FK',E.message) > 0 then
                  raise Exception.Create('Registro com relacionamento em outras tabelas. Não foi possível excluir.');
                  end;
               end;
      end;


     if resposta = 1 then
      Result := true
     else
      Result := false ;
 finally
   DestroyQuery(Qry);

 end;


end;

function TDaoFiredac.ExecutaQuery(AQuery : TFDQuery): integer;
begin
  with AQuery do
  begin
    Prepare();
    ExecSQL;
    Result := RowsAffected;
  end;
end;


procedure TDaoFiredac.FechaQuery(AQuery : TFDQuery);
begin
 with AQuery do
 begin
  Close;
  SQL.Clear;
 end;
end;

function TDaoFiredac.getFDConnection: TFDConnection;
begin
  if FDatabase.Connected then
    Result := FDatabase ;

end;

class function TDaoFiredac.getInstancia: TDaoFireDac;
begin
     if Assigned(FInstancia) then
       Result := FInstancia
     else
       raise Exception.Create('DAO não inicializado!');
end;

class function TDaoFiredac.getInstancia(pathArquivo : String): TDaoFiredac;
begin

  if OpenModeCreate = false then
  begin
      if not FileExists(pathArquivo) then
    raise Exception.Create('Arquivo de configuração não encontrado');
  end;


  if not Assigned(FInstancia) then
    FInstancia := TDaoFiredac.Create(pathArquivo) ;

    Result := FInstancia ;

end;

function TDaoFiredac.Inserir(ATabela: TTabela): TResultORM;
var
  Comando: TFuncaoAnonima;
  Qry : TFDQuery ;
begin
    Comando :=
    function(ACampos:TCamposAnoni):TValue
    var
      primaryKey : String ;
      Campo: string;
      PropRtti : TRttiProperty;
      Attribs : TCustomAttribute ;
      MyElem: TFDQuery;
    begin
      Qry := CreateQuery ;
      FechaQuery(Qry) ;
      try
          with Qry do
          begin

            sql.Add('Insert into ' + ACampos.NomeTabela);
            sql.Add('(');

           //campos da tabela
            ACampos.Sep := '';

            for PropRtti in ACampos.TipoRtti.GetProperties do
               if (CompareStr( PropRtti.Name , ACampos.AutoInc) <> 0)   then
               begin
                for attribs in proprtti.GetAttributes  do
                if attribs is TCamposProperty then
                begin
                  if not (Attribs as TCamposProperty).isNoInsert then
                  begin
                    SQL.Add(ACampos.Sep + PropRtti.Name);
                    ACampos.Sep := ',';
                  end;
                end ;
               end;

            sql.Add(')');

            //parâmetros
            sql.Add('Values (');
            ACampos.Sep := '';
            for PropRtti in ACampos.TipoRtti.GetProperties do
               if (CompareStr( PropRtti.Name , ACampos.AutoInc) <> 0)  then
               begin
                for attribs in proprtti.GetAttributes  do
                if attribs is TCamposProperty then
                begin
                  if not (Attribs as TCamposProperty).isNoInsert then
                  begin
                    SQL.Add(ACampos.Sep +':'+PropRtti.Name);
                    ACampos.Sep := ',';
                  end;
                end ;
               end;

            sql.Add(')');

            //valor dos parâmetros
            for PropRtti in ACampos.TipoRtti.GetProperties do
               if (CompareStr( PropRtti.Name , ACampos.AutoInc) <> 0)  then
               begin
                for attribs in proprtti.GetAttributes  do
                if attribs is TCamposProperty then
                begin
                    if not (Attribs as TCamposProperty).isNoInsert then
                    begin
                      Campo := PropRtti.Name;
                      ConfigParametro(Qry, PropRtti, Campo, ATabela);
                    end;
                end ;
               end
               else
                primaryKey := propRtti.Name ;
            Result := ExecutaQuery(Qry);
          end;
      finally
       //destroyQuery(Qry);
      end;

    end;

    Result.qryReturn := Qry ;
    Result.rowReturn := RttiAnonimoDAO(ATabela,Comando).rowReturn ;
end;

function TDaoFiredac.Inserir2_0(ATabela:TTabela): integer;
var
 table : TFDTable ;
  ControllerModel : TControllerModel ;
    Comando: TFuncaoAnonima;

    ctx : TRttiContext ;
    typ : TRttiType ;
    PropRtti : TRttiProperty;
    Attribs : TCustomAttribute ;
    campo : String ;
begin



       table := TFDTable.Create(FInstancia.FDatabase);
       table.Connection := FInstancia.FDatabase ;
       table.Transaction := FInstancia.FTransacao ;

       table.TableName := ControllerModel.PegaNomeTab(ATabela as TObject) ;
       table.UpdateOptions.AutoIncFields := ControllerModel.PegaPKs(ATabela as TObject)[0] ;
       table.Active := true ;

       table.Insert ;
      // table.FieldByName('DEL_CLI_ID').Value := 1 ;

              //valor dos parâmetros
              ctx := TRttiContext.Create;
              typ := ctx.GetType(ATabela.ClassType) ;
              for PropRtti in typ.GetProperties do
               if (CompareStr( PropRtti.Name , ControllerModel.PegaPKs(ATabela as TObject)[0] ) <> 0)  then
               begin
                for attribs in proprtti.GetAttributes  do
                if attribs is TCamposProperty then
                begin
                    if not (Attribs as TCamposProperty).isNoInsert then
                    begin
                      Campo := PropRtti.Name;
                                case propRtti.PropertyType.TypeKind of
                                  tkInt64,
                                  tkInteger :
                                  begin
                                    table.FieldByName(campo).Value := propRtti.GetValue(ATabela).AsInteger ;
                                  end;
                                  tkChar ,
                                  tkString ,
                                  tkUString :
                                  begin
                                    table.FieldByName(campo).Value := propRtti.GetValue(ATabela).AsString ;
                                  end;
                                  tkFloat :
                                  begin
                                    if CompareText(propRtti.PropertyType.Name, 'TDate') = 0 then
                                    begin
                                     if FormatDateTime('dd.mm.yyyy', propRtti.GetValue(ATabela).AsType<TDateTime>) <> '30.12.1899' then
                                       table.FieldByName(campo).AsDateTime := propRtti.GetValue(ATabela).AsType<TDateTime>;
                                    end
                                    else
                                    if CompareText(propRtti.PropertyType.Name, 'TTime') = 0 then
                                     table.FieldByName(campo).AsDateTime := propRtti.GetValue(ATabela).AsType<TDateTime>
                                    else
                                     begin
                                      table.FieldByName(campo).Value := propRtti.GetValue(ATabela).AsType<Double> ;
                                     end;
                                  end;
                                  tkVariant :
                                  begin
                                    table.FieldByName(campo).Value := propRtti.GetValue(ATabela).AsVariant ;
                                  end;
                                else
                                 raise Exception.Create('Tipo do campo não conhecido!'+propRtti.PropertyType.ToString);
                                end;
                    end;
                end ;
               end;

       table.Post ;
       table.Refresh ;
       Commit ;
       result := table.FieldByName( ControllerModel.PegaPKs(ATabela as TObject)[0]  ).AsInteger;
       table.Free ;

end;

function TDaoFiredac.InTransaction: Boolean;
begin
  {TODO -oHelio -cGeneral : Resolver esse result}
  Result := FInstancia.FTransacao.Connection.InTransaction ;
end;

function TDaoFiredac.isConnection: Boolean;
begin
  Result := FInstancia.FDatabase.Connected ;
end;

procedure TDaoFiredac.OFFOpenMode;
begin
  OpenModeCreate := false ;

end;

procedure TDaoFiredac.OnOpenMode;
begin
  OpenModeCreate := true ;
end;

function TDaoFiredac.OpenQuery(AQuery:TFDQuery): integer;
begin
with Aquery do
  begin
    Prepare();
    Open;
    Result := RowsAffected;
  end;
end;

procedure TDaoFiredac.RollBack;
begin
  FInstancia.FTransacao.Rollback ;
end;

function TDaoFiredac.Salvar(ATabela: TTabela): TResultORM;
var
  Comando: TFuncaoAnonima;
  Qry : TFDQuery ;
      control : TControllerModel ;
begin
  Comando := function(ACampos: TCamposAnoni): TValue
  var
    Campo: string;
    PropRtti: TRttiProperty;
    Attrib : TCustomAttribute;
  begin
    Qry := CreateQuery;
    FechaQuery(Qry);
    try
        with Qry do
        begin
          sql.Add('Update ' + ACampos.NomeTabela);
          sql.Add('set');

          //campos da tabela
          ACampos.Sep := '';
          for PropRtti in ACampos.TipoRtti.GetProperties do
          begin
             for Attrib in PropRtti.GetAttributes do
              if Attrib is TCamposProperty then
               if not (Attrib as TCamposProperty).isNoUpdate then
               begin
                    SQL.Add(ACampos.Sep + PropRtti.Name+'= :'+PropRtti.Name);
                    ACampos.Sep := ',';
               end;

          end;
          sql.Add('where');

          //parâmetros da cláusula where
          ACampos.Sep := '';
          for PropRtti in ACampos.TipoRtti.GetProperties do
          begin
            for Attrib in PropRtti.GetAttributes do
              if Attrib is TCamposPK then
               if (Attrib as TCamposPk).IsPK then
               begin
                    sql.Add(ACampos.Sep+ PropRtti.Name + '= :' + PropRtti.Name);
                    ACampos.Sep := ' and ';
                    ConfigParametro(Qry, PropRtti,PropRtti.Name, ATabela);
               end;
          end;


          //valor dos parâmetros
          for PropRtti in ACampos.TipoRtti.GetProperties do
          begin
            for Attrib in PropRtti.GetAttributes do
              if Attrib is TCamposProperty then
               if not (Attrib as TCamposProperty).isNoUpdate then
               begin
                 Campo := PropRtti.Name;
                 ConfigParametro(Qry, PropRtti, Campo, ATabela);
               end;
          end;

          Qry.Prepare ;
          Result := ExecutaQuery(Qry);
        end;
    finally
      DestroyQuery(Qry) ;
    end;

  end;

  //reflection da tabela e execução da query preparada acima.
  Result := RttiAnonimoDAO(ATabela, Comando);
end;

procedure TDaoFiredac.showLookupDisplay(AFDPrincipal, AFDLookup: TFDQuery;
  ATabela: TClassTabela;ATabelaLookup:TClassTabela);
var
ctx : TRttiContext ;
typ : TRttiType ;
PropRtti : TRttiProperty ;
AtribRtti : TCustomAttribute ;
oo : TField ;
control : TControllerModel ;

begin
 
  ctx := TRttiContext.Create ;
  typ := ctx.GetType( TClass(ATabela).ClassInfo) ;


  for PropRtti in typ.GetProperties do
    for AtribRtti in PropRtti.GetAttributes do
    begin

      if (AtribRtti is TLookupField) and  ( (AtribRtti as TLookupField).nomeTabelaLookup = control.PegaNomeTab2_0(ATabelaLookup) )   then
      begin
        AFDPrincipal.Close ;
        oo := TStringField.Create(AFDPrincipal);
        oo.FieldName := PropRtti.Name;
        oo.FieldKind := fkLookup ;
        oo.DataSet := AFDPrincipal ;
        oo.Name := AFDPrincipal.Name + oo.FieldName ;
        oo.KeyFields := (AtribRtti as TLookupField).keyField ;
        oo.LookupDataSet := AFDLookup ;
        oo.LookupKeyFields := (AtribRtti as TLookupField).LookupKey ;
        oo.LookupResultField := (AtribRtti as TLookupField).ResultField ;

        if (AtribRtti as TLookupField).Size > 0 then
          oo.Size := (AtribRtti as TLookupField).Size ;

        oo.DisplayLabel := (AtribRtti as TLookupField).DisplayLabel  ;

        oo.Index := (AtribRtti as TLookupField).ColunaIndex ;//AFDPrincipal.FieldCount ;
        AFDPrincipal.Open;

      end;
    end;
end;

procedure TDaoFiredac.StartTransaction;
begin
  FInstancia.FTransacao.StartTransaction ;
end;

function TDaoFiredac.VerificaNotNull(ATabela: TTabela): Boolean;
var
ctx : TRttiContext ;
typ : TRttiType ;
PropRtti : TRttiProperty ;
AtribRtti : TCustomAttribute ;

mengs : TResultArray ;
texto : string ;
i :  integer ;
begin

  Result := true ;
  ctx := TRttiContext.Create ;
  typ := ctx.GetType(ATabela.ClassType) ;

  for PropRtti in typ.GetProperties do
    for AtribRtti in PropRtti.GetAttributes do
      if AtribRtti is TCamposProperty then
       if (AtribRtti as TCamposProperty).isRequired = TRUE and (AtribRtti as TCamposProperty).isNoInsert = false  then
       case PropRtti.PropertyType.TypeKind of
         tkInteger :
         begin
           if PropRtti.GetValue(ATabela).AsInteger = 0 then
           begin
            SetLength(mengs,i+1);
            mengs[i]:= 'Campo '+PropRtti.Name+' não pode ser nulo' ;
            inc(i);
            Result :=  false ;
           end;
         end;
         tkUString,
         tkString,
         tkChar :
         begin
           if PropRtti.GetValue(ATabela).AsString = '' then
           begin
            SetLength(mengs,i+1);
            mengs[i]:= 'Campo '+PropRtti.Name+' não pode ser nulo' ;
            inc(i);
            Result := false ;
           end;
         end;
         tkFloat :
         begin
           if CompareText(PropRtti.PropertyType.Name, 'TDate') = 0 then
           begin
             if PropRtti.GetValue(ATabela).AsType<TDate> = 0 then
             begin
              SetLength(mengs,i+1);
              mengs[i]:= 'Campo '+PropRtti.Name+' não pode ser nulo' ;
              inc(i);
              Result := false ;
             end;
           end
           else
            if CompareText(PropRtti.PropertyType.Name, 'TDateTime') = 0 then
            begin
               if PropRtti.GetValue(ATabela).AsType<TDateTime> = 0 then
               begin
                SetLength(mengs,i+1);
                mengs[i]:= 'Campo '+PropRtti.Name+' não pode ser nulo' ;
                inc(i);
                Result := false ;
               end;
            end
             else
             begin
              //REMOVIDO A VERIFICAÇÃO NULO DE TIPOS DOUBLE, POIS SEMPRE O VALOR DEFAULT É 0 .
              { if PropRtti.GetValue(ATabela).AsType<Double> = 0 then
               begin
                SetLength(mengs,i+1);
                mengs[i]:= 'Campo '+PropRtti.Name+' não pode ser nulo' ;
                inc(i);
                Result := false ;
               end; }
             end;
         end;
       end;

      for texto in mengs do
      begin
       ShowMessage(texto);
      end;

   ctx.Free ;
end;

end.
