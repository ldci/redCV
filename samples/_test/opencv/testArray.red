Red [
Title:		"OpenCV Tests"
]

#system [
  arr: [1 2 3 4 5 6 7 8 9 10]  

]

;Red Code
arr1: [1 2 3 4 5 6 7 8 9 10]
arr2: [512.0 255.0 127.0 64.0 32.0 16.0 8.0 4.0 2.0 1.0]

probe type? arr1
n: length? arr1

print [arr1 lf]
i: 1
while [i <= n][
    print [i ": " arr1/(i)]
    i: i + 1
]

; OK


; Nenad code
; OK for integer et compiler 0.5.4
readArray: routine [ array [block!] /local i [integer!] int [red-integer!] value tail][
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

; fonctionne avec le master branch >0.5.4

readFArray: routine [ array [block!] /local i [integer!] f [red-float!] value tail][
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
readArray arr1
print ["Float array" lf]
readFArray arr2 



   
