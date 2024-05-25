Red [
]

rcvCopyImage: routine [
"Copy source image to destination image"
    src1 [image!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        dst	 [red-image!]
        handle1 handleD h w x y
][
    handle1: 0
    handleD: 0
   ; utiliser init-image
    dst: image/make-at stack/push*
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
           	pixD/value: pix1/value
           	pix1: pix1 + 1
           	pixD: pixD + 1
           	x: x + 1
       	]
       	y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]
