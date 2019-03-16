# Minimalistic PySciter sample for Windows

import sciter, strutils

OleInitialize(nil)
var s = SAPI()

SciterSetOption(nil, SCITER_SET_DEBUG_MODE, 1)
#SciterSetOption(nil, SCITER_SET_SCRIPT_RUNTIME_FEATURES, ALLOW_SYSINFO)
SciterSetOption(nil, SCITER_SET_SCRIPT_RUNTIME_FEATURES,
    #ALLOW_FILE_IO or ALLOW_EVAL or  ALLOW_SYSINFO
    ALLOW_SOCKET_IO # or #needs for conection to inspector
)
#sciter.runtime_features(allow_sysinfo=True)
var i = newValue(100)
echo "i:" , i

#var frame = sciter.Window(ismain=True, uni_theme=True)
var r = cast[ptr Rect](alloc0(sizeof(Rect)))
r.top = 200
r.left = 500
r.bottom = 500
r.right = 800
var frame = SciterCreateWindow(SW_MAIN or  SW_TITLEBAR or SW_CONTROLS, r, nil, nil, nil)

#echo sciter.version(True)
#echo sciter.classname())
echo "SciterClassName:", SciterClassName()
echo "SciterVersion:", toHex(int(SciterVersion(true)), 5)
echo "SciterVersion:", toHex(int(SciterVersion(false)), 5)

#frame.load_file(".\\minimal.htm")
discard frame.SciterLoadFile("minimal.htm")
#frame.set_title("mininal test")	
frame.setTitle("mininal test")
frame.run
