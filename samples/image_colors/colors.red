Red [
	Title:   "System Colors"
	Author:  "ldci"
	File: 	 %colors.red
	Needs:	 View
]
;based on Vladimir Vasilyev's code;'
;See https://github.com/red/code/blob/master/Scripts/palette.red
;help-string is available in console only
;colors: exclude sort extract load help-string tuple! 2 [transparent glass]
;so use redCV function to get system colors


; required libs
#include %../../libs/core/rcvCore.red

colors: rcvGetSystemColors

view/tight collect [
	keep reduce ['title "System colors in Red"]
    until [
        foreach color take/part colors 4 [
            keep reduce [
                'base 130x60 form rejoin [color " :" get color]; 'show face color, color name and tuple value
                get color 
                pick [white black] gray > get color; nice for changing  font color 
            ]
        ]
        keep 'return
        empty? colors
    ]
]

;Hiiamboris for fun
;remove-each w colors: words-of system/words [try [not tuple? get w]]
;parse colors: to [] system/words [collect any [thru tuple! p: keep (to 'p p/-2)]]