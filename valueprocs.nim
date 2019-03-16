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

<<<<<<< HEAD
#[template xDefPtr(x, v:untyped) = #TODO
=======
template xDefPtr(x, v:untyped) {.immediate.} =
>>>>>>> 78e3256c96b1c99d1d791a1385f41a5201aadf7e
    var v:ptr Value
    when x is Value:
        #var nx = x
        v = x.unsafeAddr
    else:
        v = x]#

proc isNativeFunctor*(x:Value):bool =
<<<<<<< HEAD
    #xDefPtr(x, v)    
    return ValueIsNativeFunctor(x.unsafeAddr)
=======
    xDefPtr(x, v)
    return v.ValueIsNativeFunctor()
>>>>>>> 78e3256c96b1c99d1d791a1385f41a5201aadf7e

proc nullValue*(): Value =
    result = Value()
    result.t = T_NULL

proc clone*(x:Value):Value =
<<<<<<< HEAD
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
=======
    xDefPtr(x, v)
    var dst = nullValue()
    ValueCopy(dst.addr, v)
    return dst

proc newValue*():Value =
    result = Value()
    ValueInit(result.addr)

proc newValue*(dat:string):Value =
    var ws = newWideCString(dat)
    result = newValue()
    ValueStringDataSet(result.addr, ws, uint32(ws.len()), uint32(0))

proc newValue*(dat:int32):Value=
    result = newValue()
    ValueIntDataSet(result.addr, dat, T_INT, 0)
>>>>>>> 78e3256c96b1c99d1d791a1385f41a5201aadf7e

proc newValue*(dat:float64):Value =
    result = newValue()
    ValueFloatDataSet(result.addr, dat, T_FLOAT, 0)

proc newValue*(dat:bool):Value =
    result = newValue()
    if dat:
<<<<<<< HEAD
        discard ValueIntDataSet(result.addr, 1, T_INT, 0)
    else:
        discard ValueIntDataSet(result.addr, 0, T_INT, 0)
=======
        ValueIntDataSet(result.addr, 1, T_INT, 0)
    else:
        ValueIntDataSet(result.addr, 0, T_INT, 0)
>>>>>>> 78e3256c96b1c99d1d791a1385f41a5201aadf7e

proc convertFromString*(x:ptr Value, s:string, how:VALUE_STRING_CVT_TYPE) =
    var ws = newWideCString(s)
    x.ValueFromString(ws, uint32(ws.len()), how)

proc convertToString*(x:ptr Value, how:VALUE_STRING_CVT_TYPE):uint32 =
    # converts value to T_STRING inplace
    x.ValueToString(how)

proc getString*(x:Value):string =
<<<<<<< HEAD
    #var xx = x
    var ws: WideCString
    var n:uint32
    discard ValueStringData(x.unsafeAddr, addr ws, addr n)
=======
    var xx = x
    var ws: WideCString
    var n:uint32
    ValueStringData(xx.addr, addr ws, addr n)
>>>>>>> 78e3256c96b1c99d1d791a1385f41a5201aadf7e
    return $(ws)

proc `$`*(v: Value):string =
    if v.isString():
        return v.getString()
    if v.isFunction() or v.isNativeFunctor() or v.isObjectFunction():
        return "<functor>"
    var nv = v.clone()
    discard convertToString(nv.addr, CVT_SIMPLE)
    return nv.getString()

proc getInt32*(x:ptr Value): int32 =
<<<<<<< HEAD
    discard ValueIntData(x, addr result)   
    
proc getInt*(x:Value): int =
    #var xx = x       
    result = cast[int](getInt32(x.unsafeAddr))
=======
    discard ValueIntData(x, addr result)

proc getInt*(x:Value): int =
    var xx = x
    result = cast[int](getInt32(xx.addr))
>>>>>>> 78e3256c96b1c99d1d791a1385f41a5201aadf7e

proc getBool*(x:Value): bool =
    var i = getInt(x)
    if i == 0:
        return false
    return true

proc getFloat*(x:Value): float =
<<<<<<< HEAD
    #xDefPtr(x, v)
=======
    xDefPtr(x, v)
>>>>>>> 78e3256c96b1c99d1d791a1385f41a5201aadf7e
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
<<<<<<< HEAD
    discard x.ValueBinaryDataSet(p, uint32(size), T_BYTES, 0)
=======
    x.ValueBinaryDataSet(p, uint32(size), T_BYTES, 0)
>>>>>>> 78e3256c96b1c99d1d791a1385f41a5201aadf7e

