#!/usr/local/bin/red
Red [
]

;Toomas Vooglaid and François Jouen

;--WARNING: must be compiled with -c -e for fn function

;--------------------------Matrix (mx)--------------------------------------------------
;--mx is a special vector where matrix properties are inserted at the head of matrix
;--mType: matrix type as integer [0: Char, 1: Integer, 2: Float]
;--bitSize: bit-size as integer [8 | 16 | 32 for integer! and char!, 32 | 64 for float!]
;--mSize: matrix size as pair with m rows and n columns (e.g 3x3)
;--mData: matrix values as block transformed into vector for fast computation 
;----------------------------------------------------------------------------------------

funcs: reduce [:to-char :to-integer :to-float] ;-- a block

rcvCreateMat2: function [
"Creates rows x columns matrix"
    mType 	[integer!]
    bitSize [integer!]
    mSize 	[pair!]
    mData 	[block!]
][
    cols: mSize/x
    rows: mSize/y
    t: pick [char! integer! float!] mtype 
    v: make vector! reduce [t bitSize mdata]
    fn: pick funcs mtype
    foreach d reduce [rows cols bitSize mtype][insert v fn d]
    
    
    v
]


;--methods
rcvGetMatHeader: function [mx][b: to-block copy/part mx 4 forall b [b/1: to-integer b/1] b]
rcvGetMatData: 	 function [mx][skip mx 4]

rcvGetMatOrder:	 function [
	mx		;--matrix
	return:	[pair!]
][
	h: rcvGetMatHeader mx
	as-pair h/3 h/4
]

rcvGetCol: function [
	mx		;--matrix
	col 	[integer!]
][
	h: rcvGetMatHeader mx
	data: rcvGetMatData mx
	extract at to-block data col h/3
]

rcvGetRow: function [
	mx		;--matrix
	row 	[integer!]
][
	h: rcvGetMatHeader mx
	data: rcvGetMatData mx
	copy/part at to-block data row - 1 * h/4 + 1 h/4
]


;--tests

bc: [#"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@"]
bi: [1 2 3 4 5 6 7 8 9]
bf: [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0]

m1: rcvCreateMat2 1 8 3x3  bc
probe m1
m2: rcvCreateMat2 2 16 3x3 bi
m3: rcvCreateMat2 3 64 3x3 bf

print ["Mat Order: " rcvGetMatOrder m1]
print ["Mat header:" rcvGetMatHeader m1]
print ["Mat value :" rcvGetMatData m1]

print ["Mat Order: " rcvGetMatOrder m2]
print ["Mat header:" rcvGetMatHeader m2]
print ["Mat value :" rcvGetMatData m2]

print ["Mat Order: " rcvGetMatOrder m3]
print ["Mat header:" rcvGetMatHeader m3]
print ["Mat value :" rcvGetMatData m3]

print "Rows"
i: 1
while [i <= 3][
	print [i ": " rcvGetRow m3 i]
	i: i + 1
]

print "Columns"
i: 1
while [i <= 3][
	print [i ": " rcvGetCol m3 i]
	i: i + 1
]


