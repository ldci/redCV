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

#include %rcvTiffObject.red ; for Tiff definitions

; Thanks to Xie Qingtian for bin to integer R/S func
#system [
	bin2int: func [
    p       	[byte-ptr!]
    len     	[integer!]      ;-- len <= 4
    return: 	[integer!]
    /local
        i      	[integer!]
        factor 	[integer!]
	][
    	i: 0
    	factor: 0
    	loop len [
        	i: i + ((as-integer p/value) << factor)
        	factor: factor + 8
       		p: p - 1
    	]
    	i
	]
]


;global variables
tiff:				#{}			; binary file
tiffValues: 		[]			; block of tags values
tagList: 			[]			; list of tags for visualization
IFDOffsetList: 		[]			; list of Image File Directory offsets and number of entries
bigEndian: 			false 		; by default intel 
cc: 				1			; for data offset computation
numberOfPages:		1			; 1 image
imageType: 			"grayscale"	; default grayscale or bi-level 
src:				make image! 5x5

endian: func [str [binary!]
][
	if not bigEndian [reverse str]
	to-integer str
]

rcvAssertTiffFile: func [
"Tiff file or not?"
	return: [logic!]
][
	isTiffFile: false
	tiff: head tiff
	tmp: copy/part skip tiff 0 2
	if any [tmp = TIFF_BIGENDIAN tmp = TIFF_LITTLEENDIAN] [isTiffFile: true] 
	isTiffFile
]

rcvReadTiffHeader:  func [
"Read Tiff File header (8 bytes)"
][
	tiff: head tiff
	; file created by motorola (big endian) or intel (litte endian) processor?
	tmp: copy/part skip tiff 0 2 ; byte order
	either (tmp = TIFF_BIGENDIAN) 	[bigEndian: true byteOrder: "Motorola"] 
									[bigEndian: false byteOrder: "Intel"]
	TiffHeader/tiffBOrder: endian tmp
	tmp: copy/part skip tiff 2 2 
	TiffHeader/tiffVersion: endian tmp  ; expected value: 42 TIFF_VERSION_CLASSIC
	tmp: copy/part skip tiff 4 4
	TiffHeader/tiffFIFD: endian tmp ;offset of the first Image File Directory
]

rcvmakeTiffIFDList: func [
"makes the list of  Image File Directory (IFD 12 bytes)"
][
	IFDOffsetList: copy []
	;now move to the First Image directory offset and get the number of entries
	tiff: head tiff
	stream: skip tiff TiffHeader/tiffFIFD
	startOffset: TiffHeader/tiffFIFD
	tmp: copy/part stream 2 
    numberOfEntries:  endian  tmp     ; number of directory entries
    bloc: copy []
    append bloc startOffset
    append bloc  numberOfEntries    
    append/only IFDOffsetList  bloc  
    ;move to the next IDF offset and get the value
    nextOffset: startOffset + 2 + (numberOfEntries * 12)	; Offset of next IFD
    stream: skip tiff nextOffset 
    tmp: copy/part stream 4 
    offsetValue:  endian  tmp 
    ;now move to the other IFD if exist and get the number of entries
    ; this is case for multi pages files
    ;repeat until ifd offset = 0
    if  offsetValue > 0 [
    	until [
    		startOffset: offsetValue 
    		stream: skip tiff startOffset 
    		tmp: copy/part stream 2                      
    		numberOfEntries: endian tmp	
    		bloc: copy []
    		append bloc startOffset
    		append bloc numberOfEntries 
    		append/only IFDOffsetList bloc 
    		nextOffset: startOffset + 2 + (numberOfEntries * 12)
    		stream: skip tiff nextOffset 
    		tmp: copy/part stream 4
    		offsetValue: endian tmp
    		offsetValue = 0   
    	]
    ]
    numberOfPages: length? IFDOffsetList  
]

; what kind of images are included in the file ?
; parameter the number of the image

