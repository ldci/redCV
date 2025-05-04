Red/System [
]

rcvImage!: alias struct! [
	width			[integer!]
	height			[integer!]
	data 			[byte-ptr!] 
]

;integral images
rcvIntImage!: alias struct! [
	width			[integer!]
	height			[integer!]
	data 			[int-ptr!] 
]

rcvPoint!:  alias struct! [
	x				[integer!]
	y 				[integer!]
]

rcvSize!:  alias struct! [
	x 				[integer!]
	y				[integer!]
]

rcvRect!:  alias struct! [
	x				[integer!]
	y				[integer!]
	width 			[integer!]
	height			[integer!]
]

rcvCascade!:  alias struct! [
	nStages			[integer!]
	totalNodes		[integer!]
	scale			[float!]
	;size of the window used in the training set (20 x 20)
	origWindowSize	[rcvSize! value]
	invWindowArea	[integer!]
	sumImg			[rcvIntImage!]
	sqSumImg		[rcvIntImage!]	
	stSumImg		[rcvIntImage!]		
	;pointers to the corner of the actual detection window
	*pq0			[int-ptr!]
	*pq1			[int-ptr!]
	*pq2			[int-ptr!]
	*pq3			[int-ptr!]
	*p0				[int-ptr!]
	*p1				[int-ptr!]
	*p2				[int-ptr!]
	*p3				[int-ptr!]
	*pt0			[int-ptr!]
	*pt1			[int-ptr!]
	*pt2			[int-ptr!]
	*pt3			[int-ptr!]
	
]