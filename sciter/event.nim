
type
    EventHandler* = ptr EventHandlerObj
    EventHandlerObj* = object
        subscription*: proc(he: HELEMENT, event_groups: var cuint): uint
        handle_mouse*: proc(he: HELEMENT, params: ptr MOUSE_PARAMS): uint
        handle_key*: proc(he: HELEMENT, params: ptr KEY_PARAMS): uint
        handle_focus*: proc(he: HELEMENT, params: ptr FOCUS_PARAMS): uint
        handle_timer*: proc(he: HELEMENT, params: ptr TIMER_PARAMS): uint
        handle_size*: proc(he: HELEMENT): uint
        handle_scroll*: proc(he: HELEMENT, params: ptr SCROLL_PARAMS): uint
        handle_event*: proc(he: HELEMENT,
                            params: ptr BEHAVIOR_EVENT_PARAMS): uint
        handle_method_call*: proc(he: HELEMENT, params: ptr METHOD_PARAMS): uint
        handle_data_arrived*: proc(he: HELEMENT,
                                    params: ptr DATA_ARRIVED_PARAMS): uint
        handle_draw*: proc(he: HELEMENT, params: ptr DRAW_PARAMS): uint
        ## call using sciter::value's (from CSSS!)
        handle_scripting_call*: proc(he: HELEMENT,
                                    params: ptr SCRIPTING_METHOD_PARAMS): uint
        ## call using tiscript::value's (from the script)
        handle_tiscript_call*: proc(he: HELEMENT,
                                    params: ptr TISCRIPT_METHOD_PARAMS): uint
        handle_gesture*: proc(he: HELEMENT, params: ptr GESTURE_PARAMS): uint
        handle_exchange*: proc(he: HELEMENT, params: ptr EXCHANGE_PARAMS): uint
        detached*: proc(he: HELEMENT)
        attached*: proc(he: HELEMENT)

type
    EventTarget = HWINDOW or HELEMENT

var fn_subscription = proc(he: HELEMENT,
        params: var cuint): uint = return 0
var fn_handle_mouse = proc(he: HELEMENT,
        params: ptr MOUSE_PARAMS): uint = return 0
var fn_handle_key = proc(he: HELEMENT,
        params: ptr KEY_PARAMS): uint = return 0
var fn_handle_focus = proc(he: HELEMENT,
        params: ptr FOCUS_PARAMS): uint = return 0
var fn_handle_timer = proc(he: HELEMENT,
        params: ptr TIMER_PARAMS): uint = return 0
var fn_handle_size = proc(he: HELEMENT): uint = return 0
var fn_handle_scroll = proc(he: HELEMENT,
        params: ptr SCROLL_PARAMS): uint = return 0
var fn_handle_exchange = proc(he: HELEMENT,
        params: ptr EXCHANGE_PARAMS): uint = return 0
var fn_handle_gesture = proc(he: HELEMENT,
        params: ptr GESTURE_PARAMS): uint = return 0
var fn_handle_draw = proc(he: HELEMENT,
        params: ptr DRAW_PARAMS): uint = return 0
var fn_handle_method_call = proc(he: HELEMENT,
        params: ptr METHOD_PARAMS): uint = return 0
var fn_handle_tiscript_call = proc(he: HELEMENT, 
        params: ptr TISCRIPT_METHOD_PARAMS): uint = return 0
var fn_handle_event = proc(he: HELEMENT, 
        params: ptr BEHAVIOR_EVENT_PARAMS): uint = return 0
var fn_handle_data_arrived = proc(he: HELEMENT, 
        params: ptr DATA_ARRIVED_PARAMS): uint = return 0
var fn_handle_scripting_call = proc(he: HELEMENT, 
        params: ptr SCRIPTING_METHOD_PARAMS): uint = return 0
var fn_ttach = proc(he: HELEMENT) = discard

proc newEventHandler*(): EventHandler =    
    #new(EventHandler)
    result = cast[EventHandler](alloc(sizeof(EventHandlerObj)))
    result.subscription = fn_subscription
    result.handle_mouse = fn_handle_mouse
    result.handle_key = fn_handle_key
    result.handle_focus = fn_handle_focus
    result.handle_timer = fn_handle_timer
    result.handle_size = fn_handle_size
    result.handle_scroll = fn_handle_scroll
    result.handle_gesture = fn_handle_gesture
    result.handle_exchange = fn_handle_exchange
    result.handle_draw = fn_handle_draw
    result.handle_method_call = fn_handle_method_call
    result.handle_tiscript_call = fn_handle_tiscript_call
    result.handle_event = fn_handle_event
    result.handle_data_arrived = fn_handle_data_arrived
    result.handle_scripting_call = fn_handle_scripting_call
    result.detached = fn_ttach
    result.attached = fn_ttach

import tables
#proc hash(x: EventHandler): Hash {.inline.} =  return hash(x)
var evct = newCountTable[EventHandler]()

