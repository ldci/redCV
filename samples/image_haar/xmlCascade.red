#! /usr/local/bin/red 
Red [
	Title:   "Haar Cascade "
	Author:  "ldci"
	File: 	 %xmlCascade.red
	Needs:	 View
]

;--parsing stump and tree-based opencv haar cascades XML
;--we need opencv cascade files in xml format
;--such as opencv/cascades/haarcascade_eye_tree_eyeglasses.xml
;--this code is used to create txt files for a faster access by RedCV
;--use terminal mode
; Feature Rectangle
featureRect: make object! [
	x: 0					;--x coordinate
	y: 0					;--y coordinate
	width: 0 				;--width
	height: 0				;--height
	weight: 0.0				;--threshold
]

; Binary tree nodes
node: make object! [
	featureRects:	[]		;--list of feature rectangles
	isTilted: 		0		;--tilt not used 
	threshold: 		0.0		;--Threshold for determining what to select (left value/right value) or where to go on binary tree (left or right)
	leftVal: 		0.0		;--left value
	rightVal: 		0.0		;--right value
	hasLeftNode:	0		;--Does this node have a left node?
	leftNode:		0.0		;--left node. If current node does not have a left node, this will be null
	hasRightNode:	0		;--Does this node have a right node?
	rightNode:		0.0		;--Right node. If current node does not have a right node, this will be null
]

tree: make object! [
	nodes:			[] ;--Each tree can have 3 nodes max. First one is the current and others are children of the current.
]

stage: make object! [
	trees:			[]			;--Trees in the stage
	threshold:		0.0			;--Threshold of the stage
]

stagesList: 	copy []			;--Stages of the cascade
nodesList: 		copy []			;--nodes list for faster access

windowSize:	0x0             	;-- Original (unscaled) size of searching window

isFile: false
wf: 	1 ; 4096 64
llf: 	1 ; 256  4
XMLClassifier: ""
XMLCascade: ""
totalNodes: 0
nStages: 0

getCascade: func [
"Fill xmlStages string"
	classifier 	[string!]
	return: 	[string!]
][
	xml: copy ""
	parse classifier [
		thru "<opencv_storage>" copy xml to "</opencv_storage>"
	]
	xml
]

makeStages: func [
"Make stage object and create stage and node list"
	xlmStr		[string!]
][
	parse xlmStr [
	; type_id="opencv-haar-classifier"
	thru "<" copy str to ">"
	;Original (unscaled) size of searching window	
	thru "<size>" copy _winSize0 to "</size>"
	(trim/lines _winSize0 ws: split _winSize0 " "
	windowSize: as-pair to-integer ws/1 to-integer ws/2
	stagesList: copy []
	nodesList: copy []
	)
	;-- create a new stage and add it to stagesList
	; -- we use 1-based index for Red
	any [thru "<!-- stage" copy str to "-->" 
	(newStage: copy stage 
	newStage/trees: copy []
	append stagesList newStage
	)]
	]
]


makeTrees: func [
"Make tree object"
	xlmStr 	[string!]
	return: [integer!]
][
	head xlmStr
	scount: 0		;--stage counter
	fCount: 1		;--filter counter
	parse xlmStr [
		any [thru "<trees>" copy _tree to "</trees>"
		(trim/lines _tree 
		sCount: sCount + 1
		parse _tree [any [thru "<feature>" copy feature to "</feature>"
		;--create a new tree and append tree in current stage 
		(newTree: copy tree
		newTree/nodes: copy []
		curStage: stagesList/:sCount
		append curStage/trees newTree
		fCount: fCount + 1)]
		])
		]
	]
	fcount - 1
]

