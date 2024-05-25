#!/usr/local/bin/red
Red [
	Title:   "Red and RIFF Files"
	Author:  "ldci"
	File: 	 %aviriff.red
	Tabs:	 4
	Version: 1.0.0
	Comments: "based on MicroSoft AVIRIFF.h"
	Rights:  "Copyright (C) 2021 ldci. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;--for AVIMAINHEADER dwFlags list
set 'AVIF_HASINDEX           00000010h        
set 'AVIF_MUSTUSEINDEX       00000020h
set 'AVIF_ISINTERLEAVED      00000100h
set 'AVIF_TRUSTCKTYPE        00000800h       
set 'AVIF_WASCAPTUREFILE     00010000h
set 'AVIF_COPYRIGHTED        00020000h
set 'AVI_MAX_RIFF_SIZE       40000000h
set 'AVI_MASTER_INDEX_SIZE   2048 or 256

;--for old style AVI index
set 'AVIIF_LIST       		00000001h
set 'AVIIF_KEYFRAME   		00000010h
set 'AVIIF_NO_TIME    		00000100h
set 'AVIIF_COMPRESSOR 		0FFF0000h 

set 'AVISF_DISABLED         00000001h
set 'AVISF_VIDEO_PALCHANGES 00010000h


;============== objects and macros for manipulating RIFF headers =================
RIFFChunk: make object! [
	dwFourCC:	""		;--a FOURCC code for data type (video audio text)
	dwSize:		0		;--4-byte value giving the size of the data in data 
]


RIFFList: make object! [
	dwID: 	"LIST"		;--Default FOURCC code (RIFF or LIST)
	dwSize:		0		;--The size of the list
	dwFourCC:	""		;--a FOURCC code describes the type of the chunk such as hdrl
]

riffRound: func [cb] [cb + cb AND 1]

MFCC: func [c4] [
	to-hex (((to-integer to-char c4/1) << 24)
	or ((to-integer to-char c4/2) << 16)
	or ((to-integer to-char c4/3) << 8)
	or (to-integer to-char c4/4))
]

;==================== avi header structures ===========================

;--main header for the avi file (compatibility header)
set 'ckidMAINAVIHEADER MFCC "avih"


aviMainHeader: make object! [
	fcc:				"avih"	;--default
	cb:						0	;--size of this structure
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

set 'ckidODML MFCC "odml"
set 'ckidAVIEXTHEADER  MFCC "dmlh"

aviExtHeader: make object! [
	fcc:				"dmlh"	;--dmlh
	cb:						0	;--size of this structure -8
	dwGrandFrames:			0	;--total number of frames in the file
	dwFuture: make vector! 61	;--to be defined later
]

;--structure of an AVI stream header riff chunk
set 'ckidSTREAMLIST MFCC "strl"
set 'ckidSTREAMHEADER MFCC "strh"

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

;--structure of an AVI stream format chunk
set 'ckidSTREAMFORMAT MFCC "strf"

{avi stream formats are different for each stream type
BITMAPINFOHEADER for video streams
WAVEFORMATEX or PCMWAVEFORMAT for audio streams
nothing for text streams
nothing for midi streams}

;-- structure of old style AVI index
set 'ckidAVIOLDINDEX MFCC "idx1"

aviOldIndex_entry: make object! [
	dwChunkId:		0
	dwFlags:		0	;--see old style AVI index list
	dwOffset:		0	;--offset of riff chunk header for the data
    dwSize:			0   ;--size of the data (excluding riff header size)
]

aviOldIndex: make object! [
	fcc:	"idx1"					;--idx1
  	cb:		0						;--size of this structure -8
  	aIndex:	copy aviOldIndex_entry	;--size of this array
]

;============ structures for timecode in an AVI file =================
;--union in c
timecode: make object! [
   tc: make object! [
      wFrameRate:	0	
      wFrameFract:	0
      cFrames:		0
	]
	qw:				0
]

set 'TIMECODE_RATE_30DROP 0	;--this MUST be zero

;--struct for all the SMPTE timecode info
timecodedata: make object! [
	time:			copy timecode
  	dwSMPTEflags: 	0
	dwUser:			0
]

;--dwSMPTEflags masks/values
set 'TIMECODE_SMPTE_BINARY_GROUP 07h
set 'TIMECODE_SMPTE_COLOR_FRAME  08h

;============ structures for new style AVI indexes =================
;--index type codes
set 'AVI_INDEX_OF_INDEXES       00h
set 'AVI_INDEX_OF_CHUNKS        01h
set 'AVI_INDEX_OF_TIMED_CHUNKS  02h
set 'AVI_INDEX_OF_SUB_2FIELD    03h
set 'AVI_INDEX_IS_DATA          80h

;--index subtype codes
set 'AVI_INDEX_SUB_DEFAULT      00h

;--INDEX_OF_CHUNKS subtype codes
set 'AVI_INDEX_SUB_2FIELD       01h

;--meta structure of all avi indexes
aviMetaIndex: make object![
	fcc:	"    "
	cb:		0
	wLongsPerEntry: 0
	bIndexSubType:	0
	bIndexType:		0
	nEntriesInUse:	0
	dwChunkId:		0
	dwReserved: 	[0 0 0]
	adwIndex:		[]
]

set 'STDINDEXSIZE 4000h

#macro NUMINDEX: func [wLongsPerEntry] [
	set 'STDINDEXSIZE 4000h
	to-integer STDINDEXSIZE - 32 / 4 / wLongsPerEntry
]

#macro NUMINDEXFILL: func [wLongsPerEntry] [
	set 'STDINDEXSIZE 4000h
	(STDINDEXSIZE / 4) - NUMINDEX  wLongsPerEntry
]

