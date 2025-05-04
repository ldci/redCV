Red [
	Title:   "Color tests "
	Author:  "ldci"
	File: 	 %colorWheel.red
	Needs:	 'View
]

;required libs
#include %../../libs/core/rcvCore.red

acolor: black

drawCross: 	compose [line-width 1 
			pen (acolor) line 0x10 6x10 
			pen off pen (acolor) line 14x10 20x10
			pen (acolor) line 10x0 10x6 
			pen off pen (acolor) line 10x14 10x20
			line-width 2 box 0x0 20x20]


img: rcvColorWheel 128	;--create color wheel

win: layout [
	title "Color Wheel"
	pad 195x0 button "Quit" [Quit]
	return
	canvas: base 256x256 img
	return
	f1: field 256
	at canvas/offset + 5x5 p2: base 0.0.0.254 22x22 loose draw drawCross
	on-drag [
		posct: p2/offset - canvas/offset + 11
		if all [posct/x >= 0 posct/y >= 0 posct/x <= 256 posct/y <= 256][
			clear f1/text
			color: pick img to pair! posct	;--red_0.6.5 point2D -> pair (rcv2pair)
			f1/text: rejoin ["Coordinates:" form posct " Color:" color]
		]
	]
]

view win
