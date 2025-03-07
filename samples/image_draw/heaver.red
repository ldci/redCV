Red [
	Title:   "Visual Illusion Image"
	Author:  "ldci"
	File: 	 %heaver.r.red
	Needs:	 'View
]
; based on heaver.red 2005 F. Jouen

margins: 10x10


c1: 270x190  ;270x190
c2: c1 + 100; 370x290
b1x: b3x: 219
b2x: b4x: 321
b1y: b2y: 169
b3y: b4y: 271
rot: 0.0
cl: red

p1: as-pair b1x b1y
p2: as-pair b2x b2y
p3: as-pair b3x b3y
p4: as-pair b4x b4y

;old
{target: compose  [
				;transform (rot) 320x240 1.0 1.0 -10x0
				fill-pen 0.255.0.0
				pen off
				box (c1) (c2)
]}

sFactor: 1.0
transl: -10x-17
centerXY: 320x240
target: compose [scale (sFactor) (sFactor) 
				translate (transl) rotate (rot) (centerXY) 
				fill-pen 0.255.0.0
				pen off
				box (c1) (c2)
				]
				

occlusion: compose [ fill-pen (cl)
				pen off
				box 0x0 100x100]
				
view win: layout [
		title "Visual Illusion"
		origin margins space margins
		t1: button "Start" 65[
			bx/rate: 15
		]
		t2: button "Stop " 65 [
			bx/rate: none
		]
		button 100 "Quit" [Quit]
		return
		bx: base 640x480 white draw target on-time[
			rot: rot + 1 if  rot > 180 [rot: 0.0]
			target/7: rot
		]
		
		return
		sl: slider  520x25 [val: to integer! (sl/data * 50) 
								b1/offset/x: b1x - val  b1/offset/y: b1y - val 
								b2/offset/x: b2x + val  b2/offset/y: b2y - val
								b3/offset/x: b3x - val  b3/offset/y: b3y + val
								b4/offset/x: b4x + val  b4/offset/y: b4y + val
								]
		text 100 "Occlusion" center
		return
		sl2: slider  520x25	[ v: to integer! (sl2/data * 50) bx/rate: 15 + v]		
 		text 100 "Velocity" center	 
		return
		
		at p1 b1: base 100x100 draw occlusion
		at p2 b2: base 100x100 draw occlusion 
		at p3 b3: base 100x100 draw occlusion   
		at p4 b4: base 100x100 draw occlusion 
]