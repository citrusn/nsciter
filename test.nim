import sciter, os, strutils


OleInitialize(nil)
var s = SAPI()
#echo "spi:", repr s
#echo "s.version:", s.version
echo "SciterClassName:", SciterClassName() # NOW IT'S WORKED !!!!
echo "SciterVersion:", toHex(int(SciterVersion(true)), 5)
echo "SciterVersion:", toHex(int(SciterVersion(false)), 5)

#echo "SciterCreateWindow:", repr SciterCreateWindow
#echo "s.SciterCreateWindow:", repr s.SciterCreateWindow
# to connect with Inspector
SciterSetOption(nil, SCITER_SET_DEBUG_MODE, 1)
SciterSetOption(nil, SCITER_SET_SCRIPT_RUNTIME_FEATURES,
    ALLOW_FILE_IO or ALLOW_SOCKET_IO or ALLOW_EVAL or ALLOW_SYSINFO)

var dbg: DEBUG_OUTPUT_PROC = proc (param: pointer;
    subsystem: uint32; ## #OUTPUT_SUBSYTEMS
    severity: uint32; text: WideCString;
    text_length: uint32) {.stdcall.} =
    echo "subsystem: ", cast[OUTPUT_SUBSYTEMS](subsystem),
         " severity: ", cast[OUTPUT_SEVERITY](severity), " msg: ", text
s.SciterSetupDebugOutput(nil, nil, dbg)

var r = cast[ptr Rect](alloc0(sizeof(Rect)))
r.top = 200
r.left = 500
r.bottom = 500
r.right = 800
var wnd = SciterCreateWindow(SW_CONTROLS or SW_MAIN or SW_TITLEBAR, r, nil, nil, nil)
if wnd == nil:
    quit("wnd is nil")
echo "wnd:", repr wnd

var htmlw: string = """<html> <head><title>Test Html Page</title></head> hello world! </html>"""
echo "SciterLoadHtml: " , wnd.SciterLoadHtml(htmlw[0].addr , uint32(htmlw.len), newWideCString("x:main"))
#echo "SciterLoadFile: ", wnd.SciterLoadFile("t1.html") # for test debuger
#echo "SciterLoadFile: " , wnd.SciterLoadFile("test.html")

#testInsertFn("hello, world#0" , 0)
#testInsertFn("hello, world#5" , 5)

var testInsertFn = proc(text: string; index: uint32) =
    var root: HELEMENT
    wnd.SciterGetRootElement(root.addr)
    var dv: HELEMENT
    SciterCreateElement("div", text, dv.addr)
    echo "InsertElem:", dv.SciterInsertElement(root, index)

#wnd.run
#wnd.setTitle("test") - # windows only proc calling
wnd.onClick(proc() = echo "generic click")
wnd.onClick(proc() = echo "generic click 2")
var testFn = proc() =
    var i: int8 = 100
    var p = newValue(i)
    echo "p: ", p.getInt()
    var s = "a test string"
    var sv = newValue(s)
    var s2 = sv.getString()
    echo s, "->", s2
    echo s.len, s2.len
    echo "value:", p, "\t", sv
    var f = 6.341
    var fv = newValue(f)
    echo "float value:", f, "\t", fv, "\t", fv.getFloat()
    var b: seq[byte] = @[byte(1), byte(2), byte(3), byte(4)]
    echo b
    var bv = nullValue()
    setBytes(bv.addr, b)
    echo "bv:", bv.getBytes()
    var o = nullValue()
    o["key"] = newValue(i)
    echo "o:", o
testFn()

proc nf(args: seq[Value]): Value =
    echo "NativeFunction called"
    return newValue("nf ok")

var testVptr = proc() =
    var i: int16 = 100
    var v = newValue(i)
    echo v, "\tv.isNativeFunctor():", v.isNativeFunctor()
    var vvv = newValue("ssss")
    echo "setNativeFunctor: ", vvv.setNativeFunctor(nf)
    echo vvv, "\tvvv.isNativeFunctor():", vvv.isNativeFunctor()
testVptr()

echo "dfm hello ret: ", wnd.defineScriptingFunction("hello", proc(args: seq[
        Value]): Value =
    echo "hello from script method"
    echo "args:", args
)

proc testCallback() =
    echo "dfm cbCall ret: ", wnd.defineScriptingFunction("cbCall",
            proc(args: seq[Value]): Value =
        echo "cbCall args:", args
        var fn = args[0]
        var ret = fn.invoke(newValue(100), newValue("arg2"))
        echo "cb ret:", ret
        ret = fn.invokeWithSelf(newValue("string as this"), newValue(100),
                newValue("arg2"))
    )
testCallback() 

proc testNativeFunctor() =
    echo "dfm api ret: ", wnd.defineScriptingFunction("api", proc(args: seq[Value]): Value =
        result = newValue()
        result["i"] = newValue(1000)
        result["str"] = newValue("a string")
        var fn = newValue()
        discard fn.setNativeFunctor(nf)
        result["fn"] = fn
    )
testNativeFunctor()
#echo HANDLE_SCRIPTING_METHOD_CALL, "->", ord(HANDLE_SCRIPTING_METHOD_CALL)
echo 1024, "->" , cast[EVENT_GROUPS](1024)
wnd.run

#dfgdf fhfgh fg

# test 