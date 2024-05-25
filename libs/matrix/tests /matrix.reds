Red/System [
	Title:	"redCV Matrices"
	Author: "ldci"
	File: 	%matrix.reds
	Note:	"Matrix type"
	Tabs: 	4
	Rights: "Copyright (C) 2020 Red Foundation. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

#enum depth [
	mByte		;--byte matrix
	mInteger	;--integer matrix	
	mFloat		;--float matrix
]

;runtime/datatypes/structures.reds
{red-vector!: alias struct! [
	header 	[integer!]	;-- cell header
	head	[integer!]	;-- vector's head index (zero-based)
	node	[node!]		;-- vector's buffer
	type	[integer!]	;-- vector elements datatype
]}

red-mat!: alias struct! [
	rows	[integer!]
	cols	[integer!]
	unit	[integer!]
	data	[byte-ptr!] 
]

matrix: context [
	verbose: 0
	rs-length?: func [
		mat 	[red-mat!]
		return: [integer!]
	][
		mat/rows * mat/cols * mat/unit
	]
	
	make: func [
		rows	[integer!]
		cols	[integer!]
		mType	[integer!]
		return:	[red-mat!]
		/local
		unit	[integer!]
		mSize	[integer!]
		p		[byte-ptr!]
		_m		[red-mat!]
	][
		_m: declare  red-mat!
		probe _m
		switch mType [
			mByte	[unit: size? byte!]
			mInteger[unit: size? integer!]
			mFloat	[unit: size? float!]
		]
		mSize: unit * rows * cols
		p: allocate mSize
		set-memory p as byte! 0 mSize
		_m/rows: rows
		_m/cols: cols
		_m/unit: unit
		_m/data: p
		_m
		
	]
	
	releaseMatrix: func [
		mat		[byte-ptr!]
	][
		free mat
	]
	
]

