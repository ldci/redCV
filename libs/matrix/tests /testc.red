#!/usr/local/bin/red
Red [
]

rcvCreateMat2: function [ 
"Creates 2D matrix"
	type	[integer!]
	bitSize [integer!] 
	mSize 	[pair!]
	data	[block!]
][
	cols: mSize/x
	rows: mSize/y
	case [
		 type = 1	[t: to-word char!]
		 type = 2	[t: to-word integer!]
		 type = 3	[t: to-word float!]
	]
	v: make vector! reduce [t bitSize data]
	case [
		 type = 1	[insert v to-char rows insert v to-char cols 
		 			insert v to-char bitSize insert v to-char 0]
		 type = 2	[insert v rows insert v cols insert v bitSize insert v type]
		 type = 3	[insert v to-float rows insert v to-float cols 
		 			insert v to-float bitSize insert v to-float type]
	]
	v
]

;--tests

c:  [#"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@"]
b:  [1 2 3 4 5 6 7 8 9]
bf: [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0]

m1: rcvCreateMat2 1 8 3x3 c 	;--char
m2: rcvCreateMat2 2 16 3x3 b	;--integer
m3: rcvCreateMat2 3 64 3x3 bf 	;--float

mHeader: to-block copy/part m1 4
mData: skip m1 4
mh: copy []
foreach v mHeader [append mh to-integer v]
print ["Mat header:" mh]
print ["Mat values:" mData]

mHeader: to-block copy/part m2 4
mData: skip m2 4
print ["Mat header:" mHeader]
print ["Mat values:" mData]

mHeader: to-block copy/part m3 4
mData: skip m3 4
print ["Mat header:" mHeader]
print ["Mat values:" mData]


