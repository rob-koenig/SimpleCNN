// ---------- SimpleCNN Model Parameters/Constants ----------
.data
// Kernels used for convolution. (6 x 5 x 5) signed bytes
conv_weights:   .byte 1, 2, 1, 1, 5, 2, 7, 4, 4, 4, -5, 1, 2, 0, 0, -9, -4, -4, -3, -2, 0, -3, -3, -2, 0, -4, 1, 3, 2, -1, -2, 3, 3, 1, -5, 5, 4, 2, 0, -4, 5, -1, -3, -2, -4, -5, -6, -1, -1, -2, 0, 3, 0, -3, 0, 8, 4, 2, -6, -6, -1, 1, 10, -2, -5, -8, -3, 9, 5, 1, -1, -4, 0, 4, 6, -3, 8, -2, -5, -3, 4, 5, -6, -5, -1, 4, 6, -3, 0, 1, 0, 1, 1, 0, 1, 1, 1, -1, 1, -1, -5, -3, 0, 4, 2, -2, 0, -1, 4, 4, -3, 0, -2, 3, 3, -3, -1, 0, 5, 2, -3, -4, -5, 0, 5, -7, -3, -2, -2, 4, -3, -4, -4, -6, -3, 3, -1, -1, -3, -5, 4, 3, 3, 1, -5, 3, 1, 2, 4, 2
// Biases used for convolution (6) signed bytes
conv_biases:    .byte -67, -114, -96, -54, -120, -128

// ---------- SimpleCNN Input/Outputs Matrices ----------
.bss
// Input image that is used by the convolution_max_pool procedure. (28 x 28) unsigned bytes
image:                  .space 784
// Temporary matrix used by the convolution_max_pool procedure to store the intermediate
// result of convolution. This is passed to the max_pool function. (24 x 24) signed ints
conv_output:            .space 2304
// This is used to store the result of the convolution_max_pool procedure
// This is passed to the max_pool function. (6 x 12 x 12) signed ints
conv_max_pool_output:   .space 3456

// ---------- Main Procedure (Non-Leaf) ----------
.text
.global _start

_start:
    LDUR X0, =image
    LDUR X1, =conv_weights
    LDUR X2, =conv_biases
    LDUR X3, =conv_max_pool_output
    BL convolution_max_pool
exit:
    // Exit sys call terminates program
    MOV X8, #93
    SVC 0