rcvGetTiffImageType: func  [
"Returns the image type"
	pageNumber [integer!]
][
	photometric: 0
	bloc: pick IFDOffsetList pageNumber 
	startOffset: first bloc ; offset
	numberOfEntries second bloc ; number of entries
	i: 1 
	while [i <= numberOfEntries] [
		tagOffset: (startOffset + 2) + ( 12 * (i - 1))
		tiff: head tiff
		tiff2: skip tiff  tagOffset
		stream: copy/part tiff2 12
		; tag number
		tmp: copy/part stream 2                              
    	TImgFDEntry/tiffTag: endian tmp
		stream: skip stream 8
    	; value for phometric  
		tmp: copy/part stream 4             
    	TImgFDEntry/tiffOffset: endian tmp ; value or pointer
    	; get PhotometricInterpretation
    	if (TImgFDEntry/tiffTag = 262) [photometric: TImgFDEntry/tiffOffset]
		i: i + 1
	] 
	
	; correction for long value
	if photometric > 65535 [photometric: photometric / 65536]
	
	; image type according to PhotometricInterpretation
   	imageType: "bilevel" ; default 0
   	case [
   		photometric = 0 [imageType: "bilevel"] 
    	photometric = 1 [imageType: "grayscale"]
   		photometric = 2 [imageType: "rgb"]
   		photometric = 3 [imageType: "palette"]
   	]
   	
   	;makes the image structure     
    switch imageType [
    	"bilevel" 	[Timage: make object! TBiLevel]
    	"grayscale" [Timage: make object! TGrayScale]
    	"palette" 	[Timage: make object! TColorPalette]
    	"rgb" 		[Timage: make object! TRGBImage]
    ] 
]

rcvGetTiffTagValue: func [
"Reads tag value"
][
	; use a block rather a string for specific tags such as StripOffsets 
	tiffValues: copy []  
	tiff: head tiff
	; adapt to the real data length in reference to data type
		switch TImgFDEntry/tiffDataType [
    	 	0  [cc: 1 ] ;[TIFF_NOTYPE] placeholder ; 1 byte
			1  [cc: 1 ] ;[TIFF_BYTE] 8-bit unsigned integer
			2  [cc: 1 ] ;[TIFF_ASCII]8-bit bytes w/ last byte null 
			3  [cc: 2 ] ;[TIFF_SHORT];16-bit unsigned integer 
			4  [cc: 4 ] ;[TIFF_LONG] 32-bit unsigned integer 
			5  [cc: 8 ] ;[TIFF_RATIONAL]; 64-bit unsigned fraction (Two longs first represents the numerator and second the denominator)
			6  [cc: 1 ] ;[TIFF_SBYTE] ; !8-bit signed integer 
			7  [cc: 1 ] ;[TIFF_UNDEFINED] ;!8-bit untyped data (similar to ascii)
			8  [cc: 2 ] ;[TIFF_SSHORT]; !16-bit signed integer 
			9  [cc: 4 ] ;[TIFF_SLONG]; !32-bit signed integer 
			10 [cc: 8 ] ;[TIFF_SRATIONAL]; !64-bit signed fraction (Two longs first represents the numerator and second the denominator)
			11 [cc: 4 ] ;[TIFF_FLOAT]; !32-bit IEEE floating point 
			12 [cc: 8 ] ;[TIFF_DOUBLE] ;!64-bit IEEE floating point    
	 	]
	 	
	 	tlong: (TImgFDEntry/tiffDataLength * cc )
	 	
	 	; <= 4 bytes: value is here in TImgFDEntry/tiffOffset
    	if tlong <= 4 [
    		value: TImgFDEntry/tiffOffset
    		; test for 8-bit value
    		if (TImgFDEntry/tiffDataType = 1) and (value > 255) [value: (TImgFDEntry/tiffOffset / 256)]
    		if (TImgFDEntry/tiffDataType = 6) and (value > 255) [value: (TImgFDEntry/tiffOffset / 256)]
    		; test for 16-bit value
    		if (TImgFDEntry/tiffDataType = 3) and (value > 65535) [value: to-integer (TImgFDEntry/tiffOffset / 65536)]
    		if (TImgFDEntry/tiffDataType = 8) and (value > 32767) [value: to-integer (TImgFDEntry/tiffOffset / 32768)]
        	TImgFDEntry/redValue: form value	; for Red
        	append tiffValues value 
        ] 
        
        ; > 4 bytes: value is not here
        ;go to pointer offset to find the tag value and put value in red string
        if tlong > 4 [
        	tiff:  skip tiff  to-integer TImgFDEntry/tiffOffset
        	str: copy/part tiff tlong
        	switch TImgFDEntry/tiffDataType [
        		0 [TImgFDEntry/redValue: str]
        		1 [TImgFDEntry/redValue: str]
				2 [TImgFDEntry/redValue: str] 
				3 [ n1: copy/part str 2
					TImgFDEntry/redValue: endian  n1 
				] 
				4 [	tmpstr: copy ""
					cpt: 1
					until [
						n1:  endian  copy/part str 4
						append tiffValues  n1
						either cpt <= (TImgFDEntry/tiffDataLength - 1)
						[append tmpstr rejoin [to-string n1 " "]]
						[append tmpstr to-string n1]
						str: skip str 4
						cpt: cpt + 1
						cpt = TImgFDEntry/tiffDataLength
					]
				   	TImgFDEntry/redValue: tmpstr
				]
				5 [ ; 64-bit unsigned fraction  -> get 2 values
					n1:  to-float endian  copy/part str 4
					str: skip str 4
					n2:  to-float endian  copy/part str 4
					TImgFDEntry/redValue: form n1 / n2
				]
				6 [TImgFDEntry/redValue: str]  
				7 [TImgFDEntry/redValue: str] 
				8 [n1:  endian  copy/part str 2
					TImgFDEntry/redValue: form n1
				]
				9 [n1:  endian  copy/part str 4
					TImgFDEntry/redValue: form n1
				]
				10 [; 64-bit unsigned fraction  -> get 2 values
					n1:  to-float endian  copy/part str 4
					str: skip str 4
					n2:  to-float endian  copy/part str 4
					TImgFDEntry/redValue: form n1 / n2
				]
				11 [n1:  endian  copy/part str 8
					TImgFDEntry/redValue: form n1   
	 			]
				12 [n1:  endian  copy/part str 8
					TImgFDEntry/redValue: form n1   
	 			]
        	]
    	]
    	rcvProcessTiffTag
]

