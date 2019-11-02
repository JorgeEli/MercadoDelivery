unit Principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.Imaging.pngimage;

type
  TFPrincipal = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Label1: TLabel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    BtFornecedores: TBitBtn;
    BtProdutos: TBitBtn;
    BtClientes: TBitBtn;
    Panel9: TPanel;
    BtPedidos: TBitBtn;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    procedure BtProdutosClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtFornecedoresClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FPrincipal: TFPrincipal;

implementation

{$R *.dfm}

uses DataModule, Produtos, Fornecedores;

procedure TFPrincipal.BtFornecedoresClick(Sender: TObject);
begin
  if not(assigned(FFornecedor)) then
    Application.CreateForm(TFFornecedor, FFornecedor);
  FFornecedor.WindowState := wsMaximized;
  FFornecedor.ShowModal;
end;

procedure TFPrincipal.BtProdutosClick(Sender: TObject);
begin
  if not(assigned(FProdutos)) then
    Application.CreateForm(TFProdutos, FProdutos);
  FProdutos.WindowState := wsMaximized;
  FProdutos.ShowModal;
end;

procedure TFPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caFree;
  FPrincipal := nil;
  Application.Terminate;
end;

end.
