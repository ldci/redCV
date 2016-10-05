#! /usr/local/bin/red
Red/System [
	Title:		"tests"
	Author:		""
	Rights:		""
	License:        ""
	Needs:          ""
	Tabs:		4
]


; pas compatible avec 0.5.4 mais avec master
print "Pointer to Array of floats"
print newline

sf: [512.0 255.0 127.0 64.0 32.0 16.0 8.0 4.0 2.0 1.0] ; basically it's a pointer
n: size? sf ; OK number of elements in array

print ["First: " sf/1 newline]  ;OK first element
print ["Last: " sf/n newline]   ;OK last element

print ["All elements" newline]
i: 1

while [i <= n][
    print [i ": " sf/i newline]
    i: i + 1
]


