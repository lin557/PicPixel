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

  { 打开原图片 }
  ImgOld := TGPImage.Create(sFile);

  if ((ImgOld.GetWidth <= w) and (ImgOld.GetHeight <= h)) or
     ((ImgOld.GetWidth <= h) and (ImgOld.GetHeight <= w)) then
  begin
    // 图片像素小于设置值
    w := ImgOld.GetWidth;
    h := ImgOld.GetHeight
  end else
  begin
    wh := ImgOld.GetHeight / ImgOld.GetWidth;
    if wh > 1 then
    begin
      // 高大于宽
      h := w;
      w := Round(h / wh);
    end else
    begin
      // 强制宽度比
      h := Round(w * wh);
    end;
  end;
  { 建一个新图片, 假如是缩小一倍 }
  ImgNew := TGPBitmap.Create(w, h, PixelFormat32bppARGB);

  { 获取新图片的绘图表面 }
  Graphics := TGPGraphics.Create(ImgNew);
  vBrush := TGPSolidBrush.Create(aclWhite);
  Graphics.FillRectangle(vBrush, 0, 0, w, h);
  vBrush.Free;
  { 设置缩放质量为最高质量 }
//  InterpolationModeBicubic	Bicubic	指定双三次插值法。不进行预筛选。将图像收缩为原始大小的 25% 以下时，此模式不适用。
//  InterpolationModeBilinear	Bilinear	指定双线性插值法。不进行预筛选。将图像收缩为原始大小的 50% 以下时，此模式不适用。
//  InterpolationModeDefault	Default	指定默认模式。
//  InterpolationModeHigh	High	指定高质量插值法。
//  InterpolationModeHighQualityBicubic	HighQualityBicubic	指定高质量的双三次插值法。执行预筛选以确保高质量的收缩。此模式可产生质量最高的转换图像。
//  InterpolationModeHighQualityBilinear 	HighQualityBilinear 	指定高质量的双线性插值法。执行预筛选以确保高质量的收缩。
//  InterpolationModeInvalid	Invalid	等效于 QualityMode 枚举的 Invalid 元素。
//  InterpolationModeLow	Low	指定低质量插值法。
//  InterpolationModeNearestNeighbor	NearestNeighbor	指定最临近插值法。
  Graphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);

  { 绘图质量参数 }
//  SmoothingModeInvalid     = -1; {指定一个无效模式}
//  SmoothingModeDefault     = 0;  {指定不消除锯齿}
//  SmoothingModeHighSpeed   = 1;  {指定高速度、低质量呈现}
//  SmoothingModeHighQuality = 2;  {指定高质量、低速度呈现}
//  SmoothingModeNone        = 3;  {指定不消除锯齿}
//  SmoothingModeAntiAlias   = 4;  {指定消除锯齿的呈现}
  Graphics.SetSmoothingMode(SmoothingModeHighQuality);

  { 画过来 }
  Graphics.DrawImage(ImgOld, MakeRect(0, 0, w, h), 0, 0, ImgOld.GetWidth, ImgOld.GetHeight, UnitPixel);

  { 保存 }
  // 'image/png', 'image/jpeg', 'image/gif', 'image/bmp', 'image/tiff'
  GetEncoderClsid('image/jpeg', ImgGUID);
  len := Length(ExtractFileExt(sFile));
  sTmp := ExtractFileName(sFile);
  sTmp := Copy(sTmp, 1, Length(sTmp) - len);

  encoderParam.Count := 1;
  encoderParam.Parameter[0].Guid := EncoderQuality;
  encoderParam.Parameter[0].Type_ := EncoderParameterValueTypeLong;
  encoderParam.Parameter[0].NumberOfValues := 1;
  // 压缩质量参数，可根据需要设置
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
  DragAcceptFiles(Handle, True); // 让窗口接受拖放
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
    // 判断是文件还是路径
    if System.SysUtils.DirectoryExists(sTmp) then
    begin
      // 查找目录下的所有文件

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
  num := DragQueryFile(Message.Drop, $FFFFFFFF, nil, 0); //获得拖放的文件数量
  {Accept the dropped files}
  list := TStringList.Create;
  try
    for i := 0 to num - 1 do //输出
    begin
      FillChar(buff, SizeOf(buff), #0);
      DragQueryFile(Message.Drop, i, @buff, sizeof(buff));
      list.Add(PChar(@buff[0]));
    end;

    fileList := TStringList.Create;
    try
      if GetPicFile(list, fileList) then
      begin
        if SelectDirectory('保存到指定目录(按F2可以重命名文件夹)', '', sPath, [sdNewUI, sdShowEdit, sdNewFolder], Self) then
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

          if ID_YES = MessageBox(Self.Handle, PChar('转换完成' + #13#10#13#10 + sPath + #13#10#13#10 + '是否打开文件夹？'), '确认',
                        MB_YESNO or MB_ICONINFORMATION or MB_TOPMOST) then
          begin
            ShellExecute(0, 'open', '', '', PChar(sPath), SW_NORMAL);
          end;
        end;
      end else
      begin
        MessageBox(Self.Handle, PChar(list.Text + #13#10 + '不是有效的图片(只支持jpg png bmp格式的图片)'),
          '提示', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
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
