import os #, strutils
import sciter

let api = SAPI()
SciterSetOption(nil, SCITER_SET_DEBUG_MODE, 1)
SciterSetOption(nil, SCITER_SET_SCRIPT_RUNTIME_FEATURES,
                ALLOW_FILE_IO or ALLOW_SOCKET_IO or
                ALLOW_EVAL or ALLOW_SYSINFO)

var dbg: DEBUG_OUTPUT_PROC = proc(param: pointer;
                                subsystem: uint32; ## #OUTPUT_SUBSYTEMS
                                severity: uint32;
                                text: WideCString;
                                text_length: uint32) {.stdcall.} =
    echo "subsystem: ", cast[OUTPUT_SUBSYTEMS](subsystem),
         " severity: ", cast[OUTPUT_SEVERITY](severity),
         " msg: ", text
SciterSetupDebugOutput(nil, nil, dbg)


proc OnLoadData(pns: LPSCN_LOAD_DATA) =
    return
    #echo "LPSCN_LOAD_DATA: ", pns.uri, "-",
    #    cast[SciterResourceType](pns.dataType)

proc OnDataLoaded(pns: LPSCN_DATA_LOADED) =
    return
    #echo "LPSCN_DATA_LOADED: ", pns.uri, "-",
    #    cast[SciterResourceType](pns.dataType)

proc OnAttachBehavior(pnm: LPSCN_ATTACH_BEHAVIOR)

proc OnEngineDestroyed() =
    echo "Sciter Destroyed"

proc sciterHostCallback(pns: LPSCITER_CALLBACK_NOTIFICATION;
                        callbackParam: pointer): SC_LOAD_DATA_RETURN_CODES {.stdcall.} =
    # callbackParam; // we are not using callbackParam in the sample,
    # use it when you need this to be a method of some class
    if pns.code == SC_LOAD_DATA:
        OnLoadData(cast[LPSCN_LOAD_DATA](pns))
        return LOAD_OK
    if pns.code == SC_DATA_LOADED:
        OnDataLoaded(cast[LPSCN_DATA_LOADED](pns))
        return LOAD_OK
    
    if pns.code == SC_ATTACH_BEHAVIOR:
        OnAttachBehavior(cast[LPSCN_ATTACH_BEHAVIOR](pns))
        return LOAD_OK

    if pns.code == SC_ENGINE_DESTROYED:
        OnEngineDestroyed()
        return LOAD_OK

    echo "sciterHostCallback pns.code: ", pns.code
    return LOAD_OK

var wnd = SciterCreateWindow(SW_CONTROLS or SW_MAIN or SW_TITLEBAR,
                             defaultRect, nil, nil, nil)

SciterSetCallback(wnd, sciterHostCallback, nil)

assert wnd.SciterLoadFile(getCurrentDir() / "handlers.htm")

var root: HELEMENT
assert wnd.SciterGetRootElement(root.addr) == SCDOM_OK

proc nf(args: seq[ptr Value]): Value =
    echo "NativeFunction called with args:", $(args)
    return newValue("nf ok")

proc testCallback() =
    echo "gprintln set: ", wnd.defineScriptingFunction("gprintln",
        proc(args: seq[ptr Value]): Value =
            echo "gprintln call:", $(args)
            return newValue("exit gprintln")
    )
    echo "mcall set: ",
        root.defineScriptingFunction("mcall",
            proc(args: seq[ptr Value]): Value =
                echo "mcall call:", $(args)
                return newValue("exit mcall")
    )
    echo "sumall set: ",
        wnd.defineScriptingFunction("sumall",
            proc(args: seq[ptr Value]): Value =
                var sumall: int32 = 0
                for v in args:
                    var p = v[]
                    echo "sumall v:", p
                    sumall = sumall + p.getInt()
                return newValue(sumall)
    )
    echo "kkk set: ", wnd.defineScriptingFunction("kkk",
        proc (args: seq[ptr Value]): Value =
            result = nullValue()
            result["i"] = newValue(1000)
            result["str"] = newValue("a string")
            var fn = nullValue()
            fn.setNativeFunctor(nf)
            result["f"] = fn
            return result
    )
testCallback()

proc test_call() =
    #test sciter call
    var v = wnd.callFunction("gFunc", newValue("kkk"), newValue(555))
    echo "sciter call successfully:", $v

    #test method call
    v = root.callMethod("mfn", newValue("method call"), newValue(10300))
    echo "method call successfully:", $v

    #test function call
    v = root.callFunction("gFunc", newValue("function call"), newValue(10300))
    echo "function call successfully:", $v
test_call()

var fe: seq[HELEMENT]
proc findFirst(el: HELEMENT; selector: cstring): HELEMENT =        
    proc it(he: HELEMENT; param: pointer): bool {.stdcall.} =
        fe.add(he)
        return true

    fe.setLen(0)
    el.SciterSelectElements(selector, it, nil)
    if(fe.len() == 0): return nil else: return fe[0]

proc OnAttachBehavior(pnm: LPSCN_ATTACH_BEHAVIOR) =
    echo "LPSCN_ATTACH_BEHAVIOR: " , "HE:", repr pnm.element, " ", pnm.behaviorName
    if pnm.behaviorName == "gdi-drawing": 
        echo "gdi-drawing: ", pnm.createBehavior( proc() = echo "gdi-drawing behavior" )        

proc downloadURL() =
    #var url ="http://tdp-app/astue/j_security_check"
    var url = "http://httpbin.org/html" # worked throo proxy server    
    # get span#url and frame#content:
    var span = root.findFirst("#url")
    var content = root.findFirst("#content")
    var text: string
    #echo "span=", repr span , "content=" , repr content
    span.SciterGetElementTextCB(LPCWSTR2STRING, addr(text))
    echo "span text:", text
    span.SciterSetElementHtml(cast[ptr byte](url[0].addr),
                             (cuint)url.len(), SIH_REPLACE_CONTENT)
    #Request HTML data download for this element.
    content.SciterRequestElementData(url, RT_DATA_HTML, nil)
    #content.SciterGetElementTextCB(LPCWSTR2STRING, addr(text))
    #echo text

downloadURL()

wnd.run

