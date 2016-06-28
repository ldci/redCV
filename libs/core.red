Red [
	Title:   "Red Computer Vision: Core functions"
	Author:  "Francois Jouen"
	File: 	 %core.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

; Thanks to Qingtian Xie for help :)

{To know: loaded images by red are in RGBA format (a tuple )
Images are 8-bit [0..255] and internally uses bytes as a binary string

pixel and 00FF0000h >> 16 	: Red
pixel and FF00h >> 8		: Green
pixel and FFh				: Blue
pixel >>> 24				: Alpha
}



; This file contains Red routines (including Red/System code)
; These routines can be directly called in Red Code or via their export in red.cv



; ********* image transformation **********
;general image conversion routine
; used for conversion to Grayscale  to RGBA, to BGRA or to Black and White 
rcvConvert: routine [src1 [image!] op [integer!] return: [image!]
	/local 
		dst 
		stride1 
		stride2 
		bmp1 
		bmpDst 
		data1 
		dataDst 
		w 
		h
		x 
		y 
		pos
		r
		g
		b
		a
		s
		mini
		maxi
][
    dst: as red-image! stack/push*        ;-- create an new image slot
    image/copy src1 dst null yes null
    stride1: 0
    stride2: 0
    bmp1: OS-image/lock-bitmap as-integer src1/node no
    bmpDst: OS-image/lock-bitmap as-integer dst/node yes
    
    data1: OS-image/get-data bmp1 :stride1   
    dataDst: OS-image/get-data bmpDst :stride2

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            ; OK we get RGBA values
            a: data1/pos >>> 24
            r: data1/pos and 00FF0000h >> 16 
            g: data1/pos and FF00h >> 8 
            b: data1/pos and FFh 
            s: 0
            mini: 0
            maxi: 0
            switch op [
            	1 [ s: (r + g + b) / 3 
            		dataDst/pos: ( (a << 24) OR (s << 16 ) OR (s << 8) OR s)] ;RGB2Gray average
              111 [ r: (r * 21) / 100
              		g: (g * 72) / 100 
              		b: (b * 7) / 100
              		s: r + g + b
                  	dataDst/pos: ( (a << 24) OR (s << 16 ) OR (s << 8) OR s)] ;RGB2Gray luminosity
              112	[ either r > g [mini: g][mini: r] 
              		  either b > mini [mini: mini][ mini: b] 
              		  either r > g [maxi: r][maxi: g] 
              		  either b > maxi [maxi: b][ maxi: maxi] 
              		  s: (mini + maxi) / 2
              		  dataDst/pos: ((a << 24) OR (s << 16 ) OR (s << 8) OR s)] ;RGB2Gray lightness
            	2 [dataDst/pos: ((a << 24) OR (b << 16 ) OR (g << 8) OR r)] ;2BGRA
            	3 [dataDst/pos: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)] ;2RGBA
            	4 [either r >= 128 [r: 255 g: 255 b: 255] [r: 0 g: 0 b: 0] 
            	   dataDst/pos: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)] ;2BW
            	
        	]
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    OS-image/unlock-bitmap as-integer src1/node bmp1
    OS-image/unlock-bitmap as-integer dst/node bmpDst
	as red-image! stack/set-last as cell! dst            ;-- return new image
]


; extract RGB Channel. Since we can't use 1 channel image we make a 3 channels image 
; with the same values for each channel 

rcvChannel: routine [src [image!] op [integer!] return: [image!]
	/local 
		dst 
		stride1 
		stride2 
		bmp1 
		bmpDst 
		data1 
		dataDst 
		w 
		h
		x 
		y 
		pos
		r
		g
		b
		a
][
    dst: as red-image! stack/push*        ;-- create an new image slot
    image/copy src dst null yes null
    stride1: 0
    stride2: 0
    bmp1: OS-image/lock-bitmap as-integer src/node no
    bmpDst: OS-image/lock-bitmap as-integer dst/node yes
    
    data1: OS-image/get-data bmp1 :stride1   
    dataDst: OS-image/get-data bmpDst :stride2

    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    y: 0
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            ; OK we get RGBA values
            a: data1/pos >>> 24
            r: data1/pos and 00FF0000h >> 16 
            g: data1/pos and FF00h >> 8 
            b: data1/pos and FFh 
            switch op [
            	1 [ g: r b: r]	;Red Channel
              	2 [ r: g b: g] 	;Green Channel 
              	3 [ r: b g: b] 	;blue Channel
            ]
           	dataDst/pos: ((a << 24) OR (r << 16 ) OR (g << 8) OR b)
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    OS-image/unlock-bitmap as-integer src/node bmp1
    OS-image/unlock-bitmap as-integer dst/node bmpDst
	as red-image! stack/set-last as cell! dst            ;-- return new image
]


