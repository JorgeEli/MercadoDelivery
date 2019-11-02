unit Fornecedores;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ComCtrls, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls, Vcl.ExtCtrls, Vcl.Buttons;

type
  TFFornecedor = class(TForm)
    QryFornecedores: TFDQuery;
    DsFornecedores: TDataSource;
    QryListagem: TFDQuery;
    DsListagem: TDataSource;
    PageFornecedor: TPageControl;
    TabListagem: TTabSheet;
    TabCadastro: TTabSheet;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    EdFornecedorCodigo: TDBEdit;
    EdFornecedorNome: TDBEdit;
    BtExcluir: TBitBtn;
    BtCancelar: TBitBtn;
    BtEditar: TBitBtn;
    BtSalvar: TBitBtn;
    BtNovo: TBitBtn;
    BtAtualizar: TBitBtn;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Label4: TLabel;
    EdPesquisa: TEdit;
    BtPesquisar: TBitBtn;
    BtLimparPesquisa: TBitBtn;
    BtListagemNovo: TBitBtn;
    BtAtualizarListagem: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtNovoClick(Sender: TObject);
    procedure BtExcluirClick(Sender: TObject);
    procedure BtCancelarClick(Sender: TObject);
    procedure BtAtualizarClick(Sender: TObject);
    procedure BtEditarClick(Sender: TObject);
    procedure BtSalvarClick(Sender: TObject);
    procedure TabListagemShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtPesquisarClick(Sender: TObject);
    procedure BtLimparPesquisaClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure TabCadastroShow(Sender: TObject);
    procedure BtListagemNovoClick(Sender: TObject);
    procedure DsFornecedoresStateChange(Sender: TObject);
    procedure EdPesquisaEnter(Sender: TObject);
    procedure EdPesquisaExit(Sender: TObject);
    procedure EdFornecedorNomeEnter(Sender: TObject);
    procedure EdFornecedorNomeExit(Sender: TObject);
    procedure BtAtualizarListagemClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure PesquisaFornecedor;
  end;

var
  FFornecedor: TFFornecedor;
  SqlListagem: String;

implementation

{$R *.dfm}

uses DataModule, Principal;

procedure TFFornecedor.BtAtualizarClick(Sender: TObject);
begin
  if (QryFornecedores.State in [dsInactive]) then
    QryFornecedores.Open;
  QryFornecedores.Refresh;
end;

procedure TFFornecedor.BtAtualizarListagemClick(Sender: TObject);
begin
  if (QryListagem.State in [dsInactive]) then
    QryListagem.Open();
  QryListagem.Refresh;
end;

procedure TFFornecedor.BtCancelarClick(Sender: TObject);
begin
  if (QryFornecedores.State in [dsEdit]) then
    QryFornecedores.Cancel;
  if (QryFornecedores.State in [dsInsert]) then
  begin
    QryFornecedores.Cancel;
    PageFornecedor.ActivePage := TabListagem;
  end;

end;

procedure TFFornecedor.BtEditarClick(Sender: TObject);
begin
  if QryFornecedores.RecordCount > 0 then
    QryFornecedores.Edit;
end;

procedure TFFornecedor.BtExcluirClick(Sender: TObject);
begin
  if QryFornecedores.RecordCount > 0 then
  begin
    if (Application.MessageBox('Excluir o registro?', 'Atenção...', MB_YESNO+MB_ICONQUESTION) = mrYes) then
    begin
      QryFornecedores.Delete;
      PageFornecedor.ActivePage := TabListagem;
    end;
  end;
end;

procedure TFFornecedor.BtLimparPesquisaClick(Sender: TObject);
begin
  EdPesquisa.Text := '';
  PesquisaFornecedor;
  EdPesquisa.SetFocus;
end;

procedure TFFornecedor.BtListagemNovoClick(Sender: TObject);
begin
  PageFornecedor.ActivePage := TabCadastro;
  BtNovo.Click;
end;

procedure TFFornecedor.BtNovoClick(Sender: TObject);
begin
  QryFornecedores.Append;
end;

procedure TFFornecedor.BtPesquisarClick(Sender: TObject);
begin
  PesquisaFornecedor;
end;

procedure TFFornecedor.BtSalvarClick(Sender: TObject);
  var
    QryLocal: TFDQuery;
    Codigo: Integer;
