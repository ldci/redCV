# Computer Vision with Red Language 
## see http://www.red-lang.org 
### This library needs View 


For Windows and macOS. 
Due to the excellent work of Regis 
Available for Linux now with GTK backend.

### You need the lastest Red master version.

Developped under macOS 10.14

Tested with macOS, Windows XP and Windows 10.

You must compile samples since red routines are required.

Use first -u compiler option to create a Red RT library and then just -c option which makes the compilation faster:

*red -u -c FileName -> creates a specific LibRT*

*then just red -c FileName -> Faster compilation*

### UPDATE JULY 22 2019
A lot of important changes before summer break

Updated libs

New functions for image effect. K-means algorithm implemented ...

New sample directory organization

New documentation including samples documentation (work in progress)


### UPDATE APRIL 25 2019
Updated documentation. New distance functions and samples (/samples/voronoi).

### UPDATE MARCH 25 2019

Updated documentation. New functions and samples.

### UPDATE FEBRUARY 4 2019

Update for red 0.6.4 version

### UPDATE AUGUST 26 2018

Dynamic Time Warping added to redCV.


### UPDATE AUGUST 4 2018
General update for documentation.

General update for code sample.

A lot of new samples are added for lines and shapes detection in image.


### UPDATE FEBRUARY 16 2018
redCV can write tiff images: 24-bit color format.

### UPDATE FEBRUARY 10 2018

redCV can read tiff files now. 1 to 4 channels 8-bit uncompressed images are supported. 
see /samples/tiff for code sample.

Doc is also updated.

### UPDATE JANUARY 20 2018

You'll find in /samples/image_compression/ new code for image compression with ZLib.

Documentation is updated.

### UPDATE JANUARY 04 2018

Happy New Year!

New samples in /video for wrting and reading video files with Red and Camera


### UPDATE DECEMBER 28 2017
Update for video samples according to evolution of red camera object. 

### NEW OCTOBER 4 2017

General update for Red 0.6.3

New samples for distance maps

Documentation is updated

### NEW JULY 4 2017
Added rcvContourArea function and new samples
### NEW JULY 1 2017
Quick Convex Hull algorithm added to RedCV.

Samples and documentation updated. 


### NEW JUNE 22 2017

Most of code (libs and sample) is updated according to Red modifications for Image! datatype. 

New edges detection fast operators are also added.  


### NEW MAY 13 2017

Documentation is reorganized for a better comprehension and includes an **index** of all implemented functions.

New RedCV functions added such as **logarithmic image processing model**.

A lot of new edges filters added in library and in code samples.

### APRIL 1 2017

ImageClip.red and libs updated.


### NEW MARCH 29 2017

RedCV can be used with Red 0.6.2.

New samples added such as clipping functions



### NEW DECEMBER 5 2016

Updated version for samples including B&W filters, histograms and integral image

You have to compile samples with following command:

red -c -t Windows filename.red

### NEW NOVEMBER 14 2016

Integral for matrices and images are added.

See RedCV manual for details.


### NEW NOVEMNBER 12 2016

WARNING: some exe are reported with "TR/Crypt.XPACK.Gen2" infection by Github.

Puzzling since exe are compiled under MacOS, but to avoid any problems all exe are suppressed.

You'll need to compile samples with following command:

red -c -t Windows filename.red

Very easy to do :)


### NEW NOVEMBER 9 2016

Extended morphological operators  and samples added.

Documentation updated.

### NEW NOVEMBER 4 2016

Morphological operators for color images added.

### NEW OCTOBER 18 2016

rcvHistogramEqualization function added in library. 

This very fast function is useful for improving contrast in low-contrasted images or simply modifying the contrast of image.

### NEW OCTOBER 15 2016

Statistical functions improved. See RedCV_Manual documentation for details.

### NEW OCTOBER 14 2016

New samples in /samples/Draw_DSL/ 

This is an illustration of how Draw DSL can be used to create nice graphical applications.

Enjoy 


### NEW OCTOBER 10 2016

rcvScaleImage, rcvTranslateImage and rcvRotateImage are now RedCV Functions.

See RedCV_Manual for details.

Samples and documentation updated.


