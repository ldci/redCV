Red [
	Title:   "Red Computer Vision: TIFF functions "
	Author:  "Francois Jouen"
	File: 	 %tifflib.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]



#include %rcvTiffRoutines.red

;********************* Exported Functions  ***************
; Basic Tiff image reading with red 

rcvLoadTiffImage: func [
	f 		[file!]
	return: [logic!]
][
	bigEndian: false 			; by default intel 
	bStripOffsets: copy []		; list of strips offset
	bStripByteCounts: copy []	; list of strips length
	tiffValues: copy []			; block of tags value
	imageData: copy #{} 		; image Data binary string
	tagList: copy []			; tag list for visualization
	IFDOffsetList: copy []		; list of Image File Directory
	cc: 1
	NumberOfPages: 0
	; default 8-bit image with 3 channels
	sampleFormat: 		1     
	samplesPerPixel:	3
	bitsPerSample: 		8
	ret: true
	tiff: read/binary f 
	either _assertTiffFile [
		_rcvReadTiffHeader 
		_rcvmakeTiffIFDList
		rcvReadTiffImageData 1
		ret: true
		] [ret: false]
	ret
]




; procedure to read  multiple images from the tiff file
;parameter: the number of the page in case of multipage file

rcvReadTiffImageData: func [page [integer!]] [
	imageData: copy #{}
	_getImageType page					; image type
	_readImageFileDirectory page		; read file dir and process all tags

	bStripOffsets: head  bStripOffsets
	bStripByteCounts: head bStripByteCounts
	
	StripsPerImage: TImage/ImageLength + TImage/RowsPerStrip - 1 / TImage/RowsPerStrip
	;Since each strip is a stream of bytes no endianess correction is needed.
	
	; all data are here in an unique strip
	if StripsPerImage = 1 [
		startoff: bStripOffsets/1
		dataLength: to-integer bStripByteCounts/1
		tiff:  head tiff 
		data:  skip tiff  to-integer startoff
		append imageData  copy/part data dataLength
	]
	
	
	; image data are associated to stripes offset
	if StripsPerImage > 1 [
		i: 1
		sumD: 0
		while [i < StripsPerImage] [
			startoff: bStripOffsets/:i
			dataLength: to-integer bStripByteCounts/:i
			tiff:  head tiff 
			data:  skip tiff to-integer startoff
			append imageData copy/part data dataLength
			sumD: sumD + dataLength
			i: i + 1
		]
		; find remainding values 
		calc: TImage/ImageLength * TImage/ImageWidth * BitsPerSample
		remain: calc - sumD
		if remain > 0 [
			data: skip data dataLength
			append imageData copy/part data remain
		]
	]	
]


; Tiff images to Red Image datatype

rcvTiff2RedImage: func [return: [image!]] [
 	src: make image! reduce [ to-pair compose [(TImage/ImageWidth) (TImage/ImageLength)] imageData]
 	img: rcvCreateImage src/size
 
 	; Tiff bit per Sample
 	; TIFF grayscale images are 4 and 8
 	; 4 or 8 for  Palette Color Images
 	; 8,8,8 for RGB Full Color Images
 	; 16, 32: ???
 	
 	;SamplesPerPixel is usually 1 for bilevel, grayscale, and palette-color images. 
 	;SamplesPerPixel is usually 3 for RGB images.
 	;SamplesPerPixel is usually 4 for ARGB images.
 	
 	if samplesPerPixel = 1 [_rcvBinary2Image imagedata src] 
 	if SamplesPerPixel = 4 [src/argb: imageData]
 	
 	; test motorola or intel byte order for Tiff image 
 	either bigEndian [rcv2BGRA src img] [rcvCopyImage src img] 
 	img 
]





; basic tiff writing 24-bit colour RGB red image
; mode 1: intel little endian
; mode 2: motorola big endian 
; actually red only supports little endian


