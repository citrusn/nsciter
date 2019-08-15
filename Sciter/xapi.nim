## #
## #  The Sciter Engine of Terra Informatica Software, Inc.
## #  http://sciter.com
## # 
## #  The code and information provided "as-is" without
## #  warranty of any kind, either expressed or implied.
## # 
## #  (C) 2003-2015, Terra Informatica Software, Inc.
## #
#define SCAPI __stdcall
#define SCFN(name) (__stdcall *name)


include xtypes, xdom, xgraphics, xvalue, xtiscript, xbehavior, xrequest, xdef, converters
type
  ISciterAPI* = object
    version*: uint32 ## # is zero for now
    SciterClassName*: proc (): WideCString {.stdcall.}
    SciterVersion*: proc (major: bool): uint32 {.stdcall.}
    SciterDataReady*: proc (hwnd: HWINDOW; uri: WideCString; data: pointer;
                          dataLength: uint32): bool {.stdcall.}
    SciterDataReadyAsync*: proc (hwnd: HWINDOW; uri: WideCString; 
                                data: pointer; dataLength: uint32;
                                requestId: pointer): bool {.stdcall.}
    when defined(windows):
      SciterProc*: proc (hwnd: HWINDOW; msg: uint32; wParam: WPARAM;
                        lParam: LPARAM): LRESULT {.stdcall.}
      SciterProcND*: proc (hwnd: HWINDOW; msg: uint32; wParam: WPARAM;
                          lParam: LPARAM; pbHandled: ptr bool): LRESULT {.stdcall.}
    SciterLoadFile*: proc (hWndSciter: HWINDOW; 
                          filename: WideCString): bool {.stdcall.}
    SciterLoadHtml*: proc (hWndSciter: HWINDOW; html: pointer; htmlSize: uint32;
                         baseUrl: WideCString): bool {.stdcall.}
    SciterSetCallback*: proc (hWndSciter: HWINDOW; cb: SciterHostCallback;
                            cbParam: pointer) {.stdcall.}
    SciterSetMasterCSS*: proc (utf8: pointer; 
                              numBytes: uint32): bool {.stdcall.}
    SciterAppendMasterCSS*: proc (utf8: pointer; 
                                  numBytes: uint32): bool {.stdcall.}
    SciterSetCSS*: proc (hWndSciter: HWINDOW; utf8: pointer; numBytes: uint32;
                        baseUrl: WideCString; 
                        mediaType: WideCString): bool {.stdcall.}
    SciterSetMediaType*: proc (hWndSciter: HWINDOW;
                              mediaType: WideCString): bool {.stdcall.}
    SciterSetMediaVars*: proc (hWndSciter: HWINDOW;
                              mediaVars: ptr Value): bool {.stdcall.}
    SciterGetMinWidth*: proc (hWndSciter: HWINDOW): uint32 {.stdcall.}
    SciterGetMinHeight*: proc (hWndSciter: HWINDOW; 
                              width: uint32): uint32 {.stdcall.}
    SciterCall*: proc (hWnd: HWINDOW; functionName: cstring; argc: uint32;
                     argv: ptr Value; retval: ptr Value): bool {.stdcall.}
    SciterEval*: proc (hwnd: HWINDOW; script: WideCString; scriptLength: uint32;
                     pretval: ptr Value): bool {.stdcall.}
    SciterUpdateWindow*: proc (hwnd: HWINDOW) {.stdcall.}
    when defined(windows):
      SciterTranslateMessage*: proc (lpMsg: ptr MSG): bool {.stdcall.}
    SciterSetOption*: proc (hWnd: HWINDOW; option: uint32;
                            value: uint32): bool {.stdcall.}
    SciterGetPPI*: proc (hWndSciter: HWINDOW; px: ptr uint32; 
                        py: ptr uint32) {.stdcall.}
    SciterGetViewExpando*: proc (hwnd: HWINDOW; 
                                pval: ptr VALUE): bool {.stdcall.}
    when defined(windows):
      SciterRenderD2D*: proc (hWndSciter: HWINDOW; 
                              tgt: pointer): bool {.stdcall.}
      SciterD2DFactory*: proc (ppf: pointer): bool {.stdcall.}
      SciterDWFactory*: proc (ppf: pointer): bool {.stdcall.}
    SciterGraphicsCaps*: proc (pcaps: ptr uint32): bool {.stdcall.}
    SciterSetHomeURL*: proc (hWndSciter: HWINDOW; 
                            baseUrl: WideCString): bool {.stdcall.}
    when defined(osx):
      SciterCreateNSView*: proc (frame: LPRECT): HWINDOW {.stdcall.}
    elif defined(posix):
      SciterCreateWidget*: proc (frame: ptr Rect): HWINDOW {.stdcall.}
    else:
      SciterCreateWindow*: proc (creationFlags: uint32; frame: ptr Rect;
                                delegate: SciterWindowDelegate;
                                delegateParam: pointer; 
                                parent: HWINDOW): HWINDOW {.stdcall.}
    SciterSetupDebugOutput*: proc (hwndOrNull: HWINDOW; param: pointer;
                                  pfOutput: DEBUG_OUTPUT_PROC) {.stdcall.}
    ## #|
    ## #| DOM Element API
    ## #|
    ## # HWINDOW or null if this is global output handler
    ## # param to be passed "as is" to the pfOutput
    ## # output function, output stream alike thing.
    Sciter_UseElement*: proc (he: HELEMENT): int32 {.stdcall.}
    Sciter_UnuseElement*: proc (he: HELEMENT): int32 {.stdcall.}
    SciterGetRootElement*: proc (hwnd: HWINDOW; 
                                phe: ptr HELEMENT): int32 {.stdcall.}
    SciterGetFocusElement*: proc (hwnd: HWINDOW; 
                                phe: ptr HELEMENT): int32 {.stdcall.}
    SciterFindElement*: proc (hwnd: HWINDOW; pt: Point;
                              phe: ptr HELEMENT): int32 {.stdcall.}
    SciterGetChildrenCount*: proc (he: HELEMENT;
                                  count: ptr uint32): int32 {.stdcall.}
    SciterGetNthChild*: proc (he: HELEMENT; n: uint32;
                              phe: ptr HELEMENT): int32 {.stdcall.}
    SciterGetParentElement*: proc (he: HELEMENT;
                                  p_parent_he: ptr HELEMENT): int32 {.stdcall.}
    SciterGetElementHtmlCB*: proc (he: HELEMENT; outer: bool;
                                  rcv: LPCBYTE_RECEIVER;
                                  rcv_param: pointer): int32 {.stdcall.}
    SciterGetElementTextCB*: proc (he: HELEMENT; rcv: LPCWSTR_RECEIVER;
                                 rcv_param: pointer): int32 {.stdcall.}
    SciterSetElementText*: proc (he: HELEMENT; utf16: WideCString;
                                length: uint32): int32 {.stdcall.}
    SciterGetAttributeCount*: proc (he: HELEMENT; 
                                  p_count: ptr uint32): int32 {.stdcall.}
    SciterGetNthAttributeNameCB*: proc (he: HELEMENT; n: uint32;
                                        rcv: LPCSTR_RECEIVER;
                                        rcv_param: pointer): int32 {.stdcall.}
    SciterGetNthAttributeValueCB*: proc (he: HELEMENT; n: uint32;
                                       rcv: LPCWSTR_RECEIVER;
                                       rcv_param: pointer): int32 {.stdcall.}
    SciterGetAttributeByNameCB*: proc (he: HELEMENT; name: cstring;
                                      rcv: LPCWSTR_RECEIVER;
                                      rcv_param: pointer): int32 {.stdcall.}
    SciterSetAttributeByName*: proc (he: HELEMENT; name: cstring;
                                    value: WideCString): int32 {.stdcall.}
    SciterClearAttributes*: proc (he: HELEMENT): int32 {.stdcall.}
    SciterGetElementIndex*: proc (he: HELEMENT; 
                                  p_index: ptr uint32): int32 {.stdcall.}
    SciterGetElementType*: proc (he: HELEMENT; 
                                p_type: ptr cstring): int32 {.stdcall.}
    SciterGetElementTypeCB*: proc (he: HELEMENT; rcv: LPCSTR_RECEIVER;
                                 rcv_param: pointer): int32 {.stdcall.}
    SciterGetStyleAttributeCB*: proc (he: HELEMENT; name: cstring;
                                      rcv: LPCWSTR_RECEIVER;
                                      rcv_param: pointer): int32 {.stdcall.}
    SciterSetStyleAttribute*: proc (he: HELEMENT; name: cstring;
                                    value: WideCString): int32 {.stdcall.}
    SciterGetElementLocation*: proc (he: HELEMENT; p_location: ptr Rect;
                                    areas: uint32): int32 {.stdcall.}
    ## #ELEMENT_AREAS
    SciterScrollToView*: proc (he: HELEMENT;
        SciterScrollFlags: uint32): int32 {.stdcall.}
    SciterUpdateElement*: proc (he: HELEMENT; 
                                andForceRender: bool): int32 {.stdcall.}
    SciterRefreshElementArea*: proc (he: HELEMENT; rc: Rect): int32 {.stdcall.}
    SciterSetCapture*: proc (he: HELEMENT): int32 {.stdcall.}
    SciterReleaseCapture*: proc (he: HELEMENT): int32 {.stdcall.}
    SciterGetElementHwnd*: proc (he: HELEMENT; p_hwnd: ptr HWINDOW;
                                rootWindow: bool): int32 {.stdcall.}
    SciterCombineURL*: proc (he: HELEMENT; szUrlBuffer: WideCString;
                           UrlBufferSize: uint32): int32 {.stdcall.}
    SciterSelectElements*: proc (he: HELEMENT; CSS_selectors: cstring;
                                callback: SciterElementCallback;
                                param: pointer): int32 {.stdcall.}
    SciterSelectElementsW*: proc (he: HELEMENT; CSS_selectors: WideCString;
                                  callback: SciterElementCallback;
                                  param: pointer): int32 {.stdcall.}
    SciterSelectParent*: proc (he: HELEMENT; selector: cstring; depth: uint32;
                              heFound: ptr HELEMENT): int32 {.stdcall.}
    SciterSelectParentW*: proc (he: HELEMENT; selector: WideCString; depth: uint32;
                              heFound: ptr HELEMENT): int32 {.stdcall.}
    SciterSetElementHtml*: proc (he: HELEMENT; html: ptr byte; htmlLength: uint32;
                               where: uint32): int32 {.stdcall.}
    SciterGetElementUID*: proc (he: HELEMENT; puid: ptr uint32): int32 {.stdcall.}
    SciterGetElementByUID*: proc (hwnd: HWINDOW; uid: uint32;
                                  phe: ptr HELEMENT): int32 {.stdcall.}
    SciterShowPopup*: proc (hePopup: HELEMENT; heAnchor: HELEMENT;
                            placement: uint32): int32 {.stdcall.}
    SciterShowPopupAt*: proc (hePopup: HELEMENT; pos: Point;
                              animate: bool): int32 {.stdcall.}
    SciterHidePopup*: proc (he: HELEMENT): int32 {.stdcall.}
    SciterGetElementState*: proc (he: HELEMENT;
                                pstateBits: ptr uint32): int32 {.stdcall.}
    SciterSetElementState*: proc (he: HELEMENT; stateBitsToSet: uint32;
                                  stateBitsToClear: uint32;
                                  updateView: bool): int32 {.stdcall.}
    SciterCreateElement*: proc (tagname: cstring; textOrNull: WideCString;
                              phe: ptr HELEMENT): int32 {.stdcall.} ## #out
    SciterCloneElement*: proc (he: HELEMENT; 
                              phe: ptr HELEMENT): int32 {.stdcall.} ## #out
    SciterInsertElement*: proc (he: HELEMENT; hparent: HELEMENT;
                                index: uint32): int32 {.stdcall.}
    SciterDetachElement*: proc (he: HELEMENT): int32 {.stdcall.}
    SciterDeleteElement*: proc (he: HELEMENT): int32 {.stdcall.}
    SciterSetTimer*: proc (he: HELEMENT; milliseconds: uint32;
                          timer_id: uint32): int32 {.stdcall.}
    SciterDetachEventHandler*: proc (he: HELEMENT; pep: ElementEventProc;
                                    tag: pointer): int32 {.stdcall.}
    SciterAttachEventHandler*: proc (he: HELEMENT; pep: ElementEventProc;
                                    tag: pointer): int32 {.stdcall.}
    SciterWindowAttachEventHandler*: proc (hwndLayout: HWINDOW; 
                                          pep: ElementEventProc; tag: pointer;
                                           subscription: uint32): int32 {.stdcall.}
    SciterWindowDetachEventHandler*: proc (hwndLayout: HWINDOW; pep: ElementEventProc;
                                           tag: pointer): int32 {.stdcall.}
    SciterSendEvent*: proc (he: HELEMENT; appEventCode: uint32; 
                            heSource: HELEMENT; reason: uint32;
                            handled: ptr bool): int32 {.stdcall.} ## #out
    SciterPostEvent*: proc (he: HELEMENT; appEventCode: uint32; 
                            heSource: HELEMENT; reason: uint32): int32 {.stdcall.}
    SciterCallBehaviorMethod*: proc (he: HELEMENT;
                                    params: ptr METHOD_PARAMS): int32 {.stdcall.}
    SciterRequestElementData*: proc (he: HELEMENT; url: WideCString; 
                                    dataType: uint32;
                                    initiator: HELEMENT): int32 {.stdcall.}
    SciterHttpRequest*: proc (he: HELEMENT; url: WideCString; dataType: uint32;
                              requestType: uint32; 
                              requestParams: ptr REQUEST_PARAM;
                              nParams: uint32): int32 {.stdcall.}
    ## # element to deliver data
    ## # url
    ## # data type, see SciterResourceType.
    ## # one of REQUEST_TYPE values
    ## # parameters
    ## # number of parameters
    SciterGetScrollInfo*: proc (he: HELEMENT; scrollPos: ptr Point; 
                              viewRect: ptr Rect;
                              contentSize: ptr Size): int32 {.stdcall.}
    SciterSetScrollPos*: proc (he: HELEMENT; scrollPos: Point;
                              smooth: bool): int32 {.stdcall.}
    SciterGetElementIntrinsicWidths*: proc (he: HELEMENT; pMinWidth: ptr int32;
                                            pMaxWidth: ptr int32): int32 {.stdcall.}
    SciterGetElementIntrinsicHeight*: proc (he: HELEMENT; forWidth: int32;
                                            pHeight: ptr int32): int32 {.stdcall.}
    SciterIsElementVisible*: proc (he: HELEMENT; 
                                  pVisible: ptr bool): int32 {.stdcall.}
    SciterIsElementEnabled*: proc (he: HELEMENT; 
                                  pEnabled: ptr bool): int32 {.stdcall.}
    SciterSortElements*: proc (he: HELEMENT; firstIndex: uint32;
                               lastIndex: uint32;
                              cmpFunc: ptr ELEMENT_COMPARATOR;
                              cmpFuncParam: pointer): int32 {.stdcall.}
    SciterSwapElements*: proc (he1: HELEMENT; he2: HELEMENT): int32 {.stdcall.}
    SciterTraverseUIEvent*: proc (evt: uint32; eventCtlStruct: pointer;
                                  bOutProcessed: ptr bool): int32 {.stdcall.}
    SciterCallScriptingMethod*: proc (he: HELEMENT; name: cstring; argv: ptr VALUE;
                                    argc: uint32; retval: ptr VALUE): int32 {.stdcall.}
    SciterCallScriptingFunction*: proc (he: HELEMENT; name: cstring; argv: ptr VALUE;
                                      argc: uint32; retval: ptr VALUE): int32 {.stdcall.}
    SciterEvalElementScript*: proc (he: HELEMENT; script: WideCString;
                                    scriptLength: uint32;
                                    retval: ptr VALUE): int32 {.stdcall.}
    SciterAttachHwndToElement*: proc (he: HELEMENT; hwnd: HWINDOW): int32 {.stdcall.}
    SciterControlGetType*: proc (he: HELEMENT; pType: ptr uint32): int32 {.
        stdcall.} ## #CTL_TYPE
    SciterGetValue*: proc (he: HELEMENT; pval: ptr VALUE): int32 {.stdcall.}
    SciterSetValue*: proc (he: HELEMENT; pval: ptr VALUE): int32 {.stdcall.}
    SciterGetExpando*: proc (he: HELEMENT; pval: ptr VALUE;
                            forceCreation: bool): int32 {.stdcall.}
    SciterGetObject*: proc (he: HELEMENT; pval: ptr tiscript_value;
                            forceCreation: bool): int32 {.stdcall.}
    SciterGetElementNamespace*: proc (he: HELEMENT;
                                      pval: ptr tiscript_value): int32 {.stdcall.}
    SciterGetHighlightedElement*: proc (hwnd: HWINDOW;
                                        phe: ptr HELEMENT): int32 {.stdcall.}
    SciterSetHighlightedElement*: proc (hwnd: HWINDOW;
                                        he: HELEMENT): int32 {.stdcall.}
    ## #|
    ## #| DOM Node API
    ## #|
    SciterNodeAddRef*: proc (hn: HNODE): int32 {.stdcall.}
    SciterNodeRelease*: proc (hn: HNODE): int32 {.stdcall.}
    SciterNodeCastFromElement*: proc (he: HELEMENT;
                                    phn: ptr HNODE): int32 {.stdcall.}
    SciterNodeCastToElement*: proc (hn: HNODE;
                                   he: ptr HELEMENT): int32 {.stdcall.}
    SciterNodeFirstChild*: proc (hn: HNODE; phn: ptr HNODE): int32 {.stdcall.}
    SciterNodeLastChild*: proc (hn: HNODE; phn: ptr HNODE): int32 {.stdcall.}
    SciterNodeNextSibling*: proc (hn: HNODE; phn: ptr HNODE): int32 {.stdcall.}
    SciterNodePrevSibling*: proc (hn: HNODE; phn: ptr HNODE): int32 {.stdcall.}
    SciterNodeParent*: proc (hnode: HNODE; 
                            pheParent: ptr HELEMENT): int32 {.stdcall.}
    SciterNodeNthChild*: proc (hnode: HNODE; n: uint32;
                               phn: ptr HNODE): int32 {.stdcall.}
    SciterNodeChildrenCount*: proc (hnode: HNODE; 
                                    pn: ptr uint32): int32 {.stdcall.}
    SciterNodeType*: proc (hnode: HNODE; 
                          pNodeType: ptr uint32): int32 {.stdcall.} ## #NODE_TYPE
    SciterNodeGetText*: proc (hnode: HNODE; rcv: LPCWSTR_RECEIVER;
                            rcv_param: pointer): int32 {.stdcall.}
    SciterNodeSetText*: proc (hnode: HNODE; text: WideCString;
                              textLength: uint32): int32 {.stdcall.}
    SciterNodeInsert*: proc (hnode: HNODE; where: uint32; ## #NODE_INS_TARGET
                            what: HNODE): int32 {.stdcall.}
    SciterNodeRemove*: proc (hnode: HNODE; finalize: bool): int32 {.stdcall.}
    SciterCreateTextNode*: proc (text: WideCString; textLength: uint32;
                                phnode: ptr HNODE): int32 {.stdcall.}
    SciterCreateCommentNode*: proc (text: WideCString; textLength: uint32;
                                  phnode: ptr HNODE): int32 {.stdcall.}
    ## #|
    ## #| Value API
    ## #|
    ValueInit*: proc (pval: ptr VALUE): uint32 {.stdcall.}
    ValueClear*: proc (pval: ptr VALUE): uint32 {.stdcall.}
    ValueCompare*: proc (pval1: ptr VALUE; pval2: ptr VALUE): uint32 {.stdcall.}
    ValueCopy*: proc (pdst: ptr VALUE; psrc: ptr VALUE): uint32 {.stdcall.}
    ValueIsolate*: proc (pdst: ptr VALUE): uint32 {.stdcall.}
    ValueType*: proc (pval: ptr VALUE; pType: ptr uint32;
                      pUnits: ptr uint32): uint32 {.stdcall.}
    ValueStringData*: proc (pval: ptr VALUE; pChars: ptr WideCString;
                            pNumChars: ptr uint32): uint32 {.stdcall.}
    ValueStringDataSet*: proc (pval: ptr VALUE; chars: WideCString; numChars: uint32;
                              units: uint32): uint32 {.stdcall.}
    ValueIntData*: proc (pval: ptr VALUE; pData: ptr int32): uint32 {.stdcall.}
    ValueIntDataSet*: proc (pval: ptr VALUE; data: int32;
                          `type`: uint32; units: uint32): uint32 {.stdcall.}
    ValueInt64Data*: proc (pval: ptr VALUE; pData: ptr int64): uint32 {.stdcall.}
    ValueInt64DataSet*: proc (pval: ptr VALUE; data: int64; `type`: uint32;
                              units: uint32): uint32 {.stdcall.}
    ValueFloatData*: proc (pval: ptr VALUE; pData: ptr float64): uint32 {.stdcall.}
    ValueFloatDataSet*: proc (pval: ptr VALUE; data: float64; `type`: uint32;
                              units: uint32): uint32 {.stdcall.}
    ValueBinaryData*: proc (pval: ptr VALUE; pBytes: ptr pointer;
                            pnBytes: ptr uint32): uint32 {.stdcall.}
    ValueBinaryDataSet*: proc (pval: ptr VALUE; pBytes: pointer; nBytes: uint32;
                             `type`: uint32; units: uint32): uint32 {.stdcall.}
    ValueElementsCount*: proc (pval: ptr VALUE; pn: ptr int32): uint32 {.stdcall.}
    ValueNthElementValue*: proc (pval: ptr VALUE; n: int32;
                                pretval: ptr VALUE): uint32 {.stdcall.}
    ValueNthElementValueSet*: proc (pval: ptr VALUE; n: int32;
                                    pval_to_set: ptr VALUE): uint32 {.stdcall.}
    ValueNthElementKey*: proc (pval: ptr VALUE; n: int32;
                              pretval: ptr VALUE): uint32 {.stdcall.}
    ValueEnumElements*: proc (pval: ptr VALUE; penum: KeyValueCallback;
                            param: pointer): uint32 {.stdcall.}
    ValueSetValueToKey*: proc (pval: ptr VALUE; pkey: ptr VALUE;
                              pval_to_set: ptr VALUE): uint32 {.stdcall.}
    ValueGetValueOfKey*: proc (pval: ptr VALUE; pkey: ptr VALUE;
                              pretval: ptr VALUE): uint32 {.stdcall.}
    ValueToString*: proc (pval: ptr VALUE; how: uint32): uint32 {.
        stdcall.} ## #VALUE_STRING_CVT_TYPE
    ValueFromString*: proc (pval: ptr VALUE; str: WideCString; strLength: uint32;
                          how: uint32): uint32 {.stdcall.} ## #VALUE_STRING_CVT_TYPE
    ValueInvoke*: proc (pval: ptr VALUE; pthis: ptr VALUE; argc: uint32; argv: ptr VALUE;
                      pretval: ptr VALUE; url: WideCString): uint32 {.stdcall.}
    ValueNativeFunctorSet*: proc (pval: ptr VALUE;
                                pinvoke: NATIVE_FUNCTOR_INVOKE;
                                prelease: NATIVE_FUNCTOR_RELEASE;
                                tag: pointer): uint32 {.stdcall.}
    ValueIsNativeFunctor*: proc (pval: ptr VALUE): bool {.stdcall.}
    ## # tiscript VM API
    TIScriptAPI*: proc (): ptr tiscript_native_interface {.stdcall.}
    SciterGetVM*: proc (hwnd: HWINDOW): HVM {.stdcall.}
    Sciter_tv2V*: proc (vm: HVM; script_value: tiscript_value; value: ptr VALUE;
                      isolate: bool): bool {.stdcall.}
    Sciter_V2tv*: proc (vm: HVM; valuev: ptr VALUE;
                        script_value: ptr tiscript_value): bool {.stdcall.}
    SciterOpenArchive*: proc (archiveData: pointer;
                              archiveDataLength: uint32): HSARCHIVE {.stdcall.}
    SciterGetArchiveItem*: proc (harc: HSARCHIVE; path: WideCString;
                                pdata: ptr pointer;
                                pdataLength: ptr uint32): bool {.stdcall.}
    SciterCloseArchive*: proc (harc: HSARCHIVE): bool {.stdcall.}
    SciterFireEvent*: proc (evt: ptr BEHAVIOR_EVENT_PARAMS; post: bool;
                          handled: ptr bool): int32 {.stdcall.}
    SciterGetCallbackParam*: proc (hwnd: HWINDOW): pointer {.stdcall.}
    SciterPostCallback*: proc (hwnd: HWINDOW; wparam: uint32; lparam: uint32;
                             timeoutms: uint32): uint32 {.stdcall.}
    GetSciterGraphicsAPI*: proc (): LPSciterGraphicsAPI {.stdcall.}
    GetSciterRequestAPI*: proc (): LPSciterRequestAPI {.stdcall.}
    when defined(windows):
      SciterCreateOnDirectXWindow*: proc (hwnd: HWINDOW;
                                          pSwapChain: pointer): bool {.stdcall.}
      SciterRenderOnDirectXWindow*: proc (hwnd: HWINDOW; elementToRenderOrNull: HELEMENT;
                                          frontLayer: bool): bool {.stdcall.}
      SciterRenderOnDirectXTexture*: proc (hwnd: HWINDOW; elementToRenderOrNull: HELEMENT;
                                           surface: pointer): bool {.stdcall.}
    for_c2nim_only_very_bad_patch_so_do_not_pay_attention_to_this_field * : bool
    ## #
    ## c2nim
    ## needs
    ## this :(
  SciterAPI_ptr* = proc (): ptr ISciterAPI {.stdcall.}

