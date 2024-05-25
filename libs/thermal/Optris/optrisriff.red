#!/usr/local/bin/red
Red [
	Title:   "Red and RIFF Files"
	Author:  "ldci"
	File: 	 %optrisriff.red
	Tabs:	 4
	Version: 1.0.0
	Comments: "based on different lectures"
	Rights:  "Copyright (C) 2021 ldci. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

{* heres the general layout of an AVI riff file (new format)
 *
 * RIFF (3F??????) AVI       <- not more than 1 GB in size
 *     LIST (size) hdrl
 *         avih (0038)		56 bytes
 *         LIST (size) strl
 *             strh (0038)  56 bytes
 *             strf (????)
 *             indx (3ff8)   <- size may vary, should be sector sized
 *         LIST (size) strl
 *             strh (0038)  56 bytes
 *             strf (????)
 *             indx (3ff8)   <- size may vary, should be sector sized
 *         LIST (size) odml
 *             dmlh (????)
 *         JUNK (size)       <- fill to align to sector - 12
 *     LIST (7f??????) movi  <- aligned on sector - 12
 *         00dc (size)       <- sector aligned
 *         01wb (size)       <- sector aligned
 *         ix00 (size)       <- sector aligned
 *     idx1 (00??????)       <- sector aligned
 * RIFF (7F??????) AVIX
 *     JUNK (size)           <- fill to align to sector -12
 *     LIST (size) movi
 *         00dc (size)       <- sector aligned
 * RIFF (7F??????) AVIX      <- not more than 2GB in size
 *     JUNK (size)           <- fill to align to sector - 12
 *     LIST (size) movi
 *         00dc (size)       <- sector aligned
 *
 *-===================================================================*/}

{The actual data is contained in subchunks within the 'movi' LIST 
//  chunk.  The first two characters of each data chunk are the
//  stream number with which that data is associated.}


;--Optris ravi files are AVI files with old index
;--There is only 1 video (vids) stream
;--Videos are uncompressed and use the lossless YUY2 codec for a better quality
;--This means that pixel values are 16-bit and not 24-bit as in RGBA
;--This allows to store the temperature within a w * h * 2 matrix 
;--with low and high values for each pixel
;--Formula is temp: (hi * 256.0 + lo) / 10.0 - 100.0 
;--Video streams use the BITMAPINFOHEADER structure,
;--whereas audio streams use the WAVEFORMATEX structure.
;--Optris file uses just the video stream (00db)
;--LIST L6 : optris metadata as xml 


;--IMPORTANT: All offset computation are zero-based in this lib for C compatibity
;--such as HexFriend Editor code

#include %aviriff.red	;--General AVI library

hasidx1?: 		false	;--can be present or not
hasmovi?: 	 	false	;--must be present in all files
hasix00?: 	 	false	;--index associate to movi: we can use it, data are here
hasinfo?: 	 	false	;--xml info?
hassuper?: 	 	false	;--Avi Super Index?
firstOffset: 	0		;--movi list offset

int32Size: 	 	4		;--4 bytes = 32-bit
int16Size: 	 	2		;--2 bytes = 16-bit
int8Size:  	 	1		;--1 byte  =  8-bit


;--we need this object for video frames
;--BITMAPINFOHEADER structure

bitMapInfoHeader: make object! [
	biSize:		 		0	;--Specifies the number of bytes required by the structure
	biWidth:	 		0	;--Specifies the width of the bitmap, in pixels		
	biHeight:	 		0	;--Specifies the height of the bitmap, in pixels.
	biPlanes:	 		0	;--Specifies the number of planes for the target device. This value must be set to 1.
	biBitCount:	 		0	;--Specifies the number of bits per pixel (bpp).
	biCompression:	 	""	;--FOURCC Code 
	biSizeImage:	 	0	;--Specifies the size, in bytes, of the image. This can be set to 0 for uncompressed RGB bitmaps.
	biXPelsPerMeter: 	0	;--Specifies the horizontal resolution, in pixels per meter
	biYPelsPerMeter: 	0	;--Specifies the vertical resolution, in pixels per meter
	biClrUsed:		 	0	;--Specifies the number of color indices in the color table
	biClrImportant:	 	0	;--Specifies the number of color indices that are considered important for displaying the bitmap
]


getFileInfo: func [
"There are different types of Optris files"
	f	[binary!]
][
	either find f #{494E464F} [hasinfo?:  true] [hasinfo?:  false]	;--"INFO"
	either find f #{696E6478} [hassuper?: true] [hassuper?: false]	;--"indx"
	either find f #{69647831} [hasidx1?:  true] [hasidx1?:  false]	;--"idx1"
	either find f #{6D6F7669} [hasmovi?:  true] [hasmovi?:  false] 	;--"movi"
	either find f #{69783030} [hasix00?:  true] [hasix00?:  false] 	;--"ix00"
	firstOffset: to-integer index? find f #{6D6F7669}			   	;--"movi"
	firstOffset: firstOffset - 1									;--zero-based offset
]

assertRIFFFile: func [
"RIFF file or not?"
	f		[binary!]
	return: [logic!]
][
	isRIFFFile?: false
	riff: head f
	tmp: copy/part riff int32Size
	if tmp = #{52494646} [isRIFFFile?: true] ;--RIFF
	isRIFFFile?
]


getFileHeader: func[
"Get radiometric file header(32 bytes) + 56 bytes for avih"
	f		[binary!]
][
	;--starting byte 0
	riff: head f
	header: copy/part riff 88
	RSignature: to-string copy/part skip header 0 int32Size
	ssize: to-integer reverse copy/part skip header 4 int32Size
	RSize: ssize + 8	;--exact file size in byte (n * power 10 -6 -> Mb/Mo)
	RType: to-string copy/part skip header 8 int32Size
	
	;--get required LIST hdrl
	hdrlList: copy RIFFList
	hdrlList/dwID: to-string copy/part skip header 12 int32Size
	hdrlList/dwSize: to-integer reverse copy/part skip header 16 int32Size
	hdrlList/dwFourCC: to-string copy/part skip header 20 int32Size
	
	;--Get main AVI header (avih)
	aviMainHeader/fcc: to-string copy/part skip header 24 int32Size  ;--avih (a chunk) 
	aviMainHeader/cb: to-integer reverse copy/part skip header 28 int32Size
	aviMainHeaderdwMicroSecPerFrame: to-integer reverse copy/part skip header 32 int32Size
	aviMainHeader/dwMaxBytesPerSec: to-integer reverse copy/part skip header 36 int32Size
	aviMainHeader/dwPaddingGranularity: to-integer reverse copy/part skip header 40 int32Size
	aviMainHeader/dwFlags: (to-integer reverse copy/part skip header 44 int32Size) - 16 ;--??
	aviMainHeader/dwTotalFrames: to-integer reverse copy/part skip header 48 int32Size
	aviMainHeader/dwInitialFrames: to-integer reverse copy/part skip header 52 int32Size
	aviMainHeader/dwStreams: to-integer reverse copy/part skip header 56 int32Size
	aviMainHeader/dwSuggestedBufferSize: to-integer reverse copy/part skip header 60 int32Size
	aviMainHeader/dwWidth: to-integer reverse copy/part skip header 64 int32Size
	aviMainHeader/dwHeight: to-integer reverse copy/part skip header 68 int32Size
	aviMainHeader/dwReserved/1: to-integer reverse copy/part skip header 72 int32Size
	aviMainHeader/dwReserved/2: to-integer reverse copy/part skip header 76 int32Size
	aviMainHeader/dwReserved/3: to-integer reverse copy/part skip header 80 int32Size
	aviMainHeader/dwReserved/4: to-integer reverse copy/part skip header 84 int32Size
]


getStreamHeader: func [
"Get stream headers"
	f		[binary!]
][
	;--LIST strl starting byte 88
	riff: head f
	strlList: copy RIFFList
	strlList/dwID: to-string copy/part skip riff 88 int32Size
	strlList/dwSize: to-integer reverse copy/part skip riff 92 int32Size
	strlList/dwFourCC: to-string copy/part skip riff 96 int32Size

	;--Get video stream header (strh chunck)
	cName: to-string copy/part skip riff 100 int32Size  ;--strh 
	cSize: to-integer reverse copy/part skip riff 104 int32Size
	aviStreamHeader/fccType: to-string copy/part skip riff 108 int32Size
	aviStreamHeader/fccHandler: to-string copy/part skip riff 112 int32Size
	aviStreamHeader/dwFlags: to-integer reverse copy/part skip riff 116 int32Size
	aviStreamHeader/wPriority: to-integer reverse copy/part skip riff 120 int16Size
	aviStreamHeader/wLanguage: to-integer reverse copy/part skip riff 122 int16Size
	aviStreamHeader/dwInitialFrames: to-integer reverse copy/part skip riff 124 int32Size
	aviStreamHeader/dwScale: to-integer reverse copy/part skip riff 128 int32Size
	aviStreamHeader/dwRate: to-integer reverse copy/part skip riff 132 int32Size
	aviStreamHeader/dwStart: to-integer reverse copy/part skip riff 136 int32Size
	aviStreamHeader/dwLength: to-integer reverse copy/part skip riff 140 int32Size
	aviStreamHeader/dwSuggestedBufferSize: to-integer reverse copy/part skip riff 144 int32Size
	aviStreamHeader/dwQuality: to-integer reverse copy/part skip riff 148 int32Size
	aviStreamHeader/dwSampleSize: to-integer reverse copy/part skip riff 152 int32Size
	aviStreamHeader/rcFrame/left: to-integer reverse copy/part skip riff 156 int16Size
	aviStreamHeader/rcFrame/top: to-integer reverse copy/part skip riff 158 int16Size
	aviStreamHeader/rcFrame/bottom: to-integer reverse copy/part skip riff 160 int16Size
	aviStreamHeader/rcFrame/right: to-integer reverse copy/part skip riff 162 int16Size
	
	;-Get stream format (strf: bitMapInfoHeader chunck)
	cName:  to-string copy/part skip riff 164 int32Size
	;--structure values starting byte 168
	bitMapInfoHeader/biSize: to-integer reverse copy/part skip riff 168 int32Size
	bitMapInfoHeader/biWidth: to-integer reverse copy/part skip riff 176 int32Size
	bitMapInfoHeader/biHeight: to-integer reverse copy/part skip riff 180 int32Size
	bitMapInfoHeader/biPlanes: to-integer reverse copy/part skip riff 184 int16Size
	bitMapInfoHeader/biBitCount: to-integer reverse copy/part skip riff 186 int16Size
	bitMapInfoHeader/biCompression: to-string copy/part skip riff 188 int32Size
	bitMapInfoHeader/biSizeImage: to-integer reverse copy/part skip riff 192 int32Size ;(w*h*2)
	bitMapInfoHeader/biXPelsPerMeter: to-integer reverse copy/part skip riff 196 int32Size
	bitMapInfoHeader/biYPelsPerMeter: to-integer reverse copy/part skip riff 200 int32Size
	bitMapInfoHeader/biClrUsed: to-integer reverse copy/part skip riff 204 int32Size
	bitMapInfoHeader/biClrImportant: to-integer reverse copy/part skip riff 208 int32Size
]

getAviSuperIndex: func [
	f		[binary!]
][
	;--starting byte 212
	riff: head f
	aviSuperIndex/fcc: to-string copy/part skip riff 212 int32Size
	aviSuperIndex/cb: to-integer reverse copy/part skip riff 216 int32Size
	aviSuperIndex/wLongsPerEntry: to-integer reverse copy/part skip riff 220 int16Size
	aviSuperIndex/bIndexSubType: to-integer reverse copy/part skip riff 222 int8Size
	aviSuperIndex/bIndexType: to-integer reverse copy/part skip riff 223 int8Size
	aviSuperIndex/nEntriesInUse: to-integer reverse copy/part skip riff 224 int32Size
	aviSuperIndex/dwChunkId: to-string copy/part skip riff 228 int32Size		
	aviSuperIndex/dwReserved3/1: to-integer reverse copy/part skip riff 232 int32Size
	aviSuperIndex/dwReserved3/2: to-integer reverse copy/part skip riff 236 int32Size
	aviSuperIndex/dwReserved3/3: to-integer reverse copy/part skip riff 240 int32Size
	aviSuperIndex/aIndex/qwOffset: to-integer reverse copy/part skip riff 244 int32Size
	aviSuperIndex/aIndex/dwSize: to-integer reverse copy/part skip riff 248 int32Size
	aviSuperIndex/aIndex/dwDuration: to-integer reverse copy/part skip riff 252 int32Size
]


;--indexes of the data chuncks within the file  (movi  list)
;--Specifies the location of the data chunk in the file. 
;--The value should be specified as an offset, in bytes, from the start of 'movi' 
;--However, in some files it is given as an offset from the start of the file.

;--in Optris files offset is always the start of the 'movi' list
;--but 2 cases. If ix00 is found, there is a list of 00db values with offset and length.
;--Then we can use getAviMoviIndex. Data are elsewhere in the file. 
;--if ix00 is not found, data are inside the movi list. 
;--With getAviFrameInde we get the offset values from "idx1" list 
;--at the end of the file rather than copying each frame.

;--could be from the start of the file or not
getAviFrameIndex: func [
	f		[binary!]
	return:	[block!]
][
	;--looking for idx1 chunck
	idx: (index? find f "idx1")  - 1					;--zero-based offset
	ck: copy skip f idx
	ckId: to-string copy/part ck int32Size				;--idx1
	ck: skip ck int32Size
	n: to-integer reverse copy/part ck int32Size		;--idx1 size
	ck: skip ck int32Size
	data: copy []
	repeat i n [
		if error? try [ckId: to-string copy/part ck int32Size]
					  [ckId: copy/part ck int32Size]			;--ckid
		ck: skip ck int32Size
		ckFlag: to-integer reverse copy/part ck int32Size		;--ckflag
		ck: skip ck int32Size
		ckOffset: to-integer reverse copy/part ck int32Size		;--ckoffset
		ck: skip ck int32Size
		ckLength: to-integer reverse copy/part ck int32Size		;--cklength
		append/only data reduce [ckOffset ckLength]
		;print [i " " ckId " " ckFlag " " ckOffset " " ckLength]
		ck: skip ck int32Size
	]
	data
]

;--from movi list when ix00 is present

getAviMoviIndex: func [
	f		[binary!]
	return:	[block!]
][
	idx: (index? find f "movi") - 1 			;--zero-based offset
	ck: copy skip f idx
	mov: to-string copy/part ck int32Size 		;--movi
	ck: skip ck int32Size
	ckIdx: to-string copy/part ck int32Size		;--ix00
	ck: skip ck int32Size
	n: to-integer reverse copy/part ck int32Size;--Suggested buffer size
	ck: skip ck int32Size
	n: to-integer reverse copy/part ck int32Size;--??
	ck: skip ck int32Size
	nframes: to-integer reverse copy/part ck int32Size  ;--number of frames
	ck: skip ck int32Size
	ckId: to-string copy/part ck int32Size  			;--00db
	ck: skip ck int32Size
	firstOffset: to-integer reverse copy/part ck int32Size ;--offset first 00db
	ck: skip ck int32Size
	n: to-integer reverse copy/part ck int32Size  ;--4 bytes padding?
	ck: skip ck int32Size
	n: to-integer reverse copy/part ck int32Size  ;--4 bytes padding?
	ck: skip ck int32Size
	
	;offset are calculated from firstOffset value in movi list 
	data: copy []
	repeat i nframes [
		ckOffset: to-integer reverse copy/part ck int32Size
		ckOffset: ckOffset + firstOffset
		ck: skip ck int32Size
		ckLength: to-integer reverse copy/part ck int32Size
		;print [ckOffset ckLength]
		append/only data reduce [ckOffset ckLength]
		ck: skip ck int32Size
	]
	data
]

;--a test when ix00 is absent
getAviMoviIndex2: func [
	f		[binary!]
	n		[integer!]
	return:	[block!]
][
	idx: (index? find f "movi") - 1						;--zero-based offset
	ck: copy skip f idx
	data: copy []
	repeat i n [
		ck: skip ck int32Size
		ckId: to-string copy/part ck int32Size  		;--00db chunck id
		ck: skip ck int32Size
		fSize: to-integer reverse copy/part ck int32Size;--FSize
		append/only data reduce  [idx fSize]
		ck: skip ck fSize
		idx: idx + fSize
	]
	data
]

getFrameRate: function [
"Get FPS infos, if present in ravi file"
	xml		[binary!]
][
	fps: 10
	sfps: "10"
	if find xml "INFO" [
		parse xml [
			thru "<Framerate>" copy sfps to "</Framerate>"
		]
		fps: to-integer to-string sfps
	]
	fps
]

getTempRange: function [
"Get temperature infos, if present in ravi file"
	xml		[binary!]
] [
	minRange: 	0
	maxRange: 	0
	minTemp: 	0.0
	maxTemp: 	0.0
	sminRange: "-20"
	smaxRange: "100"
	sMinTemp: "0.0"
	sMaxTemp: "0.0"
	sTempRange: ""
	sTempRangeScale: ""
	if find xml "INFO" [
		parse xml [
			thru "<TempRange>" copy sTempRange to "</TempRange>"
			thru "<TempRangeScale>" copy sTempRangeScale to "<TempRangeScale>"
		]
		parse sTempRange [
			thru "<Min>" copy sminRange to "</Min>"
			thru "<Max>" copy smaxRange to "</Max>"
		]
		parse  sTempRangeScale [
			thru "<Min>" copy sMinTemp to "</Min>"
			thru "<Max>" copy smaxTemp to "</Max>"
		] 
		minRange: 	to-integer to-string sminRange
		maxRange: 	to-integer to-string smaxRange 
		minTemp: 	round/to to-float to-string sMinTemp 0.001	
		maxTemp: 	round/to to-float to-string sMaxTemp 0.001
	]
	reduce [minRange maxRange MinTemp MaxTemp]
]








