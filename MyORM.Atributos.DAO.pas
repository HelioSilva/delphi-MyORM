unit MyORM.Atributos.DAO;

interface

Uses
     FireDAC.Comp.Client  ;

type

TOrderBy = set of (Asc,Desc);
TOperatorSQL = set of ( igual , like) ;


TListaBuscaORM = array of record
  field : String ;
  displayField : String ;
  operador : TOperatorSQL ;
end;

TResultORM = record
  rowReturn : integer ;
  genReturn : integer ;
  qryReturn : TFDQuery ;
  resp      : string ;
end;




TConditionSQL = record
  campo : string ;
  valor : variant ;
  tipo  : TOperatorSQL ;
end;

TOrderBySQL = record
  campo : string ;
  order : TOrderBy ;

end;



implementation



end.
