Red [
	Title:   "Red Computer Vision: Image Processing"
	Author:  "Francois Jouen"
	File: 	 %rcvConvolutionImg.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

; *************** IMAGE CONVOLUTION *************************

{The 2D convolution operation isn't extremely fast, 
unless you use small filters. We'll usually be using 3x3 or 5x5 filters. 
There are a few rules about the filter:
Its size has to be uneven, so that it has a center, for example 3x3, 5x5, 7x7 or 9x9 are ok. 
The sum of all elements of the filter should be 1 if you want the resulting image to have the same brightness as the original
If the sum of the elements is larger than 1, the result will be a brighter image
If it's smaller than 1, a darker image. 
If the sum is 0, the resulting image isn't necessarily completely black, but it'll be very dark
Apart from using a kernel matrix, it also has a multiplier factor and a delta. 
After applying the filter, the factor will be multiplied with the result, and the bias added to it. 
So if you have a filter with an element 0.25 in it, but the factor is set to 2, all elements of the filter 
are  multiplied by two so that element 0.25 is actually 0.5. 
The delta can be used if you want to make the resulting image brighter. 
}

rcvConvolve: routine [
"Convolves an image with the kernel"
    src  		[image!]
    dst  		[image!]
    kernel 		[block!] 
    factor 		[float!]
    delta		[float!]
    /local
    	pixel rgba 				[subroutine!]
        pixS 					[int-ptr!]
        pixD 					[int-ptr!]
        idx	 					[int-ptr!]
        handleS handleD			[integer!] 
        h w x y i j				[integer!]
        r g b					[integer!]
        accR accG accB 			[float!]
        imx imy kWidth kHeight	[integer!] 
        f						[red-float!]
		kBase kValue 			[red-value!] 
][
    handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    idx:  pixS
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    r: g: b: 0
    ;--subroutines
    rgba: [ r: idx/value and 00FF0000h >> 16 
        	g: idx/value and FF00h >> 8 
       		b: idx/value and FFh ]
    pixel: [(255 << 24) OR (r << 16) OR (g << 8) OR b]
    
    ;--get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
    	accR: accG: accB: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK  
            		imx:  (x + (i - (kWidth / 2)) + w ) % w 
        			imy:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: pixS + (imy * w) + imx  ; corrected pixel index
            		rgba
        			f: as red-float! kValue
        			; calculate weighted sums
        			accR: accR + ((as float! r) * f/value)
        			accG: accG + ((as float! g) * f/value)
        			accB: accB + ((as float! b) * f/value)
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        ; multiply and delta parameters
        r: as integer! ((accR * factor) + delta)				 
        g: as integer! ((accG * factor) + delta)
        b: as integer! ((accB * factor) + delta)				 
        if r < 0   [r: 0]
        if r > 255 [r: 255]
        if g < 0   [g: 0]
        if g > 255 [g: 255]
        if b < 0   [b: 0]
        if b > 255 [b: 255]				 
        pixD/value: pixel
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

; Similar to convolution but the sum of the weights is computed during the summation, 
; and used to scale the result.

rcvFilter2D: routine [
"Basic convolution Filter"
    src  	[image!]
    dst  	[image!]
    kernel 	[block!] 
    factor	[float!]
    delta	[float!]
    /local
        pixS pixD 			[int-ptr!]
        idx	 				[int-ptr!]
        handleS handleD		[integer!] 
        h w x y i j			[integer!]
        r g b imx imy 		[integer!]
        rf gf bf weightSum	[float!]
        accR accG accB		[float!]
        kWidth kHeight 		[integer!]
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
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
    	weightSum: accR: accG: accB: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		imx:  (x + (i - (kWidth / 2)) + w ) % w 
        			imy:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: pixS + (imy * w) + imx  ; corrected pixel index
            		rgba
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate  Sigma of weighted values
        			accR: accR + ((as float! r) * f/value)
        			accG: accG + ((as float! g) * f/value)
        			accB: accB + ((as float! b) * f/value)
        			weightSum: weightSum + f/value
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        if weightSum = 0.0 [weightSum: 1.0]; no division by zero!
        rf: accR / weightSum	
        gf: accG / weightSum
        bf: accB / weightSum
        
        rf: rf * factor + delta
        gf: gf * factor + delta
        bf: bf * factor + delta
    						 						 
        r: as integer! rf
        g: as integer! gf
        b: as integer! bf
        if r < 0 [r: 0]
        if r > 255 [r: 255]
        if g < 0 [g: 0]
        if g > 255 [g: 255]
        if b < 0 [b: 0]
        if b > 255 [b: 255]	
       			 
        pixD/value: pixel
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

; only for 1-channel image (8-bit)
rcvFastConvolve: routine [
"Convolves a 8-bit and 1-channel image with the kernel"
    src  	[image!]
    dst  	[image!]
    channel	[integer!]
    kernel 	[block!] 
    factor 	[float!]
    delta	[float!]
    /local
        pixS pixD idx	[int-ptr!]
        handleS handleD	[integer!] 
        h w x y i j v	[integer!]
        accV			[float!] 
        f 				[red-float!] 
        imx imy 		[integer!]
		kWidth kHeight 	[integer!]
		kBase kValue 	[red-value!] 
][
    handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    idx:  pixS
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
    	accV: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		imx:  (x + (i - (kWidth / 2)) + w ) % w 
        			imy:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: pixS + (imy * w) + imx  ; corrected pixel index
            		switch channel [
						1 [v: idx/value and 00FF0000h >> 16 ]
						2 [v: idx/value and FF00h >> 8 ]
						3 [v: idx/value and FFh]
					]
					;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			accV: accV + ((as float! v) * f/value)
         			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        
        v: as integer! (accV * factor)						 
    	v: v + as integer! delta
        if v < 0 [v: 0]
        if v > 255 [v: 255]
        pixD/value: (255 << 24) OR (v << 16 ) OR (v << 8) OR v	
        pixD: pixD + 1
        x: x + 1
       ]
       y: y + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]



; a faster version without controls on pixel value !
; basically for 1 channel gray scaled image
;the sum of the weights is computed during the summation, and used to scale the result

rcvFastFilter2D: routine [
"Faster convolution Filter"
    src  		[image!]
    dst  		[image!]
    kernel 		[block!] 
    /local
        pixS pixD idx		[int-ptr!]
        handleS handleD		[integer!] 
        h w x y i j			[integer!]
        imx imy 			[integer!]
        kWidth kHeight		[integer!] 
        weightSum weightAcc	[float!]
        f					[red-float!]  
		kBase kValue 		[red-value!] 
][
    handleS: handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    idx:  pixS
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
       	weightAcc: weightSum: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		imx:  (x + (i - (kWidth / 2)) + w ) % w 
        			imy:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: pixS + (imy * w) + imx  ; corrected pixel index
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			weightAcc: weightAcc + ((as float! idx/value) * f/value)
        			weightSum: weightSum + f/value
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        either (weightSum > 0.0) [pixD/value: as integer! (weightAcc / weightSum)] 
        						 [pixD/value: as integer! (weightAcc)]
       
        pixD: pixD + 1
        x: x + 1
       ]
       y: y + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]
