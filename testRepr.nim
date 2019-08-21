type
  MyFlag* {.size: sizeof(cint).} = enum
    A = -1
    B = 0
    C = 1
    D = 2
  MyFlags = set[MyFlag]

proc toNum(f: MyFlags): int = cast[cint](f)
proc toFlags(v: int): MyFlags = cast[MyFlags](v)

#echo toFlags(255*256*256*256-1)

echo cast[int]({A})
echo cast[int]({B})
echo cast[int]({C})
echo cast[int]({D})

echo A.int
echo B.int
echo C.int
echo D.int

assert toNum({}) == 0
assert toNum({A}) == 1
assert toNum({D}) == 8
assert toNum({A, C}) == 5
assert toFlags(0) == {}
assert toFlags(7) == {A, B, C}
#echo sizeof(MyFlag)


#[type EventTarget = string or int

proc attach(p: EventTarget): string =
  when p is string:
    result = "string"
  when p is int:
    return "int"

proc detach(p: EventTarget): string =
  when p is string:
    return "string"
  when p is int:
    return "int"

echo attach("1")
echo detach(1)
]#

#[import threadpool  
{.experimental: "parallel".}
proc useParallel() =
  parallel:
    for i in 0..1:
        spawn echo "echo in parallel"  
useParallel()
]#

#[template optMul{`*`(a, 2)}(a: int): int = {.noSideEffect.}: a+a
proc f(): int =
    echo "side effect!"
    result = 55
echo f()*2
]#

#[import threadpool
{.experimental: "parallel".}
proc useParallel() =
  parallel:
    for i in 0..4:
      spawn echo("echo in parallel")
useParallel()   

template optMul{`*`(a, 2)}(a: int{noSideEffect}): int = a+a
proc f(): int =
  echo "side effect!"
  result = 55
echo f() * 2 # not optimized ;-)
]#