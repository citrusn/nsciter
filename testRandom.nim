const
  STATES_BYTES = 7
  MULT = 0x13B # for STATES_BYTES =6 only
  MULT_LO = MULT and 255
  MULT_HI = MULT and 256


var
  state: seq[uint8] = @[
    byte 0x87, 0xdd, 0xdc, 0x35, 0xbc, 0x5c]

  c: uint16 = 0x42
  i = 0


proc rand8: uint8 =
  var
    t: uint16
    x: uint8

  x = state[i]
  t = (uint16)x * MULT_LO + c
  c = t shr 8

  if MULT_HI > 0: c = c + x
  x = (byte)t and 255
  state[i] = x
  inc i
  if i >= len(state): i = 0

  return x

echo "state.len: ", state.len
echo "MULT_LO:", MULT_LO
echo "MULT_HI:", MULT_HI

for i in 1..5:
  echo rand8()
