import times

let 
  n: DateTime = now()
  g  = getTime()

echo n , n.type
echo g , g.type
echo " ", toUnix(g).type

#[import macros, strutils

macro toLookupTable(data: static[string]): untyped =
  result = newTree(nnkBracket)
  for w in data.split(';'):
    result.add newLit(w)

const
  data = "mov;btc;cli;xor"
  opcodes = toLookupTable(data)

echo  opcodes.type]#
  

#[type
  MOUSE_EVENTSs* = enum #{.size: sizeof(uint8)} 
    MOUSE_ENTER = 0 
    MOUSE_LEAVE = 1 
    MOUSE_CLICK = 0xFF # = signed -1'i8
    DRAGGING = 0x100   # how ? size is one byte

  EVENT = object
    cmd : MOUSE_EVENTS
    c: char
    n: int16

echo "size in byte's: ", sizeof(MOUSE_EVENTS)
echo "size in byte's: ", sizeof(MOUSE_PARAMS) ]#

#echo DRAGGING , "  ", repr DRAGGING 
#echo MOUSE_CLICK , "  ", repr MOUSE_CLICK ," signed value: ",  cast[int8](MOUSE_CLICK)
#echo "size: ", sizeof(DRAGGING), " but value: ", DRAGGING.int

#var e: EVENT = EVENT(cmd:DRAGGING, c:'1', n:100)
#echo e.cmd
