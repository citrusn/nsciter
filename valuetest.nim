import os, sciter/sciter

echo "Test value function"

var i: int8 = 100
var p = newValue(i)

when false: #ok    
  var p1 = p.clone()
  echo "p: ", p, "p1: ", p1 
  echo "p.getInt: ", p.getInt()
  echo "p as boolean: ", p.getBool()    
  echo "value:", p
  echo "\t", sv # bad. static value desroyed

# test string conversion
when false:  
  var s1: string = "a test string"
  #var sv1 = newValue(s1)
  var sv: Value = nullValue()  
  var ws = newWideCString(s1)  
  echo ws.type , " ", ws.sizeof , " " , ws.len,  " ", repr $ws
  echo ValueStringDataSet(sv.addr, ws, ws.len.uint32, 0'u32)
  var s2 = sv.getString()
  echo "sv.getString(): ", s2
  var wd: WideCString
  var n: uint32    
  echo ValueStringData(sv.addr, wd.addr, n.addr)
  echo n,  wd
  echo s1, "->", s2
  echo s1.len, "=", s2.len

  p.convertToString()
  echo "convertToString: ", p
  p.convertFromString("hello, world")
  echo "convertFromString: ", p
  p.convertToString()
  echo "convertToString: ", p
  
#test float 
when false: #ok
  var f = 6.341
  var fv = newValue(f)
  echo "float value:", f, "\t", fv, "\t", fv.getFloat()
  
#test bytes operations
when false: #ok
  var b: seq[byte] = @[byte(1), byte(2), byte(3), byte(4)]
  echo "b: ", b
  var bv = nullValue()
  # echo "bv as int: ", bv.getInt() # bad parameter
  # echo " bv as boolean: ", p.getBool()# bad parameter
  setBytes(bv, b)
  echo "set bytes bv:", bv.getBytes()

# test array
when false: #ok
  var a = nullValue()
  a[0] = newValue(100) # min index is 0
  a[1] = newValue("111")
  echo "a:", a, " a[0] =", a[0]
  var a4 = a[1]
  echo a4.getString()
  echo "a:", a
  echo "test iterator's array"
  for v in a: 
    echo " v: ", v

# test map
when false: #ok
  var o = nullValue()
  o["key"] = newValue(999)
  o["at"] = newValue("home")
  echo "o:", o
  echo "test iterator's map"
  for k, v in o:
    echo "k: ", k, " v: ", v
# test time
when false: #ok
  import times
  var dt = getTime()
  var t = newValue(dt)
  echo "DateTime: ", dt, " Value DT:", t, " Dt from value: ", t.getDate()  

echo "values counter: ", count

echo 6 DivByZeroError