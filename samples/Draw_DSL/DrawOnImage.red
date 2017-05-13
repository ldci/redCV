Red [
	Title:   "Histogram tests "
	Author:  "Francois Jouen"
	File: 	 %DrawOnImage.red
	Needs:	 'View
]

img1: load %../../images/baboon.jpg
margins: 5x5

plot: copy [line-width 2 pen red line 0x0 512x512 pen off pen green line 0x512 512x0 
	box 10x10 50x50 box 55x55 75X75
]



view win: layout [
		title "Image Tests"
		origin margins space margins
		button 60 "Draw" [img: draw img1 plot canvas/image: img]
		button 60 "Quit" 	[Quit]
		return 
		canvas: base 512x512 img1 
		return
		sbar: field 250
		do [sbar/data: length? img1/rgb]
]
