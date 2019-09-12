#[
A Sciter archive usage example.

To build it you need the `packfolder` tool from the Sciter SDK:

* convert resources from folder `res` to `res.go` via `packfolder res res.go -v resource_name -go`
* use it in your source code via `SetResourceArchive(resource_name)`

Now the resulting executable is completely stand-alone.
]#

import sciter, os, strutils

let resource_name: seq[uint8] = @[
  byte 0x53,0x41,0x72,0x00,0x0c,0x00,0x00,0x00,0x73,0x00,0xff,0xff,0x01,0x00,0xff,0xff,0x69,0x00,0xff,0xff,0x02,0x00,0xff,0xff,0x6d,0x00,0xff,0xff,0x03,0x00,0xff,0xff,0x70,0x00,0xff,0xff,0x04,0x00,0xff,0xff,0x6c,
  0x00,0xff,0xff,0x05,0x00,0xff,0xff,0x65,0x00,0xff,0xff,0x06,0x00,0xff,0xff,0x2e,0x00,0xff,0xff,0x07,0x00,0xff,0xff,0x68,0x00,0xff,0xff,0x08,0x00,0xff,0xff,0x74,0x00,0xff,0xff,0x09,0x00,0xff,0xff,0x6d,0x00,
  0xff,0xff,0x0a,0x00,0xff,0xff,0x6c,0x00,0xff,0xff,0x0b,0x00,0xff,0xff,0x00,0x00,0xff,0xff,0x01,0x00,0xff,0xff,0x01,0x00,0x00,0x00,0x78,0x00,0x00,0x00,0x0e,0x02,0x00,0x00,0xf5,0x04,0x00,0x00,0x0e,0x3c,0x68,
  0x74,0x6d,0x6c,0x3e,0x0d,0x0a,0x0d,0x0a,0x3c,0x68,0x65,0x61,0x64,0x20,0x09,0x00,0x20,0x20,0x00,0x13,0x3c,0x74,0x69,0x74,0x6c,0x65,0x3e,0x61,0x6e,0x67,0x6c,0x65,0x73,0x20,0x64,0x65,0x6d,0x6f,0x3c,0x2f,0x80,
  0x12,0xa0,0x1f,0x02,0x73,0x74,0x79,0xe0,0x00,0x0c,0x12,0x23,0x67,0x72,0x61,0x64,0x69,0x65,0x6e,0x74,0x2d,0x72,0x6f,0x74,0x61,0x74,0x65,0x64,0x20,0x7b,0x80,0x18,0x40,0x00,0x12,0x70,0x6f,0x73,0x69,0x74,0x69,
  0x6f,0x6e,0x3a,0x20,0x61,0x62,0x73,0x6f,0x6c,0x75,0x74,0x65,0x3b,0xe0,0x01,0x1c,0x08,0x74,0x6f,0x70,0x3a,0x20,0x34,0x30,0x70,0x78,0xe0,0x02,0x13,0x03,0x6c,0x65,0x66,0x74,0xe0,0x08,0x14,0x08,0x77,0x69,0x64,
  0x74,0x68,0x3a,0x20,0x33,0x30,0xe0,0x05,0x16,0x04,0x68,0x65,0x69,0x67,0x68,0x20,0x2d,0xe0,0x07,0x17,0x12,0x62,0x61,0x63,0x6b,0x67,0x72,0x6f,0x75,0x6e,0x64,0x3a,0x20,0x6c,0x69,0x6e,0x65,0x61,0x72,0x2d,0xc0,
  0xa3,0x13,0x28,0x34,0x35,0x64,0x65,0x67,0x2c,0x20,0x72,0x65,0x64,0x2c,0x20,0x79,0x65,0x6c,0x6c,0x6f,0x77,0x29,0xe0,0x0c,0x39,0x0c,0x2d,0x69,0x6d,0x61,0x67,0x65,0x3a,0x20,0x2d,0x6d,0x6f,0x7a,0x2d,0xe0,0x07,
  0x44,0x20,0xb8,0x60,0xa8,0x01,0x20,0x2d,0xe0,0x0b,0x4e,0x0f,0x20,0x2f,0x2f,0x20,0x74,0x68,0x65,0x73,0x65,0x20,0x67,0x75,0x79,0x73,0x20,0x75,0x20,0x08,0x08,0x43,0x43,0x57,0x20,0x64,0x69,0x72,0x65,0x63,0x41,
  0x0b,0x03,0x20,0x69,0x6e,0x20,0xc0,0x4a,0x09,0x73,0x20,0x66,0x6f,0x72,0x20,0x73,0x6f,0x6d,0x65,0x20,0x43,0x04,0x61,0x73,0x6f,0x6e,0x73,0xe0,0x14,0x8c,0x05,0x77,0x65,0x62,0x6b,0x69,0x74,0xe0,0x08,0x8f,0xe0,
  0x0c,0x86,0x80,0x48,0x00,0x7d,0x80,0x06,0x80,0x05,0x00,0x23,0xe1,0x50,0xa1,0x0f,0x62,0x6f,0x72,0x64,0x65,0x72,0x3a,0x20,0x31,0x70,0x78,0x20,0x64,0x61,0x73,0x68,0x20,0x63,0x04,0x62,0x72,0x6f,0x77,0x6e,0xe0,
  0x02,0x22,0xa1,0xc4,0x02,0x34,0x32,0x34,0xe0,0x04,0x39,0xc1,0xc4,0x00,0x35,0xe0,0x05,0x50,0x04,0x74,0x72,0x61,0x6e,0x73,0x21,0x1b,0x02,0x6d,0x3a,0x20,0x80,0xb4,0x81,0xb9,0xc0,0xd6,0x40,0x00,0xe0,0x00,0x22,
  0x05,0x2d,0x6f,0x72,0x69,0x67,0x69,0x20,0xc1,0x20,0xae,0x60,0x9e,0xe0,0x02,0x24,0x61,0xbf,0xe0,0x00,0x29,0xe0,0x11,0x4c,0xc1,0x5a,0xe0,0x1b,0x2a,0xe0,0x04,0x52,0xe0,0x14,0x7c,0xe0,0x07,0x54,0xe0,0x13,0x2c,
  0xe1,0x01,0xee,0xe2,0x09,0xb5,0x40,0x2a,0xe1,0x0c,0xde,0x40,0x00,0xe0,0x01,0x38,0xe2,0x00,0x27,0x40,0xa1,0xe0,0x37,0x43,0xa0,0xbb,0xe0,0x20,0x46,0xa2,0x69,0x01,0x3c,0x2f,0xc4,0x1c,0x01,0x3c,0x2f,0xa4,0x52,
  0x20,0x0a,0x03,0x62,0x6f,0x64,0x79,0x20,0x09,0x20,0x1f,0x08,0x20,0x3c,0x64,0x69,0x76,0x20,0x69,0x64,0x3d,0xc0,0x51,0xc4,0x36,0x00,0x3e,0xc0,0x10,0xa1,0x78,0x05,0x64,0x20,0x2b,0x34,0x35,0x26,0x21,0x7b,0x02,
  0x3b,0x3c,0x2f,0x20,0x32,0xe0,0x06,0x3d,0xa0,0x23,0x04,0x3e,0x65,0x6c,0x65,0x6d,0xe0,0x13,0x33,0x01,0x3c,0x2f,0xa0,0x7a,0x40,0x0a,0x64,0xec,0x01,0x0d,0x0a
]

