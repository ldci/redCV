Red [
	Title:   "Kirsch Filter "
	Author:  "ldci"
	File: 	 %kirsch2.red
	Needs:	 'View
]


; required libs
#include %../../../libs/tools/rcvTools.red
#include %../../../libs/core/rcvCore.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/imgproc/rcvImgProc.red


margins: 10x10
defSize: 512x512
newSize: 512x512
img1: rcvCreateImage defSize
gray: rcvCreateImage defSize
dst:  rcvCreateImage defSize
cImg:  rcvCreateImage defSize
isFile: false

knl: copy [5.0 5.0 5.0 -3.0 0.0 -3.0 -3.0 -3.0 -3.0] ; HZ kernel


count: 0

loadImage: does [
    isFile: false
	canvas/image/rgb: black
	clear f/text
	clear fcount/text
	tmp: request-file
	if not none? tmp [
		win/text: copy "Edges detection: Kirsch "
		append win/text to string! tmp
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		cImg rcvCreateImage img1/size
		either cb/data [cImg: rcvCloneImage gray]
					   [cImg: rcvCloneImage img1]
		
		; update faces
		either (img1/size/x = img1/size/y) [bb/size: 120x120] [bb/size: 160x120]
		dst:  rcvCloneImage cImg
		bb/image: img1
		knl: copy [5.0 5.0 5.0 -3.0 0.0 -3.0 -3.0 -3.0 -3.0]
		count: 0
		f/text: form knl
		fcount/text: form count
		rcvConvolve cImg dst knl 1.0 0.0
		canvas/image: dst
		isFile: true
		;defSize/y: img1/size/y
	]
	
]

; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: Kirsch"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
		cb: check "Grayscale" 	[
					either cb/data  [cImg: rcvCloneImage gray]
					[cImg: rcvCloneImage img1]
					dst:  rcvCloneImage cImg
					rcvConvolve cImg dst knl 1.0 0.0
					canvas/image: dst
		]
		button "Permutation" [
					either cb2/data [lcount: 8] [lcount: 9]
					if cb2/data [remove at knl 5]
					move knl tail knl
					if cb2/data [insert at knl 5 0.0]
					f/text: form knl
					count: count + 1
					if count > lcount [count: 1]
					fcount/text: form count
					rcvConvolve cImg dst knl 1.0 0.0
					canvas/image: dst
		]
		
		cb2: check "Centered" false [
				knl: copy [5.0 5.0 5.0 -3.0 0.0 -3.0 -3.0 -3.0 -3.0]
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
		canvas: base 512x512 dst	
		do [f/text: form knl fcount/text: form count]
]
