#!/usr/local/bin/red
Red [
	Title:		"Pandore library Object"
	Author:		"F. Jouen"
	Rights:		"Copyright (c) 2021 F. Jouen. All rights reserved."
	License:    "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]


set 'PO_MAGIC "PANDORE04"
set 'PLOAD 0
set 'PSAVE 1

;--Some macro functions
#macro MIN: func [a b] [either a < b [a][b]]
#macro MAX: func [a b] [either a > b [a][b]]
#macro SQR: func [x] [x * x]
#macro CUB: func [x] [x * x * x]
#macro ABS:	func [x] [either x > 0 [x][-1 * x]]

; DO NOT CHANGE THIS ORDERING !
;ATTENTION First element is = 0 in c++ and 1 in red

typObj: [
   Po_Unknown Po_Collection
   Po_Img1duc Po_Img1dsl Po_Img1dsf
   Po_Img2duc Po_Img2dsl Po_Img2dsf
   Po_Img3duc Po_Img3dsl Po_Img3dsf
   Po_Reg1d Po_Reg2d Po_Reg3d
   Po_Graph2d Po_Graph3d
   Po_Imc2duc Po_Imc2dsl Po_Imc2dsf
   Po_Imc3duc Po_Imc3dsl Po_Imc3dsf
   Po_Imx1duc Po_Imx1dsl
   Po4_Imx1dul Po_Imx1dsf
   Po_Imx2duc Po_Imx2dsl Po4_Imx2dul
   Po_Imx2dsf Po_Imx3duc Po_Imx3dsl
   Po4_Imx3dul Po_Imx3dsf
   Po_Point1d Po_Point2d Po_Point3d
   Po_Dimension1d Po_Dimension2d Po_Dimension3d
]

PColorSpace: [
    RGB
    XYZ
    LUV
    LAB
    HSL
    AST
    I1I2I3
    LCH
    WRY
    RNGNBN
    YCBCR
    YCH1CH2
    YIQ
    YUV
    HSI 
    UNKNOWN
]


pandore: context [
	;--Each pandore file uses at least this 36 bytes general header

	poHeader: object [
		magic: 	"" 	;--The magic number (12 bytes) @ref PO_MAGIC
		ptype:	"" 	;--The object type (4 bytes)
		ident: 	""	;--The autor name (9 bytes + 1 complement)
		date: 	"" 	;--The creation date (10 bytes)
		unused: "" 	;--Unused (1 complement)
	]

	;--The common attributes structure
	;--gathered all properties for any Pandore objects

	pobjectProps: object [
		nbands: 	0 		;--The number of bands
   		nrow: 		0		;--The number of columns
    	ncol: 		0		;--The number of rows
    	ndep: 		0		;--The number of planes (depth)
    	colorspace: 0		;--The color space
    	nlabels:	0		;--The number of labels in a region map
		size:		0		;--The number of nodes in a graph
		directed:	0		;--if the graph is directed or undirected
	]

	;--Create a generic pandore object
	pobject: object [
		potype: copy poHeader		;--Header
		poprop: copy pobjectProps	;--Properties
		data: copy #{}				;--Image values
		split: false				;--Flag
	]
	
	readPanHeader: function [
	"Read pan file header"
		panFile		[file!]
	][
		invByte?: false
		header: read/binary/part panFile 36
		s: copy/part skip header 0 12 
		pobject/potype/magic: trim/with to-string s "^@"
		s: copy/part skip header 12 4
		;attention little or big endian?
		int: to-integer s 
		if int > 255 [invByte?: true]
		if invByte? [int: to-integer reverse s]
		pobject/potype/ptype: rejoin [form int ": " to-string typObj/(int + 1)]
		s: copy/part skip header 16 9
		pobject/potype/ident: trim/with to-string s "^@"
		s: copy/part skip header 25 10
		insert s "2"
		pobject/potype/date: trim/with to-string s "^@"
		s: copy/part skip header 35 1 
		pobject/potype/unused: trim/with to-string s "^@"
	]
	
	readPanAttributes: function [
	"Read pan file information"
		panFile		[file!]
	][
		;--properties
		invByte?: false
		attributes: read/binary/seek/part panFile 36 16 
		s: copy/part skip attributes 0 4
		int: to-integer s 
		if int > 255 [invByte?: true]
		if invByte? [int: to-integer reverse s]
		pobject/poprop/nbands: int
		s: copy/part skip attributes 4 4
		int: to-integer s if invByte? [int: to-integer reverse s]
		pobject/poprop/nrow: int
		s: copy/part skip attributes 8 4
		int: to-integer s if invByte? [int: to-integer reverse s]
		pobject/poprop/ncol: int
		s: copy/part skip attributes 12 4
		int: to-integer s if invByte? [int: to-integer reverse s]
		pobject/poprop/ndep: int 
	]
	
	readPanImage: function [
	"Read pan file image data"
		panFile		[file!]
	][
		;--skip file header and attributes (36 + 16)
		pan: read/binary/seek panFile 52 	
		either pobject/split [iter: 1][iter: 3]
		clear pobject/data
		foreach v pan [append/dup pobject/data v iter]
	]
]

 