proc setBytes*(x:var Value, dat: var openArray[byte]) =
    setBytes(x.addr, dat)
    
# for array and object types

proc len*(x:Value): int =
<<<<<<< HEAD
    #xDefPtr(x, v)
=======
    xDefPtr(x, v)
>>>>>>> 78e3256c96b1c99d1d791a1385f41a5201aadf7e
    var n:int32 = 0
    discard ValueElementsCount(x.unsafeAddr, addr n)
    return int(n)

<<<<<<< HEAD
proc enumerate*(x:var Value, cb:KeyValueCallback): uint32 =
    #xDefPtr(x, v)
    ValueEnumElements(x.unsafeAddr, cb, nil)

proc `[]`*[I: Ordinal, VT:Value|Value](x:var Value; i: I): Value =
    #xDefPtr(x, v)
=======
proc enumerate*(x:Value, cb:KeyValueCallback): uint32 =
    xDefPtr(x, v)
    v.ValueEnumElements(cb, nil)

proc `[]`*[I: Ordinal, VT:Value|Value](x:Value; i: I): Value =
    xDefPtr(x, v)
>>>>>>> 78e3256c96b1c99d1d791a1385f41a5201aadf7e
    result = nullValue()
    ValueNthElementValue(x.unsafeAddr i, result)

<<<<<<< HEAD
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
=======
proc `[]=`*[I: Ordinal, VT:Value|Value](x:Value; i: I; y: VT) =
    xDefPtr(x, v)
    xDefPtr(y, yp)
    ValueNthElementValueSet(v, i, yp)

proc `[]`*(x:Value; name:string): Value =
    xDefPtr(x, v)
    var key = newValue(name)
    result = nullValue()
    v.ValueGetValueOfKey(key.addr, result.addr)

proc `[]=`*(x:Value; name:string; y: Value) =
    xDefPtr(x, v)
    var yy = y
    var key = newValue(name)
    ValueSetValueToKey(v, key.addr, yy.addr)
>>>>>>> 78e3256c96b1c99d1d791a1385f41a5201aadf7e

## value functions calls

proc invokeWithSelf*(x:Value, self:Value, args:varargs[Value]):Value =
    result = Value()
<<<<<<< HEAD
    #var xx = x
    #var ss = self
=======
    var xx = x
    var ss = self
>>>>>>> 78e3256c96b1c99d1d791a1385f41a5201aadf7e
    var clen = len(args)
    var cargs = newSeq[Value](clen)
    for i in 0..clen-1:
        cargs[i] = args[i]
<<<<<<< HEAD
    ValueInvoke(x.unsafeAddr, self.unsafeAddr, uint32(len(args)), cargs[0].addr, result.addr, nil)
=======
    ValueInvoke(xx.addr, ss.addr, uint32(len(args)), cargs[0].addr, result.addr, nil)
>>>>>>> 78e3256c96b1c99d1d791a1385f41a5201aadf7e
    
proc invoke*(x:Value, args:varargs[Value]):Value =
    var self = newValue()
    invokeWithSelf(x, self, args)

var nfs = newSeq[NativeFunctor]()

proc pinvoke(tag: pointer; 
             argc: uint32; 
             argv: ptr Value;
<<<<<<< HEAD
             retval: ptr Value) {.stdcall.} =
    var idx = cast[int](tag)
    var nf = nfs[idx]
    var args = newSeq[Value](1)
    discard retval.ValueInit()
    var r = nf(args)
    discard retval.ValueCopy(r.addr)

proc prelease(tag: pointer) {.stdcall.} =    discard

proc setNativeFunctor*(v:var Value, nf:NativeFunctor):uint32 =
    nfs.add(nf)
    var tag = cast[pointer](nfs.len()-1)
    #var vv = v
    #echo "setNativeFunctor: " , repr v.unsafeAddr
    result = ValueNativeFunctorSet(v.unsafeAddr, pinvoke, prelease, tag)    
=======
             retval: ptr Value) {.cdecl.} =
    var idx = cast[int](tag)
    var nf = nfs[idx]
    var args = newSeq[Value](1)
    retval.ValueInit()
    var r = nf(args)
    retval.ValueCopy(r.addr)

proc prelease(tag: pointer) {.cdecl.} =
    discard

proc setNativeFunctor*(v:Value, nf:NativeFunctor) =
    nfs.add(nf)
    var tag = cast[pointer](nfs.len()-1)
    var vv = v
    ValueNativeFunctorSet(vv.addr, pinvoke, prelease, tag)

>>>>>>> 78e3256c96b1c99d1d791a1385f41a5201aadf7e
