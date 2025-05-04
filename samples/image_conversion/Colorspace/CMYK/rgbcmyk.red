#!/usr/local/bin/red-cli
Red [
	Author:  "ldci"
	File: %rgbcmyk.red
]

;--Convertor RGB <> CMYK
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

rgbToCmyk: function [
	r 		[integer!]
	g 		[integer!]
	b 		[integer!]
	return: [block!]
][
	r: r / 255
	g: g / 255
	b: b / 255
	;mini: min3 r g b
	maxi: max3 r g b
	k: 1 - maxi							;--;The black key (K) 
	either k = 1 [d: k] [d: (1 - k)]	;--Avoid / 0 error
	c: (1 - r - k) / d					;--The cyan color (C)
	m: (1 - g - k) / d					;--The magenta color (M)
	y: (1 - b - k) / d					;--The yellow color (Y)
	reduce [c m y k]
]

cmykToRgb: function [
	c 		[number!]
	m 		[number!]
	y 		[number!]
	k		[number!]
	return: [block!]
][
	r: to integer! (255 * (1 - c) * (1 - k))
	g: to integer! (255 * (1 - m) * (1 - k))
	b: to integer! (255 * (1 - y) * (1 - k))
	reduce [r g b]
]


