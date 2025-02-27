.data
// Global variables for print messages and 
// tracking correct and incorrect predictions
prediction_message: .asciz "0:0,0\n"
accuracy_message:   .asciz "000%\n"
correct_predictions: .byte 0
incorrect_predictions: .byte 0

.text

// Declare the functions as global, so that they can be found by the linker
.global linear
.global arg_max
.global report_prediction
.global report_accuracy

// ---------- Linear Procedure (Leaf) ----------
// Parameters:
//   X0: input
//   X1: weights
//   X2: biases
//   X3: output
linear:
    // set X9 (i) to 0
    MOV X9, #0
    // set other constants
    MOV X6, #10
    MOV X7, #6
    MOV X8, #12
    loop_linear_i:
	// Compare i with TOTAL_OUTPUT_CLASSES
        CMP X9, #10
	// Break if i >= TOTAL_OUTPUT_CLASSES
        B.GE loop_linear_i_end
	// set X4 to 0 for sum
	MOV X4, #0
	// set X10 (j) to 0
        MOV X10, #0
   	loop_linear_j:
	    // Compare j with TOTAL_KERNELS
    	    CMP X10, #6
	    // Break if j >= TOTAL_KERNELS
	    B.GE loop_linear_j_end
	    // set X11 (k) to 0
    	    MOV X11, #0
    	    loop_linear_k:
		// Compare k with MAX_POOL_OUTPUT_SIZE
    		CMP X11, #12
		// Break if k >= with MAX_POOL_OUTPUT_SIZE
		B.GE loop_linear_k_end
		// set X12 (n) to 0
    		MOV X12, #0
    		loop_linear_n:
		    // Compare n with MAX_POOL_OUTPUT_SIZE
    		    CMP X12, #12
		    // Break if y >= MAX_POOL_OUTPUT_SIZE
		    B.GE loop_linear_n_end
                    // X13 = j * MAX_POOL_OUTPUT_SIZE
		    MUL X13, X10, X8
                    // X13 = j * MAX_POOL_OUTPUT_SIZE * MAX_POOL_OUTPUT_SIZE
                    MUL X13, X13, X8
                    // X14 = k * MAX_POOL_OUTPUT_SIZE
                    MUL X14, X11, X8
                    // X15 = [j * MAX_POOL_OUTPUT_SIZE * MAX_POOL_OUTPUT_SIZE] + [k * MAX_POOL_OUTPUT_SIZE]
                    ADD X15, X13, X14
                    // X15 = [j * MAX_POOL_OUTPUT_SIZE * MAX_POOL_OUTPUT_SIZE] + [k * MAX_POOL_OUTPUT_SIZE] + n
                    ADD X15, X15, X12
                    // set X16 to all zeros
                    MOV X16, XZR
		    // left shift by 4
		    LSL X15, X15, #2
                    // X15 = base address + offset
                    ADD X15, X15, X0
                    // X16 = _input[j][k][n]
		    LDRSW X16, [X15]
                    // X13 = i * TOTAL_OUTPUT_KERNELS
                    MUL X13, X9, X7
                    // X13 = i * TOTAL_OUTPUT_KERNELS * MAX_POOL_OUTPUT_SIZE
                    MUL X13, X13, X8
                    // X13 = i * TOTAL_OUTPUT_KERNELS * MAX_POOL_OUTPUT_SIZE * MAX_POOL_OUTPUT_SIZE
                    MUL X13, X13, X8
                    // X14 = j * MAX_POOL_OUTPUT_SIZE
                    MUL X14, X10, X8
                    // X14 = j * MAX_POOL_OUTPUT_SIZE * MAX_POOL_OUTPUT_SIZE
                    MUL X14, X14, X8
                    // X15 = k * MAX_POOL_OUTPUT_SIZE
                    MUL X15, X11, X8
                    // X17 = [i * TOTAL_OUTPUT_KERNELS * MAX_POOL_OUTPUT_SIZE * MAX_POOL_OUTPUT_SIZE] + [j * MAX_POOL_OUTPUT_SIZE * MAX_POOL_OUTPUT_SIZE]
                    ADD X17, X13, X14
                    // X17 = [i * TOTAL_OUTPUT_KERNELS * MAX_POOL_OUTPUT_SIZE * MAX_POOL_OUTPUT_SIZE] + [j * MAX_POOL_OUTPUT_SIZE * MAX_POOL_OUTPUT_SIZE] + [k * MAX_POOL_OUTPUT_SIZE]
                    ADD X17, X17, X15
                    // X17 = [i * TOTAL_OUTPUT_KERNELS * MAX_POOL_OUTPUT_SIZE * MAX_POOL_OUTPUT_SIZE] + [j * MAX_POOL_OUTPUT_SIZE * MAX_POOL_OUTPUT_SIZE] + [k * MAX_POOL_OUTPUT_SIZE] + n
                    ADD X17, X17, X12
                    // set X18 to all zeros
                    MOV X18, XZR
                    // X17 = base address + offset
                    ADD X17, X17, X1
                    // W18 = weights[i][j][k][n]
                    LDRSB X18, [X17]
                    // X13 = _input[j][k][n] * weights[i][j][k][n]
                    MUL X13, X16, X18
                    // sum += _input[j][k][n] * weights[i][j][k][n]
                    ADD X4, X4, X13
                    // n++
                    ADD X12, X12, #1
                    B loop_linear_n
    		loop_linear_n_end:
		    // k++
		    ADD X11, X11, #1
		    B loop_linear_k
    	    loop_linear_k_end:
	        // j++
    		ADD X10, X10, #1
		B loop_linear_j
    	loop_linear_j_end:
            // Set X13 and X14 to all zeros
            MOV X13, XZR
	    MOV X14, XZR
            // X15 = X9 + X2
            ADD X15, X9, X2
            // X13 = biases[i]
            LDRSB X13, [X15]
            // X14 = sum + biases[i]
            ADD X14, X4, X13
	    // left shift by 4
	    LSL X15, X9, #2
	    // X15 = base adress + offset
	    ADD X15, X15, X3
            // store in output
            STR X14, [X15]
	    // i++
    	    ADD X9, X9, #1
    	    B loop_linear_i
    loop_linear_i_end:
	// return to call
    	BR LR

