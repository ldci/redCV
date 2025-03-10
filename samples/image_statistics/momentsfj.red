#! /usr/local/bin/red
Red [
	Title: "Hu Invariant Moments of 2D Image"
	File: %moments.r
	Author: "Erika Pillu and ldci"
]


get-centroid: function [
	"Return the centroid of the image"
	image "image - the image matrix"
	return:	[block!]
] [
	sum-x: 0
	sum-y: 0
	sum-xy: 0
	repeat y length? image/2 [
		repeat x length? image/1 [
			sum-x: sum-x + (x * image/(y)/(x))
			sum-y: sum-y + (y * image/(y)/(x))
			sum-xy: sum-xy + image/(y)/(x)
		]
	]
	reduce [(to-integer (sum-x / sum-xy)) (to-integer (sum-y / sum-xy))]
]

get-central-moment: function [
	"Return the central moment of the image"
	image "image - the image matrix"
	p "p - the order of the moment"
	q "q - the repetition of the moment"
	return:	[number!]
] [
	centroid: get-centroid image
	moment: 0
	repeat y length? image/2 [
		repeat x length? image/1 [
			moment: moment + (((x - centroid/1) ** p) * ((y - centroid/2) ** q) * (image/(y)/(x)))
		]
	]
	moment
]

get-scale-invariant-moment: function [
	"Return the scale invariant moment of the image"
	image "image - the image matrix"
	p "p - the order of the moment"
	q "q - the repetition of the moment"
	return:	[number!]
] [
	(get-central-moment image p q) / (get-central-moment image 0 0) ** (1 + (p + q) / 2)
	
]

get-hu-moments: function [
	"Return the seven invariant Hu moments of the image"
	image "image - the image matrix"
	return:	[block!]
] [
	n20: get-scale-invariant-moment image 2 0
	n02: get-scale-invariant-moment image 0 2
	n11: get-scale-invariant-moment image 1 1
	n12: get-scale-invariant-moment image 1 2
	n21: get-scale-invariant-moment image 2 1
	n30: get-scale-invariant-moment image 3 0
	n03: get-scale-invariant-moment image 0 3
	
	hu1: n20 + n02
	hu2: (n20 - n02) ** 2 + (2 * n11) ** 2
	hu3: (n30 - 3 * n12) ** 2 + (3 * n21 - n03) ** 2
	hu4: (n30 + n12) ** 2 + (n21 + n03) ** 2
	hu5: (n30 - 3 * n12) ** 2 + (n30 + n12) * ((n30 + n12) ** 2 - 3 * (n21 + n03) ** 2) +
			(3 * n21 - n03) * (n21 + n03) * (3 * (n30 + n12) ** 2 - (n21 + n03) ** 2)
	hu6: (n20 - n02) * ((n30 + n12) ** 2 - (n21 + n03) ** 2) + 4 * n11 * (n30 + n12) * (n21 + n03)
	hu7: (3 * n21 - n03) * (n30 + n12) * ((n30 + n12) ** 2 - 3 * (n21 + n03) ** 2) -
			(n30 - 3 * n12) * (n21 + n03) * (3 * (n30 + n12) ** 2 - (n21 + n03) ** 2)
	
	reduce [ hu1 hu2 hu3 hu4 hu5 hu6 hu7 ]
]


image1: [
[0 0 1 0]
[0 1 1 0]
[0 0 1 0]
[0 0 1 0]
]

image2: [
[0 1 0 0]
[1 1 0 0]
[0 1 0 0]
[0 1 0 0]
]

image3: [
[0 0 1 0]
[1 1 1 1]
[0 0 0 0]
[0 0 0 0]
]

print ["Centroid image: " get-centroid image1 ]
print ["Central moment: " get-central-moment image1 2 2]
print ["Hu moments	  : "get-hu-moments image1
]



