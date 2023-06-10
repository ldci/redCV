Red [
	Title:   "Highgui test"
	Author:  "Francois Jouen"
	File: 	 %testgui.red
	Needs:	 'View
]

; last Red Master required!
#include %../../libs/core/rcvCore.red
#include %../../libs/highgui/rcvHighGui.red

img1: rcvLoadImage %../../images/lena.jpg
img2: rcvCreateImage img1/size ;512x512 

s1: rcvNamedWindow "Source" 


print ["Shows source image"]
rcvShowImage s1 img1

wait 2

print ["Moves source image"]
rcvMoveWindow s1 20x60
wait 2

print ["Resizes source image"]
rcvResizeWindow s1 512x512

print ["Creates and shows destination image"]
dst: rcvNamedWindow "Destination"
rcvCopyImage img1 img2
rcvShowImage dst img2

wait 2
print ["Destination = Not Source"]
rcvNot img1 img2
rcvShowImage dst img2

print ["Done"]
do-events