makeNodes: func [
"Get nodes"
	xlmStr 	[string!]
][
	count: 1
	head xlmStr
	parse xlmStr [
		any [thru "<left_" copy str to "/right_" 
		(trim/lines str
		ss: split str " "
		parse ss/1 [thru ">" copy l to "<"]
		parse ss/2 [thru ">" copy r to "<"]
		newNode: copy node
		newNode/featureRects: copy []
		left:  to-float trim l
		right: to-float trim r
		newNode/leftVal: left
		newNode/rightVal: right
		; has nodes? (max 2 nodes)
		if any [l = "1" l = "2"] [
			newNode/hasLeftNode: 1
			newNode/leftNode: to-float trim l
			newNode/leftVal: 0.0
		]
		
		if any [r = "1" r = "2"][
			newNode/hasRightNode: 1
			newNode/rightNode: to-float trim r
			newNode/rightVal: 0.0
		]
		append nodesList newNode
		count: count + 1
		)
		]
	]
]
updateNodeIndex: func [
"Correct index for nodes"
	xlmStr 	[string!]
][
	count: 1
	ncount: 0
	head xlmStr
	parse xlmStr [
		; root node always present
		any [thru "<!-- root node -->"  copy  str to "<!-- root node -->"
			(nCount: 0 curNode: nodesList/:count
			count: count + 1
			;child nodes max 2
			parse str [thru "<!-- node" copy str2 to "<!-- tree"
				(nCount: nCount + 1
				curNode: nodesList/:count
				count: count + 1 
				)
			]
			)
		]
	]
	;last values
	curNode: last nodesList
	if nCount > 0 [
		n: length? nodesList
		curNode: nodesList/(n - ncount) 
	]
]

updateStageList: does [
"Merge node list with stage list"
	count: 1
	i: 1
	while [i <= nStages][
		curStage: stagesList/:i
		n: length? curStage/trees
		j: 1
		while [j <= n] [
			curTree: copy tree
			curTree/nodes: nodesList/:count
			curStage/trees/:j: curTree
			count: count + 1
			j: j + 1
		]
		i: i + 1
	]
]

getRectangles: func [
"Get rectangles coordinates and weight"
	xlmStr 	[string!]
][
	count: 1
	head xlmStr
	parse xlmStr [
		any [thru "<rects>" copy _rect to "</rects>"
			(nRect: 0 
			parse _rect [any [thru "<_>" copy r to "</_>"
			(nRect: nRect + 1 
			trim/lines r rr: split r " "
			newRect: copy featureRect
			newRect/x: to-integer rr/1 
			newRect/y: to-integer rr/2
			newRect/width: to-integer rr/3 
			newRect/height: to-integer rr/4
			newRect/weight: to-float rr/5
			curNode: nodesList/:count
			append curNode/featureRects newRect
			)]
			]
			
			; in all case 3 rectangles
			if nRect < 3 [
				newRect: copy featureRect
				newRect/x: 0
				newRect/y: 0
				newRect/width: 0 
				newRect/height: 0
				newRect/weight: 0.0
				curNode: nodesList/:count
				append curNode/featureRects newRect
			]
			count: count + 1
		)
		]
	]
]


GetTilted: func [
"Get rectangle orientation"
	xlmStr 	[string!]
][
	count: 1
	head xlmStr
	parse xlmStr [
		any [thru "<tilted>" copy val to "</tilted>"
		(curNode: nodesList/:count
		curNode/isTilted: to-integer val count: count + 1)
		]
	]
]

getNodeThreshold: func [
"Get filters threshold"
	xlmStr 	[string!]
][
	head xlmStr
	count: 1
	parse xlmStr [
		any [thru "<threshold>" copy tThreshold to "</threshold>"
		(curNode: nodesList/:count
		curNode/threshold: to-float tThreshold count: count + 1)
		]
	]
]


getStageThreshold: func [
"Get stages threshold"
	xlmStr 	[string!]
][
	count: 1
	head xlmStr
	parse xlmStr [
		any [thru "<stage_threshold>" copy sThreshold to "</stage_threshold>"
		(curStage: stagesList/:count
		curStage/threshold: to-float sThreshold count: count + 1)
		]
	]
]

