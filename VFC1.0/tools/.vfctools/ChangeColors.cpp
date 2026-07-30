/* includes */ // FILE: "winproc_externs.h";
  #include "winproc_externs.h"  
   //  ---------------------------------------------------------------------- ;
/*------------*/ 
LRESULT CALLBACK _Colors(HWND hDlg,UINT uMessage,WPARAM wParam,LPARAM lParam){  
  static CHOOSECOLOR cc;  
  static COLORREF _TRACE_PEN_COLOR ;  
  static COLORREF _TRACE_BRUSH_COLOR ;  
  static COLORREF _UNDEF_PEN_COLOR ;  
  static COLORREF _BREAK_PEN_COLOR ;  
  static COLORREF _BREAK_BRUSH_COLOR ;  
  static COLORREF _CURRENT_BRUSH_COLOR ;  
  static COLORREF _CURRENT_TEXT_COLOR ;  
  static COLORREF _ERROR_PEN_COLOR ;  
  static COLORREF _INTERP_PEN_COLOR ;  
  static COLORREF _TEXT_COLOR ;  
  static COLORREF _PEN_COLOR ;  
  static COLORREF _BACKGROUND_COLOR ;  
  static COLORREF _COMMENTS_COLOR ;  
  static COLORREF _DIAGRAM_THICKNESS ;  
  switch (uMessage){  
  case WM_INITDIALOG:  
    memset(&cc, 0, sizeof(CHOOSECOLOR));  
    cc.lStructSize = sizeof(CHOOSECOLOR);  
    cc.hwndOwner = hDlg;  
    cc.hInstance = NULL;  
    cc.lpCustColors = colors;  
    cc.Flags = CC_RGBINIT;  
    cc.lCustData = 0L;  
    cc.lpfnHook = NULL;  
    cc.lpTemplateName = (LPSTR)NULL;  
    _TRACE_PEN_COLOR = TRACE_PEN_COLOR;  
    _TRACE_BRUSH_COLOR = TRACE_BRUSH_COLOR;  
    _UNDEF_PEN_COLOR = UNDEF_PEN_COLOR;  
    _BREAK_PEN_COLOR = BREAK_PEN_COLOR;  
    _BREAK_BRUSH_COLOR = BREAK_BRUSH_COLOR;  
    _CURRENT_BRUSH_COLOR = CURRENT_BRUSH_COLOR;  
    _CURRENT_TEXT_COLOR = CURRENT_TEXT_COLOR;  
    _ERROR_PEN_COLOR = ERROR_PEN_COLOR;  
    _INTERP_PEN_COLOR = INTERP_PEN_COLOR;  
    _TEXT_COLOR = TEXT_COLOR;  
    _PEN_COLOR = PEN_COLOR;  
    _BACKGROUND_COLOR = BACKGROUND_COLOR;  
    _COMMENTS_COLOR = COMMENTS_COLOR;  
    _DIAGRAM_THICKNESS = DIAGRAM_THICKNESS;  
     //     EnableMenuItem(GetMenu(MainWindow),ID_OPTIONS_COLORS,FALSE ); ;
    break;  
  case WM_COMMAND:  
    switch (GET_WM_COMMAND_ID(wParam,lParam)){  
    case IDC_MONOCHROME:  
      PrintObject.print_colors();  
      DIAGRAM_THICKNESS = 1;  
      break;  
    case ID_DEFAULTS:  
      TRACE_PEN_COLOR = DEF_TRACE_PEN_COLOR; // TRACE_PEN_COLOR = DEF_TRACE_COLOR;;
      TRACE_BRUSH_COLOR = DEF_TRACE_BRUSH_COLOR;  
      UNDEF_PEN_COLOR = DEF_UNDEF_PEN_COLOR;  
      BREAK_PEN_COLOR = DEF_BREAK_PEN_COLOR;  
      BREAK_BRUSH_COLOR = DEF_BREAK_BRUSH_COLOR;  
      CURRENT_BRUSH_COLOR = DEF_CURRENT_BRUSH_COLOR;  
      CURRENT_TEXT_COLOR = DEF_CURRENT_TEXT_COLOR;  
      ERROR_PEN_COLOR = DEF_ERROR_PEN_COLOR;  
      INTERP_PEN_COLOR = DEF_INTERP_PEN_COLOR;  
      TEXT_COLOR = DEF_TEXT_COLOR;  
      PEN_COLOR = DEF_PEN_COLOR;  
      BACKGROUND_COLOR = DEF_BACKGROUND_COLOR;  
      COMMENTS_COLOR = DEF_COMMENTS_COLOR;  
      DIAGRAM_THICKNESS = 1;  
      WinprocObject.ChangeColors();  
      break;  
    case IDC_COMMENTS:  
      cc.rgbResult = COMMENTS_COLOR;  
      ChooseColor(&cc);  
      COMMENTS_COLOR=cc.rgbResult;  
      WinprocObject.ChangeColors();  
      break;  
    case IDC_BACKGROUND:  
      cc.rgbResult = BACKGROUND_COLOR;  
      ChooseColor(&cc);  
      BACKGROUND_COLOR=cc.rgbResult;  
      WinprocObject.ChangeColors();  
      break;  
    case IDC_TRACE:  
      cc.rgbResult = TRACE_BRUSH_COLOR;  
      ChooseColor(&cc);  
      TRACE_BRUSH_COLOR=cc.rgbResult;  
      TRACE_PEN_COLOR=cc.rgbResult;  
      WinprocObject.ChangeColors();  
      break;  
    case IDC_BREAK:  
      cc.rgbResult = BREAK_BRUSH_COLOR;  
      ChooseColor(&cc);  
      BREAK_BRUSH_COLOR=cc.rgbResult;  
      BREAK_PEN_COLOR=~BREAK_BRUSH_COLOR;  
      WinprocObject.ChangeColors();  
      break;  
    case IDC_UNDEFPEN:  
      cc.rgbResult = UNDEF_PEN_COLOR;  
      ChooseColor(&cc);  
      UNDEF_PEN_COLOR=cc.rgbResult;  
      WinprocObject.ChangeColors();  
      break;  
    case IDC_CURRENT:  
      cc.rgbResult = CURRENT_BRUSH_COLOR;  
      ChooseColor(&cc);  
      CURRENT_BRUSH_COLOR=cc.rgbResult;  
      WinprocObject.ChangeColors();  
      break;  
    case IDC_CURRENTTEXT:  
      cc.rgbResult = CURRENT_TEXT_COLOR;  
      ChooseColor(&cc);  
      CURRENT_TEXT_COLOR=cc.rgbResult;  
      WinprocObject.ChangeColors();  
      break;  
    case IDC_ERROR:  
      cc.rgbResult = ERROR_PEN_COLOR;  
      ChooseColor(&cc);  
      ERROR_PEN_COLOR=cc.rgbResult;  
      WinprocObject.ChangeColors();  
      break;  
    case IDC_INTERPRET:  
      cc.rgbResult = INTERP_PEN_COLOR;  
      ChooseColor(&cc);  
      INTERP_PEN_COLOR=cc.rgbResult;  
      WinprocObject.ChangeColors();  
      break;  
    case IDC_TEXT:  
      cc.rgbResult = TEXT_COLOR;  
      ChooseColor(&cc);  
      TEXT_COLOR=cc.rgbResult;  
      WinprocObject.ChangeColors();  
      break;  
    case IDC_PEN:  
      cc.rgbResult = PEN_COLOR;  
      ChooseColor(&cc);  
      PEN_COLOR=cc.rgbResult;  
      WinprocObject.ChangeColors();  
      break;  
    case IDCANCEL:  
      TRACE_PEN_COLOR = _TRACE_PEN_COLOR;  
      TRACE_BRUSH_COLOR = _TRACE_BRUSH_COLOR;  
      UNDEF_PEN_COLOR = _UNDEF_PEN_COLOR;  
      BREAK_PEN_COLOR = _BREAK_PEN_COLOR;  
      BREAK_BRUSH_COLOR = _BREAK_BRUSH_COLOR;  
      CURRENT_BRUSH_COLOR = _CURRENT_BRUSH_COLOR;  
      CURRENT_TEXT_COLOR = _CURRENT_TEXT_COLOR;  
      ERROR_PEN_COLOR = _ERROR_PEN_COLOR;  
      INTERP_PEN_COLOR = _INTERP_PEN_COLOR;  
      TEXT_COLOR = _TEXT_COLOR;  
      PEN_COLOR = _PEN_COLOR;  
      BACKGROUND_COLOR = _BACKGROUND_COLOR;  
      COMMENTS_COLOR = _COMMENTS_COLOR;  
      DIAGRAM_THICKNESS = _DIAGRAM_THICKNESS;  
      WinprocObject.ChangeColors();  
    case IDOK:  
      {  
       //   EnableMenuItem(GetMenu(MainWindow),ID_OPTIONS_COLORS,TRUE ); ;
      EndDialog(hDlg,TRUE);  
      return(TRUE);  
      }   
      break;  
    }   
  }   
return FALSE;  
}   
//  FlowCode File: ChangeColors.ins;
//  Export  File: ChangeColors.cpp;
//  Export  Date: 04:51:04 PM - 27:Feb:2002;

