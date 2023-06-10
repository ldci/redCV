Red [
	Title:   "Channel tests "
	Author:  "Francois Jouen"
	File: 	 %redCVRemoveChannel.red
	Needs:	 'View
]

{based on A. Duarte et al. / Procedia Technology 16 (2014) 1560 – 1569
Segmentation algorithms for thermal images}


;required libs
#include %../../libs/core/rcvCore.red

isFile: false
margins: 10x10
gSize: 256x256
thresh: 1			

loadImage: does [	
	isFile: false
	canvas0/image: canvas1/image: canvas3/image: canvas4/image: none
	tmp: request-file 
	if not none? tmp [		
		simg: load tmp								;--source image	
		dimg: make image! reduce [simg/size black]	;--destination image
		mimg: make image! reduce [simg/size black]	;--mask image
		rimg: make image! reduce [simg/size black]	;--final result image
		canvas0/image: simg
		sl/data: 0%
		isFile: true
		process
	]
]

process: does [
	if isFile[
		case[
	 		r1/data [rcvRChannel simg dimg 1]
	 		r2/data [rcvRChannel simg dimg 2]
	 		r3/data [rcvRChannel simg dimg 3]
	 		r4/data [rcvRChannel simg dimg 4]
	 		r5/data [rcvRChannel simg dimg 5]
	 		r6/data [rcvRChannel simg dimg 6]
		]
		canvas1/image: dimg
	]
]

process2: does [
	if isFile [
		rcvThreshold/binary dimg mimg thresh 255 ;--mask 0 or 255 according to thresh
		rcvAnd simg mimg rimg					 ;--And source  and mask 
		canvas3/image: mimg
		canvas4/image: rimg 
	]
]


; ***************** Test Program ****************************
view win: layout [
		title "Thermal images segmentation with redCV"
		origin margins space margins
		button 60 "Load"	[loadImage]
		text 100 "Remove Channel"
		r1: radio 30 "R" 	[process]
		r2: radio 30 "G" 	[process]
		r3: radio 30 "B"	[process]
		text 100 "Keep Channel"
		r4: radio 30 "R" 	[process]
		r5: radio 30 "G" 	[process]
		r6: radio 30 "B"	[process]	
		sl: slider 255 		[thresh: 1 + to-integer (face/data *  254)  
							f/text: form to-float face/data
							process2]
		f: field 40 "0.0" 
		pad 140x0		
		button 60 "Quit" 	[Quit]
		return
		text 256 "Source" text 256 "Destination" text 256 "Mask" text 256 "Result"
		return
		canvas0: base gSize black canvas1: base gSize black
		canvas3: base gSize black canvas4: base gSize black
		do  [r1/data: true]
]