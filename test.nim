import os, sciter, strutils

OleInitialize(nil)
var s = SAPI()
#echo "spi:", repr s
#echo "s.version:", s.version
echo "SciterClassName:", SciterClassName() # NOW IT'S WORKED !!!!
echo "SciterVersion:", toHex(int(SciterVersion(true)), 5)
echo "SciterVersion:", toHex(int(SciterVersion(false)), 5)

#echo HANDLE_SCRIPTING_METHOD_CALL, "->", ord(HANDLE_SCRIPTING_METHOD_CALL)
#echo 1024, "->", cast[EVENT_GROUPS](1024)
#echo "SciterCreateWindow:", repr SciterCreateWindow
#echo "s.SciterCreateWindow:", repr s.SciterCreateWindow

# for connect to Inspector
SciterSetOption(nil, SCITER_SET_DEBUG_MODE, 1)
SciterSetOption(nil, SCITER_SET_SCRIPT_RUNTIME_FEATURES,
    ALLOW_FILE_IO or ALLOW_SOCKET_IO or ALLOW_EVAL or ALLOW_SYSINFO)

var dbg: DEBUG_OUTPUT_PROC = proc ( param: pointer;
                                    subsystem: uint32; ## #OUTPUT_SUBSYTEMS
                                    severity: uint32; 
                                    text: WideCString;
                                    text_length: uint32) {.stdcall.} =
    echo "subsystem: ", cast[OUTPUT_SUBSYTEMS](subsystem),
         " severity: ", cast[OUTPUT_SEVERITY](severity), " msg: ", text
s.SciterSetupDebugOutput(nil, nil, dbg)

var wnd = SciterCreateWindow(SW_CONTROLS or SW_MAIN or SW_TITLEBAR or
        SW_RESIZEABLE, defaultRectPtr, nil, nil, nil)
#var wnd = SciterCreateWindow(0, nil, nil, nil, nil)
if wnd == nil:
    quit("wnd is nil")
#echo "wnd:", repr wnd

# test load html string into Sciter
var htmlw: string="""<html> <head><title>�������� ��������</title></head>������, hello world! </html>"""
#echo "SciterLoadHtml: " , wnd.SciterLoadHtml(htmlw[0].addr , uint32(htmlw.len), newWideCString("x:main"))
# test load html file into Sciter
echo "SciterLoadFile: ", wnd.SciterLoadFile("./t1.htm") # for test debugger
echo "SciterLoadFile: ", wnd.SciterLoadFile(addFileExt(paramStr(0), ".htm")) # work file
#echo "SciterLoadFile: ", wnd.SciterLoadFile(getCurrentDir() / "particles-demo.html") # bad path

#wnd.run
var testInsertFn = proc(text: string; index: uint32) =
    var root: HELEMENT
    wnd.SciterGetRootElement(root.addr)
    var dv: HELEMENT
    SciterCreateElement("div", text, dv.addr)
    echo "InsertElem:", dv.SciterInsertElement(root, index)
    var html:string = "<div> inserted div node </div>" 
    echo dv.SciterSetElementHtml(cast[ptr byte](html[0].addr), (cuint)html.len(), SIH_APPEND_AFTER_LAST)
    #echo dv.SciterSetElementHtml(cast[ptr byte](html.addr), (cuint)html.len(), SIH_APPEND_AFTER_LAST)
testInsertFn("hello, world#1", 1)
testInsertFn("hello, world#5", 8)

#wnd.setTitle("test setTitle window caption") - # windows only proc calling
wnd.onClick(proc() = echo "generic click")
wnd.onClick(proc() = echo "generic click 2")
var testFn = proc() =
    var i: int8 = 100
    var p = newValue(i)
    echo "p: ", p.getInt()
    echo "p as boolean: ", getBool(p)
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
    echo "b: ", b
    var bv = nullValue()
    echo "bv as boolean: ", getBool(p)
    setBytes(bv.addr, b)
    echo "set bytes bv:", bv.getBytes()
    var o = nullValue()
    o["key"] = newValue(i)
    echo "o:", o
#testFn()

proc nf(args: seq[Value]): Value =
    echo "NativeFunction called"
    return newValue("nf ok")

var testVptr = proc() =
    var i: int16 = 100
    var v = newValue(i)
    echo v, "\tv.isNativeFunctor():", v.isNativeFunctor()
    var vvv = newValue("ssss") 
    echo "vvv: " , vvv
    echo "setNativeFunctor: ", vvv.setNativeFunctor(nf)
    echo vvv, "\tvvv.isNativeFunctor():", vvv.isNativeFunctor()
testVptr()

echo "dfm hello ret: ", 
    wnd.defineScriptingFunction("hello", 
        proc(args: seq[Value]): Value =
            echo "hello from sciter script method"
            echo "\targs:", args)

proc testCallback() =
    echo "dfm cbCall ret: ", 
        wnd.defineScriptingFunction("cbCall", 
            proc(args: seq[Value]): Value =
                echo "cbCall args:", args, repr args, isObject(args[0])
                var fn = args[0]
                var ret = fn.invoke(newValue(100), newValue("arg2"))
                echo "cb ret:", ret
                ret = fn.invokeWithSelf(
                    newValue("string as this"), 
                    newValue(100),
                    newValue("arg2"))
        )
testCallback()

proc testNativeFunctor() =
    wnd.defineScriptingFunction("api",  # calling from html script
        proc(args: seq[Value]): Value =
            result = newValue()
            result["i"] = newValue(1000)
            result["str"] = newValue("a string")
            var fn = newValue()
            discard fn.setNativeFunctor(nf)
            result["fn"] = fn
    )
testNativeFunctor()

proc testGetFunction() = 
    var root: HELEMENT
    var t: string = "��������, hello world" # test for console code page 1251
    echo "t:", t
    wnd.SciterGetRootElement(root.addr)
    root.SciterGetElementHtmlCB(false, LPCBYTE2ASTRING, addr(t))
    echo "Root html =" , len(t), t
    root.SciterGetElementTextCB(LPCWSTR2STRING, addr(t))
    echo "Root text =" , len(t), t
#testGetFunction()

wnd.run
