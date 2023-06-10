#!/usr/local/bin/red
Red [
	Title:   "Red Computer Vision: Gabor Filter"
	Author:  "Francois Jouen"
	File: 	 %rcvGabor.red
	Tabs:	 4
	Rights:  "Copyright (C) 2022 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]
;--based on https://moonbooks.org/Articles
;--/How-to-plot-a-Gabor-filter-using-python-and-matplotlib-/

rcvGaborChangeBase: function [
"Calculates x and y theta"
	x y		[integer!]
	theta	[float!]
	return: [block!]
][
	x_theta: (x * cos theta) + (y * sin theta)	
    y_theta: (y * cos theta) - (x * sin theta)
    reduce [x_theta y_theta]
] 

rcvGaborFunction: function [
"Calculates Gabor function value"
	x y		[integer!]
	theta	[float!]
	f		[float!]
	sigma_x [float!]
	sigma_y [float!]
	return: [float!]
][
	b: rcvGaborChangeBase x y theta 
	r1: b/1 / sigma_x 						
	r2: b/2 / sigma_y						
	arg: -0.5 * (( r1 ** 2) + (r2 ** 2)) 	
	(exp (arg)) * cos(2 * pi * f * b/1)		
]

rcvGaborKernel: function [
"Generates Gabor kernel"
	theta	[float!]
	f		[float!]
	sigma_x [float!]
	sigma_y [float!]
	radius	[integer!]
	return: [block!]
][
	mini: 9999999999.0
	maxi: -9999999999.0
	kSize: radius * 2
	mat: copy []
	x: negate radius
	i: 0
	while [i < (radius * 2)] [
		y: negate radius
		j: 0 
		while [j < (radius * 2)][
			v: rcvGaborFunction x y theta f sigma_x sigma_y
			if maxi < v [maxi: v]
			if mini > v [mini: v]
			append mat v
			y: y + 1
			j: j + 1
		]
		x: x + 1
		i: i + 1
	]
	b: copy []
	append b kSize		;--kernel size
	append b mini		;--min of Gabor function
	append b maxi		;--max of Gabor function
	append/only b mat	;--Kernel values
	b
]

rcvGaborNormalizeFilter: function [
"Normalizes data for filter visualization"
	gKnl	[block!]
	return: [block!]
][
	mat1:  gKnl/4		;--values of Gabor function
	mat2:  copy []		;--normalized matrix 0..255 with mini and maxi of Gabor function
	foreach v mat1 [append mat2 to-integer ((v - gKnl/2) * 255) / (gKnl/3 - gKnl/2)]
	mat2
]

;--similar to rcvFilter2D
rcvImageGaborFilter: routine [
"Gabor convolutive filter"
    src  	[image!]
    dst  	[image!]
    kernel 	[block!] 
    dx	 	[integer!]
    dy		[integer!]
    /local
        pixS pixD 			[int-ptr!]
        idx	 				[int-ptr!]
        handleS handleD		[integer!] 
        h w x y i j			[integer!]
        r g b imx imy 		[integer!]
        rf gf bf weightSum	[float!]
        accR accG accB		[float!]
        f					[red-float!]  
		kBase kValue		[red-value!] 
		pixel rgba 			[subroutine!]
][
    handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    idx:  pixS
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    ;--subroutines
    r: g: b: 0
    rgba: [ r: idx/value and 00FF0000h >> 16 
        	g: idx/value and FF00h >> 8 
       		b: idx/value and FFh ]
    pixel: [(255 << 24) OR (r << 16) OR (g << 8) OR b]
	;--end of subroutines
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
    		weightSum: accR: accG: accB: 0.0
   			j: 0
			kValue: kBase
			while [j < dy][
            	i: 0
            	while [i < dx][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		imx:  (x + (i - (dx / 2)) + w ) % w 
        			imy:  (y + (j - (dy / 2)) + h ) % h 
            		idx: pixS + (imy * w) + imx  ; corrected pixel index
            		rgba 					;--get pixel value
        			f: as red-float! kValue ;get kernel values
        			; calculate  Sigma of weighted values
        			accR: accR + ((as float! r) * f/value)
        			accG: accG + ((as float! g) * f/value)
        			accB: accB + ((as float! b) * f/value)
        			weightSum: weightSum + f/value
        			kValue: kBase + (j * dx + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        if weightSum = 0.0 [weightSum: 1.0]; no division by zero!
        rf: accR / weightSum	
        gf: accG / weightSum
        bf: accB / weightSum
        					 						 
        r: as integer! rf
        g: as integer! gf
        b: as integer! bf
        
        ;print-wide [r g b lf]
        if r < 0 [r: 0] if r > 255 [r: 255]
        if g < 0 [g: 0] if g > 255 [g: 255]
        if b < 0 [b: 0] if b > 255 [b: 255]	
       			 
        pixD/value: pixel
        pixD: pixD + 1
        x: x + 1
       ]
       y: y + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]



