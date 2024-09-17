/* 2-D FFT package --- FFT2.h */
/* this program uses 1-d FFT  */
/* so needs FFT1.h included */

/* global variables */
double data[FFT_MAX][FFT_MAX];
double jdata[FFT_MAX][FFT_MAX];
double data2[FFT_MAX][FFT_MAX];
double jdata2[FFT_MAX][FFT_MAX];

void make_original_data( );
void FFT2(int flag);
void origin_centered_FFT( );
void make_output_image( );
void make_output_image_enhanced( );

void make_original_data( )
     /* image size is converted to have the power of two */
{
  int i, j; 
  int offset1, offset2, new_size = 1;

  while (1) {
    new_size *= 2;
    if (new_size >= x_size1 && new_size >= y_size1) break;
  }
  
  if (new_size > FFT_MAX) {
    printf("Too large image size! So, stop.\n");
    exit (-1);
  } else {
    num_of_data = new_size;
    offset1 = (num_of_data - x_size1) / 2;
    offset2 = (num_of_data - y_size1) / 2;
    
    /* initialization */
    for (i = 0; i < num_of_data; i++) {
      for (j = 0; j < num_of_data; j++) {
	data[i][j] = 0.0;
	jdata[i][j] = 0.0;
      }
    }
    for (i = 0; i < y_size1; i++) {
      for (j = 0; j < x_size1; j++) {
	data[i + offset2][j + offset1] = (double)image1[i][j];
      }
    }
  }
}


void FFT2(int flag)
{
  int i, j;
  static double re[FFT_MAX], im[FFT_MAX];
  
  for (i = 0; i < num_of_data; i++) {
    for (j = 0; j < num_of_data; j++) {
      re[j] = data[i][j];
      im[j] = jdata[i][j];
    }
    FFT1(re, im, num_of_data, flag);
    for (j = 0; j < num_of_data; j++) {
      data[i][j] = re[j];
      jdata[i][j] = im[j];
    }
  }
  for (i = 0; i < num_of_data; i++) {
    for (j = 0; j < num_of_data; j++) {
      re[j] = data[j][i];
      im[j] = jdata[j][i];
    }
    FFT1(re, im, num_of_data, flag);
    for (j = 0; j < num_of_data; j++) {
      data[j][i] = re[j];
      jdata[j][i] = im[j];
    }
  }
}

void origin_centered_FFT( )
{
  int i, j;
  int ii, jj;
  double temp;
  
  for (j = 0; j < num_of_data / 2; j++) {
    for (i = 0; i < num_of_data; i++) {
      ii = (i + num_of_data / 2) % num_of_data;
      jj = (j + num_of_data / 2) % num_of_data;
      temp = data[jj][ii];
      data[jj][ii] = data[j][i];
      data[j][i] = temp;
      temp = jdata[jj][ii];
      jdata[jj][ii] = jdata[j][i];
      jdata[j][i] = temp;
    }
  }
}


void make_output_image( )
{
  int x, y;
  
  x_size2 = num_of_data;
  y_size2 = num_of_data;
  for (y = 0; y < y_size2; y++) {
    for (x = 0; x < x_size2; x++) {
      if (data[y][x] < 0) data[y][x] = 0;
      if (data[y][x] > MAX_BRIGHTNESS) data[y][x] = MAX_BRIGHTNESS;
      image2[y][x] = (unsigned char)data[y][x];
    }
  }
}


void make_output_image_enhanced( )
{
  int x, y;
  double max, min;
  
  x_size2 = num_of_data;
  y_size2 = num_of_data;
  max = min = data[0][0];
  for (y = 0; y < y_size2; y++) {
    for (x = 0; x < x_size2; x++) {
      if (max < data[y][x]) max = data[y][x];
      if (min > data[y][x]) min = data[y][x];
    }
  }
  if ((int)(max - min) == 0) {
    for (y = 0; y < y_size2; y++) {
      for (x = 0; x < x_size2; x++) {
	image2[y][x] = MAX_BRIGHTNESS;
      }
    }
  } else {
    for (y = 0; y < y_size2; y++) {
      for (x = 0; x < x_size2; x++) {
	image2[y][x] = (unsigned char)((data[y][x] - min)
				       / (max - min) * MAX_BRIGHTNESS);
      }
    }
  }
}
