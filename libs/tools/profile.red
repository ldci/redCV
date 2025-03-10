#!/usr/local/bin/red
Red []

e.g.: :comment

delta-time: function [
	"Return the time it takes to evaluate a block"
	code [block! word! function!] "Code to evaluate"
	/count ct "Eval the code this many times, rather than once"
][
	ct: any [ct 1]
	t: now/time/precise
	if word? :code [code: get code]
	loop ct [do code]
	now/time/precise - t
]

runs-per: function [
	"Return the number of times code can run in a given period"
	code [block! word! function!] "Code to evaluate"
	time [time!]
][
	t: now/time/precise
	n: 0
	if word? :code [code: get code]
	until [
		n: n + 1
		do code
		now/time/precise - t >= time
	]
	n
]

; Putting the runtime first in results, and memory second, helps things
; line up nicely. It's a problem if we want to add more stats though, 
; as any code using the data with expected field indexes will break if
; we don't add the new stats at the end. We could use named fields as
; well but, for now, we'll stick with this and let this comment serve
; as a warning. More stats will certainly come in the future, as will
; GC, but this is just a quickie function in any case.
; Memory stats and formatted output added by @toomasv.
profile: function [
	"Profile code, returning [time memory source] results"
	blocks [block!] "Block of code values (block, word, or function) to profile"
	/count ct "Eval code this many times, rather than once"
	/show "Display results, instead of returning them as a block"
	/kb /mb /sec
][
	ct: any [ct 1]										; set number of evaluations
	baseline: delta-time/count [] ct
	res: collect [
		foreach blk blocks [
			stats-1: stats								; get current stats before evaluation
			n: subtract delta-time/count :blk ct baseline
			keep/only reduce [
				round/to n .001
				round/to n / ct .001
				stats - stats-1
				either block? :blk [copy blk][:blk]
			]
		]
	]
	if kb or mb [
		forall res [
			res/1/3: round/to either kb [res/1/3 / 1000.0][res/1/3 / 1000000.0] .01
		]
	]
	sort res											; sort by time
	either show [
		print ["Count:" ct]
		template: [pad (time) 12 #"|" pad (time-per) 12 #"|" pad/left (memory) 11 #"|" (mold/flat :code)]
		insert/only res compose/deep [
			(rejoin ["Time" (either sec [" (sec)"][""])]) 
			"Time (Per)" 
			(rejoin ["Memory" (case [kb [" (kb)"] mb [" (mb)"] true [""]])]) 
			Code
		]	; last column is molded, so not a string here
		foreach blk res [
			set [time time-per memory code] blk
			print compose template
		]
	][
		insert/only res compose [count: (ct) fields: [Time Time-Per Memory Code]]
		case/all [
			sec [change    res/1/4   'Time_sec]
			kb  [change at res/1/4 3 'Memory_kb]
			mb  [change at res/1/4 3 'Memory_mb]
		]
		new-line/all res on								; Return formatted results
	]
]
e.g. [
	profile []
	profile/show []
	
	profile [[wait 1] [wait .25] [wait .5]]
	profile/count [[100 / 1 * (100 / 1)] [100.0 / 1.0 ** 2] [100% / 1%]] 1000000
	
	one: [1 + 1]
	two: [2 + 2]
	profile [one two]

	profile/show [[wait 1] [wait .25] [wait .5]]
	profile/show/count [[100 / 1 * (100 / 1)] [100.0 / 1.0 ** 2] [100% / 1%]] 1000000
	profile/show [one two]
	
	b1: [wait .25]
	b2: [wait .5]
	profile/show/count reduce [b1 b2] 2

	f1: does [wait .25]
	f2: does [wait .5]
	profile/show/count reduce [:f1 :f2] 2
	
]
