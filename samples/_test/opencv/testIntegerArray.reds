Red/System [
	Title:		"tests"
	Author:		""
	Rights:		""
	License:        ""
	Needs:          ""
	Tabs:		4
]


#define float-ptr!        [pointer! [float!]]


print "1: Array of integers"
print newline
s: [1 2 3 4 5 6 7 8 9 10]

n: size? s

i: 1
while [i <= n][
    print [i ": " s/i newline]
    i: i + 1
]


print "2: pointer to array of integer"
print newline

ptrs: as int-ptr! s
n: ptrs/0
i: 1

while [i <= n][
    print [i ": " s/i newline]
    i: i + 1
]

print "3: pointer to integer array"
print newline
n: ptrs/0

i: 1
while [i <= n][
    print [i ": " ptrs/i newline]
    i: i + 1
]


