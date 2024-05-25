Red [
Title:		"Tests"
]

;blk: copy [a b c d e f]
blk: copy [1 2 3 4 5 6]
vec: make vector! [1 2 3 4 5 6]

getBlock: routine [return: [block!] /local b][
	b: as red-block! #get 'blk
	print [b " length? : " block/rs-length? b lf]
	b
]


readArray: routine [ /local array i [integer!] int [red-integer!] value tail][
	array: as red-block! #get 'blk
	print ["size: " block/rs-length? array lf]
	value: block/rs-head array
	tail: block/rs-tail array
	i: 1

	while [value < tail][
		int: as red-integer! value
		print [i ": " int " " int/value lf]
		value: value + 1
		i: i + 1
	]
]

readVector: routine [ 
	/local array i n ptr
][
	array: as red-vector! #get 'vec
	n: vector/rs-length? array
	ptr: as int-ptr! vector/rs-head array
	print ["Size " n lf]
	i: 1
	while [i <= n] [
		print [i ": " ptr/i lf]
		i: i + 1
	]
]

print ["Test Block: " getBlock]
print "Read Array " 
readArray
print "Read Array 2"
readVector blk