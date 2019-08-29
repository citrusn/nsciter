## #
## #  The Sciter Engine of Terra Informatica Software, Inc.
## #  http://sciter.com
## #  
## #  The code and information provided "as-is" without
## #  warranty of any kind, either expressed or implied.
## #  
## #  (C) 2003-2015, Terra Informatica Software, Inc.
## # 
## #
## #  DOM access methods, plain C interface
## #

import encodings

type
  HELEMENT* = distinct pointer

## #*DOM node handle.
type
  HNODE* = pointer

## #*DOM range handle.
type
  HRANGE* = pointer
  HSARCHIVE* = pointer

  HPOSITION* = object
    hn*: HNODE
    pos*: int32


## ##include <string>

## #*Type of the result value for Sciter DOM functions.
## #  Possible values are:
## #  - \b SCDOM_OK - function completed successfully
## #  - \b SCDOM_INVALID_HWND - invalid HWINDOW
## #  - \b SCDOM_INVALID_HANDLE - invalid HELEMENT
## #  - \b SCDOM_PASSIVE_HANDLE - attempt to use HELEMENT which is not marked by
## #    #Sciter_UseElement()
## #  - \b SCDOM_INVALID_PARAMETER - parameter is invalid, e.g. pointer is null
## #  - \b SCDOM_OPERATION_FAILED - operation failed, e.g. invalid html in
## #    #SciterSetElementHtml()
## #

SCDOM_RESULT* {.size: 4.} = enum
  SCDOM_OK_NOT_HANDLED* = ( - 1)
  SCDOM_OK* = 0
  SCDOM_INVALID_HWND* = 1
  SCDOM_INVALID_HANDLE* = 2
  SCDOM_PASSIVE_HANDLE* = 3
  SCDOM_INVALID_PARAMETER* = 4
  SCDOM_OPERATION_FAILED* = 5
  
type
  METHOD_PARAMS* = object
    methodID*: uint32 #BEHAVIOR_METHOD_IDENTIFIERS

  REQUEST_PARAM* = object
    name*: WideCString
    value*: WideCString

  ELEMENT_AREAS* {.size: 4.} = enum
    CONTENT_BOX = 0x00000000,   ## # content (inner)  box
    ROOT_RELATIVE = 0x00000001, ## # - or this flag if you want to get Sciter window relative coordinates,
                                ## # otherwise it will use nearest windowed container e.g. popup window.
    SELF_RELATIVE = 0x00000002, ## # - "or" this flag if you want to get coordinates relative to the origin
                                     ## # of element iself.
    CONTAINER_RELATIVE = 0x00000003, ## # - position inside immediate container.
    VIEW_RELATIVE = 0x00000004,      ## # - position relative to view - Sciter window
    PADDING_BOX = 0x00000010,        ## # content + paddings
    BORDER_BOX = 0x00000020,         ## # content + paddings + border
    MARGIN_BOX = 0x00000030,         ## # content + paddings + border + margins
    BACK_IMAGE_AREA = 0x00000040,    ## # relative to content origin - location of background image (if it set no-repeat)
    FORE_IMAGE_AREA = 0x00000050,    ## # relative to content origin - location of foreground image (if it set no-repeat)
    SCROLLABLE_AREA = 0x00000060     ## # scroll_area - scrollable area in content box


type
  SCITER_SCROLL_FLAGS* {.size: 4.} = enum
    SCROLL_TO_TOP = 0x00000001,
    SCROLL_SMOOTH = 0x00000010


## #*Callback function used with #SciterVisitElement().
type
  SciterElementCallback* = proc (he: HELEMENT; param: pointer): bool {.stdcall.}

  SET_ELEMENT_HTML* {.size: 4.} = enum
    SIH_REPLACE_CONTENT = 0,
    SIH_INSERT_AT_START = 1,
    SIH_APPEND_AFTER_LAST = 2,
    SOH_REPLACE = 3,
    SOH_INSERT_BEFORE = 4,
    SOH_INSERT_AFTER = 5

