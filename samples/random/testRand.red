Red [
	Title:   "Random test "
	Author:  "Francois Jouen"
	File: 	 %testRand.red
	Needs:	 'View
]

; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 10x10

; ***************** Test Program ****************************
view win: layout [
		title "Rand Tests"
		button 40 "Uni" [canvas/image: rcvRandomImage/uniform 512x512 255.255.255.0]
		button 40 "Alea" [canvas/image: rcvRandomImage/alea 512x512 255.255.255.0]
		button 40 "Quit" [quit]
		return
		canvas: base 512x512 black	
]