;--structure of a super index (INDEX_OF_INDEXES)
set 'ckidAVISUPERINDEX MFCC "indx"

_aviSuperdIndex_entry: make object! [
	qwOffset:			0.0	;--Position of the index chunk (ix00) this entry points to in the fi􏰁le (int 64)
	dwSize:				0	;--The size of the standard or 􏰁field index chunk the entry is pointing to
	dwDuration:			0	;--The duration, measured in stream ticks as indicated in the AVI stream heade
]

aviSuperIndex: make object! [
	fcc:				""	;--indx same as dwFourCC in chunck structure
	cb:					0	;--size of this structure
	wLongsPerEntry:		0	;--size of each entry in aIndex array = 4
	bIndexSubType:		0	;--0 (frame index) or AVI_INDEX_SUB_2FIELD 
	bIndexType:			0	;--one of AVI_INDEX_* codes 0: AVI_INDEX_OF_INDEXES
	nEntriesInUse:		0	;--offset of next unused entry in aIndex
	dwChunkId:			0	;--chunk ID of chunks being indexed, (i.e. RGB8)
	dwReserved3:   [0 0 0]	;--must be 0
	aIndex:	copy _aviSuperdIndex_entry
]

;--#define Valid_SUPERINDEX(pi) (*(DWORD *)(&((pi)->wLongsPerEntry)) == (4 | (AVI_INDEX_OF_INDEXES << 24)))

avistdindex_entry: make object! [
	dwOffset:			0	;--qwBaseOffset + this is absolute file offset
	dwSize:				0	;--bit 31 is set if this is NOT a keyframe
]

set 'AVISTDINDEX_DELTAFRAME 80000000h;-- Delta frames have the high bit set
set 'AVISTDINDEX_SIZEMASK   -2147483648

aviStdIndex: make object! [
	fcc:				""	;--same as dwFourCC in chunck structure
	cb:					0	;--same as dwSize in chunck structure
	wLongsPerEntry:		0	;--size of each entry in aIndex array
	bIndexSubType:		0	;--future use.  must be 0
	bIndexType:			0	;--one of AVI_INDEX_* codes 0: AVI_INDEX_OF_INDEXES
	nEntriesInUse:		0	;--index of first unused member in aIndex array
	dwChunkId:			0	;--fcc of what is indexed
	qwBaseOffset:		0	;--int64 This value is added to each dwOffset value of the AVISTDINDEX
	dwReserved3:  [0 0 0]	;--must be 0
	aIndex:				copy avistdindex_entry
]

