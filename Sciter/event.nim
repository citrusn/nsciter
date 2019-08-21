type
    EventHandler* = ref EventHandlerObj
    EventHandlerObj* = object
        subscription*: proc(he: HELEMENT, event_groups: ref cuint) : uint
        handle_mouse*: proc(he: HELEMENT, params: ptr MOUSE_PARAMS): uint
        handle_key*: proc(he: HELEMENT, params: ptr KEY_PARAMS): uint
        handle_focus*: proc(he: HELEMENT, params: ptr FOCUS_PARAMS): uint
        handle_timer*: proc(he: HELEMENT, params: ptr TIMER_PARAMS): uint
        handle_size*: proc(he: HELEMENT): uint
        handle_scroll*: proc(he: HELEMENT, params: ptr SCROLL_PARAMS): uint
        handle_gesture*: proc(he: HELEMENT, params: ptr GESTURE_PARAMS): uint
        handle_draw*: proc(he: HELEMENT, params: ptr DRAW_PARAMS): uint
        handle_method_call*: proc(he: HELEMENT, params: ptr METHOD_PARAMS): uint
        handle_tiscript_call*: proc(he: HELEMENT, params: ptr TISCRIPT_METHOD_PARAMS): uint
        handle_event*: proc(he: HELEMENT, params: ptr BEHAVIOR_EVENT_PARAMS): uint
        handle_data_arrived*: proc(he: HELEMENT, params: ptr DATA_ARRIVED_PARAMS): uint
        handle_scripting_call*: proc(he: HELEMENT, params: ptr SCRIPTING_METHOD_PARAMS): uint

        detached*: proc(he: HELEMENT)
        attached*: proc(he: HELEMENT)

type
    EventTarget = HWINDOW or HELEMENT

var fn_subscription = proc(he: HELEMENT, params: ref cuint): uint = return 0
var fn_handle_mouse = proc(he: HELEMENT, params: ptr MOUSE_PARAMS): uint = return 0
var fn_handle_key = proc(he: HELEMENT, params: ptr KEY_PARAMS): uint  = return 0
var fn_handle_focus = proc(he: HELEMENT, params: ptr FOCUS_PARAMS): uint  = return 0
var fn_handle_timer = proc(he: HELEMENT, params: ptr TIMER_PARAMS): uint  = return 0
var fn_handle_size = proc(he: HELEMENT): uint  = return 0
var fn_handle_scroll = proc(he: HELEMENT, params: ptr SCROLL_PARAMS): uint  = return 0
var fn_handle_gesture = proc(he: HELEMENT, params: ptr GESTURE_PARAMS): uint  = return 0
var fn_handle_draw = proc(he: HELEMENT, params: ptr DRAW_PARAMS): uint  = return 0
var fn_handle_method_call = proc(he: HELEMENT,
                                 params: ptr METHOD_PARAMS): uint  = return 0
var fn_handle_tiscript_call = proc(he: HELEMENT, params: 
                                ptr TISCRIPT_METHOD_PARAMS): uint  = return 0
var fn_handle_event = proc(he: HELEMENT, params: 
                        ptr BEHAVIOR_EVENT_PARAMS): uint  = return 0
var fn_handle_data_arrived = proc(he: HELEMENT, params:
                                ptr DATA_ARRIVED_PARAMS): uint  = return 0
var fn_handle_scripting_call = proc(he: HELEMENT, params: 
                                    ptr SCRIPTING_METHOD_PARAMS): uint  = return 0
var fn_ttach = proc(he: HELEMENT) = discard

proc newEventHandler*(): EventHandler =
    #var eh:EventHandler = cast[EventHandler](alloc(sizeof(EventHandlerObj)))
    result = new(EventHandler)
    result.subscription = fn_subscription
    result.handle_mouse = fn_handle_mouse
    result.handle_key = fn_handle_key
    result.handle_focus = fn_handle_focus
    result.handle_timer = fn_handle_timer
    result.handle_size = fn_handle_size
    result.handle_scroll = fn_handle_scroll
    result.handle_gesture = fn_handle_gesture
    result.handle_draw = fn_handle_draw
    result.handle_method_call = fn_handle_method_call
    result.handle_tiscript_call = fn_handle_tiscript_call
    result.handle_event = fn_handle_event
    result.handle_data_arrived = fn_handle_data_arrived
    result.handle_scripting_call = fn_handle_scripting_call
    result.detached = fn_ttach
    result.attached = fn_ttach
    #return result

