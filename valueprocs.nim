#import xvalue

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

proc nullValue*(): Value =
    result = Value()
    result.t = T_NULL

proc clone*(x:Value):Value =
    #xDefPtr(x, v)
    var dst = nullValue()
    discard ValueCopy(dst.addr, x.unsafeAddr)
    return dst

proc newValue*():Value =    
    result = Value()
    discard ValueInit(addr result)    

proc newValue*(dat:string):Value =
    var ws = newWideCString(dat)
    result = newValue()    
    discard ValueStringDataSet(result.addr, ws, uint32(ws.len()), uint32(0))

proc newValue*(dat:int32):Value=
    result = newValue()
    discard ValueIntDataSet(result.addr, dat, T_INT, 0)

proc newValue*(dat:float64):Value =
    result = newValue()
    ValueFloatDataSet(result.addr, dat, T_FLOAT, 0)

proc newValue*(dat:bool):Value =
    result = newValue()
    if dat:
        discard ValueIntDataSet(result.addr, 1, T_INT, 0)
    else:
        discard ValueIntDataSet(result.addr, 0, T_INT, 0)

proc convertFromString*(x:ptr Value, s:string, how:VALUE_STRING_CVT_TYPE) =
    var ws = newWideCString(s)
    x.ValueFromString(ws, uint32(ws.len()), how)

proc convertToString*(x:ptr Value, how:VALUE_STRING_CVT_TYPE):uint32 =
    # converts value to T_STRING inplace
    x.ValueToString(how)

proc getString*(x:Value):string =
    #var xx = x
    var ws: WideCString
    var n:uint32
    discard ValueStringData(x.unsafeAddr, addr ws, addr n)
    return $(ws)

proc `$`*(v: Value):string =
    if v.isString():
        return v.getString()
    if v.isFunction() or v.isNativeFunctor() or v.isObjectFunction():
        return "<functor>"
    var nv = v.clone()
    discard convertToString(nv.addr, CVT_SIMPLE)
    return nv.getString()

proc getInt32*(x:var Value): int32 =
    discard ValueIntData(addr x, addr result)   
    
proc getInt*(x:var Value): int =
    #var xx = x       
    result = cast[int](getInt32(x))

proc getBool*(x:var Value): bool =
    var i = getInt(x)
    if i == 0:
        return false
    return true

proc getFloat*(x:Value): float =
    #xDefPtr(x, v)
    var f:float64
    ValueFloatData(x.unsafeAddr, f.addr)
    return float(f)

proc getBytes*(x:ptr Value): seq[byte] =
    var p:pointer
    var size:uint32
    ValueBinaryData(x, addr p, addr size)
    result = newSeq[byte](size)
    copyMem(result[0].addr, p, int(size)*sizeof(byte))

proc getBytes*(x:var Value): seq[byte] =
    return getBytes(x.addr)

proc setBytes*(x:ptr Value, dat: var openArray[byte]) =
    var p = dat[0].addr
    var size = dat.len()*sizeof(byte)
    discard x.ValueBinaryDataSet(p, uint32(size), T_BYTES, 0)

proc setBytes*(x:var Value, dat: var openArray[byte]) =
    setBytes(x.addr, dat)
    
# for array and object types

proc len*(x:Value): int =
    #xDefPtr(x, v)
    var n:int32 = 0
    discard ValueElementsCount(x.unsafeAddr, addr n)
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

proc `[]`*(x:var Value; name:string): Value =
    #xDefPtr(x, v)
    var key = newValue(name)
    result = nullValue()
    discard ValueGetValueOfKey(x.unsafeAddr, key.addr, result.addr)

proc `[]=`*(x:var Value; name:string; y: Value) =
    #xDefPtr(x, v)
    #var yy = y
    var key = newValue(name)
    #echo "name"
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
    ValueInvoke(x.unsafeAddr, self.unsafeAddr, uint32(len(args)), cargs[0].addr, result.addr, nil)
    
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
    discard retval.ValueInit()
    var r = nf(args)
    discard retval.ValueCopy(r.addr)

proc prelease(tag: pointer) {.stdcall.} = discard

proc setNativeFunctor*(v:var Value, nf:NativeFunctor):uint32 =
    nfs.add(nf)
    var tag = cast[pointer](nfs.len()-1)
    #var vv = v
    #echo "setNativeFunctor: " , repr v.unsafeAddr
    result = ValueNativeFunctorSet(v.unsafeAddr, pinvoke, prelease, tag)    


# sds proc for python compatible

proc call_function*(hwnd: HWINDOW, name: cstring, args:varargs[Value]): Value = 
    ## Call scripting function defined in the global namespace."""
    var rv = newValue()    
    var clen = len(args)
    var cargs = newSeq[Value](clen)
    for i in 0..clen-1:
        cargs[i] = args[i]
    var ok = SciterCall(hwnd, name, uint32(clen), cargs[0].addr,  addr rv)
    #sciter.Value.raise_from(rv, ok != False, name)
    return rv

proc call_function*(he: HELEMENT, name: cstring, args:varargs[Value]): Value = 
    ## Call scripting function defined in the namespace of the element (a.k.a. global function)
    var rv = newValue()
    var clen = len(args)
    var cargs = newSeq[Value](clen)
    for i in 0..clen-1:
        cargs[i] = args[i]
    var ok = SciterCallScriptingFunction(he, name, cargs[0].addr, uint32(clen),addr rv)
    #sciter.Value.raise_from(rv, ok == SCDOM_RESULT.SCDOM_OK, name)
    #self._throw_if(ok)
    return rv

proc call_method*(he: HELEMENT, name: cstring, args:varargs[Value]): Value = 
    ## Call scripting method defined for the element
    var rv = newValue()
    var clen = len(args)
    var cargs = newSeq[Value](clen)
    for i in 0..clen-1:
        cargs[i] = args[i]
    var ok =  SciterCallScriptingMethod(he,  name,  cargs[0].addr, uint32(clen), addr rv)
    #sciter.Value.raise_from(rv, ok == SCDOM_RESULT.SCDOM_OK, name)
    #self._throw_if(ok)
    return rv
