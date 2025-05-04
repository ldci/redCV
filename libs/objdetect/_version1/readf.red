#! /usr/local/bin/red
Red [
	Title:   "Haar Cascade "
	Author:  "Francois Jouen"
	File: 	 %xmlCascade.red
	Needs:	 View
]

print "Reading Classifier ...."
t1: now/time/precise
stages: load %object.red

print "Generating objects ..."
n: (length? stages) - 1

print n 
i: 1
liste: copy []
s: do stages/:i
ws0: to-pair s
n: n + 1
i: 2
while [i <= n][
	s: do stages/:i
	print [pad "Stage" 1 pad form i - 1 2 " : " pad  form ((length? s/trees) / 3) 3 " filters" ]
	append liste s
	i: i + 1
]
t2: now/time/precise
print t2/3 - t1/3 * 1000 
Print "Done"



  


