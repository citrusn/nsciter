# Minimalistic PySciter sample for Windows

import sciter/sciter, os

OleInitialize(nil)
let api = SAPI()


assert SciterSetOption(nil, SCITER_SET_DEBUG_MODE, 1)
assert SciterSetOption(nil, SCITER_SET_SCRIPT_RUNTIME_FEATURES,
                        ALLOW_FILE_IO or ALLOW_EVAL or ALLOW_SYSINFO or
                        ALLOW_SOCKET_IO ) # needs for conection to inspector

var dbg: DEBUG_OUTPUT_PROC = proc ( param: pointer;
                                    subsystem: uint32; ## #OUTPUT_SUBSYTEMS
                                    severity: uint32; 
                                    text: WideCString;
                                    text_length: uint32) {.stdcall.} =
    echo "subsystem: ", cast[OUTPUT_SUBSYTEMS](subsystem),
         " severity: ", cast[OUTPUT_SEVERITY](severity), 
         " len: ", text_length, " msg: ", text

SciterSetupDebugOutput(nil, nil, dbg)

var i = newValue(100)
var s = newValue("test")
echo "i: ", i, " s: ", s


var frame = SciterCreateWindow(SW_MAIN or SW_TITLEBAR or SW_CONTROLS, 
                               defaultRect, nil, nil, nil)

assert SciterSetOption(frame, SCITER_SET_DEBUG_MODE, 1)

#SciterSetCallback(frame, sciterHostCallback, nil)

echo "SciterClassName: ", SciterClassName()
echo "SciterVersion: ", VersionAsString()

assert frame.SciterLoadFile(getCurrentDir() / "minimal.htm")
frame.setTitle("mininal test")
frame.run
