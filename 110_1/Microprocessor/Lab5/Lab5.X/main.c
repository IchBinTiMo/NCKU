#include "xc.h"

extern unsigned int divide(unsigned int a, unsigned int b);
extern unsigned int divide_signed(unsigned char a, unsigned char b);

void main(void) {
    volatile unsigned int res = divide_signed(-3, -5 ) ;
    volatile unsigned char quotient = res;
    volatile unsigned char remainder = res >> 8;
    while(1)
        ;
    return;
} 