; creates up down, left right mirror image or both  
rcvFlipHV: routine [src [image!] op [integer!] return: [image!]
	/local 
		dst 
		stride1 
		stride2 
		bmp1 
		bmpDst 
		data1 
		dataDst 
		w 
		h
		x 
		y 
		y2
		pos
		pos2
][
    dst: as red-image! stack/push*        ;-- create an new image slot
    image/copy src dst null yes null
    stride1: 0
    stride2: 0
    bmp1: OS-image/lock-bitmap as-integer src/node no
    bmpDst: OS-image/lock-bitmap as-integer dst/node yes
    
    data1: OS-image/get-data bmp1 :stride1   
    dataDst: OS-image/get-data bmpDst :stride2

    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    y: 0
    y2: 0
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            switch op [
            	1 [pos2: stride1 >> 2 * y + w - x] ;left/right 
            	2 [y2: h - y pos2:  stride1 >> 2 * y2 + x + 1]; Up/down 
            	3 [pos2:  stride1 >> 2 * h - pos];both 
            ]
            
           	dataDst/pos: data1/pos2
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    OS-image/unlock-bitmap as-integer src/node bmp1
    OS-image/unlock-bitmap as-integer dst/node bmpDst
	as red-image! stack/set-last as cell! dst            ;-- return new image
]





; ************ logical operators on images as Red/S routines**********

rvcLogical: routine [src1 [image!] src2 [image!] op [integer!]return: [image!]
	/local 
		dst 
		stride1 
		stride2 
		stride3 
		bmp1 
		bmp2 
		bmpDst 
		data1 
		data2 
		dataDst 
		w 
		x 
		y 
		h 
		pos
][
    dst: as red-image! stack/push*        ;-- create an new image slot
    image/copy src1 dst null yes null
    stride1: 0
    stride2: 0
    stride3: 0
    bmp1: OS-image/lock-bitmap as-integer src1/node no
    bmp2: OS-image/lock-bitmap as-integer src2/node no
    bmpDst: OS-image/lock-bitmap as-integer dst/node yes
    
    data1: OS-image/get-data bmp1 :stride1
    data2: OS-image/get-data bmp2 :stride2    
    dataDst: OS-image/get-data bmpDst :stride3

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            switch op [
           		1 [dataDst/pos: data1/pos AND data2/pos]
           		2 [dataDst/pos: data1/pos OR data2/pos]
           		3 [dataDst/pos: data1/pos XOR data2/pos]
           		4 [dataDst/pos: NOT (data1/pos AND data2/pos)]
           		5 [dataDst/pos: NOT (data1/pos OR data2/pos)]
           		6 [dataDst/pos: NOT (data1/pos XOR data2/pos)]
           		7 [either data1/pos > data2/pos [dataDst/pos: data2/pos][dataDst/pos: data1/pos]]
           		8 [either data1/pos > data2/pos [dataDst/pos: data1/pos] [dataDst/pos: data2/pos]]
            ]
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    OS-image/unlock-bitmap as-integer src1/node bmp1
    OS-image/unlock-bitmap as-integer src2/node bmp2
    OS-image/unlock-bitmap as-integer dst/node bmpDst
	as red-image! stack/set-last as cell! dst            ;-- return new image
]


; for image inversion
rcvNOT: routine [src1 [image!]  return: [image!]
	/local 
		dst 
		stride1 
		stride2 
		bmp1 
		bmpDst 
		data1 
		dataDst 
		w 
		x 
		y 
		h 
		pos
][
    dst: as red-image! stack/push*        ;-- create an new image slot
    image/copy src1 dst null yes null
    stride1: 0
    stride2: 0
    bmp1: OS-image/lock-bitmap as-integer src1/node no
    bmpDst: OS-image/lock-bitmap as-integer dst/node yes
    
    data1: OS-image/get-data bmp1 :stride1   
    dataDst: OS-image/get-data bmpDst :stride2

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            dataDst/pos: NOT data1/pos 
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    OS-image/unlock-bitmap as-integer src1/node bmp1
    OS-image/unlock-bitmap as-integer dst/node bmpDst
	as red-image! stack/set-last as cell! dst            ;-- return new image
]


; ********** Math Operators on image **********

