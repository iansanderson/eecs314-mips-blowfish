# C++ implementation of Blowfish, taken from Wikipedia, for reference.
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
	jal testinput			#test our input
	add $s0, $zero, $v0		#copy v0 into s0 to save our behavior choice
	la $a0, ifileprompt		#load our input file prompt into a0
	li $a1, 200				#set max length of input file path
	li $v0, 4				#set v0 to 4 for string printing
	syscall					#print our prompt
	li $v0, 8				#set v0 to 8 for string reading
	syscall					#read in our file path
	#TODO: start reading in file
	#TODO: set a0 and a1 to reasonable values before calling keysched
	jal keysched			#call key_schedule
	j finish				#we're done here

f:							#takes a0 as "x"
	srl $t0, $a0, 24		#shift a0 right 24 bits, store in t0
	srl $t1, $a0, 16		#shift a0 right 16 bits, store in t1
	srl $t2, $a0, 8			#shift a0 right 8 bits, store in t2
	addu $t3, $zero, $a0	#copy a0 into t3
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

encrypt:					#takes a2 as "L" and a3 as "R".
	add $s2, $zero, $ra		#copy ra into s2 so we can jump to other functions while here and still get back correctly
	li $t0, 0				#initialize t0 to 0 for looping(loop variable)
	li $t1, 16				#initialize t1 to 16 for looping(end condition)
eloop:	beq $t0, $t1, endel		#jump to the end of the loop if we've finished
		la $t2, plist			#load the P array's address into t2
		sll $t3, $t0, 2			#shift t0 left twice and store in t3, for addressing
		add $t4, $t2, $t3		#sum t2 and t3 into t4 for accessing the P array
		lw $t5, ($t4)			#load that element into t5
		xor $a2, $a2, $t5		#xor a2 with t5 and store in a2
		add $a0, $zero, $a2		#copy a2 into a0 for calling f
		jal f					#call f
		xor $a3, $a3, $v1		#xor a3 with the result of f and store in a3
		addi $t4, $t4, 1		#add 1 to t4 and store in t4
		lw $t5, ($t4)			#load the t4th element of the P array into t5
		xor $a3, $a3, $t5		#xor a3 with t5 and store in a3
		add $a0, $zero, $a3		#copy a3 into a0 for calling f
		jal f					#call f
		xor $a2, $a2, $v1		#xor a2 with the result of f and store in a2
		addi $t0, $t0, 2		#increment t0 by 2 for looping(invariant)
		j eloop					#continue the loop
endel:
	la $t0, plist			#load the P array's address into t0
	addi $t0, $t0, 64		#add 64 to it for the address of the 16th element
	lw $t1, ($t0)			#load that element into t1
	xor $a2, $a2, $t1		#xor a2 with the 16th element of the P array, store in a2
	addi $t0, $t0, 4		#add 4 more for the 17th element
	lw $t1, ($t0)			#load that element into t1
	xor $a3, $a3, $t1		#xor a3 with the 17th element of the P array, store in a3
	add $v0, $zero, $a3		#return a3 as "L"
	add $v1, $zero, $a2		#return a2 as "R"
	add $ra, $zero, $s2		#copy s2 back to ra to return to (hopefully) keysched
	jr $ra

decrypt:					#takes a2 as "L" and a3 as "R".
	add $s2, $zero, $ra		#copy ra into s2 so we can jump to other functions while here and still get back correctly
	li $t0, 16				#initialize t0 to 16 for looping(loop variable)
	li $t1, 0				#initialize t1 to 0 for looping(end condition)
