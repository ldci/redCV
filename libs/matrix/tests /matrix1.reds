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


; to be moved to /runtime/datatypes
red-matrix!: alias struct! [
	header 	[integer!]								;-- cell header
	head	[integer!]								;-- matrix's head index (zero-based)
	node	[byte-ptr!]								;-- matrix's buffer (node!)
	type	[integer!]								;-- matrix elements datatype
]


matrix: context [
	verbose: 0
	rs-length?: func [
		mat 	[red-matrix!]
		return: [integer!]
	][
		_series/get-length as red-series! mat no
	]
	
	init: does [
		datatype/register [
			TYPE_MATRIX
			TYPE_STRING
			"matrix!"
			;-- General actions --
			null			;:make
			INHERIT_ACTION	;random
			INHERIT_ACTION	;reflect
			null			;to
			:form
			:mold
			INHERIT_ACTION	;eval-path
			null			;set-path
			:compare
			;-- Scalar actions --
			null			;absolute
			:add
			:divide
			:multiply
			null			;negate
			null			;power
			:remainder
			null			;round
			:subtract
			null			;even?
			null			;odd?
			;-- Bitwise actions --
			:and~
			null			;complement
			:or~
			:xor~
			;-- Series actions --
			null			;append
			INHERIT_ACTION	;at
			INHERIT_ACTION	;back
			INHERIT_ACTION	;change
			INHERIT_ACTION	;clear
			INHERIT_ACTION	;copy
			INHERIT_ACTION	;find
			INHERIT_ACTION	;head
			INHERIT_ACTION	;head?
			INHERIT_ACTION	;index?
			:insert
			INHERIT_ACTION	;length?
			INHERIT_ACTION	;move
			INHERIT_ACTION	;next
			INHERIT_ACTION	;pick
			INHERIT_ACTION	;poke
			null			;put
			INHERIT_ACTION	;remove
			INHERIT_ACTION	;reverse
			INHERIT_ACTION	;select
			INHERIT_ACTION	;sort
			INHERIT_ACTION	;skip
			null			;swap
			INHERIT_ACTION	;tail
			INHERIT_ACTION	;tail?
			INHERIT_ACTION	;take
			null			;trim
			;-- I/O actions --
			null			;create
			null			;close
			null			;delete
			INHERIT_ACTION	;modify
			null			;open
			null			;open?
			null			;query
			null			;read
			null			;rename
			null			;update
			null			;write
		]
	]
]