rcvSaveTiffImage: func [redImage [image!] f [file!] mode [integer!]] [
	; image size
	nx: redImage/size/x 
	ny: redImage/size/y
	nChannels: 3
	nEntries: 15
	baseOffset: nEntries + (nEntries * 12)
	if odd? baseOffset [baseOffset: baseOffset + 1]
	; creates tiff file and file header
	either ( mode = 1)  [write/binary f TIFF_LITTLEENDIAN] 
						[write/binary f TIFF_BIGENDIAN]
	
	either (mode = 1) [str: "2a00"] [str: "002a"] 
	write/binary/append f debase/base str 16
	
	; IDF offset
	_offset: (nx * ny * nChannels) + 8
	bin: to-binary _offset
	if mode = 1 [reverse bin]
	write/binary/append f bin	
	
	;end of header
	
	;Write binary image data
	write/binary/append f redImage/rgb   
	
	; first and unique IFD
	; The number of directory entries
	str: to-string to-hex/size nEntries 4
	write/binary/append f debase/base str 16
	
	; Tag 1: 256: image  width , short int (3)
	either (mode = 1) [str: "0001030001000000"] [str: "0100000300000001"]
	write/binary/append f debase/base str 16
	bin: to-binary nx
	if mode = 1 [reverse bin]
	write/binary/append f bin
	
	;tag 2: 257: image height  , short int (3)
	either (mode = 1) [str: "0101030001000000"] [str: "0101000300000001"]
	write/binary/append f debase/base str 16
	bin: to-binary ny
	if mode = 1 [reverse bin]
	write/binary/append f bin
	
	
	;Tag 3: 258 Bits per sample tag, short int 
	_offset: (nx * ny * nChannels) + baseOffset; 
	either (mode = 1) [str: "0201030003000000"] [str: "0102000300000003"]
	write/binary/append f debase/base str 16
	bin: to-binary _offset
	if mode = 1 [reverse bin]
	write/binary/append f bin
	
	; tag 4: 259: Compression flag, short int : 1 none
	either (mode = 1) [str: "030103000100000001000000"] [str: "010300030000000100010000"]
	write/binary/append f debase/base str 16
	
	;Tag 5: 262 ; Photometric interpolation tag, short int: 2 RGB
	either (mode = 1) [str: "060103000100000002000000"] [str: "010600030000000100020000"]
	write/binary/append f debase/base str 16
	
	;Tag 6: 273 : Strip offset tag, long int
	either (mode = 1) [str: "110104000100000008000000"] [str: "011100040000000100000008"]
	write/binary/append f debase/base str 16
	
	;tag 7: 274 Orientation flag, short int 1: Top and Left
	either (mode = 1) [str: "120103000100000001000000"] [str: "011200030000000100010000"]
	write/binary/append f debase/base str 16
	
	;Tag 8 277;Sample per pixel tag, short int 3 since RGB Image
	either (mode = 1) [str: "150103000100000003000000"] [str: "011500030000000100030000"]
	write/binary/append f debase/base str 16
	
	;Tag 9: 278 Rows per strip tag, short int
	either (mode = 1) [str: "1601030001000000"] [str: "1601030001000000"]
	write/binary/append f debase/base str 16
	bin: to-binary ny
	if mode = 1 [reverse bin]
	write/binary/append f bin
	
	;Tag 10: 279 Strip byte count flag, long int 
	either (mode = 1) [str: "1701040001000000"] [str: "0117000400000001"]
	write/binary/append f debase/base str 16
	bin: to-binary (nx * ny * nChannels)
	if mode = 1 [reverse bin]
	write/binary/append f bin
	
	
	; Tag 11: 280 Minimum sample value flag, short int  
	_offset: (nx * ny * nChannels) + baseOffset + 6 
	either (mode = 1) [str: "1801030003000000"] [str: "0118000300000003"]
	write/binary/append f debase/base str 16
	bin: to-binary _offset
	if mode = 1 [reverse bin]
	write/binary/append f bin
	
	; Tag 12: 281 Max sample value flag, short int  
	_offset: (nx * ny * nChannels) + baseOffset + 12 
	either (mode = 1) [str: "1901030003000000"] [str: "0119000300000003"]
	write/binary/append f debase/base str 16
	bin: to-binary _offset
	if mode = 1 [reverse bin]
	write/binary/append f bin
	
	;Tag 13: 284 ;Planar configuration tag, short int 3
	either (mode = 1) [str: "1c0103000100000001000000"] [str: "011c00030000000100010000"]
	write/binary/append f debase/base str 16
	
	; Tag 14: 305 Sotfware; ascii 2
	_offset: (nx * ny * nChannels) +  baseOffset + 22
	either (mode = 1) [str: "3101020026000000"] [str: "0131200026000000"]
	write/binary/append f debase/base str 16
	bin: to-binary _offset
	if mode = 1 [reverse bin]
	write/binary/append f bin	
	
	
	;Tag 15: 339 Sample format tag, short int
	_offset: (nx * ny * nChannels) + baseOffset + 18
	either (mode = 1) [str: "5301030003000000"] [str: "0153000300000003"]
	write/binary/append f debase/base str 16
	bin: to-binary _offset
	if mode = 1 [reverse bin]
	write/binary/append f bin
	
	;End of the directory entry
	str: "00000000"
	write/binary/append f debase/base str 16
	
	; now write values addressed by pointers
	;Bits for each colour channel
	either (mode = 1) [str: "080008000800"] [str: "000800080008"]
	write/binary/append f debase/base str 16
	;Minimum value for each component
	str: "000000000000"
	write/binary/append f debase/base str 16
	;Maximum value per channel
	either (mode = 1) [str: "ff00ff00ff00"] [str: "00ff00ff00ff"]
	write/binary/append f debase/base str 16
	;Samples per pixel for each channel
	either (mode = 1) [str: "010001000100"] [str: "000100010001"]
	write/binary/append f debase/base str 16
	
	; redCV software
	str: "7265644356206C696272617279"
	write/binary/append f debase/base str 16
]

