begin
  if EdFornecedorNome.Text = '' then
  begin
    EdFornecedorNome.SetFocus;
    Application.MessageBox('Insira uma descrição para o produto.', 'Atenção...', MB_ICONERROR);
    Abort;
  end;
  if (QryFornecedores.State in [dsEdit]) then
    QryFornecedores.Post
  else
    if (QryFornecedores.State in [dsInsert]) then
    begin
      QryLocal := TFDQuery.Create(nil);
      with QryLocal do
      begin
        Connection  := DM.Connection;
        Transaction := DM.Transaction;
        Sql.Add('SELECT COALESCE(MAX(FORNECEDOR_CODIGO),0) + 1 AS CODIGO FROM FORNECEDORES');
        Open;
        Codigo := FindField('CODIGO').AsInteger;
        Close;
      end;
      FreeAndNil(QryLocal);
      QryFornecedores.FindField('FORNECEDOR_CODIGO').AsInteger := Codigo;
      QryFornecedores.Post;
    end;
end;

procedure TFFornecedor.DBGrid1DblClick(Sender: TObject);
begin
  PageFornecedor.ActivePage := TabCadastro;
end;

procedure TFFornecedor.DsFornecedoresStateChange(Sender: TObject);
begin
  BtSalvar.Enabled    := (QryFornecedores.State in [dsEdit, dsInsert]);
  BtCancelar.Enabled  := (QryFornecedores.State in [dsEdit, dsInsert]);
  BtNovo.Enabled      := not (QryFornecedores.State in [dsEdit, dsInsert]);
  BtEditar.Enabled    := not (QryFornecedores.State in [dsEdit, dsInsert]);
  BtExcluir.Enabled   := not(QryFornecedores.State in [dsEdit, dsInsert]);
  BtAtualizar.Enabled := not (QryFornecedores.State in [dsEdit, dsInsert]);
end;

procedure TFFornecedor.EdFornecedorNomeEnter(Sender: TObject);
begin
  EdFornecedorNome.Color := clYellow;
end;

procedure TFFornecedor.EdFornecedorNomeExit(Sender: TObject);
begin
  EdFornecedorNome.Color := clWhite;
end;

procedure TFFornecedor.EdPesquisaEnter(Sender: TObject);
begin
  EdPesquisa.Color := clYellow;
end;

procedure TFFornecedor.EdPesquisaExit(Sender: TObject);
begin
  EdPesquisa.Color := clWhite;
end;

procedure TFFornecedor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  QryFornecedores.Close;
  QryListagem.Close;
  Action := Cafree;
  FFornecedor := nil;
end;

procedure TFFornecedor.FormCreate(Sender: TObject);
begin
  PageFornecedor.ActivePage := TabListagem;
  SqlListagem := 'SELECT * FROM FORNECEDORES ';
end;

procedure TFFornecedor.FormShow(Sender: TObject);
begin
  QryListagem.Open;
end;

procedure TFFornecedor.PesquisaFornecedor;
  procedure Pesquisa(Tipo: SmallInt);
  begin
    QryListagem.Close;
    QryListagem.SQL.Clear;
    case Tipo of
      0: QryListagem.SQL.Add(SqlListagem + ' WHERE FORNECEDOR_CODIGO = ' + EdPesquisa.Text + ' ORDER BY FORNECEDOR_CODIGO');
      1: QryListagem.SQL.Add(SqlListagem + ' WHERE FORNECEDOR_NOME LIKE ' + QuotedStr('%' + EdPesquisa.Text + '%') + ' ORDER BY FORNECEDOR_NOME');
      2: QryListagem.SQL.Add(SqlListagem + ' ORDER BY FORNECEDOR_CODIGO');
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

procedure TFFornecedor.TabCadastroShow(Sender: TObject);
begin
  QryFornecedores.Close;
  QryFornecedores.ParamByName('CODIGO').AsInteger := QryListagem.FindField('FORNECEDOR_CODIGO').AsInteger;
  QryFornecedores.Open();
  EdFornecedorNome.SetFocus;
end;

procedure TFFornecedor.TabListagemShow(Sender: TObject);
begin
  if (QryListagem.State in [dsInactive]) then
    QryListagem.Open();
  QryListagem.Refresh;
  EdPesquisa.SetFocus;
end;


end.