; to redCV classifier
generateClassifier: does [
	if error? try [wf:  to-integer f4/text] [wf:  1]
	if error? try [llf: to-integer f5/text] [llf: 1]
	clear a2/text
	txtClassifier: copy "[Header]" 
	append txtClassifier newline
	append txtClassifier rejoin [form nStages newline]
	foreach s stagesList [
		n: length? s/trees
		append txtClassifier rejoin [form n newline]
	]
	append txtClassifier rejoin ["[Nodes]" newline]
	append txtClassifier rejoin [form windowSize newline]
	
	foreach s stagesList [
		curTree: s/trees
		foreach t curTree [
			curNode: t/nodes
			features: curNode/featureRects
			foreach f features [
				append txtClassifier rejoin [form f/x newline]
				append txtClassifier rejoin [form f/y newline]
				append txtClassifier rejoin [form f/width newline]
				append txtClassifier rejoin [form f/height newline]
				either cb/data [val: to-integer (f/weight * wf)] [val: f/weight * wf]
				append txtClassifier rejoin [form val newline]
			]
			append txtClassifier rejoin [form curNode/isTilted newline]
			either cb/data [val: to-integer round curNode/threshold * wf] [val: curNode/threshold * wf]
			append txtClassifier rejoin [form val newline]
			either cb/data [val: to-integer round curNode/leftVal * llf] [val: curNode/leftVal * llf]
			append txtClassifier rejoin [form val newline]
			either cb/data [val: to-integer round curNode/rightVal * llf] [val: curNode/rightVal * llf]
			append txtClassifier rejoin [form val newline]
			append txtClassifier rejoin [form curNode/hasLeftNode newline]
			either cb/data [val: to-integer curNode/leftNode] [val: curNode/leftNode]
			append txtClassifier rejoin [form val  newline]
			append txtClassifier rejoin [form curNode/hasRightNode newline]
			either cb/data [val: to-integer curNode/rightNode] [val: curNode/rightNode]
			append txtClassifier rejoin [form val newline]
		]
		either cb/data [val: to-integer round s/threshold * llf] [val: s/threshold  * llf]
		append txtClassifier rejoin [form val newline]
	]
	
	a2/text: txtClassifier
	sb/text: "redCV Classifier generated"
]
	
saveClassifier: does [
	if isFile [
		fsave: request-file/save
		if not none? fsave [write fsave a2/text]
	]
]

saveRedObjects: does [
	;for tree-based and for stump-based cascades
	if isFile [
		list: copy []
		str: copy form windowSize
		append list str 
		i: 1
		while [i <= nStages] [
			v: stagesList/:i 
			str: copy "stage: make object! ["
			append str trim to-string v
			append str "]"
			append list str
			i: i + 1
		]
		fsave: request-file/save
		if not none? fsave [write fsave list]
	]
]



processXML: does [
	XMLCascade: getCascade XMLClassifier
	makeStages  XMLCascade
	nStages: length? stagesList
	getStageThreshold XMLCascade
	totalNodes: makeTrees XMLCascade
	makeNodes XMLCascade
	GetTilted XMLCascade
	getNodeThreshold XMLCascade
	getRectangles XMLCascade
	updateNodeIndex XMLCascade
	updateStageList
	;probe nodesList
	;probe stagesList/1
	
	f1/text: form windowSize
	f2/text: form nStages
	f3/text: form totalNodes
	sb/text: "Done"
]


loadXML: does [
	f: request-file 
	if not none? f [
		clear a1/text
		clear a2/text
		f0/text: form f
		sb/text: "Be patient! Parsing XML file..." 
		XMLClassifier: read f
		a1/text: XMLClassifier
		do-events/no-wait
		isFile: true
		processXML
	]
]

mainWin: layout [
	title 	"XML Cascade Parser [3]"
	button 	"Load XML"			[loadXML]
	text "Weight Factor" 
	f4: field 40 
	text "Leaf Factor"
	f5: field 40 
	cb: check "Integer" false
	button  "Generate"	[if isFile [generateClassifier]]
	button	"Save as text"			[saveClassifier]
	button  "Save as object"		[saveRedObjects]
	button 50 "Quit" 				[quit]
	return
	f0: field 850
	return
	text "Win Size" 	f1: field 70
	text "N stages" 	f2: field 70
	text "N Filters" 	f3: field 70
	return
	a1: area 630x300
	font [name: "Arial" size: 14 color: black] 
	a2: area 210x300 black
	font [name: "Arial" size: 11 color: green] 
	return
	sb: field 850
	do [f4/text: form wf f5/text: form llf]
]
view mainWin




