Red [
	Title:   "Robinson Filter "
	Author:  "ldci"
	File: 	 %robinson2.red
	Needs:	 'View
]


; required libs
#include %../../../libs/tools/rcvTools.red
#include %../../../libs/core/rcvCore.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/imgproc/rcvImgProc.red

margins: 10x10
defSize: 512x512
img1: rcvCreateImage defSize
gray: rcvCreateImage defSize
dst:  rcvCreateImage defSize
cImg:  rcvCreateImage defSize
isFile: false

knl: copy [1.0 1.0 1.0 1.0 -2.0 1.0 -1.0 -1.0 -1.0]
count: 0

loadImage: does [
    isFile: false
	canvas/image/rgb: black
	clear f/text
	clear fcount/text
	tmp: request-file
	if not none? tmp [
		win/text: copy "Edges detection: Robinson "
		append win/text to string! tmp
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		cImg rcvCreateImage img1/size
		either cb/data [cImg: rcvCloneImage gray]
					   [cImg: rcvCloneImage img1]
		
		
		dst:  rcvCloneImage cImg
		bb/image: img1
		knl: copy [1.0 1.0 1.0 1.0 -2.0 1.0 -1.0 -1.0 -1.0]
		count: 0
		f/text: form knl
		fcount/text: form count
		rcvConvolve cImg dst knl 1.0 0.0
		canvas/image: dst
		isFile: true
	]
	
]

; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: Robinson"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
		cb: check "Grayscale" 	[
					either cb/data  [cImg: rcvCloneImage gray]
					[cImg: rcvCloneImage img1]
					rcvConvolve cImg dst knl 1.0 0.0
					canvas/image: dst
		]
		button "Permutation" [
					either cb2/data [lcount: 8] [lcount: 9]
					if cb2/data [remove at knl 5]
					move knl tail knl
					if cb2/data [insert at knl 5 -2.0]
					f/text: form knl
					count: count + 1
					if count > lcount [count: 1]
					fcount/text: form count
					rcvConvolve cImg dst knl 1.0 0.0
					canvas/image: dst
		]
		
		cb2: check "Centered" false [
			knl: copy [1.0 1.0 1.0 1.0 -2.0 1.0 -1.0 -1.0 -1.0]
			count: 0
			f/text: form knl
			fcount/text: form count
		]
		
			
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage dst 
								rcvReleaseImage gray
								rcvReleaseImage cImg
								Quit]
		return
		bb: base 128x128 img1
		f: field 235 fcount: field 30 
		return
		canvas: base defSize dst	
		do [f/text: form knl fcount/text: form count]
]
