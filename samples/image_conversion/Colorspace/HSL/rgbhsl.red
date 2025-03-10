#!/usr/local/bin/red-cli
Red [
	Author:  "ldci"
	File: %rgbhsv.red
]

;--Convertor RGB <> HSV
min3: function [
	a		[number!]
	b 		[number!]
	c		[number!]
	return: [number!]
][
	either a < b [mini: a] [mini: b]
	if c < mini [mini: c]
	mini
]

max3: function [
	a		[number!]
	b 		[number!]
	c		[number!]
	return: [number!]
][
	either a > b [maxi: a] [maxi: b]
	if c > maxi [maxi: c]
	maxi
]

;https://www.rapidtables.com/convert/color/rgb-to-hsv.html
;--better from a python sample
;--The RGB values are divided by 255 to change the range from 0..255 to 0..1
rgbToHsl: function [
	r 		[integer!]
	g 		[integer!]
	b 		[integer!]
	return: [block!]
][
	r: r / 255
	g: g / 255
	b: b / 255
	mini: min3 r g b
	maxi: max3 r g b
	delta: maxi - mini
	l: (maxi + mini) / 2
	;--Compute Hue 
	either delta = 0 [h: 0][
		case [
			maxi = r [h: (60 * ((g - b) / delta) + 360) % 360]
			maxi = g [h: (60 * ((b - r) / delta) + 120) % 360]
			maxi = b [h: (60 * ((r - g) / delta) + 240) % 360]
		]
	]
	
	;--Compute Saturation
	either delta = 0 [s: 0][s: delta / (1 - absolute (2 * l - 1))]
	;--Compute Value
	reduce [h s l]
]

;--With  H [0..359], S [0..1] and L [0..1] (float values)
hslToRgb: function [
	h		[number!]
	s		[number!]
	l		[number!]
	return: [block!]
][
	rr: gg: bb: 0.0
	c: (1 - absolute (2 * l - 1)) * s
	x: c *  (1 - absolute ((h / 60) %  2) - 1)
	m: l - (c / 2)
	if all [h >=   0 h <  60][rr: c gg: x bb: 0]
	if all [h >=  60 h < 120][rr: x gg: c bb: 0]
	if all [h >= 120 h < 180][rr: 0 gg: c bb: x]
	if all [h >= 180 h < 240][rr: 0 gg: x bb: c]
	if all [h >= 240 h < 300][rr: x gg: 0 bb: c]
	if all [h >= 300 h < 360][rr: c gg: 0 bb: x]
	r: to integer! round (rr + m * 255)
	g: to integer! round (gg + m * 255)
	b: to integer! round (bb + m * 255)
	reduce [r g b]
]

