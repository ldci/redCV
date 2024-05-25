
Red[
	needs: view
]

rcvXSortImage: function [src [image!] dst[image!]
"image sorting by line"
][
	w: src/size/x
	h: src/size/y
	y: 0
	while [y < h] [	
		x: 0 
		bl: copy []
		while [x < w] [
			idx: (y * w) + x + 1
			v: src/:idx
			append bl v
			x: x + 1
		]
		either reverse [b: sort/reverse bl] [b: sort bl]
		
		n: length? bl
		x: 0
		while [x < w] [
			idx: (y * w) + x + 1
			dst/:idx: b/(x + 1)
			x: x + 1
		]
		y: y + 1
	]
]

rcvYSortImage: function [src [image!] dst[image!]
"image sorting by column"
][
	w: src/size/x
	h: src/size/y
	x: 0
	while [x < w] [	
		y: 0 
		bl: copy []
		while [y < h] [
			idx: (y * w) + x + 1
			v: src/:idx
			append bl v
			y: y + 1
		]
		either reverse [b: sort/reverse bl] [b: sort bl]
		
		n: length? bl
		y: 0
		while [y < h] [
			idx: (y * w) + x + 1
			dst/:idx: b/(y + 1)
			y: y + 1
		]
		x: x + 1
	]
]


size: 400x400
reverse: false
flag: 1

loadImage: does [
    isFile: false
	tmp: request-file
	if not none? tmp [
		img1: load tmp
		img2: make image! reduce [img1/size black]
		canvas1/image: img1
		canvas2/image: img2
		isFile: true
	]
]

process: does [
	if flag = 1 [rcvXSortImage img1 img2]
	if flag = 2 [rcvYSortImage img1 img2]
	
	canvas2/image: img2
]


view win: layout [
	title "Sort"
	button "Load" [loadImage]
	r1: radio "Columns" [flag: 2 process]
	r2: radio "Lines" true [flag: 1 process]
	cb: check "Reverse" [reverse: face/data]
	button "Sort" [process]
	button "Quit" [quit]
	return
	canvas1: base size black
	canvas2: base size black
	return
	
]