proc element_proc(tag: pointer; he: HELEMENT; evtg: uint32;
                  prms: pointer): uint {.stdcall.} =
    var pThis = cast[EventHandler](tag)
    #if evtg > uint32(256):
    #  debugEcho "element_proc: tag " , repr pThis , evtg , " prms:", repr prms
    assert pThis != nil, "pThis is nil"    
    case cast[EVENT_GROUPS](evtg)
    of SUBSCRIPTIONS_REQUEST:
        var p = cast[ptr cuint](prms)
        var res = pThis.subscription(he, p[])
        echo "SUBSCRIPTIONS_REQUEST: ", cast[EVENT_GROUPS](p)
        return res

    of HANDLE_INITIALIZATION:
        var p: ptr INITIALIZATION_PARAMS = cast[ptr INITIALIZATION_PARAMS](prms)
        if p.cmd == BEHAVIOR_DETACH:
            pThis.detached(he)
            evct.inc(pThis, -1)
            if evct.contains(pThis): dealloc(pThis)
        elif p.cmd == BEHAVIOR_ATTACH:
            echo "BEHAVIOR_ATTACH"
            pThis.attached(he)
            evct.inc(pThis)
        return 1

    of HANDLE_MOUSE:
        var p: ptr MOUSE_PARAMS = cast[ptr MOUSE_PARAMS](prms)
        var res = pThis.handle_mouse(he, p)
        #echo "HANDLE_MOUSE: res " , res, " cmd: " , cast[MOUSE_EVENTS](p.cmd)
        return res

    of HANDLE_KEY:
        var p: ptr KEY_PARAMS = cast[ptr KEY_PARAMS](prms)
        return pThis.handle_key(he, p)

    of HANDLE_FOCUS:
        var p: ptr FOCUS_PARAMS = cast[ptr FOCUS_PARAMS](prms)
        return pThis.handle_focus(he, p)

    of HANDLE_DRAW:
        var p: ptr DRAW_PARAMS = cast[ptr DRAW_PARAMS](prms)
        #echo "HANDLE_DRAW: " , repr prms
        var res = pThis.handle_draw(he, p)
        return res

    of HANDLE_TIMER:
        var p: ptr TIMER_PARAMS = cast[ptr TIMER_PARAMS](prms)
        return pThis.handle_timer(he, p)

    of HANDLE_BEHAVIOR_EVENT:
        var p: ptr BEHAVIOR_EVENT_PARAMS = cast[ptr BEHAVIOR_EVENT_PARAMS](prms)
        var res = pThis.handle_event(he, p)
        #echo "BEHAVIOR_EVENT_PARAMS: res ", res, repr p
        return res

    of HANDLE_METHOD_CALL:
        var p: ptr METHOD_PARAMS = cast[ptr METHOD_PARAMS](prms)
        #echo "HANDLE_METHOD_CALL: ", cast[BEHAVIOR_METHOD_IDENTIFIERS](p.methodID)
        return pThis.handle_method_call(he, p)

    of HANDLE_DATA_ARRIVED:
        var p: ptr DATA_ARRIVED_PARAMS = cast[ptr DATA_ARRIVED_PARAMS](prms)
        return pThis.handle_data_arrived(he, p)

    of HANDLE_SCROLL:
        var p: ptr SCROLL_PARAMS = cast[ptr SCROLL_PARAMS](prms)
        return pThis.handle_scroll(he, p)

    of HANDLE_SIZE:
        var res = pThis.handle_size(he)
        return res

        ## # call using sciter::value's (from CSSS!)
    of HANDLE_SCRIPTING_METHOD_CALL:
        var p: ptr SCRIPTING_METHOD_PARAMS = cast[ptr SCRIPTING_METHOD_PARAMS](prms)
        #echo "HANDLE_SCRIPTING_METHOD_CALL: ", p.name
        return pThis.handle_scripting_call(he, p)

        ## # call using tiscript::value's (from the script)
    of HANDLE_TISCRIPT_METHOD_CALL:
        var p: ptr TISCRIPT_METHOD_PARAMS = cast[ptr TISCRIPT_METHOD_PARAMS](prms)
        #echo "HANDLE_TISCRIPT_METHOD_CALL: " , p.tag
        return pThis.handle_tiscript_call(he, p)

    of HANDLE_GESTURE:
        var p: ptr GESTURE_PARAMS = cast[ptr GESTURE_PARAMS](prms)
        return pThis.handle_gesture(he, p)

    of HANDLE_EXCHANGE:
        var p: ptr EXCHANGE_PARAMS = cast[ptr EXCHANGE_PARAMS](prms)
        return pThis.handle_exchange(he, p)

    else:
        return 0

