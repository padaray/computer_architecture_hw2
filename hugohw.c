#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

// count cycle
typedef uint64_t ticks;
static inline ticks getticks(void){

    uint64_t result;
    uint32_t l, h, h2;
    asm volatile(
        "rdcycleh %0\n"
        "rdcycle %1\n"
        "rdcycleh %2\n"
        "sub %0, %0, %2\n"
        "seqz %0, %0\n"
        "sub %0, zero, %0\n"
        "and %1, %1, %0\n"
        : "=r"(h), "=r"(l), "=r"(h2));
    result = (((uint64_t) h) << 32) | ((uint64_t) l);
    return result;
}


uint16_t count_leading_zeros(uint64_t x){

    x |= (x >> 1);
    x |= (x >> 2);
    x |= (x >> 4);
    x |= (x >> 8);
    x |= (x >> 16);
    x |= (x >> 32);

    /* count ones (population count) */
    x -= ((x >> 1) & 0x5555555555555555);
    x = ((x >> 2) & 0x3333333333333333) + (x & 0x3333333333333333);
    x = ((x >> 4) + x) & 0x0f0f0f0f0f0f0f0f;
    x += (x >> 8);
    x += (x >> 16);
    x += (x >> 32);

    return (64 - (x & 0x7f));
}



uint16_t zbytel(uint64_t x) {

    uint64_t y;
    uint16_t n;
    y = (x & 0x7F7F7F7F7F7F7F7F)+ 0x7F7F7F7F7F7F7F7F;   // convert each 0-byte to 0x80
    y = ~(y | x |0x7F7F7F7F7F7F7F7F);                  //and each nonzero byte to 0x00
    n = count_leading_zeros(y) >> 3  ;  // use number of leading zeros
    return n;                          // n = 0 ... 8 , 8 if x has no 0-byte.
}


int main(int argc, char *argv[ ] ){

    ticks t0 = getticks();
    uint64_t a = 0x1122334455007700; //In this example,
    uint16_t zbla = zbytel(a);       //the value is 5.
    uint64_t b = 0x1122334455667788; //Another example,
    uint16_t zblb = zbytel(b);       //the value is 8
    ticks t1 = getticks();

    printf("elapsed cycle: %" PRIu64 "\n", t1 - t0);    //cycle number
    printf("%llx\n",a);
    printf("%d\n",zbla);
    printf("%llx\n",b);
    printf("%d\n",zblb);

    return 0;
}