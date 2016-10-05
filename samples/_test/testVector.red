Red [
Title:		"RedCV Tests"
]


;blocks and vectors access by RS Routines
; waiting for matrices


; playing with blocks

arr1: [1 2 3 4 5 6 7 8 9 10]
arr2: [512.0 255.0 127.0 64.0 32.0 16.0 8.0 4.0 2.0 1.0]

readIntArray: routine [ array [block!] /local i [integer!] int [red-integer!] value tail][
	print ["size: " block/rs-length? array lf]
	value: block/rs-head array
	tail: block/rs-tail array
	i: 1

	while [value < tail][
		int: as red-integer! value
		print [i ": " int/value lf]
		value: value + 1
		i: i + 1
	]
]


readFloatArray: routine [ array [block!] /local i [integer!] f [red-float!] value tail][
	print ["size: " block/rs-length? array lf]
	value: block/rs-head array
	tail: block/rs-tail array
    print ["value: " value lf]
    print ["Tail: " tail lf]
	i: 1
    while [value < tail][
		f: as red-float! value
		print [i ": " f " "  f/value lf]
		value: value + 1
		i: i + 1
	]
]


print ["Integer array" lf]
readIntArray arr1
print ["Float array" lf]
readFloatArray arr2 



; now playing with vectors
; a 8-bit integer vector  
v: make vector! [integer! 8 [1 2 3 4 5 6 7 8 9 10]]
;v: make vector! [integer! 8 262144];

; OK for random
;forall v [v/1: random 255]
probe v 





readIntVector: routine [ array [vector!] /local i int value tail][
	print ["size: " vector/rs-length? array lf]
	value: vector/rs-head array
	tail: vector/rs-tail array
	print ["value: " value lf]
    print ["Tail: " tail lf]
	i: 1
	while [value < tail][
		int: vector/get-value-int as int-ptr! value 1
		print [i ": " int lf]
		i: i + 1
		value: value + 1
	]
]


print ["Integer Vector" lf]
readIntVector v

