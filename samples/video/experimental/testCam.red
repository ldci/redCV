Red [
	Title:   "Cam test"
	Author:  "Francois Jouen"
	File: 	 %testCam.red
	Needs:	 'View
]

; last Red Master required!
#include %../../../libs/redcv.red ; for redCV functions

s1: rcvNamedWindow "Camera"


; tests 
cam: 1
createCam cam
size: rcvgetCamSize cam

w: to integer! size/x
h: to integer! size/y
print w
print h
size: 640x480
rcvSetCamSize cam size
img: make image! reduce [size black]
rcvResizeWindow s1 size
rcvShowImage s1 img
i: 1 
while [i < 1000] [
	rcvGetCamImage cam img
	rcvShowImage s1 img
	print i 
	i: i + 1
]
print "Done"
rcvDestroyWindow s1