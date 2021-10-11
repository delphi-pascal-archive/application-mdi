unit foEcranTestU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfoEcranTest = class(TForm)
    Label1: TLabel;
    eNouveauTitre: TEdit;
    btnRenomer: TButton;
    procedure btnRenomerClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    constructor MonCreate(aOwner: TComponent; const aMonTitre: String);
  end;

implementation

{$R *.dfm}

procedure TfoEcranTest.btnRenomerClick(Sender: TObject);
begin
  { Renome l'écran. "Plus exactement change son titre" }
  Self.Caption := eNouveauTitre.Text; 
end;

procedure TfoEcranTest.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  { Force la libération de l'écran à sa fermeture }
  action := caFree;
end;

constructor TfoEcranTest.MonCreate(aOwner: TComponent;
  const aMonTitre: String);
begin
{ ** Un petit constructeur juste pour le Fun ** }

   { Crée le form }
   Create(aOwner);

   try
     { Met à jour le Titre }
     if (Trim(aMonTitre) <> '') then
       Self.Caption := Trim(aMonTitre);
   except
     on E:Exception do
       begin
         { Affiche le message d'erreur }
         MessageDlg('La création de l''écran a générée l''erreur suivante:'#13#13 +
                    E.Message, mtError, [mbOk], 0);

         { Force la fermeture de l'écran }
         Close;
       end;
   end; { try... except... }
end;

end.