// ---------- Argmax Procedure (Leaf) ----------
// Parameters:
//   X0: input
// Returns:
//   X0: array index of max value in input (assumes the length of input is 10)
arg_max:
    // index (X9) = 0
    MOV X9, #0
    // set X10 to all zeros
    MOV X10, XZR
    // max_value (X10) = _input[(0,)]
    LDRSW X10, [X0]
    // i (X11) = 1
    MOV X11, #1
    loop_arg:
        // Compare i with TOTAL_OUTPUT_CLASSES
        CMP X11, #10
        // Break if i >= TOTAL_OUTPUT_CLASSES
        B.GE loop_arg_end
        // Set X12 to all zeros
        MOV X12, XZR
	// shift X11
	LSL X13, X11, #2
        // X13 = X11 + X0
        ADD X13, X13, X0
        // X12 = _input[(i,)]
        LDRSW X12, [X13]
        big_arg:
            // Compare max_value and _input[(i,)]
            CMP X10, X12
            // ignore if max_value > _input[(i,)]
            B.GT big_arg_end
            // max value = _input[(i,)]
            MOV X10, X12
            // index = i
            MOV X9, X11
        big_arg_end:
            // i++
            ADD X11, X11, #1
            B loop_arg
    loop_arg_end:
        // X0 = array index of max value in input (assumes the length of input is 10)
        MOV X0, X9
        BR LR

