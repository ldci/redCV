Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvStatsRoutines.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;***************** STATISTICAL ROUTINES ***********************
; exported as functions in /libs/math/rcvStats.red
_rcvCount: routine [src1 [image!] return: [integer!]
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

_rcvStdInt: routine [src1 [image!] return: [integer!]
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
    a: sa / (w * h)
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
    fr: sqrt as float! (sr / ((w * h) - 1))
    fg: sqrt as float! (sg / ((w * h) - 1))
    fb: sqrt as float! (sb / ((w * h) - 1))
    a: as integer! fa
    r: as integer! fr
    g: as integer! fg
    b: as integer! fb
    OS-image/unlock-bitmap as-integer src1/node bmp1;
    (a << 24) OR (r << 16 ) OR (g << 8) OR b 
]

_rcvMeanInt: routine [src1 [image!] return: [integer!]
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
    a: sa / (w * h)
    r: sr / (w * h)
    g: sg / (w * h)
    b: sb / (w * h)
    OS-image/unlock-bitmap as-integer src1/node bmp1;
    (a << 24) OR (r << 16 ) OR (g << 8) OR b 
]