proc Attach*(target: EventTarget, eh: EventHandler,
            mask: uint32 = HANDLE_ALL): SCDOM_RESULT {.discardable.} =
    when EventTarget is HWINDOW:
        return SciterWindowAttachEventHandler(target, element_proc, eh, mask)
    elif EventTarget is HELEMENT:
        return SciterAttachEventHandler(target, element_proc, eh)

proc Detach*(target: EventTarget, eh: EventHandler,
            mask: uint32 = HANDLE_ALL): SCDOM_RESULT {.discardable.} =
    when EventTarget is HWINDOW:
        return SciterWindowDetachEventHandler(target, element_proc, eh, mask)
    elif EventTarget is HELEMENT:
        return SciterDetachEventHandler(target, element_proc, eh)

proc onClick*(target: EventTarget, 
            handler: proc():uint32): SCDOM_RESULT {.discardable.} =
    var eh = newEventHandler()
    eh.handle_event = proc(he: HELEMENT,
                           params: ptr BEHAVIOR_EVENT_PARAMS): uint =
        #echo "onClick: ", cast[BEHAVIOR_EVENTS](params.cmd)
        if params.cmd == BUTTON_CLICK:
            return handler()        
    return target.Attach(eh, HANDLE_BEHAVIOR_EVENT)

type NativeFunctor* = proc(args: seq[Value]): Value

proc defineScriptingFunction*(target: EventTarget, name: string,
                            fn: NativeFunctor): SCDOM_RESULT {.discardable.} =
    var eh = newEventHandler()
    eh.handle_scripting_call = proc(he: HELEMENT,
                                params: ptr SCRIPTING_METHOD_PARAMS): uint =
        #echo "handle_scripting_call: ", params.name
        if params.name != name:
            return 0
        var args = newSeq[Value](params.argc)
        var base = cast[uint](params.argv)
        var step = cast[uint](sizeof(Value))
        if params.argc > 0.uint32:
            for idx in 0..params.argc-1:
                var p = cast[ptr Value](base + step*uint(idx))
                args[int(idx)] = p[]
        echo "retv from fn", fn(args)
        #params.result = newValue("handle_scripting_call")
        return 1
    return target.Attach(eh, HANDLE_ALL)#  HANDLE_SCRIPTING_METHOD_CALL)

proc createBehavior*(target: LPSCN_ATTACH_BEHAVIOR,
                    fn: proc()): SCDOM_RESULT {.discardable.} =
    var eh = newEventHandler()
    eh.handle_mouse = proc (he: HELEMENT, params: ptr MOUSE_PARAMS): uint =
        var s: string
        if (params.cmd and MOUSE_CLICK) == MOUSE_CLICK:
            s = $cast[MOUSE_EVENTS](params.cmd and MOUSE_CLICK)
            if (params.cmd and SINKING.uint32) != 0:
                s = s & " SINKING"
            if (params.cmd and HANDLED.uint32) != 0:
                s = s & " HANDLED"
            echo "handle_mouse cmd: ", s, " pos: ", params.pos,
                " heTarget: ", repr params.target
        return 0 # иначе события BEHAVIOR_EVENTS не вызываются
    eh.subscription = proc(he: HELEMENT, params: var cuint): uint =
        echo "gdi draw subscription"
        #if comment then full subscription events
        params = HANDLE_DRAW or HANDLE_BEHAVIOR_EVENT or HANDLE_MOUSE
        return 1
    eh.handle_draw = proc(he: HELEMENT, params: ptr DRAW_PARAMS): uint =
        if params.cmd == DRAW_CONTENT: #return 0
            #echo "handle_draw: " #, repr params.area
            let g = gapi()
            let hgfx = params.gfx
            #if hgfx != nil: discard g.gAddRef(hgfx)
            discard g.gLineColor(hgfx, g.RGBA(15, 20, 240))
            discard g.gLineWidth(hgfx, 2.0)
            discard g.gFillColor(hgfx, g.RGBA(20, 20, 20))
            discard g.gRectangle(hgfx, POS(params.area.left), 
                                POS(params.area.top),
                                POS(params.area.right), 
                                POS(params.area.bottom))
            discard g.gFillColor(hgfx, g.RGBA(255, 15, 0))
            discard g.gRectangle(hgfx, POS(params.area.left+30),
                                POS(params.area.top+30),
                                POS(params.area.right-30), 
                                POS(params.area.bottom-30))
        #echo g.gLine(hgfx, 10, 10, 500, 60) # not valid coords
        #if hgfx != nil: discard g.gRelease(hgfx)
        return 1
    eh.handle_event = proc(he: HELEMENT,
                           params: ptr BEHAVIOR_EVENT_PARAMS): uint =
        echo "handle_event: ", cast[BEHAVIOR_EVENTS](params.cmd and 0x7FFF)
        #[if params.cmd == REQUEST_TOOLTIP:
            echo repr params
            params.he = tlp
            return 1]#
        return 0

    return target.element.Attach(eh, HANDLE_ALL)
