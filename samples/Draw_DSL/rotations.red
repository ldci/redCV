Red [
	Title:   "Rotations"
	Author:  "Francois Jouen"
	File: 	 %triangle.r.red
	Needs:	 'View
]

ssize: 512x512
centerXY: 256x256

_grad-offset: 0x0 ; this allows directional motion 
_grad-start-rng: 0 ; 
_grad-stop-rng: 512
_grad-angle: 0 ; 
_grad-scale-x: 1.0 ; allows modifying frequency in x range
_grad-scale-y: 1.0 ; allows modifying frequency in y range
_grad-color-1: red ; this can be modified for playing with colors
_grad-color-2: green ; this can be modified for playing with colors
_grad-color-3: blue ; this can be modified for playing with colors

rot: 0.0
cw: false
;old
{common: compose [
				anti-alias on
				pen red
				line 256x0 256x512
				line 0x256 512x256
				fill-pen linear (_grad-offset) 
			    (_grad-start-rng) (_grad-stop-rng) (_grad-angle)
				(_grad-scale-x) (_grad-scale-y) 
				(_grad-color-1)
				(_grad-color-2)
				(_grad-color-3) 
				transform (rot) (centerXY) 0.5 0.5 (centerXY)
]}

sFactor: 0.5
transl: 240x240

common: compose [
				anti-alias on
				pen red
				line 256x0 256x512
				line 0x256 512x256
				fill-pen linear (_grad-offset) 
			    (_grad-start-rng) (_grad-stop-rng) (_grad-angle)
				(_grad-scale-x) (_grad-scale-y) 
				(_grad-color-1)
				(_grad-color-2)
				(_grad-color-3) 
				scale (sFactor) (sFactor) 
				translate (transl)
				rotate (rot) (centerXY) 
]



;square
gradS: copy common
append gradS  compose [box 0x0 (ssize)]

;circle
gradC: copy common
append gradC  compose [circle (centerXY) 256]

;triangle
gradT: copy common
append gradT  compose [triangle 256x0 0x512 512x512]


grad: gradS ; square first 

view win: layout [
	title "Rotations"
	button "Start" [stimulus/rate: 50]
	button "Stop"  [stimulus/rate: none] 
	drop-down 100x30 
	data ["Square" "Circle" "Triangle"] 
	select 1 
	on-change [
		switch face/selected [
			1 [grad: gradS]
			2 [grad: gradC]
			3 [grad: gradT]
		]
		stimulus/draw: reduce [grad]
	]
	
	check 120 "Anti Clockwise" [cw: face/data]   
	button 100 "Quit" [Quit]
	return
	stimulus: base ssize  on-time [
	either cw [ rot: rot - 1] [rot: rot + 1]
		if any [rot = 360 rot = -360] [rot: 0.0]
		grad/28: rot
	]
	draw grad
	return 
	sl: slider 512 [stimulus/rate: 1 + to integer! face/data * 99] 
	do [sl/data: 0.5]
]