## #*Element callback function for all types of events. Similar to WndProc
## #  \param tag \b LPVOID, tag assigned by SciterAttachElementProc function (like GWL_USERDATA)
## #  \param he \b HELEMENT, this element handle (like HWINDOW)
## #  \param evtg \b UINT, group identifier of the event, value is one of EVENT_GROUPS
## #  \param prms \b LPVOID, pointer to group specific parameters structure.
## #  \return TRUE if event was handled, FALSE otherwise.
## #
type
  ElementEventProc* = proc (tag: pointer; he: HELEMENT; evtg: uint32;
                           prms: pointer): uint {.stdcall.}
  LPELEMENT_EVENT_PROC* = ptr ElementEventProc
  ELEMENT_STATE_BITS* {.size: 4.} = enum
    STATE_LINK = 0x00000001, 
    STATE_HOVER = 0x00000002,
    STATE_ACTIVE = 0x00000004,
    STATE_FOCUS = 0x00000008, 
    STATE_VISITED = 0x00000010,
    STATE_CURRENT = 0x00000020,     ## # current (hot) item
    STATE_CHECKED = 0x00000040,     ## # element is checked (or selected)
    STATE_DISABLED = 0x00000080,    ## # element is disabled
    STATE_READONLY = 0x00000100,    ## # readonly input element
    STATE_EXPANDED = 0x00000200,    ## # expanded state - nodes in tree view
    STATE_COLLAPSED = 0x00000400,   ## # collapsed state - nodes in tree view - mutually exclusive with
    STATE_INCOMPLETE = 0x00000800,  ## # one of fore/back images requested but not delivered
    STATE_ANIMATING = 0x00001000,   ## # is animating currently
    STATE_FOCUSABLE = 0x00002000,   ## # will accept focus
    STATE_ANCHOR = 0x00004000,      ## # anchor in selection (used with current in selects)
    STATE_SYNTHETIC = 0x00008000,   ## # this is a synthetic element - don't emit it's head/tail
    STATE_OWNS_POPUP = 0x00010000,  ## # this is a synthetic element - don't emit it's head/tail
    STATE_TABFOCUS = 0x00020000,    ## # focus gained by tab traversal
    STATE_EMPTY = 0x00040000,       ## # empty - element is empty (text.size() == 0 && subs.size() == 0)
                                    ## #  if element has behavior attached then the behavior is responsible
                                    ## #for the value of this flag.
    STATE_BUSY = 0x00080000,        ## # busy; loading
    STATE_DRAG_OVER = 0x00100000,   ## # drag over the block that can accept it (so is current drop target).
                                    ## Flag is set for the drop target block
    STATE_DROP_TARGET = 0x00200000, ## # active drop target.
    STATE_MOVING = 0x00400000,      ## # dragging/moving - the flag is set for the moving block.
    STATE_COPYING = 0x00800000,     ## # dragging/copying - the flag is set for the copying block.
    STATE_DRAG_SOURCE = 0x01000000, ## # element that is a drag source.
    STATE_DROP_MARKER = 0x02000000, ## # element is drop marker
    STATE_PRESSED = 0x04000000,   ## # pressed - close to active but has wider life span - e.g. in MOUSE_UP it
                                  ## # is still on; so behavior can check it in MOUSE_UP to discover CLICK condition.
    STATE_POPUP = 0x08000000,     ## # this element is out of flow - popup
    STATE_IS_LTR = 0x10000000,    ## # the element or one of its containers has dir=ltr declared
    STATE_IS_RTL = 0x20000000     ## # the element or one of its containers has dir=rtl declared


type
  REQUEST_TYPE* {.size: 4.} = enum
    GET_ASYNC,  ## # async GET
    POST_ASYNC, ## # async POST
    GET_SYNC,   ## # synchronous GET
    POST_SYNC   ## # synchronous POST


