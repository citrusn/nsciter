import sciter/sciter

proc nf(args: seq[ptr Value]): Value =
    echo "NativeFunction called: ", args
    var s = "NativeFunction returned result "
    result = newValue(s)
    echo "result nf: ", result

proc nf_Ptr(args: seq[ptr Value]): ptr Value =
  echo "NativeFunction called", args
  var s = "1234'i32"
  var r = newValue(s)
  result = r.addr

proc pr(tag: pointer) {.stdcall.} = 
  echo "pr tag: " , cast[int](tag)
  #ValueClear(cast[ptr Value](tag))

proc pin(tag: pointer; argc: uint32; argv: ptr Value; retval: ptr Value) {.stdcall.} =
  echo "pin invoke", cast[int](tag)
  assert ValueInit(retval) == HV_OK    
  #var ws = newWideCString("pin result")
  #echo ValueStringDataSet(retval, ws, ws.len.uint32, 0'u32)  
  ##assert ValueIntDataSet(retval, 101202.int32, T_INT, 0) == HV_OK
  #var res = newValue("All good!")   
  var args = newSeq[ptr Value](argc)
  var base = cast[uint](argv)
  var step = cast[uint](sizeof(Value))

  if argc > 0.uint32:
      for idx in 0..<argc:
          var p = cast[ptr Value](base + step*uint(idx))
          args[int(idx)] = p  
  var res = nf(args)

  assert ValueCopy(retval, res.addr) == HV_OK
  echo "retval: ", retval[]


var res = nullValue()            
res["i"] = newValue(1000)
res["str"] = newValue("a string")
var fn = nullValue()
#discard fn.setNativeFunctor(nf)
var tag = cast[pointer](101)
assert ValueNativeFunctorSet(fn.addr, pin, pr, tag) == HV_OK
res["fn"] = fn

var f = res["fn"]
echo f, repr f

var r = invoke(f.addr, newValue(1), newValue(2), newValue("String param #1 "))
echo r.type, r
