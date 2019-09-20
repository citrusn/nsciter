type
  VALUE* =  object
    t*: uint32
    u*: uint32
    d*: uint64

var count: int32 = 0

proc ValueClear(x: ptr Value ) = 
  dec count
  echo "ValueClear: " , count, " addr: ", cast[int](x)

proc ValueInit(x: ptr Value ) = 
  inc count
  echo "ValueInit: " , count, " addr: ", cast[int](x)

proc ValueCopy(dst: ptr Value;  src: ptr Value) =  
  dst.t = src.t 
  dst.u = src.u
  dst.d = src.d

proc `=destroy`(x: var Value) = 
  echo "=destroy"
  ValueClear(x.addr) 

proc `=`(dst: var Value; src: Value) =
  echo "operator ="  
  ValueInit(dst.addr)
  ValueCopy(dst.addr, src.unsafeAddr)
  
proc `=sink`(dst: var Value; src: Value) =  
  echo "operator sink="  
  ValueInit(dst.addr)
  ValueCopy(dst.addr, src.unsafeAddr)
  ValueClear(src.unsafeAddr)

proc newValue*(): Value =  
  ValueInit(result.addr)

proc newValue*(dat: int): Value =    
  echo "newValue: " , dat
  ValueInit(result.addr)
  result.d = cast[uint64](dat)  
  
var v = newValue()
var v1 = newValue(121)
v = v1
echo "v:", v, " v1:" , v1
#var v2: Value
#v2 = v1
#echo "v2 ", v2 , "v1 ", v1

echo "END PROGRAMM"
