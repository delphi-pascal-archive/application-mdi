{
  AVERTISSEMENT !!
    Ce code est donné tel quel et il peut sans doute être amélioré et/ou contenir des BUGS.

  Sources d'inspiration
  ---------------------
      > Composante  TdsTaskBar trouvée sur le site www.torry.net

      > Article de Zarko Gajic (en anglais) sur le site delphi.about.com
            http://delphi.about.com/od/delphitips2009/qt/delphi-mdi-child-prevent-on-create-resize-animation.htm
}

unit MAIN;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
     StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls, StdActns,
     ActnList, ToolWin, ImgList, Tabs;

type
  { On défini nos événements sur le MDIChild }
  TMDIChangeOp = (mdiCaption, mdiDestroy);

  { On défini notre propre struture d'Event }
  TOnMDIChange = procedure(aForm: TForm; aTabIndex: Integer;
    aMDIChangeOp: TMDIChangeOp) of object;

  { **************************************************************
    * Cet objet va nous permettre d'identifier de manière unique *
    *   1 - un MDIChild                                          *
    *   2 - les message qui en arrivent                          *
    *   3 - la procédure WindowProc d'origine du MDIChild        *
    **************************************************************  }
  TMDILink = Class(TObject)
  private
    fForm : TForm;
    fTabIndex : Integer;
    fOldFormWindowProc : TWndMethod;
    fOnMDIChange : TOnMDIChange;
    procedure MonWindowProc(var Message: TMessage); // Ma propre Procédure WindowProc
    procedure SetTabIndex(const Value: Integer);
  public
    constructor Create(aForm: TForm; aTabIndex : Integer);

    property Form : TForm read fForm;
    property TabIndex : Integer read fTabIndex write SetTabIndex;
    property OnMDIChange : TOnMDIChange read fOnMDIChange
                                        write fOnMDIChange;
  end;

  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileCloseItem: TMenuItem;
    Window1: TMenuItem;
    Help1: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    WindowCascadeItem: TMenuItem;
    WindowTileItem: TMenuItem;
    WindowArrangeItem: TMenuItem;
    HelpAboutItem: TMenuItem;
    OpenDialog: TOpenDialog;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    WindowMinimizeItem: TMenuItem;
    StatusBar: TStatusBar;
    ActionList1: TActionList;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    FileNew1: TAction;
    FileSave1: TAction;
    FileExit1: TAction;
    FileOpen1: TAction;
    FileSaveAs1: TAction;
    WindowCascade1: TWindowCascade;
    WindowTileHorizontal1: TWindowTileHorizontal;
    WindowArrangeAll1: TWindowArrange;
    WindowMinimizeAll1: TWindowMinimizeAll;
    HelpAbout1: TAction;
    FileClose1: TWindowClose;
    WindowTileVertical1: TWindowTileVertical;
    WindowTileItem2: TMenuItem;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton9: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ImageList1: TImageList;
    tsMDIList: TTabSet;
    actOuvreMonEcran: TAction;
    actMonEcranMonConstruteur: TAction;
    N2: TMenuItem;
    OuvrelcrandeTest1: TMenuItem;
    OuvrelcrandeTestavecnotreconstructeur1: TMenuItem;
    procedure FileNew1Execute(Sender: TObject);
    procedure FileOpen1Execute(Sender: TObject);
    procedure HelpAbout1Execute(Sender: TObject);
    procedure FileExit1Execute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tsMDIListChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure tsMDIListMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tsMDIListMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tsMDIListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure tsMDIListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure actOuvreMonEcranExecute(Sender: TObject);
    procedure actMonEcranMonConstruteurExecute(Sender: TObject);
  private
    { Déclarations privées }
    fOldActiveFormChange : TNotifyEvent; // Garde le lien avec l'evénement actuel
    procedure CreateMDIChild(const Name: string);
    procedure MonActiveFormChange(Sender: TObject); // Mon propre événement
    procedure MyMDIChange(aForm: TForm; aTabIndex: Integer;
      aMDIChangeOp: TMDIChangeOp);
  public
    { Déclarations publiques }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses CHILDWIN, about, FileCtrl, foEcranTestU;

procedure TMainForm.CreateMDIChild(const Name: string);
var
  Child: TMDIChild;
begin
  { crée une nouvelle fenêtre enfant MDI }
  Child := TMDIChild.Create(Application);
  Child.Caption := Name;
  if FileExists(Name) then Child.Memo1.Lines.LoadFromFile(Name);
end;

procedure TMainForm.FileNew1Execute(Sender: TObject);
begin
  CreateMDIChild('NONAME' + IntToStr(MDIChildCount + 1));
end;

procedure TMainForm.FileOpen1Execute(Sender: TObject);
begin
  if OpenDialog.Execute then
    CreateMDIChild(OpenDialog.FileName);
end;

procedure TMainForm.HelpAbout1Execute(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TMainForm.FileExit1Execute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
{ *************************************************************************
  * Pour détecter les nouvelles MDI Child Créer et le changement d'écran, *
  * on détourne l'événement OnActiveFormChange de l'objet Screen          *
  *************************************************************************  }

  { 1 - On garde le lien vers l'événement actuel pour le rappeler ensuite }
  fOldActiveFormChange := Screen.OnActiveFormChange;

  { 2 - On affecte notre propre procédure à lévénement }
  Screen.OnActiveFormChange := MonActiveFormChange;

{ ** Initialise le TabSet ** }
  tsMDIList.Tabs.Clear;       // Efface tous les Tab en cours
  tsMDIList.Visible := False; // Masque le TabSet
end;

procedure TMainForm.MonActiveFormChange(Sender: TObject);
var
  i : Integer;
  F : TForm;
  TmpMDILink : TMDILink;
begin
  { On Récupère le nouveau Form Actif }
  F := Screen.ActiveForm;

  { On ne traite que les Form de Type MDIChild }
  if (Assigned(F)) and                  // Vérifie que'il y a bien un Form actif
     (F.FormStyle = fsMDIChild) then    // Vérifie que c'est bien un MDIChild
    begin
      { Initialise la Variable }
      i := 0;

      { Recherche si le form a déjà été détecté }
      while (i < tsMDIList.Tabs.Count) and
            (tsMDIList.Tabs.Objects[i] <> Nil) and
            (tsMDIList.Tabs.Objects[i] is TMDILink) and
            (TMDILink(tsMDIList.Tabs.Objects[i]).Form <> F) do
        inc(i);

      { Vérifie si le Form a été trouvé
        /!\ les index de Tab comme à 0 donc si i = Tabs.Count j'ai dépassé le dernier Tab  }
      if (i = tsMDIList.Tabs.Count) then
        begin
          { Crée un Tab avec le caption du Form }
          i := tsMDIList.Tabs.Add(F.Caption);

          { Crée l'objet MDILink pour garder le lien avec le MDIChild }
          TmpMDILink := TMDILink.Create(F, i);

          { Affecte l'evénement en cas de changement sur MDIChild }
          TmpMDILink.OnMDIChange := MyMDIChange;

          { Affecte le TMDILink comme objet du Tab }
          tsMDIList.Tabs.Objects[i] := TmpMDILink;

          { Sélectionne le Nouveau Tab comme Tab Actif }
          tsMDIList.TabIndex := i;
        end
       else
        { Le form a été trouvé - on sélécetionne le Tab qui lui est associé }
        tsMDIList.TabIndex := i;

      { On s'assure que le TabSet est visible dés qu'il a au moins un Tab de créé }
      tsMDIList.Visible := (tsMDIList.Tabs.Count > 0);
    end;

  { On appel l'événement qu'il y avait avant le notre }
  if (Assigned(fOldActiveFormChange)) then  // On vérifie tout de même qu'il y avait bien un Evénement avant le notre
    fOldActiveFormChange(Sender);
end;

{ TMDILink }

constructor TMDILink.Create(aForm: TForm; aTabIndex : Integer);
begin
  { Vérifie qu'on a bien Form en entrée }
  if (aForm = Nil) then
    Raise Exception.Create('Le Form ne peut-être Null');

  { Garde le Form en Mémoire }
  fForm := aForm;

  { Garde l'ancienne WindowProc en Mémoire }
  fOldFormWindowProc := Form.WindowProc;

  { Affecte la Nouvelle Procédure }
  Form.WindowProc := MonWindowProc;

  { Garde l'index du Tab correspondant }
  SetTabIndex(aTabIndex);

  { Initialise les Events }
  fOnMDIChange := Nil;
end;

procedure TMDILink.MonWindowProc(var Message: TMessage);
begin
  { Appel l'ancienne Procédure du Form }
  fOldFormWindowProc(Message);

  { Détecte le Type de Changement }
  case Message.Msg of
    { Changement du caption }
    WM_SETTEXT:
      if (Assigned(fOnMDIChange)) then
        fOnMDIChange(Form, TabIndex, mdiCaption);

    { Destruction de la Fenêtre }
    WM_DESTROY:
      if (Assigned(fOnMDIChange)) then
        fOnMDIChange(Form, TabIndex, mdiDestroy);
  end;
end;

procedure TMDILink.SetTabIndex(const Value: Integer);
begin
  fTabIndex := Value;
end;

procedure TMainForm.MyMDIChange(aForm: TForm; aTabIndex: Integer;
  aMDIChangeOp: TMDIChangeOp);
var
  i : Integer;
begin
  { Met à jour les TabSet en fonction du Changement du MDIChild }
  case aMDIChangeOp of
    { Changement de Caption - Et réduit les noms de fichier trop long }
    mdiCaption :
      begin
        { Vérifie qu'il s'agisse bien d'un nom de fichier }
        if (ExtractFileDrive(aForm.Caption) <> '') then
          tsMDIList.Tabs[aTabIndex] := MinimizeName(aForm.Caption, Self.Canvas, 250)
         else
          tsMDIList.Tabs[aTabIndex] := aForm.Caption;
      end;

    { Destruction de la Fenêtre }
    mdiDestroy :
      begin
        { Efface le MDILink associé au Form }
        tsMDIList.Tabs.Objects[aTabIndex].Free;

        { Efface le Tab associé au Form }
        tsMDIList.Tabs.Delete(aTabIndex);

        { Remet à jour les Index des MDILink }
        for i := aTabIndex to tsMDIList.Tabs.Count - 1 do
          begin
            if (tsMDIList.Tabs.Objects[i] <> Nil) and
               (tsMDIList.Tabs.Objects[i] is TMDILink) then
              TMDILink(tsMDIList.Tabs.Objects[i]).TabIndex := i;
          end; { for i := aTabIndex to tsMDIList.Tabs.Count - 1 do... }

        { Masque le TabSet s'il n'y a plus de Tab }
        tsMDIList.Visible := (tsMDIList.Tabs.Count > 0);   
      end; { mdiDestroy }
  end;
end;

procedure TMainForm.tsMDIListChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
  { Si aucun Tab Sélectionné, ne Fait rien }
  if (NewTab = -1) then
    Exit;

  { Vérifie qu'il y a bien un TMDILink et un Form associé à ce Tab }
  if (tsMDIList.Tabs.Objects[NewTab] is TMDILink) and
     (TMDILink(tsMDIList.Tabs.Objects[NewTab]).Form <> Nil) then
    begin
      { /!\ ** D'après un article de Zarko Gajic sur delphi.about.com **

        évite les animation pour l'affichage du Child s'il est Minimize}
      SendMessage(ClientHandle, WM_SETREDRAW, 0, 0) ;
      try
        with (TMDILink(tsMDIList.Tabs.Objects[NewTab]).Form) do
          begin
            { Donne le Focus au Form }
            SetFocus;

            { Amène le Form devant }
            BringToFront;

            { Si le Form est minimisé, rétabli le Form }
            if WindowState = wsMinimized then
              WindowState := wsNormal; //OldWindowState;
          end; { with (TMDILink(tsMDIList.Tabs.Objects[NewTab]).Form) do... }
      finally
        { Relance le Dessin du MainForm pour voir les changements }
        SendMessage(ClientHandle, WM_SETREDRAW, 1, 0) ;

        { Para rapport à l'article j'ai ajouté le Flag RDW_ERASE qui manquait }
        RedrawWindow(ClientHandle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_ERASE or
                                           RDW_ALLCHILDREN or RDW_NOINTERNALPAINT)
      end;
    end; { if (tsMDIList.Tabs.Objects[NewTab] is TMDILink) and
              (TMDILink(tsMDIList.Tabs.Objects[NewTab]).Form <> Nil) then... }
end;

procedure TMainForm.tsMDIListMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  { Prépare le Mode Drag&Drop a démarrer dés que la souris est bougée }
  if (ssLeft in Shift) then
    tsMDIList.BeginDrag(False);
end;

procedure TMainForm.tsMDIListMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  { Stopppe le mode Drag&Drop si il est activé }
  if (tsMDIList.Dragging) then
    tsMDIList.EndDrag(True);
end;

procedure TMainForm.tsMDIListDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  { Accepte le Drag&Drop si : }
  Accept := (Sender = Source) and                                     // sur le même Composant
            (tsMDIList.ItemAtPos(Point(X, Y)) > -1) and               // un tab est détecté sous la souris
            (tsMDIList.ItemAtPos(Point(X, Y)) <> tsMDIList.TabIndex); // la futur position n'est pas la mêmeque la position actuelle
end;

procedure TMainForm.tsMDIListDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  i : Integer;
begin
  { Récupère l'index du Tab sous la souris }
  i := tsMDIList.ItemAtPos(Point(X, Y));

  { Déplace le Tab vers sa nouvelle place si un tab a été détecté sous la souris }
  if (i > -1) then
    begin
      { Place l'onglet courant à la place de celui sous la souris }
      tsMDIList.Tabs.Move(tsMDIList.TabIndex, i);

      { Vérifie que l'onglet déplacé est toujours l'onglet actif }
      tsMDIList.TabIndex := i;

      { Remet à jour les Index des MDILink }
      for i := 0 to tsMDIList.Tabs.Count - 1 do
        TMDILink(tsMDIList.Tabs.Objects[i]).TabIndex := i;
    end; { if (i > -1) then... } 
end;

procedure TMainForm.actOuvreMonEcranExecute(Sender: TObject);
begin
  { Création du MDIChild avec le constructeur par défaut }
  TfoEcranTest.Create(Self);
end;

procedure TMainForm.actMonEcranMonConstruteurExecute(Sender: TObject);
begin
  { Création du MDIChild avec le constructeur qu'on a implémenté }
  TfoEcranTest.MonCreate(Self, FormatDateTime('dd/mm/YYYY HH:MM:SS', Now));
end;

end.