rcvProcessTiffTag: func [
"Processes tag value"
][
	tagLabel: select tiffTags TImgFDEntry/tiffTag ; tiffTags a block!
	if not none? tagLabel [
		str: copy "[" 
		append str form TImgFDEntry/tiffTag
		append str "] " 
		x: length? tagLabel
		append append str form first tagLabel ": "
		code: TImgFDEntry/tiffTag
		; for human readable string
		if error? try [s: to-string TImgFDEntry/redValue ] [s: TImgFDEntry/redValue]
		append str s
		; to find secondary label 
		if error? try [val: to-integer TImgFDEntry/redValue] [val: 0]
		if x = 2 [
			val2: select second tagLabel val
			append append append str " (" val2 ")"
		]
		; update tagList for visualization
		append/only tagList str
		
		; update TImage fields
		switch TImgFDEntry/tiffTag [
			254 [TImage/SubfileType: 	to-integer TImgFDEntry/redValue]
			255 [TImage/NewSubfileType: to-integer TImgFDEntry/redValue]
			256 [TImage/ImageWidth:  	to-integer TImgFDEntry/redValue]
			257 [TImage/ImageLength: 	to-integer TImgFDEntry/redValue]
			258 [TImage/BitsPerSample: 	to-integer TImgFDEntry/redValue]
			259 [TImage/Compression:  	to-integer TImgFDEntry/redValue]
			262 [TImage/PhotometricInterpretation: to-integer TImgFDEntry/redValue]
			273 [TImage/StripOffsets: copy tiffValues]
			277 [samplesPerPixel: 1 ; default grayscale, bi-level image or color palette
				if imageType = "rgb" [
					TImage/SamplesPerPixel: to-integer TImgFDEntry/redValue
					samplesPerPixel: tImage/SamplesPerPixel]
			] 
			278 [TImage/RowsPerStrip: to-integer TImgFDEntry/redValue]
			279 [TImage/StripByteCounts: copy tiffValues]
			282 [TImage/XResolution: to-float TImgFDEntry/redValue ]
			283 [TImage/YResolution: to-float TImgFDEntry/redValue]
			296 [TImage/ResolutionUnit: to-integer TImgFDEntry/redValue]
			320 [if imageType = "palette" [
				TImage/Colormap: TImgFDEntry/tiffOffset
		     	TImage/ColorMapCount: (TImgFDEntry/tiffDataLength * cc )]
		     	]
			339 [sampleFormat: to-integer TImgFDEntry/redValue]
		] 
	]
]


