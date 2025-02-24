unit uFrmPic;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, Winapi.ShellAPI;

type
  TFrmPic = class(TForm)
    Lbl2: TLabel;
    Lbl3: TLabel;
    Lbl4: TLabel;
    SpinWidth: TSpinEdit;
    SpinHeight: TSpinEdit;
    Pnl1: TPanel;
    ChkTop: TCheckBox;
    PnlProc: TPanel;
    Pb1: TProgressBar;
    Lbl1: TLabel;
    LblFile: TLabel;
    LblCount: TLabel;
    Lbl5: TLabel;
    ComQuality: TComboBox;
    Lbl6: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ChkTopClick(Sender: TObject);
    procedure SpinWidthChange(Sender: TObject);
    procedure SpinHeightChange(Sender: TObject);
    procedure ComQualitySelect(Sender: TObject);
  private
    { Private declarations }
    procedure WMDROPFILES(var Message: TWMDROPFILES); message WM_DROPFILES;


    function GetPicFile(sFile: TStringList; vList: TStringList): Boolean;
    function ChangePixel(sFile, sPath: string; w, h: Cardinal; quality: Integer): Boolean;

    function GetWH(): TPoint;
    function GetQuality(): Byte;

    procedure LoadConfig();
    procedure SaveConfig();
  public
    { Public declarations }
  end;

var
  FrmPic: TFrmPic;

implementation

{$R *.dfm}

uses
  Vcl.Imaging.jpeg, Vcl.FileCtrl, System.IniFiles,
  Winapi.GDIPAPI, Winapi.GDIPOBJ, Winapi.GDIPUTIL;

{ TFrmPic }

function TFrmPic.ChangePixel(sFile, sPath: string; w, h: Cardinal; quality: Integer): Boolean;
var
  wh: Double;
  ImgOld, ImgNew: TGPImage;
  Graphics: TGPGraphics;
  vBrush: TGPSolidBrush;
  ImgGUID: TGUID;
  encoderParam: TEncoderParameters;
  sTmp: string;
  len: Integer;
begin
  //    1200    x      625
  //    ---- = ---- = -----
  //    1920   1600    1000
  //
  //    x * 1920 = 1200 * 1600
  //    x = 1200 * 1600 / 1920

  { ��ԭͼƬ }
  ImgOld := TGPImage.Create(sFile);

  if ((ImgOld.GetWidth <= w) and (ImgOld.GetHeight <= h)) or
     ((ImgOld.GetWidth <= h) and (ImgOld.GetHeight <= w)) then
  begin
    // ͼƬ����С������ֵ
    w := ImgOld.GetWidth;
    h := ImgOld.GetHeight
  end else
  begin
    wh := ImgOld.GetHeight / ImgOld.GetWidth;
    if wh > 1 then
    begin
      // �ߴ��ڿ�
      h := w;
      w := Round(h / wh);
    end else
    begin
      // ǿ�ƿ�ȱ�
      h := Round(w * wh);
    end;
  end;
  { ��һ����ͼƬ, ��������Сһ�� }
  ImgNew := TGPBitmap.Create(w, h, PixelFormat32bppARGB);

  { ��ȡ��ͼƬ�Ļ�ͼ���� }
  Graphics := TGPGraphics.Create(ImgNew);
  vBrush := TGPSolidBrush.Create(aclWhite);
  Graphics.FillRectangle(vBrush, 0, 0, w, h);
  vBrush.Free;
  { ������������Ϊ������� }
