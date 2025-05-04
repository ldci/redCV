Red [
	Title:   "Test ZLib "
	Author:  "ldci"
	File: 	 %compress.red
	Needs:	 'View
]

;required libs
#include %../../libs/tools/rcvTools.red
#include %../../libs/core/rcvCore.red
#include %../../libs/zLib/rcvZLib.red ;--Thanks to Bruno Anselme

margins: 5x5
defSize: 256x256
imgSize: 0x0
isFile: false
isCompressed: false

; compression level
cprx: ["Best speed" "Best compression" "Default"]
clevel: -1 ; default


loadImage: does [
	isFile: false
	tmp: request-file
	unless none? tmp [
		imgSize: rcvGetImageFileSize tmp	;--get image size
		rgb: rcvLoadImageAsBinary tmp		;--load image as binary values
		img1: rcvCreateImage imgSize		;--create image 
		img2: rcvCreateImage imgSize 		;--create image 
		img3: rcvCreateImage imgSize		;--create image 
		img1/rgb: rgb 						;--source image as binary
		b1/image: img1						;--show image
		b2/image: img2						;--show image
		b3/image: img3						;--show image
		f0/text: f1/text: f11/text: f2/text: f3/text: sb1/text: sb2/text: ""
		result: copy #{}					;--create binary string
		result2: copy #{}					;--create binary string
		f1/text: form imgSize
		isFile: true
		isCompressed: false
	]
]


compressImage: does [
	sb1/text: "Compressing image..."
	sb2/text: ""
	f0/text: f2/text:  ""
	img2/rgb: 0.0.0
	b2/image: img2
	img3/rgb: 0.0.0
	b3/image: img3
	do-events/no-wait
	n: length? rgb
	t1: now/time/precise
	result: rcvCompressRGB rgb clevel	;--compress image according level
	t2: now/time/precise
	sb1/text: rejoin ["Compressed in " rcvElapsed t1 t2 " ms"]
	nC: length? result	
	;image compression ratio τ 
	compression: round/to 1.0 - (nC / n) * 100 0.01
	f0/text: rejoin ["Compression: " form compression " %"]
	f11/text: rejoin [form n " bytes"]
	f2/text: rejoin [form nC " bytes"]
	; not useful for compression
	; only to show image compression 
	if cb/data [
		img2/rgb: copy result
		b2/image: img2
	]
	isCompressed: true
]

uncompressImage: does [
	sb2/text: "Uncompressing image..."
	f3/text: ""
	do-events/no-wait
	n: length? rgb
	t1: now/time/precise
	result2: rcvDecompressRGB result n	;-uncompress image
	t2: now/time/precise
	f3/text: rejoin [form length? result2 " bytes"]
	img3/rgb: copy result2
	b3/image: img3
	sb2/text: rejoin ["Uncompressed in " rcvElapsed t1 t2 " ms"]
]


view win: layout [
	title "Compress/Uncompress Images with Red and Bruno Anselme's ZLib"
	origin margins space margins
	button 90 "Load image" [loadImage]
	dp: drop-down 140 data cprx 
	select 3
	on-change [
		switch face/selected [
			1 [clevel: 1]
			2 [clevel: 9]
			3 [clevel: -1]
		]
		isCompressed: false
	]
	cb: check 130 "Show compression" true
	button 88 "Compress" [if isFile [compressImage]]
	f0: field 137
	button 93 "Uncompress" [if isCompressed [uncompressImage]]
	button 50 "Quit" [if isFile 
		[
			rcvReleaseImage img1 
			rcvReleaseImage img2 
			rcvReleaseImage img3
		]
		quit]
	return
	f1: field 125 f11: field 125
	text 125 "Compressed" f2: field 125
	text 125 "Uncompressed" f3: field 125
	return
	b1: base defSize black
	b2: base defSize black
	b3: base defSize black
	return
	pad 261x0
	sb1: field 256
	sb2: field 256
]