include loader
## # defining "official" API functions:

proc SciterClassName*(): WideCString =
  return SAPI().SciterClassName()

proc SciterVersion*(major: bool): uint32 =
  return SAPI().SciterVersion(major)

proc SciterDataReady*(hwnd: HWINDOW; uri: WideCString; data: pointer;
                     dataLength: uint32): bool {.inline, discardable, stdcall.} =
  return SAPI().SciterDataReady(hwnd, uri, data, dataLength)

proc SciterDataReadyAsync*(hwnd: HWINDOW; uri: WideCString; data: pointer;
                          dataLength: uint32;
                          requestId: pointer): bool {.
    inline, discardable, stdcall.}
  = return SAPI().SciterDataReadyAsync(hwnd, uri, data, dataLength, requestId)

when defined(windows):
  proc SciterProc*(hwnd: HWINDOW; msg: uint32; wParam: WPARAM;
      lParam: LPARAM): LRESULT {.inline, discardable, stdcall.}
    = return SAPI().SciterProc(hwnd, msg, wParam, lParam)

  proc SciterProcND*(hwnd: HWINDOW; msg: uint32; wParam: WPARAM; lParam: LPARAM;
                    pbHandled: ptr bool): LRESULT {.inline, discardable, stdcall.}
    = return SAPI().SciterProcND(hwnd, msg, wParam, lParam, pbHandled)