; get the image description for each subfile included in the file
; Image File Directory is 12 bytes
; index is the page number by default: 1

rcvReadTiffFileDirectory: func [
"Get the image description for each subfile included in the file"
	index [integer!]
][
	clear tagList
	bloc: IFDOffsetList/:index
	startOffset: first bloc
	numberOfEntries: second bloc
	i: 1
	while [i <= numberOfEntries ] [
		tagOffset: startOffset +  (12 * (i - 1)) + 2
		; read directory entry (12 bytes)
		tiff: head tiff
		tiff:  skip tiff tagOffset 
		stream: copy/part tiff 12
		tmp: copy/part stream 2  
    	TImgFDEntry/tiffTag: endian tmp ; get tag number
    	stream: skip stream 2
    	tmp: copy/part stream 2                              
    	TImgFDEntry/tiffDataType: endian tmp ; tag type
    	stream: skip stream 2
    	tmp: copy/part stream 4                           
    	TImgFDEntry/tiffDataLength: endian tmp; The number of values, Count of the indicated Type.
    	stream: skip stream 4
    	tmp: copy/part stream 4                  
    	TImgFDEntry/tiffOffset: endian tmp ; value or offset data 
    	rcvGetTiffTagValue; get the tag value OK
		i: i + 1
	]
]

; procedure to read  multiple images from the tiff file
;parameter: the number of the page in case of multipage file

rcvReadTiffImageData: func [page [integer!]] [
	imageData: copy #{}					; a copy for each page
	rcvGetTiffImageType page			; image type in TImage
	rcvReadTiffFileDirectory page		; read file dir and process all tags
	; for image stripes 
	; if flag 278 is not documented -> 1 rowsPerStripe
	if TImage/RowsPerStrip = 1 [rowsPerStrip: 1]
	; flag 258 documented 
	if TImage/RowsPerStrip > 1 [
		rps: TImage/ImageLength + TImage/RowsPerStrip - 1 /  TImage/RowsPerStrip
		rowsPerStrip: to-integer round/floor rps ;--Round in negative direction 
	]
		
	TImage/StripOffsets: head TImage/StripOffsets
	TImage/StripByteCounts: head TImage/StripByteCounts
	
	;Since each strip is a stream of bytes no endianess correction is needed.
	if rowsPerStrip = 1 [
		; all data are here in an unique strip
		startoff: to-integer TImage/StripOffsets/1
		dataLength: to-integer TImage/StripByteCounts/1
		tiff:  head tiff 
		data:  skip tiff  to-integer startoff
		append imageData  copy/part data dataLength
	]
	if rowsPerStrip > 1 [
		; image data are associated to stripes offset
		i: 1
		sumD: 0
		while [i < RowsPerStrip] [
			startoff: TImage/StripOffsets/:i
			dataLength: TImage/StripByteCounts/:i
			tiff:  head tiff 
			tdata:  skip tiff startoff
			append imageData copy/part tdata dataLength
			sumD: sumD + dataLength
			i: i + 1
		]
		; find remainding values 
		calc: TImage/ImageLength * TImage/ImageWidth * TImage/BitsPerSample
		remain: calc - sumD
		if remain > 0 [
			tdata: skip tdata dataLength
			append imageData copy/part tdata remain
		]
	]
]


; Tiff images to Red Image 

