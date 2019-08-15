# Minimalistic PySciter sample for Windows

import sciter, os, strutils

OleInitialize(nil)
var s = SAPI()

SciterSetOption(nil, SCITER_SET_DEBUG_MODE, 1)
#SciterSetOption(nil, SCITER_SET_SCRIPT_RUNTIME_FEATURES, ALLOW_SYSINFO)
SciterSetOption(nil, SCITER_SET_SCRIPT_RUNTIME_FEATURES,
    ALLOW_FILE_IO or ALLOW_EVAL or ALLOW_SYSINFO or
    ALLOW_SOCKET_IO # needs for conection to inspector
)
var i = newValue(100)
echo "i:", i

#var frame = sciter.Window(ismain=True, uni_theme=True)
var frame = SciterCreateWindow(SW_MAIN or SW_TITLEBAR or SW_CONTROLS, 
                            defaultRectPtr, nil, nil, nil)

echo "SciterClassName:", SciterClassName()
echo "SciterVersion:", toHex(int(SciterVersion(true)), 5)
echo "SciterVersion:", toHex(int(SciterVersion(false)), 5)

discard frame.SciterLoadFile(getCurrentDir() / "minimal.htm")
frame.setTitle("mininal test")
frame.run
