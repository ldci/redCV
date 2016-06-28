Red [
	Title:   "Test image operators and camera Red VID "
	Author:  "Francois Jouen"
	File: 	 %motion.red
	Needs:	 'View
]

{ Based on
Collins, R., Lipton, A., Kanade, T., Fijiyoshi, H., Duggins, D., Tsin, Y., Tolliver, D., Enomoto,
N., Hasegawa, O., Burt, P., Wixson, L.: A system for video surveillance and monitoring. Tech.
rep., Carnegie Mellon University, Pittsburg, PA (2000)}


; all we need for computer vision with red
#include %../libs/redcv.red ; for red functions
;do %../libs/redcv.red		 ; for red tests


live?: system/view/auto-sync?: no

rimg: make image! reduce [320x240 gray]
prevImg: copy rimg
currImg: copy rimg
nextImg: copy rimg
d1: copy rimg
d2: copy rimg
margins: 10x10


view win: layout [
		title "Video Surveillance and Monitoring"
		origin margins space margins
		cam: camera 320x240
		canvas: base 320x240 rimg rate 0:0:1 on-time [
			d1: rcvAbsdiff  prevImg currImg
			d2: rcvAbsdiff  currImg nextImg 
			r1: rcvAnd d1 d2
			;rcvThreshold r1 r1 35.0 255.0 CV_THRESH_BINARY; TBD
			motion/text: form rcvCountNonZero r1
			canvas/image: r1
			prevImg: currImg	
			currImg: nextImg
			nextImg: rcv2Gray/average to-image cam 	
			
		]
		return
		text 50 "Select" 
		cam-list: drop-list 180x32 on-create [
				face/data: cam/data
			]
		onoff: button "Start/Stop" 70x24 on-click [
				either cam/selected [
					cam/selected: none
					canvas/rate: none
					canvas/image: black
				][
					cam/selected: cam-list/selected
					canvas/rate: 0:0:0.040; 1/25 fps
				]
			]
		motion: field 	
		btnQuit: button "Quit" 70x24 on-click [quit]
		do [cam-list/selected: 1 canvas/rate: none]
]
	
	


