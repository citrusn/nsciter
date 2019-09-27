import strformat
from times import toWinTime, fromWinTime, Time

######## for value operations ##########

proc isUndefined*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_UNDEFINED

proc isBool*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_BOOL

proc isInt*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_INT

proc isFloat*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_FLOAT

proc isString*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_STRING

proc isSymbol*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_STRING and v.u == UT_STRING_SYMBOL

proc isDate*[VT: var Value | ptr Value](v:VT):bool {.inline.}  =
    return v.t == T_DATE

proc isCurrency*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_CURRENCY

proc isMap*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_MAP

proc isArray*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_ARRAY

proc isByte*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_BYTES

proc isResource*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_RESOURCE

proc isObject*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_OBJECT

proc isObjectNative*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_OBJECT and v.u == UT_OBJECT_NATIVE

proc isObjectArray*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_OBJECT and v.u == UT_OBJECT_ARRAY

proc isObjectFunction*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_OBJECT and v.u == UT_OBJECT_FUNCTION

proc isObjectObject*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_OBJECT and v.u == UT_OBJECT_OBJECT

proc isObjectClass*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_OBJECT and v.u == UT_OBJECT_CLASS

proc isObjectError*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_OBJECT and v.u == UT_OBJECT_ERROR

proc isDomElement*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_DOM_OBJECT

proc isColor*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
    return v.t == T_COLOR

proc isDuration*[VT: var Value | ptr Value](v:VT):bool {.inline.} =
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

var count* = 0

proc getString*(x: var Value): string

#[proc `=destroy`(x: ptr Value) = # this destructor is invalid
    echo "=destroy ptr "
    ValueClear(x)
    x.dealloc()]#

proc `=destroy`(x: var Value) =        
    inc count, -1    
    #echo "=destroy : ", count, " ", repr x.addr
    assert ValueClear(x.addr) == HV_OK

#[proc `=`(dst: var Value; src: Value) = # создаем копию элемента
    echo "operator ="
    #ValueClear(dst.addr)
    ValueInit(dst.addr)
    ValueCopy(dst.addr, src.unsafeAddr)]#

#proc `=sink`(dst: var Value; src: Value) = # перенос данных 
    #echo "operator sink = dst: " , dst, "src: ", src
    #ValueInit(dst.addr)
#    inc count
#    ValueCopy(dst.addr, src.unsafeAddr)

# for testing only
proc newValuePtr*(): ptr Value = 
    result = cast[ptr Value](alloc0(sizeof(Value)))    
    assert ValueInit(result) == HV_OK
    return result

proc newValuePtr*(dat: string): ptr Value = 
    result = newValuePtr()
    var ws = newWideCString(dat)
    #assert ValueFromString(result, ws, ws.len.uint32, 0) == HV_OK
    assert ValueStringDataSet(result, ws, ws.len.uint32, 0) == HV_OK
    return result

proc newValuePtr*(dat: SomeSignedInt): ptr Value = 
    result = newValuePtr()    
    assert ValueIntDataSet(result, dat.int32, T_INT, 0) == HV_OK
    return result

proc newValue*(): Value =
    inc count
    #echo "newValue(): " , count #cast[int](result.addr)
    assert ValueInit(result.addr) == HV_OK

proc nullValue*(): Value =    
    #result = Value()
    result.t = T_NULL # only here, not newVal()
    #assert ValueInit(result.addr) == HV_OK

proc cloneTo*(src: var Value, dst: var Value) {.inline.} =
    assert ValueCopy(dst.addr, src.addr) == HV_OK

proc clone*(x: var Value): Value {.inline.} =
    #xDefPtr(x, v)
    result = nullValue()
    assert ValueCopy(result.addr, x.addr) == HV_OK

