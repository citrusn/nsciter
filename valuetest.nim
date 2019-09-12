import os, sciter/sciter


echo "Test value function"

var cnt = 0
proc finalize(x: ref Value) =
  inc(cnt) 
  ValueClear(cast[ptr Value](x))
  #echo "=destroy ref Value"


proc newRV(): ref Value = 
  new(result, finalize)
  ValueInit(cast[ptr Value](result))
  return result

proc newRV(dat: int): ref Value = 
  result = newRV()
  ValueIntDataSet(cast[ptr Value](result), dat.int32, T_INT, 0)
  
for i in 1..10_000:
  var v = newRV()
  var p = newRV(i)  
  #echo v, p

echo "values object destroyed: ", cnt
sleep(2000)
GC_fullCollect()
echo "values object destroyed: ", cnt

when false: #ok
  var i: int8 = 100
  #var p = newValue(i)
  #echo "p.getInt: ", p.getInt()
  #echo "p as boolean: ", p.getBool()
  #var s = "a test string"
  #var sv = newValue(s)
  #var s2 = sv.getString()
  #echo s, "->", s2
  #echo s.len, "=", s2.len
  #echo "value:", p
  #echo "\t", sv # bad

# test string conversion
when false:
  echo "p: ", p
  discard p.clone()
  p.convertToString()
  echo "convertToString: ", p
  p.convertFromString("hello, world")
  echo "convertFromString: ", p
  p.convertToString()
  echo "convertToString: ", p
  
#[
#test float 
when true: #ok
  var f = 6.341
  var fv = newValue(f)
  echo "float value:", f, "\t", fv, "\t", fv.getFloat()
  
#test bytes operations
when true: #ok
  var b: seq[byte] = @[byte(1), byte(2), byte(3), byte(4)]
  echo "b: ", b
  var bv = nullValue()
  echo "bv as int: ", getInt(bv), " bv as boolean: ", getBool(p)
  setBytes(bv, b)
  echo "set bytes bv:", bv.getBytes()

# test array
when true: #ok
  var a = nullValue()
  a[3] = newValue(100) # min index is 0
  a[6] = newValue("111")
  echo "a:", a, " a[5]=", a[4] # last index is 4 , but 5
  var a4 = a[4]
  echo a4.getString()
  echo "a:", a

# test map
when true: #ok
  var o = nullValue()
  o["key"] = newValue(i)
  o["at"] = newValue(i+1)
  echo "o:", o

# test time
when true: #ok
  import times
  var dt = getTime()
  var t = newValue(dt)
  echo "DateTime: ", dt, " Value DT:", t, " Dt from value: ", t.getDate()  
]#