import os, sciter/sciter, strutils, strformat, times

OleInitialize(nil)
let api = SAPI()
#echo "api:", repr api
#echo "s.version:", s.version
echo "SciterClassName:", SciterClassName() # NOW IT'S WORKED !!!!
echo "SciterVersion:", toHex(int(SciterVersion(true)), 5)
echo "SciterVersion:", toHex(int(SciterVersion(false)), 5)
echo VersionAsString()

#echo HANDLE_SCRIPTING_METHOD_CALL, "->", ord(HANDLE_SCRIPTING_METHOD_CALL)
#echo 1024, "->", cast[EVENT_GROUPS](1024)
#echo "SciterCreateWindow:", repr SciterCreateWindow
#echo "s.SciterCreateWindow:", repr s.SciterCreateWindow

assert SciterSetOption(nil, SCITER_SET_SCRIPT_RUNTIME_FEATURES,
                ALLOW_FILE_IO or ALLOW_SOCKET_IO or
                ALLOW_EVAL or ALLOW_SYSINFO)

var dbg: DEBUG_OUTPUT_PROC = proc ( param: pointer;
                                    subsystem: uint32; ## #OUTPUT_SUBSYTEMS
                                    severity: uint32; 
                                    text: WideCString;
                                    text_length: uint32) {.stdcall.} =
    echo "subsystem: ", cast[OUTPUT_SUBSYTEMS](subsystem),
         " severity: ", cast[OUTPUT_SEVERITY](severity), 
         " len: ", text_length, " msg: ", text
SciterSetupDebugOutput(nil, nil, dbg)

var wnd = SciterCreateWindow(SW_CONTROLS or SW_MAIN or SW_TITLEBAR or
                            SW_RESIZEABLE, defaultRect, nil, nil, nil)
assert wnd != nil, "wnd is nil"
# for connect to Inspector
assert SciterSetOption(wnd, SCITER_SET_DEBUG_MODE, 1) 

# test load html string into Sciter
var htmlw: string="""<html> <head><title>Тестовая страница</title></head>пїЅпїЅпїЅпїЅпїЅпїЅ, hello world! </html>"""
#echo "SciterLoadHtml: " , wnd.SciterLoadHtml(htmlw[0].addr , uint32(htmlw.len), newWideCString("x:main"))
# test load html file into Sciter
#echo "SciterLoadFile: ", wnd.SciterLoadFile("./t1.htm") # for test debugger
assert wnd.SciterLoadFile(getCurrentDir() / "test.htm") # work file
#echo "SciterLoadFile: ", wnd.SciterLoadFile(getCurrentDir() / "particles-demo.html") # bad path

#wnd.run
var testInsertFn = proc(text: string; index: uint32) =
    var root: HELEMENT
    wnd.SciterGetRootElement(root.addr)
    var dv: HELEMENT
    SciterCreateElement("div", text, dv.addr)
    assert dv.SciterInsertElement(root, index) == SCDOM_OK
    var html:string = "<div> inserted div node </div>" 
    assert dv.SciterSetElementHtml(cast[ptr byte](html[0].addr), 
                                (cuint)html.len(), SIH_APPEND_AFTER_LAST) == SCDOM_OK
testInsertFn("hello, world#1", 1)
testInsertFn("hello, world#5", 8)

#wnd.setTitle("test setTitle window caption") - # windows only proc calling
wnd.onClick(proc():uint32 = 
    echo "generic click"
    return 0) # if return 1 then next proc not calling
wnd.onClick(proc():uint32 = 
    echo "generic click 2"
    return 1)

# test value function
var testFn = proc() =
    echo "Test value function"
    var i: int8 = 100
    var p = newValue(i)
    echo "p.getInt: ", p.getInt()
    echo "p as boolean: ", getBool(p)
    var s = "a test string"
    var sv = newValue(s)
    var s2 = sv.getString()
    echo s, "->", s2
    echo s.len, "=", s2.len
    echo "value:", p, "\t", sv
    var f = 6.341
    var fv = newValue(f)
    echo "float value:", f, "\t", fv, "\t", fv.getFloat()
    var b: seq[byte] = @[byte(1), byte(2), byte(3), byte(4)]
    echo "b: ", b
    var bv = nullValue()
    #echo "bv as int: ", getInt(bv), " bv as boolean: ", getBool(p)
    bv.setBytes(b)
    echo "set bytes bv:", bv.getBytes()
    var o = nullValue()
    o["key"] = newValue(i)
    echo "o:", o
    p.convertToString()
    echo "convertToString: ", p
    p.convertFromString("hello, world")
    echo "convertFromString: ", p
    p.convertToString()
    echo "convertToString: ", p
    
    var dt = getTime()
    var t = newValue(dt)
    echo "DateTime: ", dt, " Value DT:", repr t, " Dt from value: ", t.getDate()    
