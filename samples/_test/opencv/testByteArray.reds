Red/System [
	Title:		"tests"
	Author:		""
	Rights:		""
	License:        ""
	Needs:          ""
	Tabs:		4
]


#define float-ptr!        [pointer! [float!]]

; playing with arrays and pointers
; bytes

print "1: bytes array"
print newline

bs: [#"p" #"a" #"r" #"i" #"s"]

nb: size? bs ;OK pour la taille du tableau


i: 1
while [i <= nb][
    print [i ": " bs/i newline]
    i: i + 1
]


print "2: pointer to array of bytes"
print newline

sz: as int-ptr! bs
nb: sz/0

i: 1
while [i <= nb][
     print [i ": " bs/i newline]
    i: i + 1
]


print "3: pointer to bytes array"
print newline

sz2: as byte-ptr! bs

nb: sz/0

i: 1
while [i <= nb][
    print [i ": " sz2/i newline]
    i: i + 1
]