// ---------- Report Prediction Procedure (Leaf) ----------
// Parameters:
//   X0: image_index
//   X1: expected_output
//   X2: actual_output
report_prediction:
    // Set X10 to all zeros
    MOV X10, XZR
    // compare Expected and Actual
    CMP X1, X2
    //got to correct if write
    B.EQ correct_predict
    // load address of incorrect predictions
    LDR X9, =incorrect_predictions
    // load number of incorrect predictions
    LDRB W10, [X9]
    // increment
    ADD W10, W10, #1
    // store again
    STRB W10, [X9]
    B report_prediction_print
    correct_predict:
	MOV X10, XZR
        // load address of correct predictions
        LDR X9, =correct_predictions
        // load number of correct predictions
        LDRB W10, [X9]
        // increment
        ADD X10, X10, #1
        // store again
        STRB W10, [X9]
    report_prediction_print:
        // prediction_message: .asciz "0:0,0\n"
        // ascii offset
        ADD X0, X0, #48
        ADD X1, X1, #48
        ADD X2, X2, #48
        // load prediction_message location
        LDR X11, =prediction_message
        // store first value
        STRB W0, [X11]
        // g to second index
        ADD X11, X11, #1
        // X15 = colon in ascii
	MOV X15, #58
	// store the colon in the string
	STRB W15, [X11]
	// increment index
	ADD X11, X11, #1
        // store sedond value
        STRB W1, [X11]
        // go to third index
        ADD X11, X11, #1
	// store comma in X15
	MOV X15, #44
	// store colon in string
	STRB W15, [X11]
	// increment index
	ADD X11, X11, #1
        //store third element
        STRB W2, [X11]
	// inrecent index
	ADD X11, X11, #1
	// store \n in X15
	MOV X15, #10
	// store in string
	STRB W15, [X11]
	// increment index
	ADD X11, X11, #1
	// store null termination in X15
	MOV X15, XZR
	//store in string
	STRB W15, [X11]
    exit_prediction_report:
        // move 1 to X0 for standard output
        MOV X0, #1
        // load messange into X1
        LDR X1, =prediction_message
        // load 8 into X2
        MOV X2, #7
        // load 64 into X8
        MOV X8, 0x40
        // system call
        SVC 0
        BR LR

// ---------- Report Accuracy (Leaf) ----------
// Parameters: None
report_accuracy:
    // Set X10 to all zeros
    MOV X10, XZR
    // Set X12 to all zeros
    MOV X12, XZR
    // load address of correct predictions
    LDR X9, =correct_predictions
    // load number of correct predictions
    LDRB W10, [X9]
    // load address of incorrect predictions
    LDR X11, =incorrect_predictions
    // load number of incorrect predictions
    LDRB W12, [X11]
    // accuracy_message:   .asciz "000%\n"
    // load prediction_message location
    LDR X11, =accuracy_message
    // X13 = total predictions
    ADD X13, X10, X12
    // X15 = 100
    MOV X15, #100
    // multiply the correct by 100
    MUL X10, X10, X15
    // divide by total
    UDIV X14, X10, X13
    // move 10 into X15 and 0 to X16
    MOV X15, #10
    MOV X16, #0
    // check for 100% accuracy
    CMP X14, #100
    // skip if not 100%
    B.NE skip
    // move 1 into X16
    MOV X16, #1
    // subtract 100 to get 0s in the next 2 digits
    SUB X14, X14, #100
    skip:
        // Get second digit
        UDIV X17, X14, X15
        // Get third digit
        MSUB X18, X17, X15, X14
	// convert to ascii
	ADD X16, X16, #48
        // Store first digit in string
        STRB W16, [X11]
        // convert to ascii
        ADD X17, X17, #48
        // increment index 
        ADD X11, X11, #1
        // Store second digit in string
        STRB W17, [X11]
        // increment index
        ADD X11, X11, #1
	// convert to ascii
    	ADD X18, X18, #48
	// store in string
        STRB W18, [X11]
	// increment index
        ADD X11, X11, #1
        // put % in X15
        MOV X15, #37
        // store in string
        STRB W15, [X11]
        // increment index
        ADD X11, X11, #1
        // put \n in X15
        MOV X15, #10
        // store in string
        STRB W15, [X11]
        // increment index
        ADD X11, X11, #1
        // put null termination in X15
        MOV X15, XZR
        // store in string
        STR X15, [X11]
    exit_accuracy_report:
        // move 1 to X0 for standard output
        MOV X0, #1
        // load messange into X1
        LDR X1, =accuracy_message
        // load 7 into X2
        MOV X2, #7
        // load 64 into X8
        MOV X8, 0x40
        // system call
        SVC 0
        BR LR
