Red [
	Title:   "Test Compression"
	Author:  "Francois Jouen"
	File: 	 %compress21.red
	Needs:	 'View
]

;--similar to compress2.red but with other methods
;required libs
#include %../../libs/tools/rcvTools.red
#include %../../libs/core/rcvCore.red

margins: 5x5
defSize: 256x256
imgSize: 0x0
isFile: false
isCompressed: false

; compression type
cprx: ["gzip" "zLib" "deflate"]
method: to-word "gzip"

n: 	0	;--non compressed image size
nc: 0	;--compressed image size

loadImage: does [
	isFile: false
	tmp: request-file
	unless none? tmp [
		imgSize: rcvGetImageFileSize tmp
		rgb: rcvLoadImageAsBinary tmp
		img1: rcvCreateImage imgSize 
		img2: rcvCreateImage imgSize 
		img3: rcvCreateImage imgSize
		img1/rgb: rgb 
		b1/image: img1
		b2/image: img2
		b3/image: img3
		f0/text: f1/text: f11/text: f2/text: f3/text: sb/text: ""
		f1/text: form imgSize
		result: copy #{}
		result2: copy #{}
		isFile: true
		isCompressed: false
	]
]


compressImage: does [
	sb/text: "Compressing image..."
	f0/text: f2/text:  ""
	img2/rgb: 0.0.0
	b2/image: img2
	img3/rgb: 0.0.0
	b3/image: img3
	do-events/no-wait
	n: length? rgb
	t1: now/time/precise
	result: compress rgb method
	t2: now/time/precise
	sb/text: rejoin ["Compressed in " rcvElapsed t1 t2 " ms"]
	nc: length? result	
	;image compression ratio τ 
	compression: round/to 1.0 - (nc / n) * 100 0.01
	f0/text: rejoin ["Compression: " form compression " %"]
	f11/text: rejoin [form n " bytes"]
	f2/text: rejoin [form nc " bytes"]
	; not useful for compression
	; only to show image compression
	if cb/data [
		img2/rgb: copy result
		b2/image: img2
	]
	isCompressed: true
]

uncompressImage: does [
	sb/text: ""
	f3/text: ""
	do-events/no-wait
	t1: now/time/precise
	result2: decompress/size result method n
	t2: now/time/precise
	f3/text: rejoin [form length? result2 " bytes"]
	img3/rgb: copy result2
	b3/image: img3
	sb/text: rejoin ["Uncompressed in " rcvElapsed t1 t2 " ms"]
]


view win: layout [
	title "Image compression with Red"
	origin margins space margins
	button 90 "Load image" [loadImage]
	dp: drop-down 140 data cprx 
	select 1
	on-change [
		method: to-word face/text
		isCompressed: false
	]
	cb: check 130 "Show compression" true
	button 88 "Compress" [if isFile [compressImage]]
	f0: field 136
	button 93 "Uncompress" [if isCompressed [uncompressImage]]
	button 50  "Quit" [if isFile [
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
	sb: field 778
]