proc SciterLoadFile*(hWndSciter: HWINDOW;
    filename: WideCString): bool {.inline, discardable, stdcall.}
  = return SAPI().SciterLoadFile(hWndSciter, filename)

proc SciterLoadHtml*(hWndSciter: HWINDOW; html: pointer; htmlSize: uint32;
                    baseUrl: WideCString): bool {.inline, discardable, stdcall.}
  = return SAPI().SciterLoadHtml(hWndSciter, html, htmlSize, baseUrl)

proc SciterSetCallback*(hWndSciter: HWINDOW; cb: SciterHostCallback;
    cbParam: pointer) {.inline, stdcall.}
  = SAPI().SciterSetCallback(hWndSciter, cb, cbParam)

proc SciterSetMasterCSS*(utf8: pointer; numBytes: uint32): bool {.
    inline, discardable, stdcall.} =
  return SAPI().SciterSetMasterCSS(utf8, numBytes)

proc SciterAppendMasterCSS*(utf8: pointer; numBytes: uint32): bool {.
    inline, discardable, stdcall.} =
  return SAPI().SciterAppendMasterCSS(utf8, numBytes)

proc SciterSetCSS*(hWndSciter: HWINDOW; utf8: pointer; numBytes: uint32;
                  baseUrl: WideCString; mediaType: WideCString): bool {.
    inline, discardable, stdcall.} =
  return SAPI().SciterSetCSS(hWndSciter, utf8, numBytes, baseUrl, mediaType)

