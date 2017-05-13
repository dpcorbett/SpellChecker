unit untSpellChecker;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  StrUtils,
  SysUtils,
  FileUtil,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  StdCtrls;

type
  TheMisSpelled = (TEH, ETH, EHT);     // Enumeration of 'the' mis-spellings
  { TForm1 }

  TForm1 = class(TForm)
    btnLoadFile: TButton;
    btnSaveFile: TButton;
    btnCorrect: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MemoBox: TMemo;

    procedure btnCorrectClick(Sender: TObject);
    procedure btnLoadFileClick(Sender: TObject);
    procedure btnSaveFileClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { private declarations }
         // Method added by the author
     function  ChangeText(var AText : String; theType : TheMisSpelled) : Boolean;
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  fileName : String;
  fileData : TStringList;
  openDialog : TOpenDialog;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Set the title of the form - our application title
  Form1.Caption := 'Very simple spell corrector';

  // Disable all except the load file button
  btnSaveFile.Enabled    := false;
  btnCorrect.Enabled := false;

  // Clear the file display box
  MemoBox.Clear;

  // Enable scroll bars for this memo box - this allows us to scroll up
  // and down and left and right to see all the text
  MemoBox.ScrollBars := ssBoth;

  // do not allow the user to directly type into the displayed file text
  MemoBox.ReadOnly := true;

  // Set the font of the memo box to a mono-spaced one to ease reading
  MemoBox.Font.Name := 'Courier New';

  // Set all of the labels to blank
  Label1.Caption := '';
  Label2.Caption := '';
  Label3.Caption := '';
  Label4.Caption := '';

  // Create the open dialog object - used by the GetTextFile routine
  openDialog := TOpenDialog.Create(self);

  // Ask for only files that exist
  openDialog.Options := [ofFileMustExist];

  // Ask only for text files
  openDialog.Filter := 'Text files|*.txt';

  // Create the string list object that holds the file contents
  fileData := TStringList.Create;
end;

procedure TForm1.btnLoadFileClick(Sender: TObject);
begin
  // Display the file selection dialog
  if openDialog.Execute then        // Did the user select a file?
  begin
      // Save the file name
      fileName := openDialog.FileName;

      // Now that we have a file loaded, enable the text correction button
      btnCorrect.Enabled := true;

      // Load the file into our string list
      fileData.LoadFromFile(fileName);
    end;

  // And display the file in the file display box.
  MemoBox.Text:=fileData.Text;

  // Clear the changed lines information.
  Label1.Caption:='';
  Label2.Caption:='';
  Label3.Caption:='';

  // Display the number of lines in the file.
  Label4.Caption:='The file has '+IntToStr(fileData.Count)+' lines of text.';
  end;

// Procedure called when the file save button is pressed
procedure TForm1.btnSaveFileClick(Sender: TObject);
begin
  // Simply save the contents of the file string list
  if fileName <> '' then
    fileData.SaveToFile(fileName);

  // And disable the file save button
  btnSaveFile.Enabled := false;
end;

function TForm1.ChangeText(var AText: String; theType: TheMisSpelled): Boolean;
var
  m_changed : Boolean;
begin
  // Indicate no changes yet
  m_changed := false;

  // First see if the string contains the desired string
  case theType of
    TEH :
      if AnsiContainsStr(AText, 'teh') or AnsiContainsStr(AText, 'Teh') then
      begin
        AText := AnsiReplaceStr(AText, 'teh', 'the');    // Starts lower case
        AText := AnsiReplaceStr(AText, 'Teh', 'The');    // Starts upper case
        m_changed := true;
      end;
    ETH :
      if AnsiContainsStr(AText, 'eth') then
      begin
        AText := AnsiReplaceStr(AText, 'eth', 'the');    // Lower case only
        m_changed := true;
      end;
    EHT :
      if AnsiContainsStr(AText, 'eht') then
      begin
        AText := AnsiReplaceStr(AText, 'eht', 'the');    // Lower case only
        m_changed := true;
      end;
  end;

  // Return the changed status
  Result := m_changed;
end;

procedure TForm1.btnCorrectClick(Sender: TObject);
  var
    strText : String;
    line : Integer;
    changeCounts : array[TEH..EHT] of Integer;

  begin
    // Set the changed line counts
    changeCounts[TEH] := 0;
    changeCounts[ETH] := 0;
    changeCounts[EHT] := 0;

    // Process each line of the file one at a time
    for line := 0 to fileData.Count-1 do
    begin
      // Store the current line in a single variable
      strText := fileData[line];

      // Change the 3 chosen basic ways of mis-spelling 'the'
      if ChangeText(strText, TEH) then Inc(changeCounts[TEH]);
      if ChangeText(strText, ETH) then Inc(changeCounts[ETH]);
      if ChangeText(strText, EHT) then Inc(changeCounts[EHT]);

      // And store this padded string back into the string list
      fileData[line] := strText;
    end;

    // And redisplay the file
    MemoBox.Text := fileData.Text;

    // Display the changed line totals
    if changeCounts[TEH] = 1
    then Label1.Caption := 'Teh/teh changed on 1 line'
    else Label1.Caption := 'Teh/teh changed on '+
                           IntToStr(changeCounts[TEH])+' lines';

    if changeCounts[ETH] = 1
    then Label2.Caption := 'eth changed on 1 line'
    else Label2.Caption := 'eth changed on '+
                           IntToStr(changeCounts[ETH])+' lines';

    if changeCounts[EHT] = 1
    then Label3.Caption := 'eht changed on 1 line'
    else Label3.Caption := 'eht changed on '+
                           IntToStr(changeCounts[EHT])+' lines';

    // Finally, indicate that the file is now eligible for saving
    btnSaveFile.Enabled := true;

    // And that no more corrections are necessary
    btnCorrect.Enabled := false;
end;

end.
