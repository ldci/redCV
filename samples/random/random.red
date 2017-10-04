Red [
	Title:   "Random test "
	Author:  "Francois Jouen"
	File: 	 %random.red
	Needs:	 'View
]

; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
rnd: 255.255.255; white 

; ***************** Test Program ****************************
view win: layout [
		title "Rand Tests"
		button 80 "Uniform"  [canvas/image: rcvRandomImage/uniform 512x512 rnd]
		button 80 "Random" [canvas/image: rcvRandomImage/alea 512x512 rnd]
		button 50 "Quit" [quit]
		return
		canvas: base 512x512 black	
]