rcvMath: routine [src1 [image!] src2 [image!] op [integer!]return: [image!]
	/local 
		dst 
		stride1 
		stride2 
		stride3 
		bmp1 
		bmp2 
		bmpDst 
		data1 
		data2 
		dataDst 
		w 
		x 
		y 
		h 
		pos
		
][
    dst: as red-image! stack/push*        ;-- create an new image slot
    image/copy src1 dst null yes null
    stride1: 0
    stride2: 0
    stride3: 0
    bmp1: OS-image/lock-bitmap as-integer src1/node no
    bmp2: OS-image/lock-bitmap as-integer src2/node no
    bmpDst: OS-image/lock-bitmap as-integer dst/node yes
    
    data1: OS-image/get-data bmp1 :stride1
    data2: OS-image/get-data bmp2 :stride2    
    dataDst: OS-image/get-data bmpDst :stride3

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            switch op [
            	1 [dataDst/pos: data2/pos + data1/pos] 
            	2 [dataDst/pos: data1/pos - data2/pos] 
            	3 [dataDst/pos: data1/pos * data2/pos]
            	4 [dataDst/pos: data1/pos / data2/pos]
            	5 [dataDst/pos: data1/pos // data2/pos]
            	6 [dataDst/pos: data1/pos % data2/pos]
            	7 [ either data1/pos > data2/pos [dataDst/pos: data1/pos - data2/pos]
            		[dataDst/pos: data2/pos - data1/pos]]
            ]
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    OS-image/unlock-bitmap as-integer src1/node bmp1
    OS-image/unlock-bitmap as-integer src2/node bmp2
    OS-image/unlock-bitmap as-integer dst/node bmpDst
	as red-image! stack/set-last as cell! dst            ;-- return new image
]

; ********** Math operators with Tuple *********

rcvMathT: routine [src1 [image!]  value [tuple!] op [integer!] return: [image!]
	/local 
		dst 
		stride1 
		stride2 
		bmp1 
		bmpDst 
		data1 
		dataDst 
		w 
		x 
		y 
		h 
		pos
		tp
][
    dst: as red-image! stack/push*        ;-- create an new image slot
    image/copy src1 dst null yes null
    stride1: 0
    stride2: 0
    bmp1: OS-image/lock-bitmap as-integer src1/node no
    bmpDst: OS-image/lock-bitmap as-integer dst/node yes
    
    data1: OS-image/get-data bmp1 :stride1   
    dataDst: OS-image/get-data bmpDst :stride2

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    tp: as red-tuple! value
    
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            switch op [
            	1 [dataDst/pos: data1/pos + tp]
            	2 [dataDst/pos: data1/pos - tp]
            	;3 [dataDst/pos: data1/pos * tp]
            	
            ]
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    OS-image/unlock-bitmap as-integer src1/node bmp1
    OS-image/unlock-bitmap as-integer dst/node bmpDst
	as red-image! stack/set-last as cell! dst            ;-- return new image
]

; ********** Math operators with scalar (integer) *********

rcvMathS: routine [src1 [image!]  value [integer!] op [integer!] return: [image!]
	/local 
		dst 
		stride1 
		stride2 
		bmp1 
		bmpDst 
		data1 
		dataDst 
		w 
		x 
		y 
		h 
		pos
][
    dst: as red-image! stack/push*        ;-- create an new image slot
    image/copy src1 dst null yes null
    stride1: 0
    stride2: 0
    bmp1: OS-image/lock-bitmap as-integer src1/node no
    bmpDst: OS-image/lock-bitmap as-integer dst/node yes
    
    data1: OS-image/get-data bmp1 :stride1   
    dataDst: OS-image/get-data bmpDst :stride2

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            switch op [
            	1 [dataDst/pos: data1/pos + value]
            	2 [dataDst/pos: data1/pos - value]
            	3 [dataDst/pos: data1/pos * value]
            	4 [dataDst/pos: data1/pos / value]
            	5 [dataDst/pos: data1/pos // value]
            	6 [dataDst/pos: data1/pos % value]
            	7 [dataDst/pos: data1/pos * data1/pos]
            	8 [dataDst/pos: data1/pos << value]
            	9 [dataDst/pos: data1/pos >> value]
            ]
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    OS-image/unlock-bitmap as-integer src1/node bmp1
    OS-image/unlock-bitmap as-integer dst/node bmpDst
	as red-image! stack/set-last as cell! dst            ;-- return new image
]

; ********** Statistical Functions  *********

rcvMean: routine [src1 [image!]  return: [image!]
	/local 
		dst 
		stride1 
		stride2 
		bmp1 
		bmpDst 
		data1 
		dataDst 
		w 
		x 
		y 
		h 
		pos
		r 
		g
		b
		a
		sr 
		sg
		sb
		sa
][
    dst: as red-image! stack/push*        ;-- create an new image slot
    image/copy src1 dst null yes null
    stride1: 0
    stride2: 0
    bmp1: OS-image/lock-bitmap as-integer src1/node no
    bmpDst: OS-image/lock-bitmap as-integer dst/node yes
    
    data1: OS-image/get-data bmp1 :stride1   
    dataDst: OS-image/get-data bmpDst :stride2

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    sa: 0
    sr: 0
    sg: 0
    sb: 0
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
           	sa: sa + (data1/pos >>> 24)
            sr: sr + (data1/pos and 00FF0000h >> 16)  
            sg: sg + (data1/pos and FF00h >> 8)
            sb: sb + (data1/pos and FFh)
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    x: 0
    y: 0
    
    sa: sa / (w * h)
    sr: sr / (w * h)
    sg: sg / (w * h)
    sb: sb / (w * h)
 	; makes mean image
    while [y < h][
        while [x < w][
        	pos: stride1 >> 2 * y + x + 1
        	dataDst/pos: ((sa << 24) OR (sr << 16 ) OR (sg << 8) OR sb)
        	x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    OS-image/unlock-bitmap as-integer src1/node bmp1
    OS-image/unlock-bitmap as-integer dst/node bmpDst
	as red-image! stack/set-last as cell! dst            ;-- return new image
]


rcvMeanInt: routine [src1 [image!] return: [integer!]
	/local 
		stride1 
		bmp1 
		data1 
		w 
		x 
		y 
		h 
		pos
		r 
		g
		b
		a
		sr 
		sg
		sb
		sa
][
    stride1: 0
    bmp1: OS-image/lock-bitmap as-integer src1/node no
    data1: OS-image/get-data bmp1 :stride1   

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    sa: 0
    sr: 0
    sg: 0
    sb: 0
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            sa: sa + (data1/pos >>> 24)
            sr: sr + (data1/pos and 00FF0000h >> 16)  
            sg: sg + (data1/pos and FF00h >> 8)
            sb: sb + (data1/pos and FFh)
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    a: 0; 255 xor (sa / (w * h))
    r: sr / (w * h)
    g: sg / (w * h)
    b: sb / (w * h)
    OS-image/unlock-bitmap as-integer src1/node bmp1;
    (a << 24) OR (r << 16 ) OR (g << 8) OR b 
]


rcvVarInt: routine [src1 [image!] return: [integer!]
	/local 
		stride1 
		bmp1 
		data1 
		w 
		x 
		y 
		h 
		pos
		r 
		g
		b
		a
		sr 
		sg
		sb
		sa
		fr 
		fg
		fb
		fa
		e
][
    stride1: 0
    bmp1: OS-image/lock-bitmap as-integer src1/node no
    data1: OS-image/get-data bmp1 :stride1   

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    sa: 0
    sr: 0
    sg: 0
    sb: 0
    fa: 0.0
    fr: 0.0
    fg: 0.0
    fb: 0.0
    ; Sigma X
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            sa: sa + (data1/pos >>> 24)
            sr: sr + (data1/pos and 00FF0000h >> 16)  
            sg: sg + (data1/pos and FF00h >> 8)
            sb: sb + (data1/pos and FFh)
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    ; mean values
    a: 0; 255 xor (sa / (w * h))
    r: sr / (w * h)
    g: sg / (w * h)
    b: sb / (w * h)
    x: 0
    y: 0
    e: 0
    ; x - m 
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            e: (data1/pos >>> 24) - a sa: sa + (e * e)
            e: (data1/pos and 00FF0000h >> 16) - r   sr: sr + (e * e)
            e: (data1/pos and FF00h >> 8) - g sg: sg + (e * e)
            e: (data1/pos and FFh) - b sb: sb + (e * e)
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    ; standard deviation
    fa: 0.0; 255 xor sa / ((w * h) - 1)
    fr: sqrt integer/to-float (sr / ((w * h) - 1))
    fg: sqrt integer/to-float (sg / ((w * h) - 1))
    fb: sqrt integer/to-float (sb / ((w * h) - 1))
    a: float/to-integer fa
    r: float/to-integer fr
    g: float/to-integer fg
    b: float/to-integer fb
    
    OS-image/unlock-bitmap as-integer src1/node bmp1;
    (a << 24) OR (r << 16 ) OR (g << 8) OR b 
]


rcvCount: routine [src1 [image!] return: [integer!]
	/local 
		stride1 
		bmp1 
		data1 
		w 
		x 
		y 
		h 
		pos
		r 
		g
		b
		a
		n
][
    stride1: 0
    bmp1: OS-image/lock-bitmap as-integer src1/node no
    data1: OS-image/get-data bmp1 :stride1   

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    n: 0
    while [y < h][
        while [x < w][
            pos: stride1 >> 2 * y + x + 1
            r: data1/pos and 00FF0000h >> 16
            g: data1/pos and FF00h >> 8
            b: data1/pos and FFh
            if (r > 0) and (g > 0) and (b > 0) [n: n + 1]
            x: x + 1
        ]
        x: 0
        y: y + 1
    ]
    
    OS-image/unlock-bitmap as-integer src1/node bmp1;
    n
]