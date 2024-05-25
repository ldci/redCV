Red [
	Title:   "Random test "
	Author:  "Francois Jouen"
	File: 	 %random.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red

margins: 10x10
rnd: 255.255.255; white 
flag: 1
size: 512x512
sizex: size/x - 200


process: does [
	t1: now/time/precise
	case [
		flag = 1 [canvas/image: rcvRandomImage/uniform size rnd]
		flag = 2 [canvas/image: rcvRandomImage/alea size rnd]
		flag = 3 [canvas/image: rcvRandomImage/fast size rnd]
	]
	t2: now/time/precise
	f/text: rejoin [form round/to ((third t2 - t1) * 1000.0) 0.01 " msec"]
]


; ***************** Test Program ****************************
view win: layout [
		title "Random Tests"
		button 80 "Uniform" [flag: 1 process]
		button 80 "Random" 	[flag: 2 process]
		button 80 "Fast" 	[flag: 3 process]
		button 50 "Quit" 	[quit]
		return
		canvas: base size black	
		return
		f: field sizex
		text 150 "© Red Foundation 2019"
]