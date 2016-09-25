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
#include %../../libs/redcv.red ; for red functions

iSize: 320x240
rimg: rcvCreateImage iSize
prevImg: rcvCloneImage rimg
currImg: rcvCloneImage rimg
nextImg: rcvCloneImage rimg
d1: rcvCloneImage rimg
d2: rcvCloneImage rimg
r1: rcvCloneImage rimg
r2: rcvCloneImage rimg

margins: 10x10
threshold: 32

to-text: function [val][form to integer! 0.5 + 128 * any [val 0]]


view win: layout [
		title "Motion Detection"
		origin margins space margins
		text "Motion " 35 
		motion: field 50 rate 0:0:1 on-time [face/text: to-text rcvCountNonZero r2]
		btnQuit: button "Quit" 60x24 on-click [
			rcvReleaseImage rimg
			rcvReleaseImage prevImg
			rcvReleaseImage currImg
			rcvReleaseImage nextImg
			rcvReleaseImage d1
			rcvReleaseImage d2
			rcvReleaseImage r1
			rcvReleaseImage r2
			quit]
		return
		cam: camera iSize
		canvas: base 320x240 rimg rate 0:0:1 on-time [
			rcvAbsdiff  prevImg currImg d1
			rcvAbsdiff  currImg nextImg d2
			rcvAnd d1 d2 r1
			rcv2BWFilter r1 r2 threshold
			canvas/image: r2
			prevImg: currImg	
			currImg: nextImg
			nextImg: to-image cam
		]
		return
		text 50 "Select" 
		cam-list: drop-list 185x32 on-create [
				face/data: cam/data
			]
		onoff: button "Start/Stop" 65x24 on-click [
				either cam/selected [
					cam/selected: none
					canvas/rate: none
					motion/rate: none
					canvas/image: black
				][
					cam/selected: cam-list/selected
					canvas/rate: 0:0:0.10;  max 1/25 fps in ms
					motion/rate: 0:0:0.10				
					]
			]
		text "Filter" 30
		sl1: slider 250 [filter/text: to-text sl1/data threshold: to integer! filter/data ]
		filter: field 20 "32" 
		do [cam-list/selected: 1 motion/rate: canvas/rate: none sl1/data: 0.32 ]
]
	
	