OleInitialize(nil)
var api = SAPI()

SciterSetOption(nil, SCITER_SET_DEBUG_MODE, 1)

SciterSetOption(nil, SCITER_SET_SCRIPT_RUNTIME_FEATURES,
                ALLOW_FILE_IO or ALLOW_EVAL or ALLOW_SYSINFO or
                ALLOW_SOCKET_IO) # needs for conection to inspector

var harc: HSARCHIVE

proc OnLoadData(params: LPSCN_LOAD_DATA): SC_LOAD_DATA_RETURN_CODES = 
  echo "LPSCN_LOAD_DATA: ", params.uri, "-",
    cast[SciterResourceType](params.dataType)
  var uri = $params.uri
  echo "uri: ", $uri
  if uri.startsWith("this://app/"):
    # load resource starting with our schema
    var url = uri[11..^1]
    var fileData = harc.GetArchiveItem(url) #echo fileData
    var len = fileData[1]
    if len > 0:
      # use loaded resource
      echo "file downloading..."
      discard params.hwnd.DataReady(url, 
                                  toopenarray(fileData[0], 0, fileData[1]-1 ))
    else:
      # failed to load
      echo "error: failed to load ", params.uri
      #  but fallback to Sciter anyway			
    return LOAD_OK
  else:
    return LOAD_OK # else don't conecting to Inspector

proc sciterHostCallback(params: LPSCITER_CALLBACK_NOTIFICATION;
                        callbackParam: pointer): SC_LOAD_DATA_RETURN_CODES {.stdcall.} =
  # callbackParam; // we are not using callbackParam in the sample,
  # use it when you need this to be a method of some class
  if params.code == SC_LOAD_DATA:
    return OnLoadData(cast[LPSCN_LOAD_DATA](params))
  #else:
  #  return LOAD_OK

var frame = SciterCreateWindow(SW_MAIN or SW_TITLEBAR or
                               SW_CONTROLS or SW_RESIZEABLE,
                               defaultRect, nil, nil, nil)

SciterSetCallback(frame, sciterHostCallback, nil)

harc = SetResourceArchive(resource_name)

#echo frame.SciterLoadFile("this://app/simple.html")
echo frame.SciterLoadFile(getCurrentDir() / "simple.html")
#frame.setTitle("Resource app's test")
echo VersionAsString()
frame.run
