# matrix
Little matrix DSL for Red

Features:
* binary ops: `['+ | '- | '* | '/ | '% | '** | '>> | '<< | '>>> | 'and | 'or | 'xor | 'div | 'x | 'augment]`
* unary-matrix ops `transpose`, `rotate n`, `swap rows x1 x2`, `determinant`, `trace`, `identity`, `rref` (reduced row eschelon form), `invert` 
* `div` turns args to floats
* `x` is standard matrix multiplication op
* `*` is Hadamard multiplication op
* `X` is Kronecker's multiplication op
* `augment` appends a matrix with same number of rows
* ops with scalar args
* order of ops as usual
* parens to change priority
* set-words to catch states
```
do %matrix.red
>> matrix [2x3 [1 2 3 4 5 6]]
== [
    1 2 3 
    4 5 6
]
;### Prettify ###
>> matrix [m: 2x3 [1 2 3 444 55 666]]
== [
    1 2 3 
    444 55 666
]
>> m/pretty
┌            ┐
│   1  2   3 │
│ 444 55 666 │
└            ┘ 
;### Unary ops ###
; a) Transpose 
>> matrix [transpose 2x3 [1 2 3 4 5 6]]
== [
    1 4 
    2 5 
    3 6
]
; b) Rotate (clockwise [1 | 2 | 3] or counter-clockwise [-3 | -2 | -1]) 
>> matrix [rotate 1 2x3[1 2 3 4 5 6]]
== [
    4 1 
    5 2 
    6 3
]
>> matrix [rotate 2 2x3[1 2 3 4 5 6]]
== [
    6 5 4 
    3 2 1
]
>> matrix [rotate 3 2x3[1 2 3 4 5 6]]
== [
    3 6 
    2 5 
    1 4
]
>> matrix [rotate -1 2x3[1 2 3 4 5 6]]
== [
    3 6 
    2 5 
    1 4
]
;### Hadamard-like ops (preserving dims) ###
matrix [2x3 [1 2 3 4 5 6] + 2x3 [2 3 4 5 6 7]]
== [
    3 5 7 
    9 11 13
]
matrix [2x3 [1 2 3 4 5 6] * 2x3 [2 3 4 5 6 7]]
== [
    2 6 12 
    20 30 42
]
;Any binary op from ['+ | '- | '* | '/ | '% | '** | '>> | '<< | '>>> | 'and | 'or | 'xor | 'div] 
;### Standard product ###
matrix [2x3 [1 2 3 4 5 6] x 3x2 [2 3 4 5 6 7]]
== [
    28 34 
    64 79
]
;### Kronecker product ###
matrix [2x3 [1 2 3 4 5 6] X 3x2 [2 3 4 5 6 7]]
== [
    2 3 4 6 6 9 
    4 5 8 10 12 15 
    6 7 12 14 18 21 
    8 12 10 15 12 ...
;### Augmenting ###
>> matrix [m: 2x2[1 2 3 4] n: m augment 2x1[3 5]]
== [
    1 2 3 
    3 4 5
]
;### Reduced row eschelon form (continued from last example)
>> matrix [o: rref n]
== [
    1.0 0.0 -1.0 
    0.0 1.0 2.0
]
>> ((1 * -1) + (2 * 2)) = 3
== true
>> ((3 * -1) + (4 * 2)) = 5
== true

a: first m/split-col 3
b: second o/split-col 3
matrix [a x b]
== [
    3.0 
    5.0
]
;### Boolean logic ###
matrix [2x2 [1 0 1 1] and 2x2 [0 1 1 0]]
== [
    0 0 
    1 0
]
;### Scalar args ### NB! This doesn't work as intended after last update!
matrix [3x3 [1 2 3 2 4 5 3 6 2] * 2 - 5]
== [
    -3 -1 1 
    -1 3 5 
    1 7 -1
]
;### Prepared data ###
>> data1: [1 2 3 4 5 6]
== [1 2 3 4 5 6]
>> matrix [2x3 data1]
== [
    1 2 3 
    4 5 6
]
>> matrix [2x3 data1 x 3x3 [1 2 2 1 3 1 2 2 3]]
== [
    9 14 13 
    21 35 31
]
>> data2: object [rows: 3 cols: 2 data: [1 2 3 3 2 1]]
== make object! [
    rows: 3
    cols: 2
    data: [1 2 3 3 2 1]
]
>> matrix [2x3 data1 x data2]
== [
    13 11 
    31 29
]
;### Catching state ###
>> matrix [m: 3x3[1 2 3 4 5 6 7 8 9]]
== [
    1 2 3 
    4 5 6 
    7 8 9
]
>> probe m ; This has changed! More funcs.
make object! [
    rows: 3
    cols: 3
    data: [1 2 3 4 5 6 7 8 9]
    get-col: func [col][extract at data col cols]
    get-row: func [row][copy/part at data row - 1 * cols + 1 cols]
    get-idx: func [row col][pick data row - 1 * cols + col]
    to-float: func [][forall data [data/1: system/words/to-float data/1]]
    swap-dim: func [][c: cols cols: rows rows: c]
]
;### Pair entries ###
 matrix [2x2[1x1 1x2 2x1 2x2] x 2x2[1x2 2x1 3x2 2x3]]
== [
    4x6 4x7 
    8x6 8x7
]
;### Date entries ###
matrix [2x2[1-2-2017 1-3-2018 1-4-2017 31-5-2017] + 2x2[2 1 3 3]]
== [
    3-Feb-2017 2-Mar-2018 
    4-Apr-2017 3-Jun-2017
]
;### Different entries ###
>> matrix [2x2[1.2.3.4 1-3-2018 12:05 1%] + 2x2[2 1 60 3%]]
== [
    3.4.5.6 2-Mar-2018 
    12:06:00 4%
]
>> date: 2017-3-25 
>> matrix [2x2[1.2.0.4 1-3-2018 12:05 1%] + 2x2[191.166.1.46 date/day 55 * 60 3%]]
== [
    192.168.1.50 26-Mar-2018 
    13:00:00 4%
]
;### Determinant ###
>> matrix [determinant 2x2[1 2 3 4]]
== -2
;### Trace ###
>> matrix [trace 2x2[1 2 3 4]]
== 5
;### Identity ###
; a) Symmetric
>> matrix [identity 3x3[1 2 3 4 5 6 7 8 9]]
== [
    1 0 0 
    0 1 0 
    0 0 1
]
; b) Asymmetric
>> matrix [identity 'l 2x3[1 2 3 4 5 6]]
== [
    1 0 
    0 1
]
>> matrix [identity 'r 2x3[1 2 3 4 5 6]]
== [
    1 0 0 
    0 1 0 
    0 0 1
]
;### Reduced row eschelon form ###
>> matrix [rref 2x3[2 1 3 5 2 4]]
== [
    1.0 0.0 -2.0 
    0.0 1.0 7.0
]
;### Invert ###
>> matrix [m: 2x2[1 2 3 4] n: invert m]
== [
    -2.0 1.0 
    1.5 -0.5
]
>> matrix [x: m x n]
== [
    1.0 0.0 
    0.0 1.0
]
>> matrix [m: 3x3[2 3 4 5 2 3 4 2 1] n: invert m]
== [
    -0.1904761904761904 0.2380952380952381 0.04761904761904758 
    0.3333...
>> matrix [x: m x n]
== [
    1.0 0.0 0.0 
    2.220446049250313e-16 1.0 -2.220446049250313e-16 
   ...
>> x/pretty
┌                                                  ┐
│                   1.0 0.0                    0.0 │
│ 2.220446049250313e-16 1.0 -2.220446049250313e-16 │
│                   0.0 0.0                    1.0 │
└                                                  ┘ 
>> 0.000000000000001 > 2.220446049250313e-16
== true
;### Filling ###
>> matrix [x: 3x3[0]]
== [
    0 0 0 
    0 0 0 
    0 0 0
]
;### Sub-matrix addition ###
>> x/sub/put 1x1 2x2[1]
== [0 0 0 0]
>> x/show
== [
    1 1 0 
    1 1 0 
    0 0 0
]
;### Row rotation (poitive - right, negative - left) ###
>> x/rotate-row 1 1
...
>> x/show
== [
    0 1 1 
    1 1 0 
    0 0 0
]
;### Column rotation (positive - down, negative - up) ###
>> x/rotate-col 2 -1
...
>> x/show
== [
    0 1 1 
    1 0 0 
    0 1 0
]
; Also multi-column rotation
>> x/rotate-col [2 3] 1
...
>> x/show
== [
    0 1 0 
    1 1 1 
    0 0 0
]
; m/pretty/tight/box removes spaces from between columns and can produce eg such maze:
┌─────────────────────────────────────────┐
│ █ █   █ ██  ████████ █ █████   █  ██ ██ │
│█0 ██  ██ ██ █  █   ███ █     █     ██ ██│
│██  █ █ ██ █    ██   █  █ ████ ████   █  │
│ █  █ ██ ███████ █ █ ████ ██ ███   ██ █  │
│███ █   █  █    ██ █   █    █    █  █ █ █│
│███   █ █  █ ██    █   ██ █  ████ █   █  │
│ █ ██   █ ██ ████ ████  ██ █ █  ██ ██  ██│
│ █████  █     ███  █ █   █   █   ██████  │
│   ████ ███      █  ████ ██ ███ █  ██ ███│
│ █  ███ █████ █████ ██ ██ █  ██  █   █   │
│ ██  █    █ ███  ██   █ █  █ █ █  ██   ██│
│     █  █     █     █  █████ █  █ █ █████│
│ ██ ████ ████ █  █████ ██  █ ███  ███  ██│
│ ██ █  ███    ██ █  ██  █  ███ ███   █  █│
│ █  ██     ██ ██      █ █ █  █     █  █  │
│ ███ █ ██████ █████ █  ██ █  █ ███  █   █│
│    ██ ██  █      ██ █    █ ██   ███ ████│
│  █      █ █  ██ █ █  ██  █   ███  █ █  █│
│█  ██  █ █ █████ █ ████████████ ████     │
│███ ██   ███  █  ██    █  █    █  █████ █│
│█ █  ██ █     █ █ ████    █ ██        ██ │
│ ██████ █ ██  █  █  ███████ █████ ██ █ ██│
│ ██   █ █████ ██      █  █   █  ████ ██ █│
│  █ █      ██ █ ██  █  █ ██  █ █        █│
│  ██ █████ █  ██ ███ █ █  █ ██ █ ██  ██ █│
│   █ █  ██ ███ ██  ██  █ ██    ██ █████ █│
│█  █     ██   █ ██  █ ██   ██ █ ██   █   │
│███████    ██ ██ █ ██ █ ███ █ ██ █   █  █│
│█     █  █  █   ██ █  ███ █ █   ███ ████ │
│█ ██  ███ █   █    █     ██  ██  ██ █  █ │
│██████  ██ ██  ██ ██████ █ █   █ █  █  █ │
│   █ █ █ ██████ █  █  ██ ██ ████ ██████X█│
│██  ██ ██  ██ █ ██        ███  █   ██ █  │
│█ █      █  ███ █████ ██       █    ████ │
│█  ██  █  █  █    █ █████████ █████  ███ │
│███ ██  █  █ ██ █      █  ███ ██   █     │
│█ █  ███ █ ██ ██ █████     █     █ ████ █│
│ ████  █       ███  █ ███  █ ████   ███ █│
│ ██ █████  ██       █   █ ██    █        │
│   █  █ ██ ███  ██████  █   ██ ███  ██ ██│
│ █    █  █ ████ █  ████ ██████ █ █████   │
└─────────────────────────────────────────┘

```
