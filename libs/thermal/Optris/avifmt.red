#!/usr/local/bin/red
Red [
	Title:   "Red and RIFF Files"
	Author:  "ldci"
	File: 	 %avifmt.red
	Tabs:	 4
	Version: 1.0.0
	Comments: "based on MicroSoft AVIFMT.h"
	Rights:  "Copyright (C) 2021 ldci. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

#macro mmioFOURCC: func [c4] [
	to-hex (((to-integer to-char c4/1) << 24)
	or ((to-integer to-char c4/2) << 16)
	or ((to-integer to-char c4/3) << 8)
	or (to-integer to-char c4/4))
]

#macro aviTWOCC: func [c2] [
	to-hex/size (((to-integer to-char c2/1) << 8)
	or (to-integer to-char c2/2)) 4
]

;--Warning: These are nasty macro, and MS C 6.0 compiles some of them
;--incorrectly if optimizations are on.  Ack.

;--/* Macro to get stream number out of a FOURCC ckid */
#macro fromHex: func [n] [to-integer n]

;--Macro to get TWOCC chunk type out of a FOURCC ckid */
#macro TWOCCFromFOURCC: func [fcc] [
    copy/part to-binary fcc 2
]

;--Macro to make a ckid for a chunk out of a TWOCC and a stream number from 0-255
#macro toHex: func [n] [to-hex n]


;-- form types, list types, and chunk types */
set 'formtypeAVI             mmioFOURCC "AVI "  
set 'listtypeAVIHEADER       mmioFOURCC "hdrl"
set 'ckidAVIMAINHDR          mmioFOURCC "avih"
set 'listtypeSTREAMHEADER    mmioFOURCC "strl"
set 'ckidSTREAMHEADER        mmioFOURCC "strh"
set 'ckidSTREAMFORMAT        mmioFOURCC "strf"
set 'ckidSTREAMHANDLERDATA   mmioFOURCC "strd"
set 'ckidSTREAMNAME			 mmioFOURCC "strn"
set 'listtypeAVIMOVIE        mmioFOURCC "movi"
set 'listtypeAVIRECORD       mmioFOURCC "rec "  
set 'ckidAVINEWINDEX         mmioFOURCC "idx1"

;--stream types for the <fccType> field of the stream header.
set 'streamtypeVIDEO         mmioFOURCC "vids"
set 'streamtypeAUDIO         mmioFOURCC "auds"
set 'streamtypeMIDI			 mmioFOURCC "mids"
set 'streamtypeTEXT          mmioFOURCC "txts"

;-- Basic chunk types */
set 'cktypeDIBbits           aviTWOCC "db"
set 'cktypeDIBcompressed     aviTWOCC "dc"
set 'cktypePALchange         aviTWOCC "pc"
set 'cktypeWAVEbytes         aviTWOCC "wb"

;--Chunk id to use for extra chunks for padding.
set 'ckidAVIPADDING          mmioFOURCC "JUNK"

;--flags for use in <dwFlags> in AVIFileHdr *

set 'AVIF_HASINDEX           00000010h        
set 'AVIF_MUSTUSEINDEX       00000020h
set 'AVIF_ISINTERLEAVED      00000100h
set 'AVIF_TRUSTCKTYPE        00000800h       
set 'AVIF_WASCAPTUREFILE     00010000h
set 'AVIF_COPYRIGHTED        00020000h

;--The AVI File Header LIST chunk should be padded to this size

set 'AVI_HEADERSIZE  		2048	;--// size of AVI header list

MainAVIHeader: make object! [
	dwMicroSecPerFrame: 	0	;--frame display rate (or 0)
	dwMaxBytesPerSec:		0	;--max transfer rate
	dwPaddingGranularity:	0	;--pad to multiples of this size (512)
	dwFlags:				0	;--the ever-present flags (see flag list)
	dwTotalFrames:			0	;--number of frames in file
	dwInitialFrames:		0	;--initial frame (00000000) ignored
	dwStreams:				0	;--Number of streams in the 􏰁file
	dwSuggestedBufferSize:	0	;--Size of buff􏰀er required to hold chunks of the 􏰁file
	dwWidth:				0	;--Width of the video frame 
	dwHeight:				0	;--Height of the video frame
	dwReserved:		[0 0 0 0]	;--DWORD dwReserved[4]			
]

;--Stream header

set 'AVISF_DISABLED				00000001h
set 'AVISF_VIDEO_PALCHANGES		00010000h

rect: make object! [
	left: 	0
	top:	0		
	right:	0
    bottom: 0
]

aviStreamHeader: make object! [
	fccType:				""	;--vids - video auds - audio txts - subtitle
	fccHandler:				""	;--FourCC of codec to be used: YUY2
	dwFlags:			 	0	;--AVISF_DISABLED or AVISF_VIDEO_PALCHANGES
	wPriority:			 	0	;--Stream priority		
	wLanguage:			 	0	;--Stream Language if txts
	dwInitialFrames: 	 	0	;--Significant data for interleaved Files,specifies Audio position relative to Video
	dwScale:			 	0	;--samples / second (audio) or frames / second (video)(123750)
	dwRate:					0	;--idem (Sps 80.81)
	dwStart:			 	0	;--Specifies Starting Time of the Stream
	dwLength:			 	0	;--size of stream in units as de􏰁ned in dwRate and dwScale  (671) , Seconds 8.3
	dwSuggestedBufferSize: 	0	;--Size of bu􏰀ffer necessary to store blocks of that stream.
	dwQuality:			 	0	;--should indicate the quality of the stream. Not important
	dwSampleSize:		 	0	;--number of bytes of one stream single sample
	rcFrame:	 	copy rect	;--frame rectangle
]

;--Flags for index 
set 'AVIIF_LIST			00000001h ;--chunk is a 'LIST'
set 'AVIIF_KEYFRAME		00000010h ;--this frame is a key frame.
set 'AVIIF_FIRSTPART	00000020h ;--this frame is the start of a partial frame.
set 'AVIIF_LASTPART		00000040h ;--this frame is the end of a partial frame.
set 'AVIIF_MIDPART		(AVIIF_LASTPART or AVIIF_FIRSTPART)

set 'AVIIF_NOTIME		00000100h ;--this frame doesn't take any time
set 'AVIIF_COMPUSE		0FFF00h

AviIndexEntry: make object! [
	ckid:			0
  	dwFlags:		0
	dwChunkOffset:	0	;--Position of chunk
    dwChunkLength:	0	;--Length of chunk
]

;--Palette change chunk. Used in video streams

aviPalChange: make object! [
	bFirstEntry:	0	;--first entry to change */
	bNumEntries:	0	;--# entries to change (0 if 256) */
	wFlags:			0	;--Mostly to preserve alignment... */
	peNew:		   []	;--New color specifications */
]

	