//  InterpolationModeBicubic	Bicubic	ָ��˫���β�ֵ����������Ԥɸѡ����ͼ������Ϊԭʼ��С�� 25% ����ʱ����ģʽ�����á�
//  InterpolationModeBilinear	Bilinear	ָ��˫���Բ�ֵ����������Ԥɸѡ����ͼ������Ϊԭʼ��С�� 50% ����ʱ����ģʽ�����á�
//  InterpolationModeDefault	Default	ָ��Ĭ��ģʽ��
//  InterpolationModeHigh	High	ָ����������ֵ����
//  InterpolationModeHighQualityBicubic	HighQualityBicubic	ָ����������˫���β�ֵ����ִ��Ԥɸѡ��ȷ������������������ģʽ�ɲ���������ߵ�ת��ͼ��
//  InterpolationModeHighQualityBilinear 	HighQualityBilinear 	ָ����������˫���Բ�ֵ����ִ��Ԥɸѡ��ȷ����������������
//  InterpolationModeInvalid	Invalid	��Ч�� QualityMode ö�ٵ� Invalid Ԫ�ء�
//  InterpolationModeLow	Low	ָ����������ֵ����
//  InterpolationModeNearestNeighbor	NearestNeighbor	ָ�����ٽ���ֵ����
  Graphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);

  { ��ͼ�������� }
//  SmoothingModeInvalid     = -1; {ָ��һ����Чģʽ}
//  SmoothingModeDefault     = 0;  {ָ�����������}
//  SmoothingModeHighSpeed   = 1;  {ָ�����ٶȡ�����������}
//  SmoothingModeHighQuality = 2;  {ָ�������������ٶȳ���}
//  SmoothingModeNone        = 3;  {ָ�����������}
//  SmoothingModeAntiAlias   = 4;  {ָ��������ݵĳ���}
  Graphics.SetSmoothingMode(SmoothingModeHighQuality);

  { ������ }
  Graphics.DrawImage(ImgOld, MakeRect(0, 0, w, h), 0, 0, ImgOld.GetWidth, ImgOld.GetHeight, UnitPixel);

  { ���� }
  // 'image/png', 'image/jpeg', 'image/gif', 'image/bmp', 'image/tiff'
  GetEncoderClsid('image/jpeg', ImgGUID);
  len := Length(ExtractFileExt(sFile));
  sTmp := ExtractFileName(sFile);
  sTmp := Copy(sTmp, 1, Length(sTmp) - len);

  encoderParam.Count := 1;
  encoderParam.Parameter[0].Guid := EncoderQuality;
  encoderParam.Parameter[0].Type_ := EncoderParameterValueTypeLong;
  encoderParam.Parameter[0].NumberOfValues := 1;
  // ѹ�������������ɸ�����Ҫ����
  encoderParam.Parameter[0].Value := @quality;

  ImgNew.Save(sPath + '\_' + sTmp + '.jpg', ImgGUID, @encoderParam);

  Graphics.Free;
  ImgNew.Free;
  ImgOld.Free;

  Result := True;
end;

procedure TFrmPic.ChkTopClick(Sender: TObject);
begin
  with Sender as TCheckBox do
  begin
    if Checked then
      Self.FormStyle := fsStayOnTop
    else
      Self.FormStyle := fsNormal;
  end;
end;

procedure TFrmPic.ComQualitySelect(Sender: TObject);
begin
  SaveConfig;
end;

procedure TFrmPic.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, True); // �ô��ڽ����Ϸ�
  LoadConfig();
end;

function TFrmPic.GetPicFile(sFile, vList: TStringList): Boolean;
var
  i: Integer;
  sTmp, ext: string;
begin
  for i := 0 to sFile.Count - 1 do
  begin
    sTmp := sFile[i];
    // �ж����ļ�����·��
    if System.SysUtils.DirectoryExists(sTmp) then
    begin
      // ����Ŀ¼�µ������ļ�

    end else
    begin
      ext := ExtractFileExt(sTmp);
      if SameText(ext, '.jpg') or SameText(ext, '.jpeg') or
         SameText(ext, '.bmp') or SameText(ext, '.png')
       then
        vList.Add(sTmp);
    end;
  end;
  Result := vList.Count > 0;
end;

function TFrmPic.GetQuality: Byte;
begin
  case ComQuality.ItemIndex of
    0: Result := 50;
    1: Result := 70;
    2: Result := 90;
    3: Result := 100;
  else
    Result := 80;
  end;
end;

function TFrmPic.GetWH: TPoint;
begin
  Result.X := SpinWidth.Value;
  Result.Y := SpinHeight.Value;
end;

procedure TFrmPic.LoadConfig;
var
  sFile: string;
  Old: TNotifyEvent;