proc SciterSetMediaType*(hWndSciter: HWINDOW; mediaType: WideCString): bool {.
    inline, discardable, stdcall.} =
  return SAPI().SciterSetMediaType(hWndSciter, mediaType)

proc SciterSetMediaVars*(hWndSciter: HWINDOW; mediaVars: ptr Value): bool {.
    inline, discardable, stdcall.} =
  return SAPI().SciterSetMediaVars(hWndSciter, mediaVars)

proc SciterGetMinWidth*(hWndSciter: HWINDOW): uint32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetMinWidth(hWndSciter)

proc SciterGetMinHeight*(hWndSciter: HWINDOW; width: uint32): uint32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetMinHeight(hWndSciter, width)

proc SciterCall*(hWnd: HWINDOW; functionName: cstring;
                argc: uint32; argv: ptr Value;
                retval: ptr Value): bool {.inline, discardable, stdcall.} =
  return SAPI().SciterCall(hWnd, functionName, argc, argv, retval)

proc SciterEval*(hwnd: HWINDOW; script: WideCString; scriptLength: uint32;
                pretval: ptr Value): bool {.inline, discardable, stdcall.} =
  return SAPI().SciterEval(hwnd, script, scriptLength, pretval)

proc SciterUpdateWindow*(hwnd: HWINDOW) {.inline, stdcall.} =
  SAPI().SciterUpdateWindow(hwnd)

