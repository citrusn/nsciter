import strformat
from times import toWinTime, fromWinTime, Time

######## for value operations ##########

proc isUndefined*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_UNDEFINED

proc isBool*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_BOOL

proc isInt*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_INT

proc isFloat*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_FLOAT

proc isString*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_STRING

proc isSymbol*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_STRING and v.u == UT_STRING_SYMBOL

proc isDate*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_DATE

proc isCurrency*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_CURRENCY

proc isMap*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_MAP

proc isArray*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_ARRAY

proc isByte*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_BYTES

proc isObject*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_OBJECT

proc isObjectNative*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_OBJECT and v.u == UT_OBJECT_NATIVE

proc isObjectArray*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_OBJECT and v.u == UT_OBJECT_ARRAY

proc isObjectFunction*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_OBJECT and v.u == UT_OBJECT_FUNCTION

proc isObjectObject*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_OBJECT and v.u == UT_OBJECT_OBJECT

proc isObjectClass*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_OBJECT and v.u == UT_OBJECT_CLASS

proc isObjectError*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_OBJECT and v.u == UT_OBJECT_ERROR

proc isDomElement*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_DOM_OBJECT

proc isColor*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_COLOR

proc isDuration*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_DURATION

proc isAngle*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_ANGLE

proc isNull*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_NULL

proc isFunction*[VT: Value | ptr Value](v:VT):bool =
    return v.t == T_FUNCTION

#[template xDefPtr(x, v:untyped) = #TODO
    var v:ptr Value
    when x is Value:
        #var nx = x
        v = x.unsafeAddr
    else:
        v = x]#

proc isNativeFunctor*(x:Value):bool =
    #xDefPtr(x, v)    
    return ValueIsNativeFunctor(x.unsafeAddr)

#proc `=destroy`(x: var Value) =
#    ValueClear(x.addr)

proc nullValue*(): Value =
    result = Value()
    result.t = T_NULL

proc clone*(x: Value):Value =
    #xDefPtr(x, v)
    var dst = nullValue()
    ValueCopy(dst.addr, x.unsafeAddr)
    return dst

proc newValue*():Value =    
    result = Value()
    ValueInit(result.addr) 

