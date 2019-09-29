# Minimalistic PySciter sample for Windows

import sciter/sciter, os

OleInitialize(nil)
discard SAPI()

assert SciterSetOption(nil, SCITER_SET_DEBUG_MODE, 1) # don't work
assert SciterSetOption(nil, SCITER_SET_SCRIPT_RUNTIME_FEATURES,
                        ALLOW_FILE_IO or ALLOW_EVAL or ALLOW_SYSINFO or
                        ALLOW_SOCKET_IO ) # needs for conection to inspector

var i = newValue(100)
var s = newValue("test")
echo "i: ", i, " s: ", s

var frame = SciterCreateWindow(SW_MAIN or SW_TITLEBAR or SW_CONTROLS, 
                               defaultRect, nil, nil, nil)

#assert SciterSetOption(frame, SCITER_SET_DEBUG_MODE, 1)

#SciterSetCallback(frame, sciterHostCallback, nil)

echo "SciterClassName: ", SciterClassName()
echo "SciterVersion: ", VersionAsString()

assert frame.SciterLoadFile(getCurrentDir() / "minimal.htm")
frame.setTitle("mininal test")
frame.run