when defined(windows):
  proc SciterTranslateMessage*(lpMsg: ptr MSG): bool {.
    inline, discardable, stdcall.} =
    return SAPI().SciterTranslateMessage(lpMsg)

proc SciterSetOption*(hWnd: HWINDOW; option: uint32; 
                      value: uint32): bool {.discardable.} =
  return SAPI().SciterSetOption(hWnd, option, value)

proc SciterGetPPI*(hWndSciter: HWINDOW; px: ptr uint32; py: ptr uint32) {.
    inline, stdcall.} =
  SAPI().SciterGetPPI(hWndSciter, px, py)

proc SciterGetViewExpando*(hwnd: HWINDOW; pval: ptr VALUE): bool {.inline,
    discardable, stdcall.} =
  return SAPI().SciterGetViewExpando(hwnd, pval)

when defined(windows):
  proc SciterRenderD2D*(hWndSciter: HWINDOW; prt: pointer): bool {.inline,
      discardable, stdcall.} =
    return SAPI().SciterRenderD2D(hWndSciter, prt)

  proc SciterD2DFactory*(ppf: pointer): bool {.inline, discardable, stdcall.} =
    return SAPI().SciterD2DFactory(ppf)

  proc SciterDWFactory*(ppf: pointer): bool {.inline, discardable, stdcall.} =
    return SAPI().SciterDWFactory(ppf)

proc SciterGraphicsCaps*(pcaps: ptr uint32): bool {.inline, discardable, stdcall.} =
  return SAPI().SciterGraphicsCaps(pcaps)

proc SciterSetHomeURL*(hWndSciter: HWINDOW; baseUrl: WideCString): bool {.
    inline, discardable, stdcall.} =
  return SAPI().SciterSetHomeURL(hWndSciter, baseUrl)

when defined(osx):
  proc SciterCreateNSView*(frame: ptr Rect): HWINDOW {.
      inline, discardable, stdcall.}
    = return SAPI().SciterCreateNSView(frame)

proc SciterCreateWindow*(creationFlags: uint32; frame: ptr Rect;
                        delegate: SciterWindowDelegate; delegateParam: pointer;
                        parent: HWINDOW): HWINDOW {.inline, discardable, stdcall.}
  = return SAPI().SciterCreateWindow(creationFlags, frame, delegate,
                                  delegateParam, parent)

proc SciterSetupDebugOutput*(hwndOrNull: HWINDOW; param: pointer;
            pfOutput: DEBUG_OUTPUT_PROC) {.stdcall.} =
  SAPI().SciterSetupDebugOutput(hwndOrNull, param, pfOutput)

proc Sciter_UseElement*(he: HELEMENT): int32 {.inline, discardable, stdcall.} =
  return SAPI().Sciter_UseElement(he)

proc Sciter_UnuseElement*(he: HELEMENT): int32 {.inline, discardable, stdcall.} =
  return SAPI().Sciter_UnuseElement(he)