## #*Callback comparator function used with #SciterSortElements().
## # Shall return -1,0,+1 values to indicate result of comparison of two elements
## #
type
  ELEMENT_COMPARATOR* = proc (he1: HELEMENT; he2: HELEMENT; param: pointer): int32 {.stdcall.}
  CTL_TYPE* {.size: 4.} = enum
    CTL_NO = 0,          ## #< This dom element has no behavior at all.
    CTL_UNKNOWN = 1,     ## # < This dom element has behavior but its type is unknown.

    CTL_EDIT = 2,             ## #< Single line edit box.
    CTL_NUMERIC = 3,          ## #< Numeric input with optional spin buttons.
    CTL_CLICKABLE = 4,        ## #< toolbar button, behavior:clickable.
    CTL_BUTTON = 5,           ## #< Command button.
    CTL_CHECKBOX = 6,         ## #< CheckBox (button).
    CTL_RADIO = 7,            ## #< OptionBox (button).
    CTL_SELECT_SINGLE = 8,    ## #< Single select, ListBox or TreeView.
    CTL_SELECT_MULTIPLE = 9,  ## #< Multiselectable select, ListBox or TreeView.
    CTL_DD_SELECT = 10,        ## #< Dropdown single select.
    CTL_TEXTAREA = 11,         ## #< Multiline TextBox.
    CTL_HTMLAREA = 12,         ## #< HTML selection behavior.
    CTL_PASSWORD = 13,         ## #< Password input element.
    CTL_PROGRESS = 14,         ## #< Progress element.
    CTL_SLIDER = 15,           ## #< Slider input element.  
    CTL_DECIMAL = 16,          ## #< Decimal number input element.
    CTL_CURRENCY = 17,         ## #< Currency input element.
    CTL_SCROLLBAR = 18,
    CTL_LIST = 19,
    CTL_RICHTEXT = 20,
    CTL_CALENDAR = 21,
    CTL_DATE = 22,
    CTL_TIME = 23,
    CTL_FILE = 24,             ## #< file input element.
    CTL_PATH = 25,             ## #< path input element.

    CTL_LAST_INPUT = 26,

    # CTL_HYPERLINK = CTL_LAST_INPUT,
    CTL_FORM = 27,

    CTL_MENUBAR = 28,
    CTL_MENU = 29,
    CTL_MENUBUTTON = 30,

    CTL_FRAME = 31,
    CTL_FRAMESET = 32,

    CTL_TOOLTIP = 33,

    CTL_HIDDEN = 34,
    CTL_URL = 35,              ## #< URL input element.
    CTL_TOOLBAR = 36,

    CTL_WINDOW = 37,           ## #< has HWND attached to it

    CTL_LABEL = 38,
    CTL_IMAGE = 39,           ## #< image/video object.  
    CTL_PLAINTEXT = 40        ## #< Multiline TextBox + colorizer.

type
  NODE_TYPE* {.size: 4.} = enum
    NT_ELEMENT, NT_TEXT, NT_COMMENT

type
  NODE_INS_TARGET* {.size: 4.} = enum
    NIT_BEFORE, NIT_AFTER, NIT_APPEND, NIT_PREPEND

proc LPCBYTE2ASTRING*(bytes: cstring; str_length: cuint; param: pointer) {.stdcall.} =
  # proc (bytes: ptr array[256, byte];num_bytes: uint32 ; param: void )
  # sciter::astring* s = (sciter::astring*)param;
  # *s = sciter::astring((const char*)bytes,num_bytes);
  var s1 = cast[ptr string](param)
  #s1[].setLen(str_length)
  #for i in 0..str_length-1:
  #  s1[i]=bytes[i]
  var s: string
  add(s, bytes)
  s1[] = convert(s, srcEncoding = "UTF-8", destEncoding = "CP1251")

proc LPCSTR2ASTRING*(str: cstring; str_length: cuint; param: pointer) {.stdcall.} =
  # sciter::astring* s = (sciter::astring*)param;
  # *s = sciter::astring(str,str_length);
  LPCBYTE2ASTRING(str, str_length, param)

proc LPCWSTR2STRING*(str: WideCString; str_length: cuint; param: pointer) {.stdcall.} =
  #sciter::string* s = (sciter::string*)param;
  #*s = sciter::string(str,str_length);
  var s1 = cast[ptr string](param)
  #echo "LPCWSTR2STRING:" , str_length , str
  s1[] = convert($str, srcEncoding = "UTF-8", destEncoding = "CP1251")
