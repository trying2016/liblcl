  Interfaces, // this includes the LCL widgetset,
{$IFDEF WINDOWS}
  Windows,
  MultiMon,
  ShellAPI,
  ShlObj,
  ComObj,
  ActiveX,
  Win32Int,
  win32proc,
  CommCtrl,
  LazUTF8,
  InterfaceBase,
{$ELSE}
  Types,
{$ENDIF}
  LResources,
  LCLType,
  typinfo,
  LCLProc,
  LCLIntf,
  LCLStrConsts,
  LMessages,
  DateUtils,
  IniFiles,
  Registry,
  Forms,
  StdCtrls,
  Dialogs,
  ExtCtrls,
  Graphics,
  Controls,
  Buttons,
  ComCtrls,
  ToolWin,
  ImgList,
  ExtDlgs,
  ActnList,
  ColorBox,
  PrintersDlgs,
  DateTimePicker,
  Calendar,
  Menus,
  Clipbrd,
  CheckLst,
  MaskEdit,
  Grids,
  ValEdit,
  Spin,
  Printers,
  ComboEx,
{$I UserDefineComponentUses.inc}
  uLinkLabel,
  uEventCallback,
  ImageButton,
  uMiniWebview,
  xButton,
  uGoForm,
  uRichEdit,
  uGauge