copyImage: routine [
"Copy source image to destination image"
    src 	[image!]
    dst  	[image!]
    /local
        pixS pixD 			[int-ptr!]
        handleS handleD i n [integer!]
][
    handleS: 0 handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
    i: 0
    while [i < n] [
    	pixD/value: pixS/value
        pixS: pixS + 1 pixD: pixD + 1
    	i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]


;for 8-bit and 1-channel image (bi-level or grayscale)

tiff2Image: routine [
"Convert Tiff image to Red image"
	bin		[binary!]
	dst		[image!]
	/local
	pixD 		[int-ptr!]
	handle pos	[integer!]
	w h x y i	[integer!]
][
	handle: 0
    pixD: image/acquire-buffer dst :handle
    w: IMAGE_WIDTH(dst/size)
    h: IMAGE_HEIGHT(dst/size)
    y: 0
    pos: 0
    while [y < h][
    	x: 0
    	while [x < w] [
       		i: binary/rs-abs-at bin pos
       		pixD/value: ((255 << 24) OR (i << 16 ) OR (i << 8) OR i)
        	pixD: pixD + 1
        	pos: pos + 1
        	x: x + 1
        ]
    	y: y + 1
    ]
    image/release-buffer dst handle yes
]

; for 32-bit image (not used)
binary2mat: routine [
"Read 32-bit Tiff images"
	binStr 	[binary!]
	step	[integer!]
	return:	[vector!]
	/local
	mat		[red-vector!]
	pMat	[int-ptr!]
	s    	[series!]
	h t		[byte-ptr!]
	l int	[integer!]
][
	l: (binary/rs-length? binStr) / step
	h: binary/rs-head binStr
	t: binary/rs-tail binStr
	;make vector -- slot, size, type, unit
	mat: vector/make-at stack/push* l TYPE_INTEGER 4; 32-bit integer 
	pMat: as int-ptr! vector/rs-head mat			; vector pointer
	while [h < t] [
		int: (integer/from-binary binStr)			; get value
		if int 	>= 65536 [int: int / 65536]		
    	if int	>= 256 	 [int: int / 256]	
		pMat/1: int									; add to mat
		binary/rs-skip binStr step					; next value according to step
		pmat: pMat + 1								; update vector pointer						
		h: h + step
	]
	s: GET_BUFFER(mat)							 	; get mat values as series
    s/tail: as cell! (as float-ptr! s/offset) + l  	; set the tail properly
    as red-vector! stack/set-last as cell! mat     	; return the new vector
]

tiff82Red: does [
	iSize: to-pair compose [(TImage/ImageWidth) (TImage/ImageLength)]
 	src: make image! iSize 
	switch SamplesPerPixel [ 
		1 [tiff2Red 1 imagedata src]	; for bilevel, grayscale, and palette-color images
		3 [src/rgb:  copy imageData]	; for RGB images		
		4 [src/argb: copy imageData]	; for ARGB images
	]
]

;for 1-channel image (bi-level or grayscale)
decodeBin: routine [
	bin 	[binary!]
	mat		[vector!]
	step	[integer!]
	/local
	s		[byte-ptr!]
	e		[byte-ptr!]
	n		[integer!]
	int		[integer!]
	scale	[integer!]
][
	vector/rs-clear mat								;-- clear matrix
	s: binary/rs-head bin       					;-- start
	n: binary/rs-length? bin						;-- bin length?
	e: s + n                    					;-- end
	switch step [
		1	[scale: 1]								;-- 8-bit  image default 
		2	[scale: 16]								;-- 16-bit image
		4	[scale: 65536]							;-- 32-bit image
		default [scale: 1]
	]
	
	while [s < e][
		if s + step > e [step: as-integer e - s]    ;-- check if pass the end
    	int: (bin2int s step) / scale	
    	if step = 4 [
    		if int = 0 [int: (bin2int s step)]		; specific 32-bit 0..255
    	]									
    	vector/rs-append-int mat int
    	s: s + step
	]
]

mat2Image: routine [
	mat		[vector!]
	dst		[image!]
	/local
	pixD 			[int-ptr!]
	value			[byte-ptr!]
	handle unit		[integer!]
	s				[series!]
	h w x y i	[integer!]
	
] [
	handle: 0
    pixD: image/acquire-buffer dst :handle
    w: IMAGE_WIDTH(dst/size) 
    h: IMAGE_HEIGHT(dst/size) 
    value: vector/rs-head mat ; get pointer address of the matrice
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	print unit
	y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
       		i: vector/get-value-int as int-ptr! value unit; get mat value as integer
       		if unit = 1 [i: i and FFh] ; for 8-bit values [-127 .. 127]
       		pixD/value: ((255 << 24) OR (i << 16 ) OR (i << 8) OR i)
       		value: value + unit
           	pixD: pixD + 1
           	x: x + 1
       ]
       y: y + 1
    ]
    image/release-buffer dst handle yes
]

