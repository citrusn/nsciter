# Native Clock sample with resource packed

import sciter/sciter, os

OleInitialize(nil)
let api = SAPI()

assert SciterSetOption(nil, SCITER_SET_SCRIPT_RUNTIME_FEATURES,
                       ALLOW_FILE_IO or ALLOW_EVAL or ALLOW_SYSINFO or
                       ALLOW_SOCKET_IO ) # needs for conection to inspector

var frame = SciterCreateWindow(SW_MAIN or SW_TITLEBAR or SW_CONTROLS, 
                               defaultRect, nil, nil, nil)

assert SciterSetOption(frame, SCITER_SET_DEBUG_MODE, 1)

#SciterSetCallback(frame, sciterHostCallback, nil)

echo "SciterVersion: ", VersionAsString()

assert frame.SciterLoadFile(getCurrentDir() / "nativeClock.htm")
frame.setTitle("Часики")
frame.run
 
