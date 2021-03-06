#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

// C++ implementation of Blowfish, taken from Wikipedia, for reference.
uint32_t P[18];     // P-array
uint32_t S[4][256]; // S-boxes

uint32_t f (uint32_t x) {
	uint32_t h = S[0][x >> 24] + S[1][x >> 16 & 0xff];
	return ( h ^ S[2][x >> 8 & 0xff] ) + S[3][x & 0xff];
}
void encrypt (uint32_t L, uint32_t R) {
	for (int i=0 ; i<16 ; i += 2) {
		L ^= P[i];
		R ^= f(L);
		R ^= P[i+1];
		L ^= f(R);
	}
	L ^= P[16];
	R ^= P[17];
	swap (L, R);
}
void decrypt (uint32_t L, uint32_t R) {
	for (int i=16 ; i > 0 ; i -= 2) {
		L ^= P[i+1];
		R ^= f(L);
		R ^= P[i];
		L ^= f(R);
	}
	L ^= P[1];
	R ^= P[0];
	swap (L, R);
}
void key_schedule (uint32_t key[], int keylen) {
	// Initialize the P-Array and S-Boxes
	for (int i=0 ; i<18 ; ++i)
		P[i] ^= key[i % keylen];
	uint32_t L = 0, R = 0;
	for (int i=0 ; i<18 ; i+=2) {
		encrypt (L, R);
		P[i] = L; P[i+1] = R;
	}
	for (int i=0 ; i<4 ; ++i)
		for (int j=0 ; j<256; j+=2) {
			encrypt (L, R);
			S[i][j] = L; S[i][j+1] = R;
		}
	}