convert: routine [
"General image conversion routine"
    src [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pixS 	[int-ptr!]
        pixD 	[int-ptr!]
        handleS	[integer!] 
        handleD	[integer!] 
        n i		[integer!] 
        a r g b	[integer!] 
        
][
    handleS: 0
    handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    n: IMAGE_WIDTH(src/size) * IMAGE_HEIGHT(src/size)
   	i: 0
    while [i < n] [
    	a: pixS/value >>> 24
       	r: pixS/value and 00FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh 
        switch op [
        	1 [pixD/value: (a << 24) OR (b << 16 ) OR (g << 8) OR r] ;2BGRA
            2 [pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b] ;2RGBA
        ]
        pixS: pixS + 1
        pixD: pixD + 1
       i: i + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]


tiff2Red: func [
	step	[integer!]
][
	imageData:  head imageData 
 	mat: make vector! []
 	decodeBin imageData mat step
 	iSize: to-pair compose [(TImage/ImageWidth) (TImage/ImageLength)]
 	src: make image! iSize
 	mat2Image mat src
]



; Show Tiff image
rcvTiff2RedImage: func [return: [image!]] [
	switch TImage/BitsPerSample [
		8  [tiff82Red] 		;  8-bit Image  
		16 [tiff2Red 2]		;  16-bit Image
		32 [tiff2Red 4]		;  32-bit Image
	]
 	img: make image! src/size 
 	; test motorola or intel byte order for Tiff image 
 	either bigEndian [ 
 			either rowsPerStrip = 1 [convert src img 2] [convert src img 1]
 	] [copyImage src img] 
 	img 
]


;***************** Basic Tiff image reading and writing with Red ***************

rcvLoadTiffImage: func [
	f 		[file!]
	return: [logic!]
][
	cc: 1
	numberOfPages: 1
	; default 8-bit image with 3 channels
	sampleFormat: 				1     
	samplesPerPixel:			3
	rowsPerStrip: 				1
	clear tiffValues
	clear tagList
	clear IFDOffsetList
	ret: true
	tiff: read/binary f 
	either rcvAssertTiffFile [
		rcvReadTiffHeader 
		rcvmakeTiffIFDList
		rcvReadTiffImageData 1
		ret: true
		][ret: false]
	ret
]


; 24 bit color RGB TIFF creation (Paul Bourke, 1998)
; basic tiff writing 24-bit color RGB red image
; mode 1: intel little endian
; mode 2: motorola big endian 
; actually red only supports little endian for writing

rcvSaveTiffImage: func [
	redImage 	[image!] 
	f 			[file!] 
	mode 		[integer!]
][
	; image size
	nx: redImage/size/x 
	ny: redImage/size/y
	nChannels: 3
	nEntries: 14
	
	;************ creates tiff file and file header ******************
	either ( mode = 1)  [write/binary f TIFF_LITTLEENDIAN] 
						[write/binary f TIFF_BIGENDIAN]
	bin: to-binary to-hex/size TIFF_VERSION_CLASSIC 4 ;-- tiff magic number
	if mode = 1 [reverse bin]
	write/append f bin	
	; offset of the first IFD for a file with 1 RGB image 
	bin: to-binary nx * ny * nChannels + 8 ;-- (8 = Header Size in byte)
	if mode = 1 [reverse bin]
	write/append f bin	
	
	;********************* end of header *****************************

	write/append f redImage/rgb; write red image data (nx * ny * nChannels)
	
	;********************** IFD *****************************************
	; first and unique IFD
	; The number of directory entries
	bin: to-binary to-hex/size nEntries 4
	if mode = 1 [reverse bin]
	write/append f bin
	
	; Tag 1: 256: image  width , short int (3)
	either (mode = 1) [str: #{0001030001000000}] [str: #{0100000300000001}]
	write/append f str
	bin: to-binary nx
	if mode = 1 [reverse bin]
	write/append f bin
	
	;tag 2: 257: image height  , short int (3)
	either (mode = 1) [str: #{0101030001000000}] [str: {0101000300000001}]
	write/append f str
	bin: to-binary ny
	if mode = 1 [reverse bin]
	write/append f bin
	
	
	;Tag 3: 258 Bits per sample tag, short int 
	either (mode = 1) [str: #{0201030003000000}] [str: #{0102000300000003}]
	write/append f str 
	bin: to-binary nx * ny * nChannels + 182 ;--value offset
	if mode = 1 [reverse bin]
	write/append f bin
	
	; tag 4: 259: Compression flag, short int : 1 none
	either (mode = 1) [str: #{030103000100000001000000}] [str: #{010300030000000100010000}]
	write/append f str
	
	;Tag 5: 262 ; Photometric interpolation tag, short int: 2 RGB
	either (mode = 1) [str: #{060103000100000002000000}] [str: #{010600030000000100020000}]
	write/append f str
	
	;Tag 6: 273 : Strip offset tag, long int
	either (mode = 1) [str: #{110104000100000008000000}] [str: #{011100040000000100000008}]
	write/append f  str 
	
	;tag 7: 274 Orientation flag, short int 1: Top and Left
	either (mode = 1) [str: #{120103000100000001000000}] [str: #{011200030000000100010000}]
	write/append f str
	
	;Tag 8 277;Sample per pixel tag, short int 3 since RGB Image
	either (mode = 1) [str: #{150103000100000003000000}] [str: #{011500030000000100030000}]
	write/append f str
	
	;Tag 9: 278 Rows per strip tag, short int
	either (mode = 1) [str: #{1601030001000000}] [str: #{1601030001000000}]
	write/append f str
	bin: to-binary ny
	if mode = 1 [reverse bin]
	write/append f bin
	
	;Tag 10: 279 Strip byte count flag, long int 
	either (mode = 1) [str: #{1701040001000000}] [str: #{0117000400000001}]
	write/append f str
	bin: to-binary nx * ny * nChannels ;--value offset
	if mode = 1 [reverse bin]
	write/append f bin
	
	
	; Tag 11: 280 Minimum sample value flag, short int  
	either (mode = 1) [str: #{1801030003000000}] [str: #{0118000300000003}]
	write/append f str
	bin: to-binary nx * ny * nChannels + 188	;--value offset
	if mode = 1 [reverse bin]
	write/append f bin
	
	; Tag 12: 281 Max sample value flag, short int  
	either (mode = 1) [str: #{1901030003000000}] [str: #{0119000300000003}]
	write/append f str
	bin: to-binary nx * ny * nChannels + 194 ;--value offset
	if mode = 1 [reverse bin]
	write/append f bin
	
	;Tag 13: 284 ;Planar configuration tag, short int 3
	either (mode = 1) [str: #{1c0103000100000001000000}] [str: #{011c00030000000100010000}]
	write/append f str 
	
	
	;Tag 14: 339 Sample format tag, short int
	either (mode = 1) [str: #{5301030003000000}] [str: #{0153000300000003}]
	write/append f str 
	bin: to-binary nx * ny * nChannels + 200  ; tag offset
	if mode = 1 [reverse bin]
	write/append f bin
	
	str: #{00000000}	; 4 byte for end of IFD
	write/append f str
	;******************** End of the directory entry **********************
	
	; now write values addressed by tags offset (pointers)
	;Bits for each colour channel
	either (mode = 1) [str: #{080008000800}] [str: #{000800080008}]
	write/append f str
	;Minimum value for each component
	str: #{000000000000}
	write/append f str
	;Maximum value per channel
	either (mode = 1) [str: #{ff00ff00ff00}] [str: #{00ff00ff00ff}]
	write/append f str
	;Samples per pixel for each channel
	either (mode = 1) [str: #{010001000100}] [str: #{000100010001}]
	write/append f str
]