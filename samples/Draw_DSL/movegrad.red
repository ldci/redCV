Red [
	Title:   "Gradient Motion"
	Author:  "Francois Jouen"
	File: 	 %movegrad.r.red
	Needs:	 'View
]
; based on movegrad.r 2010 F. Jouen

_grad-offset: 0x0 ; this allows directional motion 
_grad-start-rng: 90 ; to create lines
_grad-stop-rng: 180 ;to create lines
_grad-angle: 0.0 ; 0 for horizontal motion and 90 for vertical motion
_grad-scale-x: 1.0 ; allows modifying frequency in x range
_grad-scale-y: 1.0 ; allows modifying frequency in y range
_grad-color-1: silver ; this can be modified for playing with colors
_grad-color-2: blue; snow ; this can be modified for playing with colors
_grad-color-3: silver ; this can be modified for playing with colors

velocity: 1


direction: "right"
ssize: 800x600; tested up 1600x1200


grad: compose [fill-pen linear (_grad-offset) 
			    (_grad-start-rng) (_grad-stop-rng) (_grad-angle)
				(_grad-scale-x) (_grad-scale-y) 
				(_grad-color-1)
				(_grad-color-2)
				(_grad-color-3) 
				box 0x0 (ssize)
]


view win: layout [
	title "Motion"
	stimulus: base ssize  on-time[
		switch direction [
	   		"right"	[_grad-offset: _grad-offset + velocity]
	   		"left"	[_grad-offset: _grad-offset - velocity]
	   		"up"    [_grad-offset: _grad-offset - velocity]
	   		"down"  [_grad-offset: _grad-offset + velocity]
	    ]
	    grad/3: _grad-offset
	]
	draw grad
	
	return
	b1: button "Left"	[_grad-angle: 0.0  direction: "left"  grad/6: _grad-angle]
	b2: button "Up"		[_grad-angle: 90.0 direction: "up"    grad/6: _grad-angle]
	b3: button "Down"	[_grad-angle: 90.0 direction: "down"  grad/6: _grad-angle]
	b4: button "Right"	[_grad-angle: 0.0  direction: "right" grad/6: _grad-angle]
	text "Velocity"
	sl: slider 100x24 [velocity: to integer! (sl/data * 19) + 1 vit/data: to integer! velocity]
	vit: field 40x30  "1"
	button "Start" [stimulus/rate: 25]
	button "Stop"  [stimulus/rate: none]
	button "Zero" [_grad-offset: 0x0 grad/3: _grad-offset]
	button "Quit" [Quit]
]