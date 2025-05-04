#! /usr/local/bin/rebol
;; ===================================================
;; Script: compression.r
;; downloaded from: www.REBOL.org
;; on: 10-Jan-2018
;; at: 15:29:05.528656 UTC
;; owner: luce80 [script library member who can update
;; this script]
;; ===================================================
REBOL [
	title: "Various compression algorithms"
	file: %compression.r
	author: "Marco Antoniazzi"
	email: [luce80 AT libero DOT it]
	date: 14-02-2013
	version: 0.0.3
	Purpose: "Collect and show various compression algorithms (Huffman, RLE, LZ77, LZSS, LZ78, LZW)."
	History: [
		0.0.1 [01-01-2013 "Started"]
		0.0.2 [12-02-2013 "ok"]
		0.0.3 [14-02-2013 "Fixed silly bug in lzw binary! decompress"]
	]
	library: [
		level: 'intermediate
		platform: 'all
		type: [function tool]
		domain: [compression]
		tested-under: [View 2.7.8.3.1]
		support: none
		license: 'public-domain
	]
	notes: {
		I should say that these functions are made slow on pourpose.
		Any optimization for speed or bits-saving is left as an exercise to the reader ;)
		
		Do not esitate to help me improve this script by adding more algorithms.
	}
]

compression: context [
	; some functions taken or partially derived from an article of Ole Friis in www.rebolforces.com

	alphadigits: "0123456789ABCDEF"
	enbase: func [value [integer!] /base base-value [integer!] /local result num][
		if value = 0 [return "0"]
		base-value: any [base-value 16]
		result: copy ""
		while [value <> 0][
			num: mod value base-value
			insert result any [alphadigits/(num + 1) "0"]
			value: (value - num) / base-value
		]
		result
	]
	debase: func [value [any-string!] /base base-value [integer!] /local num char pos][
		base-value: any [base-value 16]
		;FIXME: if 0 <> mod (length? string) base-value [make error! "wrong string length"]
		num: 0
		foreach char value [
			if none? pos: find alphadigits uppercase char [break]
			num: num * base-value + (index? pos) - 1
		]
		num
	]
	from-base2: func [value][debase/base value 2]
	to-base2: func [value][enbase/base value 2]
	
	
	
	bit-pos: 1
	bin-result: copy #{}
	to-bin: func [num][system/words/debase/base to-hex num 16]
	bits-set: func [num len /local shifted-num result][
		; shift num left to bit-pos
		shifted-num: shift/left to-integer num 32 - len - bit-pos + 1 
		; overwrite dest binary with shifted number
		result: change bin-result bin-result or to-bin shifted-num
		; update bit number and bin-result pos
		bit-pos: bit-pos + len
		while [bit-pos > 8] [bit-pos: bit-pos - 8 bin-result: next bin-result]
		head result
	]
	bits-get: func [len /local mask num][
		mask: shift to-integer #{80000000} len - 1
		mask: shift/logical mask bit-pos - 1
		; extract bits using mask and then shift them to get the right number
		num: mask and to-integer copy/part bin-result 4
		num: shift/logical num 32 - len - bit-pos + 1
		bit-pos: bit-pos + len
		while [bit-pos > 8] [bit-pos: bit-pos - 8 bin-result: next bin-result]
		num
	]

	encode-bitstream: func [;author Ole Friis
		"Encodes a string of 1's and 0's to a binary string"
		s [string!] "The string of 1's and 0's"
		/local res byte add-this
		][
		res: copy #{}
		forever [
			byte: 0
			add-this: 128
			while [(add-this <> 0) and (not tail? s)] [
				if #"1" = first s [byte: byte + add-this]
				add-this: shift add-this 1
				s: next s
			]
			append res to-char byte
			if tail? s [return res]
		]
	]
	decode-bitstream: func [;author Ole Friis
		"Decodes a binary string into a string of 1's and 0's"
		s [binary!] "The binary string"
		/local res next-bit
		][
		res: copy ""
		next-bit: 128
		while [not tail? s] [
			append res either 0 = and~ next-bit to-integer first s ["0"]["1"]
			next-bit: shift next-bit 1
			if next-bit = 0 [next-bit: 128  s: next s]
		]
		res
	]	



	huffman: context [

		stats: none ; The statistics
		tree: none ; the Huffman tree
		codes: none ; the translation table with alphabet symbols and their Huffman code
		huffman-code: copy "" ; temporary partial Huffman code

		build_stats: func [
			{build a block with all symbols and their count (eg. [2 #"e" 7 #"a" ...])}
			data [any-string!] "data to analyze"
			/local char pos
			][
			stats: copy []
			data: as-string data
			foreach char data [
				either pos: find/case stats char [pos/(-1): pos/(-1) + 1][insert insert stats 1 char]
			]
			
			sort/skip stats 2
		]

		build_tree: func [
			"build the Huffman tree" ; the tree is a list of lists something like: [[[a 3] [[[c 1] [b 1] 2] [e 2] 4] 7]]
			stats [block!] "The statistics"
			/local node1 node2 weight new-node temp-list
			][
			tree: copy []
			; Create a leaf node for each symbol and add it to the tree
			forskip stats 2 [repend/only tree [second stats first stats]]

			while [1 < length? tree][
				node1: take tree
				node2: take tree
				weight: (last node1) + (last node2)
				new-node: reduce [node1 node2 weight]
				; Insert the new node correctly (sorted) in the tree (we could use a bisection)
				temp-list: head tree
				while [all [not tail? temp-list  (last first temp-list) <= weight]][
				  temp-list: next temp-list
				]
				insert/only temp-list new-node
			]
			; Return the top element of the Huffman tree
			tree: first tree
		]

		build_table: func [
			"recursively traverse the huffman tree building a translation table"
			tree [block!]
			/local node
			][
			if block? node: first tree [
				append huffman-code "0"
				build_table node
			]
			either block? node: second tree [
				append huffman-code "1"
				build_table node
			][
				repend codes [first tree copy huffman-code]
			]
			remove back tail huffman-code
			make hash! codes
		]

		compress: func [
			"Huffman-compress a string series"
			data [any-string!] "Data to compress"
			/table block [block!]  "The Huffman translation table to use"
			/to-block "Give result as a block of strings"
			/local char result code block-result
			][
			result: copy ""
			block-result: copy []
			block: any [block do [codes: copy [] build_table build_tree build_stats data]]
			foreach char data [
				insert tail result code: select block to-char char ;cannot use path selection because it is case INSENSITIVE (!?)
				if to-block [insert tail block-result code]
			]
			if to-block [return block-result]
			result: encode-bitstream result
		]

		to-canonical: func [
			"Transform a Huffman translation table to a canonical one"
			/table block [block!]  "The Huffman translation table to use"
			/local codes-copy canonical-codes current-bit-length new-code
			][
			codes-copy: copy any [block codes]
			sort/skip codes-copy 2
			canonical-codes: copy []
			;The first symbol in the list gets assigned a codeword which is the same length as the symbol's original codeword but all zeros. This will often be a single zero ('0').
			current-bit-length: length? second codes-copy
			repend canonical-codes [first codes-copy head insert/dup clear "" "0" current-bit-length]

			new-code: second canonical-codes
			codes-copy: skip codes-copy 2
			forskip codes-copy 2 [
				current-bit-length: length? second codes-copy
				new-code: to-base2 (from-base2 new-code) + 1
				if current-bit-length > length? new-code [insert new-code "0"]
				if current-bit-length > length? new-code [insert tail new-code "0"]
				repend canonical-codes [first codes-copy new-code]
			]
			make hash! canonical-codes
		]

		decompress: func [
			"decompress Huffman encoded block or binary"
			data [block! binary!] "data to decompress"
			/tree tree-block [block!]  "The Huffman tree to use"
			/table block [block!]  "The Huffman translation table to use"
			/local result char temp-code node
			][
			result: copy #{}
			if block? data [data: rejoin data]
			if binary? data [data: decode-bitstream data]
			either block [
				while [not tail? data][
					temp-code: clear ""
					char: false
					while [not char][
						append temp-code first+ data
						char: find/case block temp-code
						if char [char: first back char]
					]
					append result char
				]
			][
				tree-block: any [tree-block self/tree]
				while [not tail? data][
					node: tree-block
					until [
						node: either (first+ data) = #"0" [first node] [second node]
						(length? node) = 2 ; a leaf
					]
					append result first node
				]
			]
			data: head data
			result
		]
		
	] ; huffman
	
	rle: context [

		compress: func [
			"Run length (aka PackBits) compresses a string series and returns it."
			data [any-string!] "Data to compress"
			/local start count char result
			][
			result: copy #{}
			while [not tail? data] [
				count: 0
				start: data
				char: pick data 1
				; collect a sequence of not equal characters (optionally including some pairs of equals)
				while [all [any [char <> pick data 2 char <> pick data 3] count < 127]][
					count: count + 1
					data: next data
					char: pick data 1
				]
				if count > 0 [repend result [to-char (count - 1) copy/part start count]]
				if count = 127 [data: back data]
				if tail? data [break] 
				count: 0
				start: data
				char: pick data 1
				; collect a sequence of all equal characters
				while [all [char = pick data 1 count < 128]][
					count: count + 1
					data: next data
				]
				if count > 1 [repend result [to-char (256 - count + 1) char]]
			]
			data: head data
			result
		]

		decompress: func [
			"decompress a run length (aka PackBits) compressed binary"
			data [binary!] "Data to decompress"
			/local char count result
			][
			result: copy #{}
			while [not tail? data] [
				char: first data
				case [
					char < 128 [
						count: 1 + char
						insert tail result copy/part next data count
						data: skip data count + 1
					]
					char > 128 [
						insert/dup tail result to-char second data (256 + 1 - char)
						data: skip data 2
					]
					char = 128 [
						data: skip data 1
					]
				]
			]
			data: head data
			result
		]
	] ; rle

	; utility functions for LZ77 and LZSS
		shift_window: func [look-ahead-buffer positions][
			set look-ahead-buffer skip get look-ahead-buffer positions 				
		]
		match-length: func [a b /local start][
			start: a
			while [all [a/1 = b/1 not tail? a]][a: next a b: next b]
			offset? start a
		]
		find_longest_match: func [search data search-buffer-size look-ahead-buffer-size /local pos len off length result][
			pos: data
			length: 0
			result: head insert insert clear [] 0 0
			while [pos: find/case/reverse pos first data] [
				if (off: offset? pos data) > search-buffer-size [break]
				if (len: match-length pos data) > length [
					if len > look-ahead-buffer-size [break]
					length: len
					change/part result reduce [off length] 2
				]
			]
			result
		]
	;

	lz77: context [

		result: copy []

		compress: func [
			"LZ77 compress a string series"
			data [any-string!] "data to compress"
			/to-block "return abstract block"
			/local
			look-ahead-buffer look-ahead-buffer-size search-buffer search-buffer-size position length
			emit
			][
			clear result
			look-ahead-buffer: data
			look-ahead-buffer-size: 15
			search-buffer: data
			search-buffer-size: 255 ; if you increase this you have to change the code to generate binary! accordingly

			emit: func [pos len char][insert insert insert tail result pos len char]

			while [not empty? look-ahead-buffer] [
				;go backwards in search buffer to find longest match of the look-ahead buffer
				set [position length] find_longest_match search-buffer look-ahead-buffer search-buffer-size look-ahead-buffer-size
				emit position length any [pick look-ahead-buffer length + 1 "^@"]
				shift_window 'look-ahead-buffer length + 1
			]

			probe result
			; convert to compact binary!
			unless to-block [
				bit-pos: 1 ; reset bit position
				bin-result: clear head bin-result
				while [not tail? result] [
					either 0 = first result [
						insert insert tail bin-result to-char first result third result
					][
						insert insert insert tail bin-result to-char first result to-char second result third result
					]
					result: skip result 3
				]
				return copy head bin-result
			]

			copy result
		]

		decompress: func [
			"decompress LZ77 encoded binary"
			data [block! binary!] "String to decompress"
			/local flag outstring index char out bytes
			][
			if binary? data [
				;convert back to block
				;(obviously we could convert directly to final binary but this is kind of "educational")
				bit-pos: 1 ; reset bit position
				bin-result: copy data
				out: copy []
				while [0 < length? bin-result][
					flag: first bin-result
					insert tail out flag
					either flag != 0 [
						insert tail out any [pick bin-result 2 0]
						insert tail out to-char any [pick bin-result 3 0]
						bin-result: skip bin-result 3
					][
						insert tail out 0
						insert tail out to-char second bin-result
						bin-result: skip bin-result 2
					]
				]
				probe data: out
			]

			out: make binary! length? data
			foreach [offset length symbol] data [
				;go reverse in previous output by offset characters and copy character wise for length symbols;
				out: insert out bytes: copy/part skip out negate offset length
				; special case for duplicated bytes (encoding reaches look-ahead buffer)
				if length > offset [
					out: insert/dup out bytes (to-integer length / offset) - 1
					out: insert out copy/part bytes mod length offset
				] 
				out: insert out symbol
			]
			head out
		]

	] ; lz77

	lzss: context [

		result: copy []

		compress: func [
			"LZSS compress a string series"
			data [any-string!] "data to compress"
			/to-block "return abstract block"
			/local
			look-ahead-buffer look-ahead-buffer-size search-buffer search-buffer-size minimum-match-length position length
			emit emit-char
			][
			clear result
			look-ahead-buffer: data
			look-ahead-buffer-size: 15
			search-buffer: data
			search-buffer-size: 4095
			minimum-match-length: 2
			emit: func [flag pos len][insert insert insert tail result flag pos len]
			emit-char: func [flag char][insert insert tail result flag char]

			while [not empty? look-ahead-buffer] [
				;go backwards in search buffer to find longest match of the look-ahead buffer
				set [position length] find_longest_match search-buffer look-ahead-buffer search-buffer-size look-ahead-buffer-size
				either length > minimum-match-length [
					emit 0 position length
					shift_window 'look-ahead-buffer length
				][
					emit-char 1 first look-ahead-buffer
					shift_window 'look-ahead-buffer 1
				]
			]
			
			probe result
			; convert to compact binary!
			; (note that the (un)compressed flag is reversed from standard since this simplifies decoding)
			unless to-block [
				bit-pos: 1 ; reset bit position
				bin-result: clear head bin-result
				while [not tail? result] [
					either 0 = first result [
						bits-set 0 1
						bits-set second result 12
						bits-set third result 4
						result: skip result 3
					][
						bits-set 1 1
						bits-set second result 8
						result: skip result 2
					]
				]
				return copy head bin-result
			]
			copy result
		]

		decompress: func [
			"decompress LZSS encoded binary"
			data [block! string! binary!] "data to decompress"
			/local offset length out flag bytes
			][
			if string? data [data: to-binary data]
			if binary? data [
				;convert back to block
				;(obviously we could convert directly to final binary but this is kind of "educational")
				bit-pos: 1 ; reset bit position
				bin-result: copy data
				out: copy []
				while [0 < length? bin-result][
					flag: bits-get 1
					insert tail out flag
					either flag = 0 [
						insert tail out bits-get 12
						insert tail out bits-get 4
					][
						insert tail out to-char bits-get 8
					]
				]
				data: out
			]
			probe data

			out: make binary! length? data
			while [not empty? data] [
				either 0 = first data [ 
					offset: second data
					length: third data
					;go reverse in previous output by offset characters and copy character wise for length symbols;
					out: insert out bytes: copy/part skip out negate offset length
					; special case for duplicated bytes (encoding reaches look-ahead buffer)
					if length > offset [
						out: insert/dup out bytes (to-integer length / offset) - 1
						out: insert out copy/part bytes mod length offset
					] 
					data: skip data 3
				][
					out: insert out second data ; copy uncompressed character
					data: skip data 2
				]
			]
			head out
		]

	] ; lzss
	
	lz78: context [

		result: copy []
		string-table: make hash! []

		add_table_entry: func [string][head insert tail string-table string]

		compress: func [
			"LZ78 compress a string"
			data [any-string!] "String to compress"
			/to-block "return abstract block"
			/local
			bytes byte bytes+byte index
			emit index_from_string
			][
			clear result
			clear string-table
			emit: func [code char][head insert insert tail result code char]
			index_from_string: func [string /local pos][(pos: find/case string-table string) either pos [index? pos][0]]

			bytes: ""
			foreach byte data [
				bytes+byte: join bytes byte
				either find/case string-table bytes+byte [
					bytes: bytes+byte
				][
					emit index_from_string bytes byte
					add_table_entry bytes+byte
					clear bytes
				]
			]
			emit index_from_string bytes ""

			probe result
			; convert to compact binary!
			unless to-block [
				bit-pos: 1 ; reset bit position
				bin-result: clear head bin-result
				index: 1
				forskip result 2 [
					bits-set first result to integer! 0.99999 + log-2 index ; this math calcs necessary number of bits
					bits-set second result 8
					index: index + 1
				]
				return copy head bin-result
			]

			copy result
		]

		decompress: func [
			"decompress LZ78 encoded binary"
			data [block! binary!] "data to decompress"
			/local
			outstring index char out
			emit string_from_index
			][
			if binary? data [
				;convert back to block
				;(obviously we could convert directly to final binary but this is kind of "educational")
				bit-pos: 1 ; reset bit position
				bin-result: copy data
				out: copy []
				insert tail out 0
				insert tail out to-char bits-get 8
				index: 2
				while [0 < length? bin-result][
					insert tail out bits-get to integer! 0.99999 + log-2 index
					insert tail out to-char bits-get 8
					index: index + 1
				]
				data: out
			]
			probe data

			out: make binary! length? data
			emit: func [string][insert tail out string]
			string_from_index: func [index][either index > 0 [string-table/(index)][""]]

			clear string-table
			forskip data 2 [
				;read pair of index and character from input
				index: first data
				char: second data
				outstring: join string_from_index index char
				emit outstring
				add_table_entry outstring
			]
			out
		]

	] ; lz78

	lzw: context [; encoding and decoding algorithms translated from TIFF documentation

		clearcode: 256
		endofinformation: 257
		result: copy []
		string-table: make hash! []
		bit-len: 9
		
		initialize_table: does [
			either empty? string-table [
				clear head string-table
				for n 0 255 1 [insert tail string-table to-string to-char n]
				insert tail string-table clearcode
				insert tail string-table endofinformation
			][
				string-table: head clear at string-table 259
			]
			bit-len: 9
		]

		compress: func [
			"LZW compresses a string series and returns it."
			data [any-string!] "Data to compress"
			/to-block "return abstract block"
			/local bytes byte bytes+byte out
			add_table_entry emit code_from_string
			][
			result: clear head result

			bit-pos: 1 ; reset bit position
			bin-result: clear head bin-result

			initialize_table

			add_table_entry: func [string][
				insert tail string-table string
				switch length? string-table [
					512  [bit-len: 10]
					1024 [bit-len: 11]
					2048 [bit-len: 12]
					4096 [emit clearcode initialize_table]
				]
			]
			emit: func [code][
				head insert tail result either code > 255 [code][to-char code] ;remove or comment this if you want only binary
				unless to-block [bits-set code bit-len]
			]
			code_from_string: func [string][(index? find/case string-table string) - 1] ; - 1 because index? is 1 based

			emit clearcode
			bytes: ""
			foreach byte data [
				bytes+byte: join bytes byte
				either find/case string-table bytes+byte [
					bytes: bytes+byte
				][
					emit code_from_string to-string bytes
					add_table_entry bytes+byte
					bytes: byte
				]
			] ; end of for loop
			emit code_from_string to-string bytes
			emit endofinformation

			probe result
			unless to-block [return copy head bin-result]
			copy result
		]

		decompress: func [
			"Decompress LZW compressed binary"
			data [block! binary!] "Data to decompress"
			/local code oldcode out
			add_table_entry emit is_in_table
			][
			if binary? data [
				bit-pos: 1 ; reset bit position
				bin-result: copy data
				bit-len: 9
			]

			out: make binary! length? data
			add_table_entry: func [string][
				insert tail string-table string
				switch length? string-table [
					511  [bit-len: 10]
					1023 [bit-len: 11]
					2047 [bit-len: 12]
				]
			]
			emit: func [code][insert tail out code ]
			is_in_table: func [code][if code < 256 [code: to-string to-char code] any [find/case string-table code code < length? string-table]]
			get-code: func [][
				either block? data [
					to-integer first+ data
				][
					bits-get bit-len
				]
			]

			while [(code: get-code) != endofinformation] [
				either code = clearcode [
					initialize_table
					code: get-code data
					if code = endofinformation [break]
					emit string-table/(code + 1)
				][ ; end of clearcode case
					either is_in_table code [
						emit string-table/(code + 1)
						add_table_entry join string-table/(oldcode + 1) first string-table/(code + 1)
					][
						outstring: join string-table/(oldcode + 1) first string-table/(oldcode + 1)
						emit outstring
						add_table_entry outstring
					]
				] ; end of not-clearcode case
				oldcode: code
			] ; end of while loop
			out
		]

	]; lzw

]

; comment [
do [
	string: "abracadabradadadadadadaaaaaaaa"
	
	rgb: #{
F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2CCCC
CCCCCCCCDEDEDDF2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2
F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F292908F5C5951
444238615E496965515C594B4B494258554C8F8E8CDEDEDDF2F2F2F2F2F2F2F2
F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2999999312D2788
8462D0CB8DFEF9ACFEF9ACFEF9ACFEF9ACF5F0A6D0CB8D949068646253918F8C}

	print "^/Huffman compress:"
	probe string
	probe stream: compression/huffman/compress/to-block string
	probe as-string compression/huffman/decompress stream
	print "^/RLE compress:"
	probe string
	probe stream: compression/rle/compress string
	probe as-string compression/rle/decompress stream
	;probe as-string compression/rle/decompress stream
	print "^/LZ77 compress:"
	probe string
	probe stream: compression/lz77/compress string
	probe as-string compression/lz77/decompress stream
	print "^/LZSS compress:"
	probe string
	probe stream: compression/lzss/compress string
	probe as-string compression/lzss/decompress stream
	print "^/LZ78 compress:"
	probe string
	probe stream: compression/lz78/compress string
	probe as-string compression/lz78/decompress stream
	print "^/LZW compress:"
	probe string
	probe stream: compression/lzw/compress string
	probe as-string compression/lzw/decompress stream

	halt
]