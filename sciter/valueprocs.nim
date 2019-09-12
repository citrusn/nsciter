import strformat
from times import toWinTime, fromWinTime, Time

######## for value operations ##########

proc isUndefined*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_UNDEFINED

proc isBool*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_BOOL

proc isInt*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_INT

proc isFloat*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_FLOAT

proc isString*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_STRING

proc isSymbol*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_STRING and v.u == UT_STRING_SYMBOL

proc isDate*[VT: Value | ptr Value](v:VT):bool {.inline.}  =
    return v.t == T_DATE

proc isCurrency*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_CURRENCY

proc isMap*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_MAP

proc isArray*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_ARRAY

proc isByte*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_BYTES

proc isObject*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_OBJECT

proc isObjectNative*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_OBJECT and v.u == UT_OBJECT_NATIVE

proc isObjectArray*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_OBJECT and v.u == UT_OBJECT_ARRAY

proc isObjectFunction*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_OBJECT and v.u == UT_OBJECT_FUNCTION

proc isObjectObject*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_OBJECT and v.u == UT_OBJECT_OBJECT

proc isObjectClass*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_OBJECT and v.u == UT_OBJECT_CLASS

proc isObjectError*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_OBJECT and v.u == UT_OBJECT_ERROR

proc isDomElement*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_DOM_OBJECT

proc isColor*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_COLOR

proc isDuration*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_DURATION

proc isAngle*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_ANGLE

proc isNull*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_NULL

proc isFunction*[VT: Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_FUNCTION

#[template xDefPtr(x, v:untyped) = #TODO
    var v:ptr Value
    when x is Value:
        #var nx = x
        v = x.unsafeAddr
    else:
        v = x]#

#proc isNativeFunctor*(x: var Value):bool =
proc isNativeFunctor*[VT: var Value | ptr Value](v: VT): bool {.inline.} =
    #xDefPtr(x, v)    
    return ValueIsNativeFunctor(v.unsafeAddr)

var count = 0

proc `=destroy`(x: var Value) =
    inc count, -1
    echo "=destroy: ", count, " ", cast[int](x.addr), " ", cast[VTYPE](x.t)    
    #ValueClear(x.addr)

proc newValueP*(): ptr Value = 
    result = cast[ptr Value](alloc0(sizeof(Value)))
    assert ValueInit(result) == HV_OK

proc newValue*(): Value =    
    inc count
    #result = Value()
    echo "newValue(): " , count #cast[int](result.addr)
    assert  ValueInit(result.addr) == HV_OK
    #return result

proc nullValue*(): Value =
    #echo "nullValue()"
    result = newValue()
    result.t = T_NULL

proc cloneTo*(src: var Value, dst: var Value) {.inline.} =
    assert ValueCopy(dst.addr, src.addr) == HV_OK

proc clone*(x: var Value): Value {.inline.} =
    #xDefPtr(x, v)
    #echo "clone"
    result = newValue()
    assert ValueCopy(result.addr, x.addr) == HV_OK
    #return result

