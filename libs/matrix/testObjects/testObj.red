Red [
]

matrix: context [
	; integer or float matrix type
	getMatType: routine [
	"Returns matrix type (char, integer or float)"
		mat  	[vector!]
		return: [integer!]
		/local
		s		[series!] 
		unit	[integer!] 
		type	[integer!]
	][
		s: GET_BUFFER(mat)
		unit: GET_UNIT(s)
		; 1 char or integer 2 float
		either unit <= 4 [type: 1] [type: 2] 
		type
	]
	
	getMatBitSize: routine [
	"Returns matrice bit size"
		mat  	[vector!]
		return: [integer!]
		/local
		s		[series!]  
	][
		s: GET_BUFFER(mat)
		GET_UNIT(s)
	]
	
	
];--end of context

mat: make vector! [float! 64 1000]
print matrix/getMatType mat
print matrix/getMatBitSize mat