import tables, hashes
proc hash(x: EventHandler): Hash {.inline.} =
    return hash(addr x[])

var evct = newCountTable[EventHandler]()

proc element_proc(tag: pointer; he: HELEMENT; evtg: uint32; 
                  prms: pointer): uint {.stdcall.} =
    var pThis: EventHandler = cast[EventHandler](tag)
    #if evtg > uint32(256):
    #  debugEcho "element_proc: tag " , repr pThis , evtg , " prms:", repr prms
    #if pThis == nil: echo "pThis is nil"  return 0
    case cast[EVENT_GROUPS](evtg)
    of SUBSCRIPTIONS_REQUEST:
        var p : ref cuint
        var res = pThis.subscription(he, cast[ref cuint](prms))
        echo "SUBSCRIPTIONS_REQUEST: ", cast[EVENT_GROUPS](p)
        return res

    of HANDLE_INITIALIZATION:
        var p: ptr INITIALIZATION_PARAMS = cast[ptr INITIALIZATION_PARAMS](prms)
        if p.cmd == BEHAVIOR_DETACH:
            pThis.detached(he)
            #evct.inc(pThis, -1)
            #if evct.contains(pThis):
            #  dealloc(pThis)
        elif p.cmd == BEHAVIOR_ATTACH:
            echo "BEHAVIOR_ATTACH"
            pThis.attached(he)
            #evct.inc(pThis)
        return 1

    of HANDLE_MOUSE:
        var p: ptr MOUSE_PARAMS = cast[ptr MOUSE_PARAMS](prms)
        #echo "HANDLE_MOUSE: " , cast[MOUSE_EVENTS](p.cmd)
        return pThis.handle_mouse(he, p)

    of HANDLE_KEY:
        var p: ptr KEY_PARAMS = cast[ptr KEY_PARAMS](prms)
        return pThis.handle_key(he, p)

    of HANDLE_FOCUS:
        var p: ptr FOCUS_PARAMS = cast[ptr FOCUS_PARAMS](prms)
        return pThis.handle_focus(he, p)

    of HANDLE_DRAW:
        var p: ptr DRAW_PARAMS = cast[ptr DRAW_PARAMS](prms)
        #echo "HANDLE_DRAW: " , repr prms
        return pThis.handle_draw(he, p)

    of HANDLE_TIMER:
        var p: ptr TIMER_PARAMS = cast[ptr TIMER_PARAMS](prms)
        return pThis.handle_timer(he, p)

    of HANDLE_BEHAVIOR_EVENT:
        var p: ptr BEHAVIOR_EVENT_PARAMS = cast[ptr BEHAVIOR_EVENT_PARAMS](prms)
        echo "BEHAVIOR_EVENT_PARAMS: " , cast[BEHAVIOR_EVENTS](p.cmd)
        return pThis.handle_event(he, p)

    of HANDLE_METHOD_CALL:
        var p: ptr METHOD_PARAMS = cast[ptr METHOD_PARAMS](prms)
        #echo "HANDLE_METHOD_CALL"
        return pThis.handle_method_call(he, p)

    of HANDLE_DATA_ARRIVED:
        var p: ptr DATA_ARRIVED_PARAMS = cast[ptr DATA_ARRIVED_PARAMS](prms)
        return pThis.handle_data_arrived(he, p)

    of HANDLE_SCROLL:
        var p: ptr SCROLL_PARAMS = cast[ptr SCROLL_PARAMS](prms)
        return pThis.handle_scroll(he, p)

    of HANDLE_SIZE:
        discard pThis.handle_size(he)
        return 0

        ## # call using sciter::value's (from CSSS!)
    of HANDLE_SCRIPTING_METHOD_CALL:
        var p: ptr SCRIPTING_METHOD_PARAMS = cast[ptr SCRIPTING_METHOD_PARAMS](prms)
        echo "HANDLE_SCRIPTING_METHOD_CALL: ", p.name
        return pThis.handle_scripting_call(he, p)

        ## # call using tiscript::value's (from the script)
    of HANDLE_TISCRIPT_METHOD_CALL:
        var p: ptr TISCRIPT_METHOD_PARAMS = cast[ptr TISCRIPT_METHOD_PARAMS](prms)
        echo "HANDLE_TISCRIPT_METHOD_CALL: " , p.tag
        return pThis.handle_tiscript_call(he, p)

    of HANDLE_GESTURE:
        var p: ptr GESTURE_PARAMS = cast[ptr GESTURE_PARAMS](prms)
        return pThis.handle_gesture(he, p)

    else:
        return 0
    return 0