proc newValue*(dat: string): Value =
    #UINT SCFN( ValueStringDataSet )( VALUE* pval, LPCWSTR chars, UINT numChars, UINT units );
    var ws = newWideCString(dat)
    result = newValue()
    assert ValueStringDataSet(result.addr, ws, ws.len.uint32, 0'u32) == HV_OK

proc newValue*(dat: SomeSignedInt): Value =
    result = newValue()
    when dat is int64:
        assert ValueInt64DataSet(result.addr, dat, T_INT, 0) == HV_OK
    else:
        assert ValueIntDataSet(result.addr, dat.int32, T_INT, 0) == HV_OK

proc newValue*(dat: Time): Value =
    result = newValue()
    var s = toWinTime(dat)
    assert ValueInt64DataSet(result.addr, s, T_DATE, DT_HAS_SECONDS) == HV_OK
  
proc newValue*(dat: float64): Value =
    result = newValue()
    assert ValueFloatDataSet(result.addr, dat, T_FLOAT, 0) == HV_OK

proc newValue*(dat: bool): Value =
    result = newValue()
    if dat:
        assert ValueIntDataSet(result.addr, 1, T_BOOL, 0) == HV_OK
    else:
        assert ValueIntDataSet(result.addr, 0, T_BOOL, 0) == HV_OK

proc convertFromString*(x: var Value, s: string, 
                        how: VALUE_STRING_CVT_TYPE = CVT_SIMPLE) {.discardable.} =
    #UINT SCFN( ValueFromString )( VALUE* pval, LPCWSTR str, UINT strLength, /*VALUE_STRING_CVT_TYPE*/ UINT how );
    var ws = newWideCString(s)    
    assert ValueFromString(x.addr, cast[ptr uint16](ws), ws.len.uint32, how) == HV_OK

proc convertToString*(x: var Value, 
                    how: VALUE_STRING_CVT_TYPE = CVT_SIMPLE) {.discardable.} =
    # converts value to T_STRING inplace
    #UINT SCFN( ValueToString )( VALUE* pval, /*VALUE_STRING_CVT_TYPE*/ UINT how );
    assert ValueToString(x.addr, how) == HV_OK

proc getString*(x: var Value): string =
    #UINT SCFN( ValueStringData )( const VALUE* pval, LPCWSTR* pChars, UINT* pNumChars );
    #var xx = x
    var ws: WideCString
    var n: uint32    
    assert ValueStringData(x.addr, ws.addr, n.addr) == HV_OK
    return $(ws)

proc `$`*(v: var Value): string =
    result = fmt"({cast[VTYPE](v.t)}) "
    if  v.isString():        
        result = result & v.getString()
    elif v.isFunction() or v.isNativeFunctor() or v.isObjectFunction():
        result = result & "<functor>"
    elif v.isResource():
        result = result & "<resource>"
    else:        
        var nv: Value = v.clone()
        nv.convertToString(CVT_SIMPLE)
        result = result & nv.getString()
    return result

#proc `$`*(v: Value): string =     
#    return $v

proc `$`*(v: ptr Value): string =     
    #result = "Ptr: " & (repr cast[pointer](v)) & " " &
    return $(v[])

proc `$`*(v: ref Value): string = 
    result = "Ref to value: " & $(v[])

proc getInt64*(x: var Value): int64 =
    assert ValueInt64Data(x.unsafeAddr, result.addr) == HV_OK
    return result

proc getInt32*(x: var Value): int32 =
    assert ValueIntData(x.unsafeAddr, result.addr) == HV_OK
    return result
    
proc getInt*(x: var Value): int32 =
    #var xx = x
    result = if x.isInt: getInt32(x) else: 0

proc getBool*(x: var Value): bool =
    var i = getInt(x)
    result = if i == 0: false else: true

proc getFloat*(x: var Value): float =
    #xDefPtr(x, v)
    var f:float64
    assert ValueFloatData(x.unsafeAddr, f.addr) == HV_OK
    return float(f)

proc getBytes*(x: var Value): seq[byte] = # 
    var p:pointer
    var size:uint32
    assert ValueBinaryData(unsafeAddr x, addr p, addr size) == HV_OK
    result = newSeq[byte](size)
    copyMem(result[0].addr, p, int(size)*sizeof(byte))

proc setBytes*(x: var Value, dat: var openArray[byte]): uint32 {.discardable.} =
    var p = dat[0].addr
    var size = dat.len()*sizeof(byte)
    assert ValueBinaryDataSet(unsafeAddr x, p, uint32(size), T_BYTES, 0) == HV_OK    

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

proc enumerate*(x: var Value, cb: KeyValueCallback, param: pointer = nil) =
    #xDefPtr(x, v)
    assert ValueEnumElements(x.addr, cb, param) == HV_OK

# one list fo two iterator...
var tempList = newSeq[(ptr Value, ptr Value)]() 

var cb = proc (param: pointer; 
                pkey: ptr VALUE; pval: ptr VALUE): bool {.stdcall.} = 
    tempList.add (pkey, pval)
    return true

iterator items*(x: var Value): ptr Value =
    tempList.setLen(0)
    enumerate(x, cb)
    var i : int = 0
    while i < len(tempList):
        yield tempList[i][1]
        inc i

iterator pairs*(x: var Value): (ptr Value, ptr Value) =
    tempList.setLen(0)
    enumerate(x, cb)
    var i : int = 0
    while i < len(tempList):
        yield tempList[i]
        inc i

proc `[]`*[I: Ordinal, VT:var Value|ptr Value](x: VT; i: I): Value =
    #xDefPtr(x, v)
    result = newValue()
    assert ValueNthElementValue(x.unsafeAddr, cast[int32](i), result.addr) == HV_OK

#proc `[]=`*[I: Ordinal, VT:var Value|ptr Value](x: VT; i: I; y: VT) =
proc `[]=`*(x: var Value, i: int32, y: Value) =
    #xDefPtr(x, v)
    #xDefPtr(y, yp)
    assert ValueNthElementValueSet(x.addr, cast[int32](i), y.unsafeAddr) == HV_OK

proc `[]`*(x: var Value; name: string): Value =
    #xDefPtr(x, v)
    var key = newValue(name)
    result = newValue()
    assert ValueGetValueOfKey(x.unsafeAddr, key.addr, result.addr) == HV_OK

proc `[]=`*(x: var Value; name: string; y: Value) =
    #xDefPtr(x, v)
    #var yy = y
    var key = newValue(name)
    assert ValueSetValueToKey(x.unsafeAddr, key.addr, y.unsafeAddr) == HV_OK

## value functions calls
proc invokeWithSelf*(x: ptr Value, self: var Value, 
                    args: varargs[Value]): Value = 
    result = newValue(0)
    #var xx = x
    #var ss = self
    var clen = len(args)
    var cargs = newSeq[ptr Value](clen+1)
    #var url = newWideCString("[Native Script]")
    if clen>0:
        for i in 0..<clen:
            cargs[i] = args[i].unsafeAddr
    echo "invokeWithSelf. x:" , x[]
    assert ValueInvoke(x, self.addr, uint32(len(args)),
                       cargs[0], result.addr, nil) == HV_OK
    echo "invokeWithSelf. result: ", result
    return result

## value functions calls    
proc invoke*(x: ptr Value, args: varargs[Value]): Value =
    echo "invoke"
    var self = newValue()
    result = x.invokeWithSelf(self, args)
    echo result
    #return newValue("return from invoke")

var nfs = newSeq[NativeFunctor]()

proc pinvoke(tag: pointer;
            argc: uint32; 
            argv: ptr Value;
            retval: ptr Value) {.cdecl.} =
    #is available only when ``--threads:on`` and ``--tlsEmulation:off`` are used
    #setupForeignThreadGc()
    var i = cast[int](tag)
    var nf = nfs[i]    
    var res = nf(packArgs(argc, argv))    
    assert ValueInit(retval) == HV_OK
    assert ValueCopy(retval, res.addr) == HV_OK    

proc prelease(tag: pointer) {.cdecl.} = 
    echo "prelease tag index: ", cast[int](tag)

proc setNativeFunctor*(v: var Value, nf: NativeFunctor) = 
    nfs.add(nf)
    var tag = cast[pointer](nfs.len()-1)
    #var vv = v
    assert ValueNativeFunctorSet(v.unsafeAddr, pinvoke, prelease, tag) == HV_OK

## # sds proc for python compatible

proc callFunction*(hwnd: HWINDOW | HELEMENT, 
                  name: cstring, args: varargs[Value]): Value =  
    result = newValue()    
    var clen = len(args)
    var cargs = newSeq[ptr Value](clen)
    for i in 0..clen-1:
        cargs[i] = args[i].unsafeAddr
    when hwnd is HWINDOW:
        ## Call scripting function defined in the global namespace."""
        var ok = SciterCall(hwnd, name, uint32(clen), cargs[0],  result.addr)
        assert ok # == SCDOM_OK
        #sciter.Value.raise_from(rv, ok != False, name)
    else:
        ## Call scripting function defined in the namespace of the element (a.k.a. global function)
        var ok = SciterCallScriptingFunction(hwnd, name, cargs[0],
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
proc callMethod*(he: HELEMENT, name: cstring, args: varargs[Value]): Value = 
    result = newValue()
    var clen = len(args)
    var cargs = newSeq[ptr Value](clen)
    for i in 0..clen-1:
        cargs[i] = args[i].unsafeAddr
    var ok =  SciterCallScriptingMethod(he,  name,  cargs[0], 
                                        uint32(clen), result.addr)
    assert ok == SCDOM_OK
    #sciter.Value.raise_from(rv, ok == SCDOM_RESULT.SCDOM_OK, name)
    #self._throw_if(ok)
    return result