import dynlib, os

var api:ptr ISciterAPI = nil

proc SAPI*():ptr ISciterAPI =  
  if api != nil:
    return api
  var libhandle = loadLib(SCITER_DLL_NAME)
  echo "Load Library Sciter"
  if libhandle == nil:
    libhandle = loadLib(getCurrentDir()&"/"&SCITER_DLL_NAME)
  if libhandle == nil:
    quit "sciter runtime library not found: "&SCITER_DLL_NAME
    #return nil
  var procPtr = symAddr(libhandle, "SciterAPI")
  let p = cast[SciterAPI_ptr](procPtr)
  api = p()
  return api
  
proc gapi*():LPSciterGraphicsAPI =
  return SAPI().GetSciterGraphicsAPI()
  
proc rapi*():LPSciterRequestAPI =
  return SAPI().GetSciterRequestAPI()