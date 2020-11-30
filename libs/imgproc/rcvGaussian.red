Red [
	Title:   "Red Computer Vision: Image Processing"
	Author:  "Francois Jouen"
	File: 	 %rcvGaussian.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

; for gaussian filters kernel generation
; new function for Gaussian noise on image 

rcvGenerateNoise: routine [
"Generates Gaussian noise"
	src 	[image!]
	noise   [float!]
	t		[tuple!]
	/local
		pix	idx		[int-ptr!]  
		handle 		[integer!]
		nPixels 	[float!] 	
		n x y pos	[integer!]
		r g b w h 	[integer!]
][
	handle: 0
    pix: image/acquire-buffer src :handle 
    idx: pix
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
	nPixels: as float! (w * h) 
	nPixels: nPixels * noise 
	n: as integer! nPixels
	r: t/array1 and FFh 
	g: t/array1 and FF00h >> 8 
	b: t/array1 and 00FF0000h >> 16 
	loop n [
		x: as integer! ((as float! _random/rand) / 2147483647.0 * as float! w)
      	y: as integer! ((as float! _random/rand) / 2147483647.0 * as float! h)
      	pos: (y * w) + x
    	idx: pix + pos
		idx/Value: (255 << 24) OR (r << 16 ) OR (g << 8) OR b
	]
	image/release-buffer src handle yes	
]

rcvMakeGaussian: function [
"Creates a gaussian uneven kernel"
	kSize 	[pair!]
	sigma	[float!]
][
  gaussian: copy []
  n: kSize/x - 1 / 2
  sum: 0.0
  d: 0.0
  s2: 2.0 * power sigma 2.0
  j: negate n
  while [j <= n] [
  	i: negate n
  	while [i <= n] [
  		;(exp(-(r*r)/s))/(M_PI * s);
  		d: square-root (i * i) + (j * j)
  		g: exp (negate (d * d) / s2) / (pi * s2)
  		;g: (exp (negate(d * d) / s2)) / (pi * s2)
  		append gaussian g
  		sum: sum + g
  		i: i + 1
  	]
  	j: j + 1
  ]
  
  ; now normalize the kernel -> new sum = 1.0
  i: 1
  while [i <= (kSize/x * kSize/y)] [
  	gaussian/:i: gaussian/:i / sum
  	i: i + 1
  ] 
  gaussian	
]

; for testing 
rcvMakeGaussian2: function [
"Creates a gaussian uneven kernel"
	kSize 	[pair!]
	sigma	[float!]
][
  gaussian: copy []
  n: kSize/x - 1 / 2
  i: negate n
  j: negate n
  sum: 0.0
  d: 0.0
  s2: power sigma 2.0
  while [j <= n] [
  	i: negate n
  	while [i <= n] [
  		d: (power i 2.0) + (power j 2.0)
  		g1: 1.0 / (2.0 * pi * s2)
  		g2: exp (negate (d / (2.0 * s2)))
  		append gaussian g1 * g2
  		sum: sum + g1 * g2
  		i: i + 1
  	]
  	j: j + 1
  ]
  ; now normalize the kernel
  i: 1
  while [i <= (kSize/x * kSize/y)] [
  	gaussian/:i: gaussian/:i / sum
  	i: i + 1
  ] 
  gaussian	
]
;********************** Functions *********************



