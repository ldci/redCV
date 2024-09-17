Red [
Title:		"OpenCV Tests"
]

; some tests 
; the way to access global Red variables

i: 100 ; integer
f: 0.012345 ; float
s: "Hello Red" ; string
bin: #{FFFF00FFFF00FFFF}

testint: routine [/local int][
	int: as red-integer! #get 'i
	print [int/value lf]
]


testFloat: routine [/local fl][
	fl: as red-float! #get 'f
	print [fl/value lf]
]

testStr: routine [/local st][
	st: as red-string! #get 's
	print as c-string! string/rs-head st
]


testStr2: does [
	s: "Another string"
	testStr
]


testBin: routine [/local st h][
	st: as red-binary! #get 'bin
	print [binary/rs-head st lf]
	print [binary/rs-length? st lf]
	print [st lf]
]


print ["Test Integer " testint lf]
print ["Test Float " testFloat lf]

print ["Test String " testStr lf]

print ["Test Binary " testBin lf]

print [bin lf]
;print s
;testStr2
;print lf
;print s 
print lf

print "done"
