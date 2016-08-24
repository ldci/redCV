Red [
	Title:   "Highgui test"
	Author:  "Francois Jouen"
	File: 	 %testgui.red
	Needs:	 'View
]

; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
img1: rcvLoadImage %../../images/lena.jpg
img2: rcvCreateImage 512x512 

s1: rcvNamedWindow "Source"


rcvShowImage s1 img1
wait 2

rcvMoveWindow s1 20x60
wait 2

rcvResizeWindow s1 512x512
wait 2

dst: rcvNamedWindow "Destination"
rcvCopyImage img1 img2
rcvShowImage dst img2
wait 2

rcvFlip/horizontal img1 img2
rcvShowImage dst img2
wait 2

rcvFlip/vertical img1 img2
rcvShowImage dst img2
wait 2

rcvFlip/both img1 img2
rcvShowImage dst img2
wait 2


rcvNot img1 img2
rcvShowImage dst img2
wait 2

rcvDestroyAllWindows


;this can be also used for each window
;rcvDestroyWindow dst
;wait 1
;rcvDestroyWindow s1


do-events