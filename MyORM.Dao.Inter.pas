unit MyORM.Dao.Inter;

interface

uses Classes,
MyORM.Atributos,
MyORM.Atributos.Model,
MyORM.Atributos.DAO,
 System.Generics.Collections ;

type
  IBaseDados = interface
  ['{26851001-CCE4-4EA3-9942-5B35E30503FE}']
  end;

  ITransacao = interface
  ['{0F337C38-E15B-47F7-B975-CF168C39F987}']
  end;

  IDaoBase =  interface
  ['{3C9E170D-B0FE-4DB4-A577-1FA52020C865}']

  function Inserir(ATabela: TTabela)  : TResultORM;
  function Salvar (ATabela: TTabela)   : TResultORM;
  function Excluir(ATabela: TTabela; ACondition : TList<TConditionSQL>)  : TResultORM;
  function Buscar (ATabela: TObject; ACondition : TList<TConditionSQL> ; AOrder : TList<TOrderBySQL> )   : TResultORM;

  function InTransaction              : Boolean;
  procedure StartTransaction;
  procedure Commit;
  procedure RollBack;

end;

implementation

end.
