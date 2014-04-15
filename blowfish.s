# C implementation of Blowfish, taken from Wikipedia, for reference.
#
# uint32_t P[18];     // P-array
# uint32_t S[4][256]; // S-boxes
# 
# uint32_t f (uint32_t x) {
#    uint32_t h = S[0][x >> 24] + S[1][x >> 16 & 0xff];
#    return ( h ^ S[2][x >> 8 & 0xff] ) + S[3][x & 0xff];
# }
# 
# void encrypt (uint32_t & L, uint32_t & R) {
#    for (int i=0 ; i<16 ; i += 2) {
#       L ^= P[i];
#       R ^= f(L);
#       R ^= P[i+1];
#       L ^= f(R);
#    }
#    L ^= P[16];
#    R ^= P[17];
#    swap (L, R);
# }
# 
# void decrypt (uint32_t & L, uint32_t & R) {
#    for (int i=16 ; i > 0 ; i -= 2) {
#       L ^= P[i+1];
#       R ^= f(L);
#       R ^= P[i];
#       L ^= f(R);
#    }
#    L ^= P[1];
#    R ^= P[0];
#    swap (L, R);
# }
# 
# void key_schedule (uint32_t key[], int keylen) {
#    // ...
#    // initializing the P-array and S-boxes with values derived from pi; omitted in the example
#    // ...
#    for (int i=0 ; i<18 ; ++i)
#       P[i] ^= key[i % keylen];
#    uint32_t L = 0, R = 0;
#    for (int i=0 ; i<18 ; i+=2) {
#       encrypt (L, R);
#       P[i] = L; P[i+1] = R;
#    }
#    for (int i=0 ; i<4 ; ++i)
#       for (int j=0 ; j<256; j+=2) {
#          encrypt (L, R);
#          S[i][j] = L; S[i][j+1] = R;
#       }
# }

main:
	la $a0, behaviorprompt	#load our behavior prompt into a0
	li $v0, 4				#set v0 to 4 for string printing
	syscall					#print our prompt
	li $v0, 5				#set v0 to 5 for integer reading
	syscall					#read input into v0
	jal testinput
	la $a0, ifileprompt		#load our input file prompt into a0
	li $a1, 200				#set max length of input file path
	li $v0, 4				#set v0 to 4 for string printing
	syscall					#print our prompt
	li $v0, 8				#set v0 to 8 for string reading
	syscall					#read in our file path
	#TODO: start reading in file
	j keysched				#call key_schedule
	#TODO: call relevant functions

f:
	srl $t0, $s0, 24		#shift s0 right 24 bits, store in t0
	srl $t1, $s0, 16		#shift s0 right 16 bits, store in t1
	srl $t2, $s0, 8			#shift s0 right 8 bits, store in t2
	addu $t3, $zero, $s0	#copy s0 into t3
	andi $t1, $t1, 0xff		#and our 16-bit-shifted copy of s0 with 255
	andi $t2, $t2, 0xff		#again, for 8-bit
	andi $t3, $t3, 0xff		#again, for the non-shifted one
	sll $t0, $t0, 2			#shift t0 left 2 for use as an array index
	sll $t1, $t1, 2			#same for t1
	sll $t2, $t2, 2			#same for t2
	sll $t3, $t3, 2			#same for t3
	la $t0, slistone($t0)	#load the element of slistone at t0 into t0
	la $t1, slisttwo($t1)	#same, for slisttwo and t1
	la $t2, slistthree($t2)	#same, for slistthree and t2
	la $t3, slistfour($t3)	#same, for slistfour and t3
	add $t0, $t0, $t1		#add t0 to t1 and store in t0
	xor $t0, $t0, $t2		#xor with t2
	add $v1, $t0, $t3		#add to t3 and store in v1 for output
	jr $ra					#jump back to where we came here from.

encrypt:


decrypt:


keysched:


testinput:
	li $t0, 1				#load 1 into t0
	bne $v0, $t0, t2		#test v0 against t0 (1). if they're unequal, go to where we test it against 2.
	jr $ra					#otherwise, return to where we came from
t2: li $t0, 2				#load 2 into t0
	bne $v0, $t0, invalid	#if v0 and t0 are still unequal we got neither 1 nor 2, input invalid.
	jr $ra					#otherwise, jump back to where we came from

invalid:
	la $a0, invalidinput	#load our invalidity notice into a0
	li $v0, 4				#set v0 to 4 for string printing
	syscall					#print the notice
	li $a0, 1				#set a0 to 1, an arbitrary error code
	li $v0, 17				#set v0 to 17 for exiting with a code
	syscall					#exit with code a0

finish:
	li $v0, 10				#set v0 to 10 for exiting
	syscall					#exit

.data
#These lists obviously don't have the correct data in them. plist is the right length, though,
#and the 256 at the end of the slists denotes that that's how long they will be.
plist: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18
slistone: 1, 2, 3, 4, 5, 6, 256
slisttwo: 1, 2, 3, 4, 5, 6, 256
slistthree: 1, 2, 3, 4, 5, 6, 256
slistfour: 1, 2, 3, 4, 5, 6, 256
behaviorprompt: .asciiz "Are we encrypting(1) or decrypting(2)? "
invalidinput: .asciiz "Invalid input. Exiting. \n"
ifileprompt: .asciiz "Please enter the full path of the input file(max 200 characters): "
ofileprompt: .ascciiz "Please enter the full path to where you wish the result to appear(max 200 characters): "