proc newValue*(dat:string):Value =
    var ws = newWideCString(dat)
    result = newValue()    
    ValueStringDataSet(result.addr, ws, uint32(ws.len()), 0'u32)

proc newValue*(dat:int8|int16|int32|int64):Value=
    result = newValue()
    when dat is int64:
        ValueInt64DataSet(result.addr, dat, T_INT, 0)   
    else:        
        ValueIntDataSet(result.addr, dat.int32, T_INT, 0)

proc newValue*(dat: Time):Value=
    result = newValue()
    var s = toWinTime(dat)
    ValueInt64DataSet(result.addr, s, T_DATE, DT_HAS_SECONDS)
  
proc newValue*(dat:float64):Value =
    result = newValue()
    ValueFloatDataSet(result.addr, dat, T_FLOAT, 0)

proc newValue*(dat:bool):Value =
    result = newValue()
    if dat:
        ValueIntDataSet(result.addr, 1, T_INT, 0)
    else:
        ValueIntDataSet(result.addr, 0, T_INT, 0)

proc convertFromString*(x: var Value, s: string, 
                        how: VALUE_STRING_CVT_TYPE = CVT_SIMPLE ):uint32 {.discardable.} =
    var ws = newWideCString(s)
    return ValueFromString(x.addr, ws, uint32(ws.len()), how)

proc convertToString*(x: var Value, 
                    how: VALUE_STRING_CVT_TYPE = CVT_SIMPLE):uint32 {.discardable.} =
    # converts value to T_STRING inplace
    return ValueToString(x.addr, how)

proc getString*(x:Value):string =
    #var xx = x
    var ws: WideCString
    var n:uint32
    ValueStringData(x.unsafeAddr, ws.addr, n.addr)
    return $(ws)

proc `$`*(v: Value):string =
    result = fmt"({cast[VTYPE](v.t)}) "
    if v.isString():
        return (result & v.getString())
    if v.isFunction() or v.isNativeFunctor() or v.isObjectFunction():
        return (result & "<functor>")
    var nv = v.clone()
    discard convertToString(nv, CVT_SIMPLE)
    return result & nv.getString()

proc getInt64*(x: Value): int64 =
    ValueInt64Data(x.unsafeAddr, result.addr)
    return result

proc getInt32*(x: Value): int32 =
    ValueIntData(x.unsafeAddr, result.addr)
    return result
    
proc getInt*(x: Value): int =
    #var xx = x       
    result = (int)getInt32(x)

proc getBool*(x: Value): bool =
    var i = getInt(x)
    if i == 0:
        return false
    return true

proc getFloat*(x: Value): float =
    #xDefPtr(x, v)
    var f:float64
    ValueFloatData(x.unsafeAddr, f.addr)
    return float(f)

proc getBytes*(x:var Value): seq[byte] = # 
    var p:pointer
    var size:uint32
    ValueBinaryData(addr x, addr p, addr size)
    result = newSeq[byte](size)
    copyMem(result[0].addr, p, int(size)*sizeof(byte))

#proc getBytes*(x: var Value): seq[byte] =
#    return getBytes(x)

proc setBytes*(x:var Value, dat: var openArray[byte]) =
    var p = dat[0].addr
    var size = dat.len()*sizeof(byte)
    ValueBinaryDataSet(addr x, p, uint32(size), T_BYTES, 0)

#proc setBytes*(x: var Value, dat: var openArray[byte]) =
#    setBytes(x, dat)

proc getColor*(x: Value): uint32 =
    assert x.isColor()
    #ValueIntData(this, (INT*)&v);
    return cast[uint32](getInt(x))
    
## returns radians if this->is_angle()
proc getAngle*(x: Value): float32 = 
      assert x.isAngle()
      #ValueFloatData(this, &v);
      return getFloat(x)
    
## returns seconds if this->is_duration()
proc getDuration*(x: Value): float32 =    
    assert x.isDuration()
    #ValueFloatData(this, &v)
    return getFloat(x)  

proc getDate*(x: Value): Time = 
    var v: int64
    assert x.isDate()
    if(ValueInt64Data(x.unsafeAddr, v.addr) == HV_OK): 
        return fromWinTime(v)
    else:
        return fromWinTime(0)
    
## for array and object types
proc len*(x:Value): int =
    #xDefPtr(x, v)
    var n:int32 = 0
    ValueElementsCount(x.unsafeAddr, addr n)
    return int(n)

proc enumerate*(x:var Value, cb:KeyValueCallback): uint32 =
    #xDefPtr(x, v)
    ValueEnumElements(x.unsafeAddr, cb, nil)

proc `[]`*[I: Ordinal, VT:Value|Value](x:var Value; i: I): Value =
    #xDefPtr(x, v)
    result = nullValue()
    ValueNthElementValue(x.unsafeAddr i, result)

proc `[]=`*[I: Ordinal, VT:Value|Value](x:var Value; i: I; y: VT) =
    #xDefPtr(x, v)
    #xDefPtr(y, yp)
    ValueNthElementValueSet(x.unsafeAddr, i, y.unsafeAddr)

proc `[]`*(x: Value; name:string): Value =
    #xDefPtr(x, v)
    var key = newValue(name)
    result = nullValue()
    ValueGetValueOfKey(x.unsafeAddr, key.addr, result.addr)

proc `[]=`*(x:var Value; name:string; y: Value) =
    #xDefPtr(x, v)
    #var yy = y
    var key = newValue(name)
    ValueSetValueToKey(x.unsafeAddr, key.addr, y.unsafeAddr)

## value functions calls
proc invokeWithSelf*(x:Value, self:Value, args:varargs[Value]):Value =
    result = Value()
    #var xx = x
    #var ss = self
    var clen = len(args)
    var cargs = newSeq[Value](clen)
    for i in 0..clen-1:
        cargs[i] = args[i]
    ValueInvoke(x.unsafeAddr, self.unsafeAddr, uint32(len(args)),
                cargs[0].addr, result.addr, nil)

## value functions calls    
proc invoke*(x:Value, args:varargs[Value]):Value =
    var self = newValue()
    invokeWithSelf(x, self, args)

var nfs = newSeq[NativeFunctor]()

proc pinvoke(tag: pointer; 
             argc: uint32; 
             argv: ptr Value;
             retval: ptr Value) {.stdcall.} =
    var idx = cast[int](tag)
    var nf = nfs[idx]
    var args = newSeq[Value](1)
    retval.ValueInit()
    var r = nf(args)
    retval.ValueCopy(r.addr)

proc prelease(tag: pointer) {.stdcall.} = discard

proc setNativeFunctor*(v:var Value, nf:NativeFunctor):uint32 =
    nfs.add(nf)
    var tag = cast[pointer](nfs.len()-1)
    #var vv = v
    #echo "setNativeFunctor: " , repr v.unsafeAddr
    return ValueNativeFunctorSet(v.addr, pinvoke, prelease, tag)    

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
        assert ok
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