### NEW OCTOBER 10 2016

Scale, Translate and Rotate operators based on Red Draw Dialect added.

New convolution samples added.


### NEW OCTOBER 5 2016

RedCV Reference Manual replaces basic documentation.

About 150 functions tested and are functional.


### NEW SEPTEMBER 29 2016

New color space conversions added.

rcvInRange function added: Extracts sub array from image according to lower and upper rgb values.

Samples and documentation updated.

### NEW SEPTEMBER 25 2016

Histogram functions for matrices and color images added.

New samples added.

Doc updated.

### NEW SEPTEMBER 21 2016

Statistical functions are rewritten to be used with images and matrices.

rcvMinLoc and rcvMaxLoc functions added: Finds global minimum or maximum location in array.

Doc updataed.

### NEW SEPTEMBER 19 2016

Split and Merge functions for matrices are added.


### NEW SEPTEMBER 12 2016
A lot of optimized functions for working with 8,16 and 32-bit integer matrices.

New samples added.

Documentation updated.

### NEW SEPTEMBER 1 2016
Image resizing and Gaussian Pyramid Decomposition are added with this function: 

rcvResizeImage: function [src [image!] canvas iSize [pair!]/gaussian return: [pair!]]

Only Gaussian 5x5 kernel is currently supported. Canvas is a base facet.If you don’t call /Gaussian refinement image is just resized by Red.
Documentation updated.


### NEW AUGUST 29 2016

Convolution with integer matrices is now possible. 

Also added  a faster rcvFastConvolve working on separate image channel or grayscaled images. 


### NEW AUGUST 24 2016

Back from summer break with a lot of new samples and functions!

Matrices can be used now with vector! datatype, but we'll wait for the matrix! datatype for improving functions.

New samples folder thematic organization.

Doc is updated.


### NEW JULY 27 2016

gaussianFilter sample updated.


### NEW JULY 26 2016

Slight changes in libs: all red routines begin with underscore (e.g. _rcvCopy).

Documentation updated.

Samples updated.   

New samples added in /samples/test directory.


### NEW July 24 2016

A sample for Gaussian Filter


### NEW July 23 2016

Gaussian filter added (see /samples/test/ testGaussian.red)


### NEW July 18 2016

Convolve routines are improved but rather low speed as expected!

2D Filtering can be used. (see documentation for details)

More samples to come

### NEW July 12 2016

Fast flip render and documentation update

### NEW july 10 2016

#### Documentation for redCV functions added

### NEW july 9 2016

Black and white image filter added.

A new sample (motion.red) for motion tracking with webcam.


### NEW: July 8 2106
A lot of work for this new version with faster routines and functions

Most of functions are in the form rcvFunction [src [image!] dst [image!]] [....]
This avoids memory leaks due to image copy 

New organizations for libs 

All Red/System Routines are in the same file and routines are exported as red functions in the various libs

New basic samples (to be compiled) 

Documentation and new samples will be included ASAP


### NEW: June 28 2016

rcvFlip routines are faster (written in Red/System).

Motion detection sample added : you can use your webcam to do a video monitoring!

Samples are compiled with -t WindowsXP option.


### NEW: June 22 2016
Libs are improved for faster routines.

New convolution samples are included.

Rendering duration is calculated with the new Red timer and sent back to the user.

Special thanks for DideC for interface improvment:)

New folder organisation:

/samples for red code
/samples/_exe for exec files


### NEW: June 17 2016

Convolution routines for images are added.

More to come ...


### NEW: June 15 2016
Added statistical functions on image.

Added some space color conversion.

More to come...


### NEW: June 2016
After playing a long time with OpenCV and Red language, it's time for me to write some image processing functions directly with Red:)

Conversions, logical and some math operators for images are available.


According to KISS spirit of Red, you only need  to include one file in your code : #include %libs/redcv.red.(See opimage.red sample for detail).

This file includes Red Functions and calls all necessary routines. 

More functions and samples to come!

You'll find some images to play within images folder. All supported images by Red can be used.

Special thanks to Nenad for developing Red, and to Qingtian for image implementation.


##Please feel free to contribute and enjoy :)