dloop:	beq $t0, $t1, enddl		#jump to the end of the loop if we've finished
		la $t2, plist			#load the P array's address into t2
		sll $t3, $t0, 2			#shift t0 left twice and store in t3, for addressing
		add $t4, $t2, $t3		#sum t2 and t3 into t4 for accessing the P array
		addi $t4, $t4, 1		#add 1 to t4 and store in t4
		lw $t5, ($t4)			#load that element into t5
		xor $a2, $a2, $t5		#xor a2 with t5 and store in a2
		add $a0, $zero, $a2		#copy a2 into a0 for calling f
		jal f					#call f
		xor $a3, $a3, $v1		#xor a3 with the result of f and store in a3
		addi $t4, $t4, -1		#subtract 1 from t4 and store in t4(getting back to the "i"th element, rather than "i+1"th)
		lw $t5, ($t4)			#load the t4th element of the P array into t5
		xor $a3, $a3, $t5		#xor a3 with t5 and store in a3
		add $a0, $zero, $a3		#copy a3 into a0 for calling f
		jal f					#call f
		addi $t0, $t0, -2		#decrement t0 by 2 for looping(invariant)
		j dloop					#continue the loop
enddl:
	la $t0, plist			#load the P array's address into t0
	lw $t1, ($t0)			#load that element into t1
	xor $a3, $a3, $t1		#xor a3 with the 0th element of the P array, store in a3
	addi $t0, $t0, 4		#add 4 to it for the address of the 1st element
	lw $t1, ($t0)			#load that element into t1
	xor $a2, $a2, $t1		#xor a2 with the 1st element of the P array, store in a2
	add $v0, $zero, $a3		#return a3 as "L"
	add $v1, $zero, $a2		#return a2 as "R"
	add $ra, $zero, $s2		#copy s2 back to ra to return to (hopefully) keysched
	jr $ra

keysched:					#takes a0 as "key[]" and a1 as "keylen"
	add $s1, $zero, $ra		#copy ra into s1 so we can jump to other functions while here and still get back correctly
	#TODO: initialize P array and S boxes
	li $t0, 0				#set t0 to 0 for looping(loop variable)
	li $t1, 18				#set t1 to 18 for looping(end condition)
ksl1:	beq $t0, $t1, endkl1	#jump to the end of the loop if we've finished
		div $t0, $a1			#divide t0 by a1 to get "i % keylen"
		mfhi $t2				#copy the result of "i % keylen" into t2
		sll $t2, $t2, 2			#shift t2 left twice for addressing
		add $t3, $t2, $a0		#copy a0 into t3 and add t2 to it so that t3 is the address of the element in "key[]" that we want
		lw $t4, ($t3)			#load that element into t4
		la $t2, plist			#load the address of the P array into t2
		sll $t3, $t0, 2			#shift t0 left twice and store in t3 for addressing
		add $t3, $t2, $t3		#sum t2 and t3, store in t3
		sw $t4, ($t3)			#store the value we put into t4 in the address t3 ("P[i]")
		addi $t0, $t0, 1		#increment t0 by 1 for looping(invariant)
		j ksl1					#continue the loop
endkl1:
	#TODO: the meat of keysched
	add $ra, $zero, $s1		#copy s1 back to ra to return to (hopefully) main
	jr $ra

testinput:
	li $t0, 1				#load 1 into t0
	bne $v0, $t0, tt		#test v0 against t0 (1). if they're unequal, go to where we test it against 2.
	jr $ra					#otherwise, return to where we came from
tt:		li $t0, 2				#load 2 into t0
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
	la $a0, donemsg			#load our ending message into a0
	li $v0, 4				#set v0 to 4 for string printing
	syscall					#print the ending message
	li $v0, 10				#set v0 to 10 for exiting
	syscall					#exit

.data
plist: .space 72
slistone: .space 1024
slisttwo: .space 1024
slistthree: .space 1024
slistfour: .space 1024
behaviorprompt: .asciiz "Are we encrypting(1) or decrypting(2)? "
invalidinput: .asciiz "Invalid input. Exiting. \n"
ifileprompt: .asciiz "Please enter the full path of the input file(max 200 characters): "
ofileprompt: .asciiz "Please enter the full path to where you wish the result to appear(max 200 characters): "
donemsg: .asciiz "Complete! \n"