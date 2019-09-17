import os, sciter/sciter


echo "Test value ref function"

var cnt = 0
proc finalize(x: ref Value) =
  inc(cnt, -1) 
  ValueClear(cast[ptr Value](x))
  #echo "=destroy ref Value"

proc newRV(): ref Value = 
  inc(cnt) 
  new(result, finalize)
  ValueInit(cast[ptr Value](result))
  return result

proc newRV(dat: int): ref Value = 
  result = newRV()
  ValueIntDataSet(cast[ptr Value](result), dat.int32, T_INT, 0)
  
for i in 1..30_000:
  var v = newRV()
  var p = newRV(i)  
  #echo v, p

echo "values object lives: ", cnt
GC_fullCollect()
echo "values object lives: ", cnt

echo "values counter: ", count