proc newValue*(dat: string): Value =
    var ws = newWideCString(dat)
    result = newValue()        
    assert ValueStringDataSet(result.addr, ws, ws.len.uint32, 0'u32) == HV_OK

proc newValue*(dat:int8|int16|int32|int64): Value=
    result = newValue()
    when dat is int64:
        ValueInt64DataSet(result.addr, dat, T_INT, 0)   
    else:        
        ValueIntDataSet(result.addr, dat.int32, T_INT, 0)

proc newValue*(dat: Time): Value=
    result = newValue()
    var s = toWinTime(dat)
    ValueInt64DataSet(result.addr, s, T_DATE, DT_HAS_SECONDS)
  
proc newValue*(dat: float64): Value =
    result = newValue()
    ValueFloatDataSet(result.addr, dat, T_FLOAT, 0)

proc newValue*(dat: bool): Value =
    result = newValue()
    if dat:
        ValueIntDataSet(result.addr, 1, T_INT, 0)
    else:
        ValueIntDataSet(result.addr, 0, T_INT, 0)

#proc convertFromString*(x: ptr Value|var Value, s: string, 
proc convertFromString*(x: var Value, s: string, 
                        how: VALUE_STRING_CVT_TYPE = CVT_SIMPLE ):uint32 {.discardable.} =
    var ws = newWideCString(s)    
    result = ValueFromString(x.unsafeAddr, ws, uint32(ws.len()), how)
    assert result == HV_OK

proc convertToString*(x: var Value, 
                    how: VALUE_STRING_CVT_TYPE = CVT_SIMPLE):uint32 {.discardable.} =
    # converts value to T_STRING inplace
    result = ValueToString(x.unsafeAddr, how)
    assert result == HV_OK

proc getString*(x: var Value): string =
    #var xx = x
    var ws: WideCString
    var n: uint32
    ValueStringData(x.unsafeAddr, ws.addr, n.addr)
    #echo "getString(bytes) : ", n    
    return $(ws)

proc `$`*(v: Value): string = 
    echo "$ discard"

proc `$`*(v: ref Value): string = 
    result = fmt"({cast[VTYPE](v.t)}) {v.t} {v.u} {v.d} "

proc `$`*(v:var Value): string =
    result = fmt"({cast[VTYPE](v.t)}) "
    if  v.isString():        
        result = result & v.getString()
        #if v.isFunction() or v.isNativeFunctor() or v.isObjectFunction():
        #    return result & "<functor>"
    else:
        var nv:Value# = v.clone()
        #discard convertToString(nv, CVT_SIMPLE)
        result = result# & nv.getString()
    return result

proc getInt64*(x: var Value): int64 =
    assert ValueInt64Data(x.unsafeAddr, result.addr) == HV_OK
    return result

proc getInt32*(x: var Value): int32 =
    assert ValueIntData(x.unsafeAddr, result.addr) == HV_OK
    return result
    
proc getInt*(x: var Value): int =
    #var xx = x       
    result = (int)getInt32(x)

proc getBool*(x: var Value): bool =
    var i = getInt(x)
    if i == 0:
        return false
    return true

proc getFloat*(x: var Value): float =
    #xDefPtr(x, v)
    var f:float64
    ValueFloatData(x.unsafeAddr, f.addr)
    return float(f)

proc getBytes*(x: var Value): seq[byte] = # 
    var p:pointer
    var size:uint32
    ValueBinaryData(unsafeAddr x, addr p, addr size)
    result = newSeq[byte](size)
    copyMem(result[0].addr, p, int(size)*sizeof(byte))

#proc getBytes*(x: var Value): seq[byte] =
#    return getBytes(x)

proc setBytes*(x: var Value, dat: var openArray[byte]): uint32 {.discardable.} =
    var p = dat[0].addr
    var size = dat.len()*sizeof(byte)
    return ValueBinaryDataSet(unsafeAddr x, p, uint32(size), T_BYTES, 0)

proc getColor*(x: var Value): uint32 =
    assert x.isColor()
    #ValueIntData(this, (INT*)&v);
    return cast[uint32](getInt(x))
    
## returns radians if this->is_angle()
proc getAngle*(x: var Value): float32 = 
      assert x.isAngle()
      #ValueFloatData(this, &v);
      return getFloat(x)
    
## returns seconds if this->is_duration()
proc getDuration*(x: var Value): float32 =    
    assert x.isDuration()
    #ValueFloatData(this, &v)
    return getFloat(x)  

proc getDate*(x: var Value): Time = 
    var v: int64
    assert x.isDate()
    if(ValueInt64Data(x.unsafeAddr, v.addr) == HV_OK): 
        return fromWinTime(v)
    else:
        return fromWinTime(0)
    
## for array and object types
proc len*(x: var Value): int32 =
    #xDefPtr(x, v)
    #var n:int32 = 0
    assert ValueElementsCount(x.unsafeAddr, result.addr) == HV_OK
    return result

proc enumerate*(x: var Value, cb: KeyValueCallback): uint32 =
    #xDefPtr(x, v)
    assert ValueEnumElements(x.unsafeAddr, cb, nil) == HV_OK

proc `[]`*[I: Ordinal, VT:var Value|ptr Value](x: VT; i: I): Value =
    #xDefPtr(x, v)
    result = newValue()
    assert ValueNthElementValue(x.unsafeAddr, cast[int32](i), result.addr) == HV_OK

#proc `[]=`*[I: Ordinal, VT:var Value|ptr Value](x: VT; i: I; y: VT) =
proc `[]=`*(x: var Value, i: int32, y: Value) =
    #xDefPtr(x, v)
    #xDefPtr(y, yp)
    assert ValueNthElementValueSet(x.addr, cast[int32](i), y.unsafeAddr) == HV_OK

proc `[]`*(x: var Value; name: var string): Value =
    #xDefPtr(x, v)
    var key = newValue(name)
    result = newValue()
    ValueGetValueOfKey(x.unsafeAddr, key.addr, result.addr)

proc `[]=`*(x: var Value; name: string; y: Value) =
    #xDefPtr(x, v)
    #var yy = y
    var key = newValue(name)
    assert ValueSetValueToKey(x.unsafeAddr, key.addr, y.unsafeAddr) == HV_OK

## value functions calls
proc invokeWithSelf*(x: var Value, self: var Value, 
                    args:varargs[Value]): Value = 
    result = Value()
    #var xx = x
    #var ss = self
    var clen = len(args)
    var cargs = newSeq[Value](clen)
    for i in 0..clen-1:
        cargs[i] = args[i]
    assert ValueInvoke(x.unsafeAddr, self.unsafeAddr, uint32(len(args)),
                cargs[0].addr, result.addr, nil) == HV_OK

## value functions calls    
proc invoke*(x: var Value, args:varargs[Value]): Value =
    var self = newValue()
    invokeWithSelf(x, self, args)

var nfs = newSeq[NativeFunctor]()

proc pinvoke(tag: pointer; 
             argc: uint32; 
             argv: ptr Value;
             retval: ptr Value) {.stdcall.} =
    # is available only when ``--threads:on`` and ``--tlsEmulation:off`` are used
    #setupForeignThreadGc()
    #[var i = cast[int](tag)
    var nf = nfs[i]
    var args = newSeq[Value](argc)
    var base = cast[uint](argv)
    var step = cast[uint](sizeof(Value))
    if argc > 0.uint32:
        for idx in 0..argc-1:
            var p = cast[ptr Value](base + step*uint(idx))
            args[int(idx)] = p[]

    var res = nf(args) ]#
    #gV = newValue("123.45")
    var b: seq[byte] = @[byte 1, 2]
    #res.setBytes( b )
    echo "ValueInit: ", ValueInit(retval)
    #echo retval.setBytes( b )    
    #echo "return value nf: " , res, repr res
    #retval.convertFromString("s")
    echo "retval 1 : ", retval[], "-", repr retval
    #var ws = newWideCString("t12.21")
    #echo ValueFromString(retval.addr, ws, uint32(ws.len()), 0)
    #ValueCopy(retval, gV.addr)
    #retval.convertToString()
    echo "retval 2 : ", retval[], "-", repr retval