begin
  sFile := ExtractFilePath(ParamStr(0)) + 'config.ini';
  with TIniFile.Create(sFile) do
  begin
    try
      Old := SpinWidth.OnChange;
      SpinWidth.OnChange := nil;
      SpinWidth.Value := ReadInteger('param', 'width', 1600);
      SpinWidth.OnChange := Old;

      Old := SpinHeight.OnChange;
      SpinHeight.OnChange := nil;
      SpinHeight.Value := ReadInteger('param', 'height', 1200);
      SpinHeight.OnChange := Old;

      ComQuality.ItemIndex := ReadInteger('param', 'quality', 2);
    finally
      Free;
    end;
  end;
end;

procedure TFrmPic.SaveConfig;
var
  sFile: string;
begin
  sFile := ExtractFilePath(ParamStr(0)) + 'config.ini';
  with TIniFile.Create(sFile) do
  begin
    try
      WriteInteger('param', 'width', SpinWidth.Value);
      WriteInteger('param', 'height', SpinHeight.Value);
      WriteInteger('param', 'quality', ComQuality.ItemIndex);

      WriteBool('param', 'topmost', ChkTop.Checked);
    finally
      Free;
    end;
  end;
end;

procedure TFrmPic.SpinHeightChange(Sender: TObject);
begin
  SaveConfig;
end;

procedure TFrmPic.SpinWidthChange(Sender: TObject);
begin
  SaveConfig;
end;

procedure TFrmPic.WMDROPFILES(var Message: TWMDROPFILES);
var
  num: Cardinal;
  i, quality: Integer;
  buff: array[0..255] of char;
  list, fileList: TStringList;
  sPath, sTmp: string;
  pt: TPoint;
begin
  {How many files are being dropped}
  num := DragQueryFile(Message.Drop, $FFFFFFFF, nil, 0); //����Ϸŵ��ļ�����
  {Accept the dropped files}
  list := TStringList.Create;
  try
    for i := 0 to num - 1 do //���
    begin
      FillChar(buff, SizeOf(buff), #0);
      DragQueryFile(Message.Drop, i, @buff, sizeof(buff));
      list.Add(PChar(@buff[0]));
    end;

    fileList := TStringList.Create;
    try
      if GetPicFile(list, fileList) then
      begin
        if SelectDirectory('���浽ָ��Ŀ¼(��F2�����������ļ���)', '', sPath, [sdNewUI, sdShowEdit, sdNewFolder], Self) then
        begin
          Pb1.Max := fileList.Count;
          Pb1.Min := 0;
          Pb1.Position := 0;
          Pb1.Step := 1;
          PnlProc.Align := alClient;
          PnlProc.Show;
          PnlProc.BringToFront;
          pt := GetWH;
          quality := GetQuality;
          for i := 0 to fileList.Count - 1 do
          begin
            sTmp := fileList[i];
            LblFile.Caption := sTmp;
            LblCount.Caption := Format('%d/%d', [i + 1, fileList.Count]);
            Pb1.Position := i + 1;
            ChangePixel(sTmp, sPath, pt.X, pt.Y, quality);
            Application.ProcessMessages;
          end;
          for i := 1 to 4 do
          begin
            Sleep(100);
            Application.ProcessMessages;
          end;
          PnlProc.Hide;

          if ID_YES = MessageBox(Self.Handle, PChar('ת�����' + #13#10#13#10 + sPath + #13#10#13#10 + '�Ƿ���ļ��У�'), 'ȷ��',
                        MB_YESNO or MB_ICONINFORMATION or MB_TOPMOST) then
          begin
            ShellExecute(0, 'open', '', '', PChar(sPath), SW_NORMAL);
          end;
        end;
      end else
      begin
        MessageBox(Self.Handle, PChar(list.Text + #13#10 + '������Ч��ͼƬ(ֻ֧��jpg png bmp��ʽ��ͼƬ)'),
          '��ʾ', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
      end;
    finally
      fileList.Free;
    end;

  finally
    list.Free;
  end;
  DragFinish(Message.Drop);
end;

end.