proc Attach*(target: EventTarget, eh: EventHandler,
            mask: uint32 = HANDLE_ALL): int32 {.discardable.} =
    when EventTarget is HWINDOW:
        result = SciterWindowAttachEventHandler(target, element_proc, addr eh[], mask)
    when EventTarget is HELEMENT:
        return SciterAttachEventHandler(target, element_proc, addr eh[])

proc Detach*(target: EventTarget, eh: EventHandler,
            mask: uint32 = HANDLE_ALL): int32 {.discardable.} =
    when EventTarget is HWINDOW:
        return SciterWindowDetachEventHandler(target, element_proc, addr eh[], mask)
    when EventTarget is HELEMENT:
        return SciterDetachEventHandler(target, element_proc, addr eh[])

proc onClick*(target: EventTarget, handler: proc()): int32 {.discardable.} =
    var eh = newEventHandler()
    eh.handle_event = proc(he: HELEMENT,
            params: ptr BEHAVIOR_EVENT_PARAMS): uint =
        if params.cmd == BUTTON_CLICK:
            handler()
        return 0
    return target.Attach(eh, HANDLE_BEHAVIOR_EVENT) #HANDLE_ALL

type
    NativeFunctor* = proc(args: seq[Value]): Value

proc defineScriptingFunction*(target: EventTarget, name: string,
        fn: NativeFunctor): int32 {.discardable.} =
        var eh = newEventHandler()
        eh.handle_scripting_call = proc(he: HELEMENT,
                params: ptr SCRIPTING_METHOD_PARAMS): uint =
            if params.name != name:
                return 0
            var args = newSeq[Value](params.argc)
            var base = cast[uint](params.argv)
            var step = cast[uint](sizeof(Value))
            if params.argc > 0.uint32:
                for idx in 0..params.argc-1:
                    var p = cast[ptr Value](base + step*uint(idx))
                    args[int(idx)] = p[]
            params.result = fn(args)
            return 1
        return target.Attach(eh, HANDLE_ALL)

proc createBehavior*(target: LPSCN_ATTACH_BEHAVIOR, fn: proc()): int32 {.discardable.} =
    var eh = newEventHandler()
    eh.handle_mouse = proc (he: HELEMENT, params: ptr MOUSE_PARAMS): uint =
        echo "handle_mouse cmd: ",  cast[MOUSE_EVENTS](params.cmd)
        if params.cmd == MOUSE_DOWN:
            echo "click at: " , params.pos
        return 1
    eh.subscription = proc(he: HELEMENT, params: ref cuint): uint =  
        echo "gdi draw subscription"
        #if comment then full subscription events
        params[] = HANDLE_DRAW or HANDLE_BEHAVIOR_EVENT #or HANDLE_MOUSE
        return 1
    eh.handle_draw = proc(he: HELEMENT, params: ptr DRAW_PARAMS): uint = 
        if params.cmd != DRAW_CONTENT: return 0
        #echo "handle_draw: " #, repr params.area
        let g = gapi()
        let hgfx = params.gfx
        #if hgfx != nil: discard g.gAddRef(hgfx)
        discard g.gLineColor(hgfx, g.RGBA(15, 20, 240))
        discard g.gLineWidth(hgfx, 2.0)
        discard g.gFillColor(hgfx, g.RGBA(20, 20, 20))
        discard g.gRectangle(hgfx, POS(params.area.left), POS(params.area.top),
                            POS(params.area.right), POS(params.area.bottom))
        discard g.gFillColor(hgfx, g.RGBA(255, 15, 0))
        discard g.gRectangle(hgfx, POS(params.area.left+30), POS(params.area.top+30),
                            POS(params.area.right-30), POS(params.area.bottom-30))
        #echo g.gLine(hgfx, 10, 10, 500, 60) # not valid coords
        #if hgfx != nil: discard g.gRelease(hgfx)
        return 1
    eh.handle_event = proc(he: HELEMENT, params: ptr BEHAVIOR_EVENT_PARAMS): uint =
        echo "handle_event: ", cast[BEHAVIOR_EVENTS](params.cmd)
        fn() #
        return 1

    return target.element.Attach(eh, HANDLE_ALL)
