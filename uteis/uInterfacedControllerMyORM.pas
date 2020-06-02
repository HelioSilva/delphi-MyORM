unit uInterfacedControllerMyORM;

interface

uses
      {Nativos da Linguagem}
       FireDAC.Comp.Client,

      {Terceiros - PRoprios}
        uBaseDeEventos,MyORM.Atributos.DAO,
        MyORM.Atributos,
        MyORM.Collections,
        System.Generics.Collections, MyORM.Atributos.Model;

type

iControllerMyORM = interface
      {Private}


        function getQueryFormatado(SQL : string) : TFDQuery ;
        procedure atualizaEventos ;
      {Public}
        function novo():iControllerMyORM ;
        function editar(Value:integer):iTabela ;
        function read():iControllerMyORM ;
        function create_update(Value : iTabela):iControllerMyORM;

end;

implementation

end.