// ---------- ConvolutionMaxPool Procedure (Leaf) ----------
// Parameters:
//   X0: image
//   X1: weights
//   X2: biases
//   x3: output
convolution_max_pool:
	// set X9 (i) to 0
    MOV X9, #0
	// set other constants
	MOV X6, #5
	MOV X7, #6
	MOV X8, #4
    loop_icon:
		// Compare i with TOTAL_KERNELS
        CMP X9, #6
		// Break if i >= TOTAL_KERNELS
        B.GE loop_icon_end
		// set X4 to the base address of conv_output
		LDUR X4, =conv_output
		// set X10 (j) to 0
        MOV X10, #0
   		loop_jcon:
			// Compare j with CONV_OUTPUT_SIZE
    	    CMP X10, #24
			// Break if j >= CONV_OUTPUT_SIZE
	    	B.GE loop_jcon_end
			// set X11 (k) to 0
    	    MOV X11, #0
    	    loop_kcon:
				// Compare k with CONV_OUTPUT_SIZE
    			CMP X11, #24
				// Break if k >= CONV_OUTPUT_SIZE
				B.GE loop_kcon_end
				// set X12 (con_sum) to 0
    			MOV X12, #0
				// set X13 (y) to 0
    			MOV X13, #0
    			loop_ycon:
					// Compare y with CONV_KERNEL_SIZE
    		    	CMP X13, #5
					// Break if y >= CONV_KERNEL_SIZE
		    		B.GE loop_ycon_end
					// set X14 (x) to 0
    		    	MOV X14, #0
    		    	loop_xcon:
						// Compare x with CONV_KERNEL_SIZE
        				CMP X14, #5
						// Break if x >= CONV_KERNEL_SIZE
						B.GE loop_xcon_end
						// X15 = j + y
						ADD X15, X10, X13
						// X16 = K + X
						ADD X16, X11, X14
						MOV X5, #28
						// compute offset of first index
						MUL X15, X15, X5 
						// add offset of second index
						ADD X15, X15, X16
						// Load input[(j + y)][(k + x)]
						LDURB X18, [X0, X15]
						// X15 = i * CONV_KERNEL_SIZE
						MUL X15, X9, X6
						// X15 = i * CONV_KERNEL_SIZE * CONV_KERNEL_SIZE
						MUL X15, X15, X6
						// X15 = y * CONV_KERNEL_SIZE
						MUL X16, X13, X6
						// X16 = [i * CONV_KERNEL_SIZE * CONV_KERNEL_SIZE] + [y * CONV_KERNEL_SIZE]
						ADD X16, X16, X15
						// X16 = [i * CONV_KERNEL_SIZE * CONV_KERNEL_SIZE] + [y * CONV_KERNEL_SIZE] + x
						ADD X16, X16, X14
						// X17 = weights[i][y][x]
						LDURSB X17, [X1, X16]
						// Multiply input * weights
						MUL X15, X18, X17
						// con_sum += product
						ADD X12, X12, X15
						// x++
						ADD X14, X14, #1
						B loop_xcon
    		   		loop_xcon_end:
						// y++
						ADD X13, X13, #1
						B loop_ycon
    			loop_ycon_end:
					// Load biases[i]
					LDURSB X15, [X2, X9]
					// con_sum + biases[i]
					ADD X12, X12, X15
					// add 2 slots to the stack
					SUB SP, SP, #32
					// store the link register 
					STUR LR, [SP, #0]
					// store the X0 value
					STUR X0, [SP, #16]
					// assign X12 to X0 for relu
					MOV X0, X12
					// call relu
    		    	BL relu
					// assign relu output to X12
					MOV X12, X0
					// load old X0 value
					LDUR X0, [SP, #16]
					// load old link register
					LDUR LR, [SP, #0]
					// remove 2 slots off a stack
					ADD SP, SP, #32
					MOV X5, #24
					// j * CONV_OUTPUT_SIZE
					MUL X15, X10, X5
					// add k offset
					ADD X15, X15, X11
					// shift by 4 
					LSL X15, X15, #2
					// stores con_sum to calculated location
					STURW X12, [X4, X15]
					// k++
					ADD X11, X11, #1
					B loop_kcon
    	    loop_kcon_end:
				// j++
    			ADD X10, X10, #1
				B loop_jcon
    	loop_jcon_end:
			// add 6 slots to the stack
			SUB SP, SP, #96
			// store X0 values
			STUR X0, [SP, #0]
			// stores X1 values
			STUR X1, [SP, #16]
			// stores X2 values
			STUR X2, [SP, #32]
			// stores LR
			STUR LR, [SP, #48]
			// stores convolution i
			STUR X9, [SP, #64]
			// stores convolution j
			STUR X10, [SP, #80]
			// Pass i in X0
    	    MOV X0, X9
			// Pass con_output in X1
    	    MOV X1, X4
			// Pass output in X2
    	    MOV X2, X3 
			// Call max_pool function
    	    BL max_pool
			// Move max pool output to convol output
			MOV X3, X2
			// reassign constant registers
			MOV X6, #5
			MOV X7, #6
			MOV X8, #4
			// loads convolution j
			LDUR X10, [SP, #80]
			// loads convolution i
			LDUR X9, [SP, #64]
			// load LR
			LDUR LR, [SP, #48]
			// load old X2
			LDUR X2, [SP, #32]
			// load old X1
			LDUR X1, [SP, #16]
			// load old X0
			LDUR X0, [SP, #0]
			// remove 6 slots from stack
			ADD SP, SP, #96
			// i++
    	    ADD X9, X9, #1
    	    B loop_icon
    loop_icon_end:
		// return to call
    	BR LR

// ---------- MaxPool Procedure (Leaf) ----------
// Parameters:
//   X0: k (kernel index)
//   X1: input (base pointer to conv_output matrix)
//   X2: output (base pointer to conv_max_pool_output matrix)
max_pool:
	// set X9 (i) to 0
    MOV X9, #0
	// set other constants
	MOV X5, #2
	MOV X6, #12
	MOV X8, #4
    loop_imp:
		// Check if X9 < MAX_POOL_OUTPUT_SIZE
        CMP X9, #12
		// If >=, go to end_max_pool
        B.GE end_max_pool
		// set X10 (j) to 0
        MOV X10, #0
        loop_jmp:
			// Check if X10 < MAX_POOL_OUTPUT_SIZE
            CMP X10, #12
			// If >=, go to loop_Jmp_end
            B.GE loop_jmp_end
			// set X16 (maxp) to #0
            MOV X16, #0
			// set X11 (y) to #0
            MOV X11, #0
    	    loop_ymp:
				// Check if X11 < MAX_POOL_WINDOW_SIZE
				CMP X11, #2
				// If >=, go to loop_Ymp_end
				B.GE loop_ymp_end
				// set X12 (x) to 0
				MOV X12, #0
				loop_xmp:
					// Check if X12 < MAX_POOL_WINDOW_SIZE
					CMP X12, #2
					// If >=, got to loop_Xmp_end
					B.GE loop_xmp_end
					MOV X7, #24
					// temp1 = i * MAX_POOL_STRIDE
					MUL X13, X9, X5
					// temp1 + y
					ADD X13, X13, X11
					// temp2 = j * MAX_POOL_STRIDE
					MUL X14, X10, X5
					// temp2 + x
					ADD X14, X14, X12
					// Calculates first index offset
					MUL X15, X13, X7
					// Adds second index offset
					ADD X15, X15, X14
					// shifts the index offset by 4
					LSL X15, X15, #2
					// Load input[temp1][temp2]
					LDURSW X17, [X1, X15]
					// Compare maxp and input[temp1][temp2]
					CMP X16, X17
					// If maxp >= input, go there
					B.GE big_maxp 
					// Assign input value to maxp
					MOV X16, X17
					// x++
					ADD X12, X12, #1
					B loop_xmp
				big_maxp:
					// keep maxp and increment x
					ADD X12, X12, #1
					B loop_xmp
				loop_xmp_end:
					// y++
					ADD X11, X11, #1
					B loop_ymp
			loop_ymp_end:
				// multiply k by first matrix dimension for first index
				MUL X13, X0, X6
				// multiply again by second matrix dimension
				MUL X13, X13, X6
				// multiply i by second matrix dimension for second index
				MUL X14, X9, X6
				// add offset from first and second matricies
				ADD X14, X14, X13
				// add j for third index
				ADD X15, X14, X10
				// shift by 4
				LSL X15, X15, #2
				// Store maxp in output[k][i][j]
				STURW X16, [X2, X15]
				// j++
				ADD X10, X10, #1
				B loop_jmp
    	loop_jmp_end:
			// i++
            ADD X9, X9, #1
            B loop_imp
    end_max_pool:
		// Return to call
		BR LR

// ---------- ReLU Procedure (Leaf) ----------
// Parameters:
//   X0: x (convolution + bias)
// Returns:
//   X0: max(0, x)
relu:
	// compares input at X0 to #0 
    CMP X0, #0   
	// go to relu_zero if X0 < #0
    B.LE relu_zero
	// return 
    BR LR
    relu_zero:
		// assign 0 to X0
        MOV X0, #0
		// return
        BR LR
