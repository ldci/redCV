/* 1-D FFT package --- FFT1.h */
#define FFT_MAX  1024
#define PI 3.141592653589  /* the circular constant */

/* Global variables */
int number, num_of_data, power, flag;
double *r_part, *im_part;

/* Prototype declaration of functions */
int calc_power_of_two(int number);
void make_initial_data(double *r_part, double *im_part, 
		       int num_of_data, int power);
void FFT1(double *r_part, double *im_part, int num_of_data, int flag);


int calc_power_of_two(int number)
     /* check if number is the power of two */
     /* ex. 8 --> 3, 16 --> 4, 32 --> 5,... */
{
  int power;
  
  power = 0;
  while (number != 1) {
    power++;
    number = number >> 1;  /* division by two */
  }
  return (power);
}

void make_initial_data(double *r_part, double *im_part, 
		       int num_of_data, int power)
     /* rearrangement of data for input to FFT */
{
  int i, j;              /* loop variable              */
  int pntr, offset;      /* variables for array elements   */
  int new_pntr;          /* new element number */
  int DFT;               /* dimension of DFT */
  double r_p[FFT_MAX], im_p[FFT_MAX];  /* arrays for output  */
  
  DFT = num_of_data;
  for (i = 1; i < power; i++) {
    new_pntr = 0;
    offset = 0;
    while (new_pntr < num_of_data) {
      pntr = 0;
      while (pntr < DFT) {
	r_p[new_pntr] = *(r_part + offset + pntr);
	im_p[new_pntr] = *(im_part + offset + pntr);
	new_pntr++;
	pntr = pntr + 2;
	if (pntr == DFT) pntr = 1;
      }
      offset = offset + DFT;
    }
    /* result of calculation is copied into arrays */
    for (j = 0; j < num_of_data; j++) {
      *(r_part + j) =  r_p[j];
      *(im_part + j) = im_p[j];
    }
    DFT = DFT / 2;
  }
}

void FFT1(double *r_part, double *im_part, int num_of_data, int flag)
     /* FFT (flag = 1), IFFT (flag = -1) */
{
  int i, j, k, power;
  double unit_angle, step_angle;  /* angle variables  */
  int DFT, half, num_of_DFT; 
  int num_out, num_in1, num_in2;
  double r_p, im_p, angle;      /* working variables */
  
  static double r_p_new[FFT_MAX], im_p_new[FFT_MAX];
  
  /* IFFT ( flg = -1 ) */
  if (flag == -1) {
    for (i = 0; i < num_of_data; i++) {
      *(r_part + i) = *(r_part + i) / num_of_data;
      *(im_part + i) = - *(im_part + i) / num_of_data;
    }
  }
  
  power = calc_power_of_two(num_of_data);
  
  make_initial_data(r_part, im_part, num_of_data, power);
  
  unit_angle = 2.0 * PI / num_of_data;
  DFT = 2;
  for (i = 0; i < power; i++) {
    num_of_DFT = num_of_data / DFT;
    step_angle = unit_angle * num_of_DFT;
    half = DFT / 2;
    for (j = 0; j < num_of_DFT; j++) {
      angle = 0.0;
      for (k = 0; k < DFT; k++) {
	num_out = j * DFT + k;
	if (k < half) {
	  num_in1 = num_out;
	  num_in2 = num_in1 + half;
	} else {
	  num_in2 = num_out;
	  num_in1 = num_out - half;
	}
	
	r_p = *(r_part + num_in2);
	im_p = *(im_part + num_in2);
	r_p_new[num_out] = *(r_part + num_in1) 
	  + r_p * cos(angle) + im_p * sin(angle);
	im_p_new[num_out] = *(im_part + num_in1) 
	  + im_p * cos(angle) - r_p * sin(angle);
	
	angle = angle + step_angle;
      }
    }
    /* result of calculation is copied into original arrays */
    for (j = 0; j < num_of_data; j++) {
      *(r_part + j) = r_p_new[j];
      *(im_part + j) = im_p_new[j];
    }
    DFT = DFT * 2;
  }
  /* IFFT ( flg = -1 ) */
  if (flag == -1) {
    for (j = 0; j < num_of_data; j++) {
      *(im_part + j) = - *(im_part + j);
    }
  }
}