#testFn()

assert wnd.defineScriptingFunction("hello", 
        proc(args: seq[ptr Value]): Value =
            echo "hello:"
            echo "\targs:" , args
            #var res = newValue("native call hello is ok")
            #return res
) == SCDOM_OK

proc testCallback() =
    assert  wnd.defineScriptingFunction("cbCall", 
        proc(args: seq[ptr Value]): Value =
            echo "cbCall args:" , args #, repr args, isObject(args[0])
            var fn = args[0]
            #var res = newValue("returning from cbCall") 
            var res = fn.invoke(newValue(100), newValue("arg2"))
            echo "cb result:", res
            
            var self = newValue("string as this-self")
            res = fn.invokeWithSelf( #TODO: proverit
                                    self, 
                                    newValue(100),
                                    newValue("arg2"))
            return res
    ) == SCDOM_OK
testCallback()

proc nf(args: seq[ptr Value]): Value =
    echo "NativeFunction called", args
    var s = "NativeFunction is calling OK!"
    var r = newValue(s)
    return r

var testVptr = proc() =
    var i: int16 = 100
    var v = newValue(i)
    echo v, "\tv.isNativeFunctor():", v.isNativeFunctor()
    var vvv = newValue("ssss") 
    echo "vvv: " , vvv
    vvv.setNativeFunctor(nf)
    echo vvv, "\tvvv.isNativeFunctor():", vvv.isNativeFunctor()
#testVptr()

proc testNativeFunctor() =
    wnd.defineScriptingFunction("api",  # calling from html script
        proc(args: seq[ptr Value]): Value =
            var res = nullValue()            
            res["i"] = newValue(1000)
            res["str"] = newValue("a string")
            var fn = nullValue() # check
            fn.setNativeFunctor(nf)
            res["fn"] = fn
            return res
    )
testNativeFunctor()

proc pr(tag: pointer) {.cdecl.} = #discard
    echo "pr tag: " , cast[int](tag)

var s*: array[10, uint16] = [uint16 112,105,110,32,114,101,115,117,108,116]

proc pin(tag: pointer; 
        argc: uint32; 
        argv: ptr Value;
        retval: ptr Value) {.cdecl.} = 
    
    assert retval.ValueInit() == HV_OK        
    var res = newValue("all good")    
    assert ValueCopy(retval, res.addr) == HV_OK
    echo "pin retval: ", retval

proc defFunc*(target: HWINDOW, name: string): SCDOM_RESULT {.discardable.} =
    var eh = newEventHandler()
    eh.handle_scripting_call = proc(he: HELEMENT,
                                    params: ptr SCRIPTING_METHOD_PARAMS): uint =
        if params.name != name:
            return 0
        var res = newValuePtr()
        var tag = newValuePtr(12889)
                
        assert ValueNativeFunctorSet(res, pin, pr, tag) == HV_OK
        #var ret = invoke(res.addr)
        echo " defFunc: ", res
        params.result = res[]
        return 1
    return target.Attach(eh,  HANDLE_SCRIPTING_METHOD_CALL) 

wnd.defFunc("nf")

proc testGetElFunction() = 
    var root: HELEMENT
    var t: string = "Привет мир, hello world" # test for console code page 1251
    echo "t:", t
    wnd.SciterGetRootElement(root.addr)
    root.SciterGetElementHtmlCB(false, LPCBYTE2ASTRING, addr(t))
    echo fmt"Root html (size:{t.len})  = {t}"
    root.SciterGetElementTextCB(LPCWSTR2STRING, addr(t))
    echo fmt"Root text ({t.len}) = {t}"
#testGetElFunction()

try:
    wnd.run
finally:
    echo "End!"