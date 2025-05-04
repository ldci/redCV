#!/usr/local/bin/red-cli
Red [
	Title:   "Pandore test"
	Author:  "ldci"
	File: 	 %callp.red
]

home: select list-env "HOME"
panhome: rejoin [home "/Programmation/pandore/"]
sampleDir: rejoin [panhome "examples/"]
tmpDir: rejoin [sampleDir "tmp/"]
if not exists? to-file tmpDir [make-dir to-file tmpDir]
change-dir to-file panhome

prin "Red calls Pandore Version: " 
prog: rejoin [panhome "bin/pversion"]
call/console/shell prog
prin "Image Conversion Test: "
prog: rejoin ["bin/pbmp2pan " sampleDir "tangram.bmp " tmpDir "tangram.pan"]
call/console prog
prog: "bin/pstatus"
call/console prog
prin "Shows Pandore Image: "
prog: rejoin ["bin/pvisu " tmpDir "tangram.pan"]
call prog
prog: "bin/pstatus"
call/console prog
print "Done"

 
