unit Produto;

interface

uses Rtti , MyORM.Atributos.Model ,System.TypInfo ;


type
[TNomeTabela('PRODUTO')]
TProduto = class(TTabela)
  private
    FMedidaCompra: String;
    FPrecoCusto: Currency;
    FCodigoBarras: String;
    FPrecoVenda: Currency;
    FId: Integer;
    FNome: String;
    FMedidaVenda: String;
    FDataVencimento: TDate;
    FDataCadastro: TDateTime;
    procedure SetCodigoBarras(const Value: String);
    procedure SetId(const Value: Integer);
    procedure SetMedidaCompra(const Value: String);
    procedure SetMedidaVenda(const Value: String);
    procedure SetNome(const Value: String);
    procedure SetPrecoCusto(const Value: Currency);
    procedure SetPrecoVenda(const Value: Currency);
    procedure SetDataVencimento(const Value: TDate);
    procedure SetDataCadastro(const Value: TDateTime);

  public
    [TCamposPK(true)]
    property Id : Integer  read FId write SetId;
    [TCamposPK(false)]
    [TCamposInfo('Nome do Campo')]
    [TCamposProperty([Unique])]
    property Nome : String read FNome write SetNome;
    [TCamposProperty([])]
    property MedidaVenda : String read FMedidaVenda write SetMedidaVenda;
    property MedidaCompra : String read FMedidaCompra write SetMedidaCompra;
    [TCamposInfo('Codigo de Barras')]
    property CodigoBarras : String read FCodigoBarras write SetCodigoBarras;
    property PrecoVenda : Currency  read FPrecoVenda write SetPrecoVenda;
    [TCamposProperty([NoUpdate])]
    property PrecoCusto : Currency  read FPrecoCusto write SetPrecoCusto;
    property DataVencimento : TDate  read FDataVencimento write SetDataVencimento;
    property DataCadastro : TDateTime  read FDataCadastro write SetDataCadastro;
end;


implementation

{ TProduto }

procedure TProduto.SetCodigoBarras(const Value: String);
begin
  FCodigoBarras := Value;
end;

procedure TProduto.SetDataCadastro(const Value: TDateTime);
begin
  FDataCadastro := Value;
end;

procedure TProduto.SetDataVencimento(const Value: TDate);
begin
  FDataVencimento := Value;
end;

procedure TProduto.SetId(const Value: Integer);
begin
  FId := Value;
end;

procedure TProduto.SetMedidaCompra(const Value: String);
begin
  FMedidaCompra := Value;
end;

procedure TProduto.SetMedidaVenda(const Value: String);
begin
  FMedidaVenda := Value;
end;

procedure TProduto.SetNome(const Value: String);
begin
  FNome := Value;
end;

procedure TProduto.SetPrecoCusto(const Value: Currency);
begin
  FPrecoCusto := Value;
end;

procedure TProduto.SetPrecoVenda(const Value: Currency);
begin
  FPrecoVenda := Value;
end;

end.
