Red [
	Title:   "Test camera Red VID "
	Author:  "Francois Jouen"
	File: 	 %compress1.red
	Needs:	 'View
]

#system [
	#include %../../../libs/ZLib/zlib.reds ; for ZLib compression
	; Thanks to Bruno Anselme
	
]


margins: 5x5
defSize: 256x256
imgSize: 0x0
isFile: false
isCompressed: false


cprx: ["Best speed" "Best compression" "Default"]

clevel: -1

compressRGB: routine [rgb [binary!] level [integer!] return: [binary!]
	/local 
	byte-count
	data
	buffer 
	] [
	byte-count: 0
	data: binary/rs-head as red-binary! rgb
	buffer: zlib/compress data binary/rs-length? rgb :byte-count level
	as red-binary! stack/set-last as red-value! binary/load buffer byte-count
]


decompressRGB: routine [rgb [binary!] bCount [integer!] return: [binary!]
	/local 
	data
	buffer 
	] [
	data: binary/rs-head as red-binary! rgb
	buffer: zlib/decompress data bCount
	as red-binary! stack/set-last as red-value! binary/load buffer bCount
]



loadImage: does [
	isFile: false
	tmp: request-file
	if not none? tmp [
		img0: load tmp
		imgSize: img0/size
		rgb: copy img0/rgb
		img1: make image! imgSize 
		img2: make image! imgSize 
		img3: make image! imgSize 
		img1/rgb: rgb
		img2/rgb: 0.0.0
		img3/rgb: 0.0.0
		b1/image: img1
		b2/image: img2
		b3/image: img3
		f0/text: f1/text: f11/text: f2/text: f3/text: sb/text: ""
		result: copy #{}
		result2: copy #{}
		f1/text: form imgSize
		isFile: true
		isCompressed: false
	]
]


compressImage: does [
	f0/text: f2/text:  ""
	img2/rgb: 0.0.0
	b2/image: img2
	img3/rgb: 0.0.0
	b3/image: img3
	n: length? rgb
	t1: now/time/precise
	result: compressRGB rgb clevel
	n1: length? result	
	compression: 100 - (100 * n1 / n)
	f0/text: rejoin [" Compression: " form compression]
	append f0/text " %"
	f11/text: rejoin [form n " bytes"]
	f2/text: rejoin [form n1 " bytes"]
	; not useful for compression
	; only to show img2 and avoid pointer error
	if cb/data [
		i: n1 
		while [i < n ] [
			append result 0
			i: i + 1
		]
		img2/rgb: copy result
		b2/image: img2
	]
	t2: now/time/precise
	sb/text: rejoin ["Compressed in " form t2 - t1]
	isCompressed: true
]

uncompressImage: does [
	f3/text: ""
	n: length? rgb
	t1: now/time/precise
	result2: decompressRGB result n
	t2: now/time/precise
	f3/text: rejoin [form length? result2 " bytes"]
	img3/rgb: copy result2
	b3/image: img3
	
	sb/text: rejoin ["Uncompressed in " form t2 - t1]
]


view win: layout [
	title "Compress/Uncompress Images with Red and ZLib"
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
	]
	cb: check 130 "Show compression"
	button 90 "Compress" [if isFile [compressImage]]
	f0: field 120
	button 105 "Uncompress" [if isCompressed [uncompressImage]]
	button 50 "Quit" [quit]
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