proc SciterGetRootElement*(hwnd: HWINDOW; phe: ptr HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetRootElement(hwnd, phe)

proc SciterGetFocusElement*(hwnd: HWINDOW; phe: ptr HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetFocusElement(hwnd, phe)

proc SciterFindElement*(hwnd: HWINDOW; pt: Point; phe: ptr HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterFindElement(hwnd, pt, phe)

proc SciterGetChildrenCount*(he: HELEMENT; count: ptr uint32): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetChildrenCount(he, count)

proc SciterGetNthChild*(he: HELEMENT; n: uint32; phe: ptr HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetNthChild(he, n, phe)

proc SciterGetParentElement*(he: HELEMENT; p_parent_he: ptr HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetParentElement(he, p_parent_he)

proc SciterGetElementHtmlCB*(he: HELEMENT; outer: bool; 
                            rcv: LPCBYTE_RECEIVER;
                            rcv_param: pointer): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetElementHtmlCB(he, outer, rcv, rcv_param)

proc SciterGetElementTextCB*(he: HELEMENT; rcv: LPCWSTR_RECEIVER;
                            rcv_param: pointer): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetElementTextCB(he, rcv, rcv_param)

proc SciterSetElementText*(he: HELEMENT; utf16: WideCString;
    length: uint32): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterSetElementText(he, utf16, length)

proc SciterGetAttributeCount*(he: HELEMENT; p_count: ptr uint32): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetAttributeCount(he, p_count)

proc SciterGetNthAttributeNameCB*(he: HELEMENT; n: uint32; rcv: LPCSTR_RECEIVER;
                                 rcv_param: pointer): int32 {.inline,
    discardable, stdcall.} =
  return SAPI().SciterGetNthAttributeNameCB(he, n, rcv, rcv_param)

proc SciterGetNthAttributeValueCB*(he: HELEMENT; n: uint32;
                                  rcv: LPCWSTR_RECEIVER;
                                      rcv_param: pointer): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetNthAttributeValueCB(he, n, rcv, rcv_param)

proc SciterGetAttributeByNameCB*(he: HELEMENT; name: cstring;
                                rcv: LPCWSTR_RECEIVER;
                                    rcv_param: pointer): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetAttributeByNameCB(he, name, rcv, rcv_param)

proc SciterSetAttributeByName*(he: HELEMENT; name: cstring;
    value: WideCString): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterSetAttributeByName(he, name, value)

proc SciterClearAttributes*(he: HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterClearAttributes(he)

proc SciterGetElementIndex*(he: HELEMENT; p_index: ptr uint32): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetElementIndex(he, p_index)

proc SciterGetElementType*(he: HELEMENT; p_type: ptr cstring): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetElementType(he, p_type)

proc SciterGetElementTypeCB*(he: HELEMENT; rcv: LPCSTR_RECEIVER;
                            rcv_param: pointer): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetElementTypeCB(he, rcv, rcv_param)

proc SciterGetStyleAttributeCB*(he: HELEMENT; name: cstring;
                               rcv: LPCWSTR_RECEIVER;
                                   rcv_param: pointer): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetStyleAttributeCB(he, name, rcv, rcv_param)

proc SciterSetStyleAttribute*(he: HELEMENT; name: cstring;
    value: WideCString): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterSetStyleAttribute(he, name, value)

proc SciterGetElementLocation*(he: HELEMENT; p_location: ptr Rect;
    areas: uint32): int32 {.inline, discardable, stdcall.} =
  ## #ELEMENT_AREAS
  return SAPI().SciterGetElementLocation(he, p_location, areas)

proc SciterScrollToView*(he: HELEMENT; SciterScrollFlags: uint32): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterScrollToView(he, SciterScrollFlags)

proc SciterUpdateElement*(he: HELEMENT; andForceRender: bool): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterUpdateElement(he, andForceRender)

proc SciterRefreshElementArea*(he: HELEMENT; rc: Rect): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterRefreshElementArea(he, rc)

proc SciterSetCapture*(he: HELEMENT): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterSetCapture(he)

proc SciterReleaseCapture*(he: HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterReleaseCapture(he)

proc SciterGetElementHwnd*(he: HELEMENT; p_hwnd: ptr HWINDOW;
    rootWindow: bool): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterGetElementHwnd(he, p_hwnd, rootWindow)

proc SciterCombineURL*(he: HELEMENT; szUrlBuffer: WideCString;
    UrlBufferSize: uint32): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterCombineURL(he, szUrlBuffer, UrlBufferSize)

proc SciterSelectElements*(he: HELEMENT; CSS_selectors: cstring;
                          callback: SciterElementCallback;
                              param: pointer): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterSelectElements(he, CSS_selectors, callback, param)

proc SciterSelectElementsW*(he: HELEMENT; CSS_selectors: WideCString;
                           callback: SciterElementCallback;
                               param: pointer): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterSelectElementsW(he, CSS_selectors, callback, param)

proc SciterSelectParent*(he: HELEMENT; selector: cstring; depth: uint32;
                        heFound: ptr HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterSelectParent(he, selector, depth, heFound)

proc SciterSelectParentW*(he: HELEMENT; selector: WideCString; depth: uint32;
                         heFound: ptr HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterSelectParentW(he, selector, depth, heFound)

proc SciterSetElementHtml*(he: HELEMENT; html: ptr byte; htmlLength: uint32;
                          where: uint32): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterSetElementHtml(he, html, htmlLength, where)

proc SciterGetElementUID*(he: HELEMENT; puid: ptr uint32): int32 {.inline,
    discardable, stdcall.} =
  return SAPI().SciterGetElementUID(he, puid)

proc SciterGetElementByUID*(hwnd: HWINDOW; uid: uint32;
    phe: ptr HELEMENT): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterGetElementByUID(hwnd, uid, phe)

proc SciterShowPopup*(hePopup: HELEMENT; heAnchor: HELEMENT;
    placement: uint32): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterShowPopup(hePopup, heAnchor, placement)

proc SciterShowPopupAt*(hePopup: HELEMENT; pos: Point; animate: bool): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterShowPopupAt(hePopup, pos, animate)

proc SciterHidePopup*(he: HELEMENT): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterHidePopup(he)

proc SciterGetElementState*(he: HELEMENT; pstateBits: ptr uint32): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetElementState(he, pstateBits)

proc SciterSetElementState*(he: HELEMENT; stateBitsToSet: uint32;
                           stateBitsToClear: uint32; updateView: bool): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterSetElementState(he, stateBitsToSet, 
                                      stateBitsToClear,  updateView)

proc SciterCreateElement*(tagname: cstring; textOrNull: WideCString;
                         phe: ptr HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  ## #out
  return SAPI().SciterCreateElement(tagname, textOrNull, phe)

proc SciterCloneElement*(he: HELEMENT; phe: ptr HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  ## #out
  return SAPI().SciterCloneElement(he, phe)

proc SciterInsertElement*(he: HELEMENT; hparent: HELEMENT;
    index: uint32): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterInsertElement(he, hparent, index)

proc SciterDetachElement*(he: HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterDetachElement(he)

proc SciterDeleteElement*(he: HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterDeleteElement(he)

proc SciterSetTimer*(he: HELEMENT; milliseconds: uint32;
    timer_id: uint32): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterSetTimer(he, milliseconds, timer_id)

proc SciterDetachEventHandler*(he: HELEMENT; pep: ElementEventProc;
                              tag: pointer): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterDetachEventHandler(he, pep, tag)

proc SciterAttachEventHandler*(he: HELEMENT; pep: ElementEventProc;
                              tag: pointer): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterAttachEventHandler(he, pep, tag)

proc SciterWindowAttachEventHandler*(hwndLayout: HWINDOW; pep: ElementEventProc;
                                    tag: pointer; subscription: uint32): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterWindowAttachEventHandler(hwndLayout, pep, tag, subscription)

proc SciterWindowDetachEventHandler*(hwndLayout: HWINDOW; pep: ElementEventProc;
                                    tag: pointer): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterWindowDetachEventHandler(hwndLayout, pep, tag)

proc SciterSendEvent*(he: HELEMENT; appEventCode: uint32; heSource: HELEMENT;
                     reason: uint32; handled: ptr bool): int32 {.
    inline, discardable, stdcall.} =
  ## #out
  return SAPI().SciterSendEvent(he, appEventCode, heSource, reason, handled)

proc SciterPostEvent*(he: HELEMENT; appEventCode: uint32; heSource: HELEMENT;
                     reason: uint32): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterPostEvent(he, appEventCode, heSource, reason)

proc SciterFireEvent*(evt: ptr BEHAVIOR_EVENT_PARAMS; post: bool;
                      handled: ptr bool): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterFireEvent(evt, post, handled)

proc SciterCallBehaviorMethod*(he: HELEMENT;
    params: ptr METHOD_PARAMS): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterCallBehaviorMethod(he, params)

proc SciterRequestElementData*(he: HELEMENT; url: WideCString; dataType: uint32;
                              initiator: HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterRequestElementData(he, url, dataType, initiator)

proc SciterHttpRequest*(he: HELEMENT; url: WideCString; dataType: uint32;
                       requestType: uint32; requestParams: ptr REQUEST_PARAM;
                       nParams: uint32): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterHttpRequest(he, url, dataType, requestType, 
                                  requestParams, nParams)

proc SciterGetScrollInfo*(he: HELEMENT; scrollPos: ptr Point; viewRect: ptr Rect;
                         contentSize: ptr Size): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetScrollInfo(he, scrollPos, viewRect, contentSize)

proc SciterSetScrollPos*(he: HELEMENT; scrollPos: Point; smooth: bool): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterSetScrollPos(he, scrollPos, smooth)

proc SciterGetElementIntrinsicWidths*(he: HELEMENT; pMinWidth: ptr int32;
                                     pMaxWidth: ptr int32): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetElementIntrinsicWidths(he, pMinWidth, pMaxWidth)

proc SciterGetElementIntrinsicHeight*(he: HELEMENT; forWidth: int32;
                                     pHeight: ptr int32): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetElementIntrinsicHeight(he, forWidth, pHeight)

proc SciterIsElementVisible*(he: HELEMENT; pVisible: ptr bool): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterIsElementVisible(he, pVisible)

proc SciterIsElementEnabled*(he: HELEMENT; pEnabled: ptr bool): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterIsElementEnabled(he, pEnabled)

proc SciterSortElements*(he: HELEMENT; firstIndex: uint32; lastIndex: uint32;
                        cmpFunc: ptr ELEMENT_COMPARATOR;
                        cmpFuncParam: pointer): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterSortElements(he, firstIndex, lastIndex, 
                                  cmpFunc, cmpFuncParam)

proc SciterSwapElements*(he1: HELEMENT; he2: HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterSwapElements(he1, he2)

proc SciterTraverseUIEvent*(evt: uint32; eventCtlStruct: pointer;
                           bOutProcessed: ptr bool): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterTraverseUIEvent(evt, eventCtlStruct, bOutProcessed)

proc SciterCallScriptingMethod*(he: HELEMENT; name: cstring; argv: ptr VALUE;
                               argc: uint32; retval: ptr VALUE): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterCallScriptingMethod(he, name, argv, argc, retval)

proc SciterCallScriptingFunction*(he: HELEMENT; name: cstring; argv: ptr VALUE;
                                 argc: uint32; retval: ptr VALUE): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterCallScriptingFunction(he, name, argv, argc, retval)

proc SciterEvalElementScript*(he: HELEMENT; script: WideCString;
                             scriptLength: uint32; retval: ptr VALUE): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterEvalElementScript(he, script, scriptLength, retval)

proc SciterAttachHwndToElement*(he: HELEMENT; hwnd: HWINDOW): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterAttachHwndToElement(he, hwnd)

proc SciterControlGetType*(he: HELEMENT; pType: ptr uint32): int32 {.
    inline, discardable, stdcall.} =
  ## #CTL_TYPE
  return SAPI().SciterControlGetType(he, pType)

proc SciterGetValue*(he: HELEMENT; pval: ptr VALUE): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetValue(he, pval)

proc SciterSetValue*(he: HELEMENT; pval: ptr VALUE): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterSetValue(he, pval)

proc SciterGetExpando*(he: HELEMENT; pval: ptr VALUE;
    forceCreation: bool): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterGetExpando(he, pval, forceCreation)

proc SciterGetObject*(he: HELEMENT; pval: ptr tiscript_value;
    forceCreation: bool): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterGetObject(he, pval, forceCreation)

proc SciterGetElementNamespace*(he: HELEMENT;
    pval: ptr tiscript_value): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterGetElementNamespace(he, pval)

proc SciterGetHighlightedElement*(hwnd: HWINDOW; phe: ptr HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterGetHighlightedElement(hwnd, phe)

proc SciterSetHighlightedElement*(hwnd: HWINDOW; he: HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterSetHighlightedElement(hwnd, he)

proc SciterNodeAddRef*(hn: HNODE): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterNodeAddRef(hn)

proc SciterNodeRelease*(hn: HNODE): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterNodeRelease(hn)

proc SciterNodeCastFromElement*(he: HELEMENT; phn: ptr HNODE): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterNodeCastFromElement(he, phn)

proc SciterNodeCastToElement*(hn: HNODE; he: ptr HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterNodeCastToElement(hn, he)

proc SciterNodeFirstChild*(hn: HNODE; phn: ptr HNODE): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterNodeFirstChild(hn, phn)

proc SciterNodeLastChild*(hn: HNODE; phn: ptr HNODE): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterNodeLastChild(hn, phn)

proc SciterNodeNextSibling*(hn: HNODE; phn: ptr HNODE): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterNodeNextSibling(hn, phn)

proc SciterNodePrevSibling*(hn: HNODE; phn: ptr HNODE): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterNodePrevSibling(hn, phn)

proc SciterNodeParent*(hnode: HNODE; pheParent: ptr HELEMENT): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterNodeParent(hnode, pheParent)

proc SciterNodeNthChild*(hnode: HNODE; n: uint32; phn: ptr HNODE): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterNodeNthChild(hnode, n, phn)

proc SciterNodeChildrenCount*(hnode: HNODE; pn: ptr uint32): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterNodeChildrenCount(hnode, pn)

proc SciterNodeType*(hnode: HNODE; pNodeType: ptr uint32): int32 {.
    inline, discardable, stdcall.} =
  ## #NODE_TYPE
  return SAPI().SciterNodeType(hnode, pNodeType)

proc SciterNodeGetText*(hnode: HNODE; rcv: LPCWSTR_RECEIVER;
    rcv_param: pointer): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterNodeGetText(hnode, rcv, rcv_param)

proc SciterNodeSetText*(hnode: HNODE; text: WideCString;
    textLength: uint32): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterNodeSetText(hnode, text, textLength)

proc SciterNodeInsert*(hnode: HNODE; where: uint32; ## #NODE_INS_TARGET
                      what: HNODE): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterNodeInsert(hnode, where, what)

proc SciterNodeRemove*(hnode: HNODE; finalize: bool): int32 {.
    inline, discardable, stdcall.} =
  return SAPI().SciterNodeRemove(hnode, finalize)

proc SciterCreateTextNode*(text: WideCString; textLength: uint32;
    phnode: ptr HNODE): int32 {.inline, discardable, stdcall.} =
  return SAPI().SciterCreateTextNode(text, textLength, phnode)

proc SciterCreateCommentNode*(text: WideCString; textLength: uint32;
                             phnode: ptr HNODE): int32 {.
    inline, discardable, stdcall.} 
  = return SAPI().SciterCreateCommentNode(text, textLength, phnode)

proc SciterGetVM*(hwnd: HWINDOW): HVM {.inline, discardable, stdcall.} 
  = return SAPI().SciterGetVM(hwnd)

proc ValueInit*(pval: ptr VALUE): uint32 {.inline, discardable, stdcall.} =
  return SAPI().ValueInit(pval)

proc ValueClear*(pval: ptr VALUE): uint32 {.inline, discardable, stdcall.} =
  return SAPI().ValueClear(pval)

proc ValueCompare*(pval1: ptr VALUE; pval2: ptr VALUE): uint32 {.
    inline, discardable,stdcall.}
  = return SAPI().ValueCompare(pval1, pval2)

proc ValueCopy*(pdst: ptr VALUE; psrc: ptr VALUE): uint32 {.
    inline, discardable, stdcall.} 
  = return SAPI().ValueCopy(pdst, psrc)

proc ValueIsolate*(pdst: ptr VALUE): uint32 {.
    inline, discardable, stdcall.} 
  = return SAPI().ValueIsolate(pdst)

proc ValueType*(pval: ptr VALUE; pType: ptr uint32;
    pUnits: ptr uint32): uint32 {.inline,discardable, stdcall.} =
  return SAPI().ValueType(pval, pType, pUnits)

proc ValueStringData*(pval: ptr VALUE; pChars: ptr WideCString;
    pNumChars: ptr uint32): uint32 {.inline, discardable, stdcall.} 
  = return SAPI().ValueStringData(pval, pChars, pNumChars)

proc ValueStringDataSet*(pval: ptr VALUE; chars: WideCString; numChars: uint32;
                        units: uint32): uint32 =
  return SAPI().ValueStringDataSet(pval, chars, numChars, units)

proc ValueIntData*(pval: ptr VALUE; pData: ptr int32): uint32 =
  return SAPI().ValueIntData(pval, pData)

proc ValueIntDataSet*(pval: ptr VALUE; data: int32; `type`: uint32;
    units: uint32): uint32 =
  return SAPI().ValueIntDataSet(pval, data, `type`, units)

proc ValueInt64Data*(pval: ptr VALUE; pData: ptr int64): uint32 =
  return SAPI().ValueInt64Data(pval, pData)

proc ValueInt64DataSet*(pval: ptr VALUE; data: int64; `type`: uint32;
    units: uint32): uint32 =
  return SAPI().ValueInt64DataSet(pval, data, `type`, units)

proc ValueFloatData*(pval: ptr VALUE; pData: ptr float64): uint32 {.
    inline, discardable, stdcall.} =
  return SAPI().ValueFloatData(pval, pData)

proc ValueFloatDataSet*(pval: ptr VALUE; data: float64; `type`: uint32;
    units: uint32): uint32 {.inline, discardable, stdcall.} =
  return SAPI().ValueFloatDataSet(pval, data, `type`, units)

proc ValueBinaryData*(pval: ptr VALUE; pBytes: ptr pointer;
    pnBytes: ptr uint32): uint32 {.inline, discardable, stdcall.} =
  return SAPI().ValueBinaryData(pval, pBytes, pnBytes)

proc ValueBinaryDataSet*(pval: ptr VALUE; pBytes: pointer; nBytes: uint32;
                        `type`: uint32; units: uint32): uint32 =
  return SAPI().ValueBinaryDataSet(pval, pBytes, nBytes, `type`, units)

proc ValueElementsCount*(pval: ptr VALUE; pn: ptr int32): uint32 =
  return SAPI().ValueElementsCount(pval, pn)

proc ValueNthElementValue*(pval: ptr VALUE; n: int32;
    pretval: ptr VALUE): uint32 =
  return SAPI().ValueNthElementValue(pval, n, pretval)

proc ValueNthElementValueSet*(pval: ptr VALUE; n: int32;
    pval_to_set: ptr VALUE): uint32 {.inline, discardable, stdcall.} =
  return SAPI().ValueNthElementValueSet(pval, n, pval_to_set)

proc ValueNthElementKey*(pval: ptr VALUE; n: int32;
    pretval: ptr VALUE): uint32 =
  return SAPI().ValueNthElementKey(pval, n, pretval)

proc ValueEnumElements*(pval: ptr VALUE; penum: KeyValueCallback;
    param: pointer): uint32 {.inline, discardable, stdcall.} =
  return SAPI().ValueEnumElements(pval, penum, param)

proc ValueSetValueToKey*(pval: ptr VALUE; pkey: ptr VALUE;
    pval_to_set: ptr VALUE): uint32 {.inline, discardable, stdcall.} =
  return SAPI().ValueSetValueToKey(pval, pkey, pval_to_set)

proc ValueGetValueOfKey*(pval: ptr VALUE; pkey: ptr VALUE;
    pretval: ptr VALUE): uint32 =
  return SAPI().ValueGetValueOfKey(pval, pkey, pretval)

proc ValueToString*(pval: ptr VALUE; how: uint32): uint32 =
  return SAPI().ValueToString(pval, how)

proc ValueFromString*(pval: ptr VALUE; str: WideCString; strLength: uint32;
    how: uint32): uint32 {.inline, discardable, stdcall.} =
  return SAPI().ValueFromString(pval, str, strLength, how)

proc ValueInvoke*(pval: ptr VALUE; pthis: ptr VALUE; argc: uint32; 
                argv: ptr VALUE; pretval: ptr VALUE; url: WideCString): uint32 {.
    inline, discardable, stdcall.} =
  return SAPI().ValueInvoke(pval, pthis, argc, argv, pretval, url)

proc ValueNativeFunctorSet*(pval: ptr VALUE; 
                            pinvoke: NATIVE_FUNCTOR_INVOKE;
                            prelease: NATIVE_FUNCTOR_RELEASE;
                            tag: pointer): uint32 {.
    inline, discardable, stdcall.} =
  return SAPI().ValueNativeFunctorSet(pval, pinvoke, prelease, tag)

proc ValueIsNativeFunctor*(pval: ptr VALUE): bool {.
    inline, discardable, stdcall.} =
  return SAPI().ValueIsNativeFunctor(pval)

## # conversion between script (managed) value and the VALUE ( com::variant alike thing )
proc Sciter_tv2V*(vm: HVM; script_value: tiscript_value; out_value: ptr VALUE;
                 isolate: bool): bool {.inline, discardable, stdcall.} =
  return SAPI().Sciter_tv2V(vm, script_value, out_value, isolate)

proc Sciter_V2tv*(vm: HVM; value: ptr VALUE;
    out_script_value: ptr tiscript_value): bool {.discardable.} =
  return SAPI().Sciter_V2tv(vm, value, out_script_value)

when defined(windows):
  proc SciterCreateOnDirectXWindow*(hwnd: HWINDOW; 
                                    pSwapChain: pointer): bool {.discardable.} =
    return SAPI().SciterCreateOnDirectXWindow(hwnd, pSwapChain)

  proc SciterRenderOnDirectXWindow*(hwnd: HWINDOW; elementToRenderOrNull: HELEMENT;
                                   frontLayer: bool): bool {.discardable.} =
    return SAPI().SciterRenderOnDirectXWindow(hwnd, 
                                            elementToRenderOrNull, frontLayer)

  proc SciterRenderOnDirectXTexture*(hwnd: HWINDOW;
                                    elementToRenderOrNull: HELEMENT;
                                    surface: pointer): bool {.discardable.} =
    return SAPI().SciterRenderOnDirectXTexture(hwnd, elementToRenderOrNull, surface)
