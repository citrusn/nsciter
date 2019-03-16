import sciter, os, strutils

var s = SAPI()
SciterSetOption(nil, SCITER_SET_DEBUG_MODE, 1)
SciterSetOption(nil, SCITER_SET_SCRIPT_RUNTIME_FEATURES,
    ALLOW_FILE_IO or ALLOW_SOCKET_IO or ALLOW_EVAL or ALLOW_SYSINFO)

var dbg: DEBUG_OUTPUT_PROC = proc (param: pointer; subsystem: uint32; ## #OUTPUT_SUBSYTEMS
                severity: uint32; text: WideCString; text_length: uint32) {.stdcall.} =
    echo "subsystem: ", cast[OUTPUT_SUBSYTEMS](subsystem),
         " severity: ", cast[OUTPUT_SEVERITY](severity), 
         " msg: ", text
SciterSetupDebugOutput(nil, nil, dbg)

proc OnLoadData(pns: LPSCN_LOAD_DATA) =
    echo "LPSCN_LOAD_DATA: " , repr pns.uri
    #echo pns.uri

proc OnDataLoaded(pns: LPSCN_DATA_LOADED ) = 
    echo "LPSCN_DATA_LOADED: " , repr pns.uri
    #echo pns.uri

proc sciterHostCallback(pns: LPSCITER_CALLBACK_NOTIFICATION;
    callbackParam: pointer): uint32 {.stdcall.} =
    # callbackParam; // we are not using callbackParam in the sample,
    # use it when you need this to be a method of some class
    echo "pns.code: ", pns.code
    if pns.code == SC_LOAD_DATA:
        OnLoadData(cast[LPSCN_LOAD_DATA](pns))
        return 0
    if pns.code == SC_DATA_LOADED:
        OnDataLoaded(cast[LPSCN_DATA_LOADED](pns))
        return 0    
    return 0

var shCallBack: SciterHostCallback = sciterHostCallback

var r: Rect = Rect()
r.top = 100
r.left = 100
r.bottom = 500
r.right = 800
var wnd = SciterCreateWindow(SW_CONTROLS or SW_MAIN or SW_TITLEBAR, addr r, nil, nil, nil)
SciterSetCallback(wnd, shCallBack, nil)

echo "SciterLoadFile: ", wnd.SciterLoadFile("D:/Soft/nim-0.19.4/nsciter-master/handlers.html")
                                            
var root: HELEMENT
wnd.SciterGetRootElement(root.addr)

proc testCallback() =
    echo "gprintln set: ", wnd.defineScriptingFunction("gprintln",
            proc(args: seq[Value]): Value =
        echo "gprintln call:" , $(args)        
    )
    echo "mcall set: ", root.defineScriptingFunction("mcall",
            proc(args: seq[Value]): Value =
        echo "mcall call:" , $(args)
    )
    echo "sumall set: ", wnd.defineScriptingFunction("sumall",
            proc(args: seq[Value]): Value =
        echo "sumall call:" , $(args)
    )
    echo "kkk set: ", wnd.defineScriptingFunction("kkk",
            proc(args: seq[Value]): Value =
        echo "kkk call:" , $(args)
    )
testCallback()

wnd.run