proc prelease(tag: pointer) {.stdcall.} = discard
    #echo "prelease tag index: ", cast[int](tag)

proc setNativeFunctor*(v: var Value, nf: NativeFunctor):uint32 = 
    nfs.add(nf)
    var tag = cast[pointer](nfs.len()-1)
    #var vv = v
    result = ValueNativeFunctorSet(v.unsafeAddr, pinvoke, prelease, tag)
    assert result == HV_OK
    return result

## # sds proc for python compatible

proc callFunction*(hwnd: HWINDOW | HELEMENT, 
                  name: cstring, args:varargs[Value]): Value =  
    result = newValue()    
    var clen = len(args)
    var cargs = newSeq[Value](clen)
    for i in 0..clen-1:
        cargs[i] = args[i]
    when hwnd is HWINDOW:
        ## Call scripting function defined in the global namespace."""
        var ok = SciterCall(hwnd, name, uint32(clen), cargs[0].addr,  result.addr)
        assert ok # == SCDOM_OK
        #sciter.Value.raise_from(rv, ok != False, name)
    else:
        ## Call scripting function defined in the namespace of the element (a.k.a. global function)
        var ok = SciterCallScriptingFunction(hwnd, name, cargs[0].addr,
                                             uint32(clen), result.addr)
        assert ok == SCDOM_OK
        #sciter.Value.raise_from(rv, ok == SCDOM_RESULT.SCDOM_OK, name)
        #self._throw_if(ok)
    return result

## Call scripting function defined in the namespace of the element (a.k.a. global function)
#[proc call_function*(he: HELEMENT, name: cstring, args:varargs[Value]): Value = 
    result = newValue()
    var clen = len(args)
    var cargs = newSeq[Value](clen)
    for i in 0..clen-1:
        cargs[i] = args[i]
    var ok = SciterCallScriptingFunction(he, name, cargs[0].addr, uint32(clen),addr rv)
    assert ok == SCDOM_RESULT.SCDOM_OK
    #sciter.Value.raise_from(rv, ok == SCDOM_RESULT.SCDOM_OK, name)
    #self._throw_if(ok)
    return rv]#

## Call scripting method defined for the element
proc callMethod*(he: HELEMENT, name: cstring, args:varargs[Value]): Value = 
    result = newValue()
    var clen = len(args)
    var cargs = newSeq[Value](clen)
    for i in 0..clen-1:
        cargs[i] = args[i]
    var ok =  SciterCallScriptingMethod(he,  name,  cargs[0].addr, 
                                        uint32(clen), result.addr)
    assert ok == SCDOM_OK
    #sciter.Value.raise_from(rv, ok == SCDOM_RESULT.SCDOM_OK, name)
    #self._throw_if(ok)
    return result
