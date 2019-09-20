import strformat

type
  VALUE = ref VALUEobj
  VALUEobj* = object
    t*: uint32
    u*: uint32
    d*: uint64

var count: int32 = 0

proc ValueClear(x: Value ) = 
  dec count
  echo x.d, " ValueClear: ", count, " addr: ", fmt"{cast[int](x):x}"

proc ValueInit(x: Value ) = 
  inc count
  echo "ValueInit: ", count, " addr: ", fmt"{cast[int](x):x}"

proc ValueCopy(dst: Value; src: Value) =  
  dst.t = src.t 
  dst.u = src.u
  dst.d = src.d

proc finalyze(x: Value) = 
  echo "=destroy"
  ValueClear(x) 

#[proc `=`(dst: var Value; src: Value) =
  echo "operator ="  
  ValueInit(dst)
  ValueCopy(dst, src)]#
  
#[proc `=sink`(dst: var Value; src: Value) =  
  echo "operator sink="  
  ValueInit(dst)
  ValueCopy(dst, src)
  ValueClear(src)]#

proc newValue*(): Value =  
  var res: Value
  new(res, finalyze)
  ValueInit(res)
  return res

proc newValue*(dat: int): Value =    
  echo "newValue: " , dat
  var res: Value
  new(res, finalyze)
  ValueInit(res)
  res.d = cast[uint64](dat)  
  return res
  
var v: Value# = newValue()
for i in 1 .. 10:
  v = newValue(i)
#v = v1
#echo "v:", repr v, " v1:" , repr v1
#ref v2: Value
#v2 = v1
#echo "v2 ", v2 , "v1 ", v1
#dispose(v)
#dispose(v1)
GC_fullCollect()

echo "END PROGRAMM"