;--struct of a time variant standard index (AVI_INDEX_OF_TIMED_CHUNKS)

avitimedindex_entry: make object! [
	dwOffset:		1362	;--32 bit offset to data (points to data, not riff header)
	dwSize: 		2734	;--31 bit size of data (does not include size of riff header) (high bit is deltaframe bit)
	dwDuration: 	0 		;--how much time the chunk should be played (in stream ticks)
]

aviTimedIndex: make object! [
	fcc:			"indx"	;--'indx' or '##ix'
	cb:					0	;--size of this structure
	wLongsPerEntry:		3   ;--==3
	bIndexSubType:		0 	;--==0
	bIndexType:			2	;--==AVI_INDEX_OF_TIMED_CHUNKS
	nEntriesInUse:		0	;--offset of next unused entry in aIndex
	dwChunkId:			0   ;-- chunk ID of chunks being indexed, (i.e. RGB8)
	qwBaseOffset:		0 	;--base offset that all index intries are relative to
	dwReserved_3:		0	;--must be 0
	aIndex: copy avitimedindex_entry
	adwTrailingFill:	2734;--to align struct to correct size
]

;--structure of a timecode stream
aviTimeCodeIndex: make object! [
	fcc:		"indx"          ;-- 'indx' or '##ix'
	b:				0			;-- size of this structure
	wLongsPerEntry:	4    		;-- ==4
	bIndexSubType:	0     		;-- ==0
	bIndexType:		80h        	;-- ==AVI_INDEX_IS_DATA
	nEntriesInUse:	9     		;-- offset of next unused entry in aIndex
	dwChunkId:	"time" 			;-- 'time'
	dwReserved:		0			;-- must be 0
	aIndex: copy timecodedata 	;--[NUMINDEX(sizeof(TIMECODEDATA)/sizeof(LONG))]:
]

;--structure of a timecode discontinuity list (when wLongsPerEntry == 7)

avitcdlindex_entry: make object! [
	dwTick:			0				;--// stream tick time that maps to this timecode value
	time:			copy timecode
	dwSMPTEflags:	0
	dwUser:			0
    szReelId:		make string! 12 append/dup szReelId "0" 12
] 

aviTcdLindex: make object! [
	fcc:			 "indx"	;--'indx' or '##ix'
	cb:					0	;--size of this structure
	wLongsPerEntry:		7	;--==7 (must be 4 or more all 'tcdl' indexes
	bIndexSubType:		0	;--==0
	bIndexType:       80h 	;--==AVI_INDEX_IS_DATA
	nEntriesInUse:		0	;--offset of next unused entry in aIndex
	dwChunkId:		"tcdl"	;--'tcdl'
	dwReserved:			0	;--must be 0
   	aIndex: 			copy avitcdlindex_entry ;--[NUMINDEX(7)]:
	adwTrailingFill: 	NUMINDEXFILL 7			;--to align struct to correct size
]

avifieldindex_entry: make object! [
	dwOffset:		0	;--size of all fields
	dwSize:			0	;--size of all fields (bit 31 set for NON-keyframes)
	dwOffsetField2:	0	;--offset to second field
]

aviFieldIndex_chunk: make object! [
	fcc:        "ix##"	;--'ix##'
	cb: 			0	;--size of this structure
	wLongsPerEntry:	0	;--must be 3 (size of each entry aIndex array)
	bIndexSubType:	0	;--AVI_INDEX_2FIELD
	bIndexType:		1	;--AVI_INDEX_OF_CHUNKS (01h)
	nEntriesInUse:	0   ;--
	dwChunkId:		""  ;--'##dc' or '##db'
	qwBaseOffset:	0	;--offsets in aIndex array are relative to this
	dwReserved3:	0   ;--must be 0
   	aIndex: copy avifieldindex_entry
]



          

