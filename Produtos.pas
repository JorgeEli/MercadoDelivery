unit Produtos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Mask, Vcl.DBCtrls, Vcl.ExtCtrls;

type
  TFProdutos = class(TForm)
    PageProdutos: TPageControl;
    TabListagem: TTabSheet;
    TabCadastro: TTabSheet;
    QryProdutos: TFDQuery;
    DsProdutos: TDataSource;
    DsListagem: TDataSource;
    QryListagem: TFDQuery;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    EdProdutoCodigo: TDBEdit;
    EdProdutoDescricao: TDBEdit;
    BtExcluir: TBitBtn;
    BtCancelar: TBitBtn;
    BtEditar: TBitBtn;
    BtSalvar: TBitBtn;
    BtNovo: TBitBtn;
    BtAtualizar: TBitBtn;
    Label3: TLabel;
    LkFornecedor: TDBLookupComboBox;
    QryFornecedores: TFDQuery;
    DsFornecedores: TDataSource;
    Panel2: TPanel;
    EdPesquisa: TEdit;
    BtPesquisar: TBitBtn;
    BtLimparPesquisa: TBitBtn;
    Label4: TLabel;
    Panel3: TPanel;
    Panel4: TPanel;
    BtListagemNovo: TBitBtn;
    BtAtualizarListagem: TBitBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure BtNovoClick(Sender: TObject);
    procedure BtExcluirClick(Sender: TObject);
    procedure BtCancelarClick(Sender: TObject);
    procedure BtEditarClick(Sender: TObject);
    procedure BtAtualizarClick(Sender: TObject);
    procedure BtSalvarClick(Sender: TObject);
    procedure TabListagemShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtPesquisarClick(Sender: TObject);
    procedure BtLimparPesquisaClick(Sender: TObject);
    procedure TabCadastroShow(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure BtListagemNovoClick(Sender: TObject);
    procedure DsProdutosStateChange(Sender: TObject);
    procedure EdPesquisaEnter(Sender: TObject);
    procedure EdPesquisaExit(Sender: TObject);
    procedure EdProdutoDescricaoEnter(Sender: TObject);
    procedure EdProdutoDescricaoExit(Sender: TObject);
    procedure LkFornecedorEnter(Sender: TObject);
    procedure LkFornecedorExit(Sender: TObject);
    procedure BtAtualizarListagemClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure PesquisaProduto;
  end;

var
  FProdutos: TFProdutos;
  SqlListagem: String;

implementation

{$R *.dfm}

uses DataModule;

procedure TFProdutos.BtPesquisarClick(Sender: TObject);
begin
  PesquisaProduto;
end;

procedure TFProdutos.BtAtualizarClick(Sender: TObject);
begin
  if (QryProdutos.State in [dsInactive]) then
    QryProdutos.Open;
  QryProdutos.Refresh;
end;

procedure TFProdutos.BtAtualizarListagemClick(Sender: TObject);
begin
  if (QryListagem.State in [dsInactive]) then
    QryListagem.Open();
  QryListagem.Refresh;
end;

procedure TFProdutos.BtCancelarClick(Sender: TObject);
begin
  if (QryProdutos.State in [dsEdit]) then
    QryProdutos.Cancel;
  if (QryProdutos.State in [dsInsert]) then
  begin
    QryProdutos.Cancel;
    PageProdutos.ActivePage := TabListagem;
  end;
end;

procedure TFProdutos.BtEditarClick(Sender: TObject);
begin
  if QryProdutos.RecordCount > 0 then
    QryProdutos.Edit;
end;

procedure TFProdutos.BtExcluirClick(Sender: TObject);
begin
  if QryProdutos.RecordCount > 0 then
  begin
    if (Application.MessageBox('Excluir o registro?', 'Atenção...', MB_YESNO+MB_ICONQUESTION) = mrYes) then
    begin
      QryProdutos.Delete;
      PageProdutos.ActivePage := TabListagem;
    end;
  end;
end;

procedure TFProdutos.BtLimparPesquisaClick(Sender: TObject);
begin
  EdPesquisa.Text := '';
  PesquisaProduto;
  EdPesquisa.SetFocus;
end;

procedure TFProdutos.BtListagemNovoClick(Sender: TObject);
begin
  PageProdutos.ActivePage := TabCadastro;
  BtNovo.Click;
end;

procedure TFProdutos.BtNovoClick(Sender: TObject);
begin
  QryProdutos.Append;
end;

procedure TFProdutos.BtSalvarClick(Sender: TObject);
  var
    QryLocal: TFDQuery;
    Codigo: Integer;
begin
  if EdProdutoDescricao.Text = '' then
  begin
    EdProdutoDescricao.SetFocus;
    Application.MessageBox('Insira uma descrição para o produto.', 'Atenção...', MB_ICONERROR);
    Abort;
  end;
  if LkFornecedor.Text = '' then
  begin
    LkFornecedor.SetFocus;
    Application.MessageBox('Insira um fornecedor.', 'Atenção...', MB_ICONERROR);
    Abort;
  end;
  if (QryProdutos.State in [dsEdit]) then
    QryProdutos.Post
  else
    if (QryProdutos.State in [dsInsert]) then
    begin
      QryLocal := TFDQuery.Create(nil);
      with QryLocal do
      begin
        Connection  := DM.Connection;
        Transaction := DM.Transaction;
        Sql.Add('SELECT COALESCE(MAX(PRODUTO_CODIGO),0) + 1 AS CODIGO FROM PRODUTOS');
        Open;
        Codigo := FindField('CODIGO').AsInteger;
        Close;
      end;
      FreeAndNil(QryLocal);
      QryProdutos.FindField('PRODUTO_CODIGO').AsInteger := Codigo;
      QryProdutos.Post;
    end;
end;

procedure TFProdutos.DBGrid1DblClick(Sender: TObject);
begin
  PageProdutos.ActivePage := TabCadastro;
end;

procedure TFProdutos.DsProdutosStateChange(Sender: TObject);
begin
  BtSalvar.Enabled    := (QryProdutos.State in [dsEdit, dsInsert]);
  BtCancelar.Enabled  := (QryProdutos.State in [dsEdit, dsInsert]);
  BtNovo.Enabled      := not (QryProdutos.State in [dsEdit, dsInsert]);
  BtEditar.Enabled    := not (QryProdutos.State in [dsEdit, dsInsert]);
  BtExcluir.Enabled   := not (QryProdutos.State in [dsEdit, dsInsert]);
  BtAtualizar.Enabled := not (QryProdutos.State in [dsEdit, dsInsert]);
end;

procedure TFProdutos.EdPesquisaEnter(Sender: TObject);
begin
  EdPesquisa.Color := clYellow;
end;

procedure TFProdutos.EdPesquisaExit(Sender: TObject);
begin
  EdPesquisa.Color := clWhite;
end;

procedure TFProdutos.EdProdutoDescricaoEnter(Sender: TObject);
begin
  EdProdutoDescricao.Color := clYellow;
end;

procedure TFProdutos.EdProdutoDescricaoExit(Sender: TObject);
begin
  EdProdutoDescricao.Color := clWhite;
end;

procedure TFProdutos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  QryListagem.Close;
  QryProdutos.Close;
  QryFornecedores.Close;
  Action := cafree;
  FProdutos := nil;
end;

procedure TFProdutos.FormCreate(Sender: TObject);
begin
  PageProdutos.ActivePage := TabListagem;
  SqlListagem := 'SELECT p.*, f.FORNECEDOR_NOME FROM PRODUTOS p LEFT OUTER JOIN FORNECEDORES f ON f.FORNECEDOR_CODIGO = p.FORNECEDOR_CODIGO';
end;

procedure TFProdutos.FormShow(Sender: TObject);
begin
  QryListagem.Open;
  QryFornecedores.Open();
end;

procedure TFProdutos.LkFornecedorEnter(Sender: TObject);
begin
  LkFornecedor.Color := clYellow;
end;

procedure TFProdutos.LkFornecedorExit(Sender: TObject);
begin
  LkFornecedor.Color := clWhite;
end;

procedure TFProdutos.PesquisaProduto;
  procedure Pesquisa(Tipo: SmallInt);
  begin
    QryListagem.Close;
    QryListagem.SQL.Clear;
    case Tipo of
      0: QryListagem.SQL.Add(SqlListagem + ' WHERE p.PRODUTO_CODIGO = ' + EdPesquisa.Text + ' ORDER BY p.PRODUTO_CODIGO');
      1: QryListagem.SQL.Add(SqlListagem + ' WHERE p.PRODUTO_DESCRICAO LIKE ' + QuotedStr('%' + EdPesquisa.Text + '%') + ' ORDER BY p.PRODUTO_CODIGO');
      2: QryListagem.SQL.Add(SqlListagem + ' ORDER BY p.PRODUTO_CODIGO');
    end;
    QryListagem.Open();
  end;
begin
  if EdPesquisa.Text <> '' then
  begin
      try
        Pesquisa(StrToInt(EdPesquisa.Text) * 0);
       except
        Pesquisa(1);
      end;
  end
  else
    Pesquisa(2);
end;

procedure TFProdutos.TabCadastroShow(Sender: TObject);
begin
  QryProdutos.Close;
  QryProdutos.ParamByName('CODIGO').AsInteger := QryListagem.FindField('PRODUTO_CODIGO').AsInteger;
  QryProdutos.Open;
  EdProdutoDescricao.SetFocus;
end;

procedure TFProdutos.TabListagemShow(Sender: TObject);
begin
  if (QryListagem.State in [dsInactive]) then
    QryListagem.Open();
  QryListagem.Refresh;
  EdPesquisa.SetFocus;
end;

end.
