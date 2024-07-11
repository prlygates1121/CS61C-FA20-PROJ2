.globl classify

.data
m0_rows: .space 4
m0_cols: .space 4
m1_rows: .space 4
m1_cols: .space 4
input_rows: .space 4
input_cols: .space 4

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero,
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    addi sp, sp, -52
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)
    sw s10, 44(sp)
    sw s11, 48(sp)

    li t0, 5                                # Get a 5
    bne a0, t0, exception89                 # Check argc
    mv s0, a1                               # s0 gets argv
    lw s1, 4(s0)                            # s1 gets <M0_PATH> (2nd pointer in argv)
    lw s2, 8(s0)                            # s2 gets <M1_PATH> (3rd pointer in argv)
    lw s3, 12(s0)                           # s3 gets <INPUT_PATH> (4th pointer in argv)
    lw s4, 16(s0)                           # s4 gets <OUTPUT_PATH> (5th pointer in argv)
    mv s11, a2                              # s11 gets a2

	# =====================================
    # LOAD MATRICES
    # =====================================

    # Load pretrained m0
    mv a0, s1                               # a0 is the file name
    la a1, m0_rows                          # a1 is the pointer to the # of rows
    la a2, m0_cols                          # a2 is the pointer to the # of columns
    jal read_matrix
    mv s5, a0                               # s5 gets the address of m0

    # Load pretrained m1
    mv a0, s2                               # a0 is the file name
    la a1, m1_rows                          # a1 is the pointer to the # of rows
    la a2, m1_cols                          # a2 is the pointer to the # of columns
    jal read_matrix
    mv s6, a0                               # s6 gets the address of m1

    # Load input matrix
    mv a0, s3                               # a0 is the file name
    la a1, input_rows                       # a1 is the pointer to the # of rows
    la a2, input_cols                       # a2 is the pointer to the # of columns
    jal read_matrix
    mv s7, a0                               # s7 gets the address of input matrix

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # Allocate space for the result of m0 * input
    la t0, m0_rows                          # t0 gets the address of m0's # of rows
    lw t0, 0(t0)                            # t0 gets m0's # of rows
    la t1, input_cols                       # t1 gets the address of input's # of cols
    lw t1, 0(t1)                            # t1 gets input's # of cols
    mul s8, t0, t1                          # s8 gets the # of elements in the resultant mat of m0 * input
    slli a0, s8, 2                          # a0 is the # of bytes for the resultant mat
    jal malloc                              # allocate memory for the resultant mat
                                            # a0 gets the address of the result
    beq a0, x0, exception88
    mv s9, a0                               # s9 gets the address of the result

    # Perform the multiplication m0 * input
    mv a0, s5                               # a0 is the address of m0
    la t0, m0_rows
    lw a1, 0(t0)                            # a1 is m0's # of rows
    la t0, m0_cols
    lw a2, 0(t0)                            # a2 is m0's # of cols
    mv a3, s7                               # a3 is the address of input matrix
    la t0, input_rows
    lw a4, 0(t0)                            # a4 is input's # of rows
    la t0, input_cols
    lw a5, 0(t0)                            # a5 is input's # of cols
    mv a6, s9                               # a6 is the address of the result
    jal matmul

    # Free m0 and input
    mv a0, s5
    jal free
    mv a0, s7
    jal free

    # Perform relu on the result
    mv a0, s9                               # a0 gets the resultant matrix
    mv a1, s8                               # a1 gets the # of ints in the mat
    jal relu                                # perform relu on the matrix

    # Allocate space for the output matrix (m1 * ReLU(m0 * input))
    la t0, m1_rows
    lw t0, 0(t0)
    la t1, input_cols
    lw t1, 0(t1)
    mul s8, t0, t1
    slli a0, s8, 2
    jal malloc
    beq a0, x0, exception88
    mv s10, a0

    # Perform the multiplication m1 * ReLu(m0 * input)
    mv a0, s6
    la t0, m1_rows
    lw a1, 0(t0)
    la t0, m1_cols
    lw a2, 0(t0)
    mv a3, s9
    la t0, m0_rows
    lw a4, 0(t0)
    la t0, input_cols
    lw a5, 0(t0)
    mv a6, s10
    jal matmul

    # Free m1
    mv a0, s6
    jal free

    # Free the result of m0 * input
    mv a0, s9
    jal free

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix (s10)

    mv a0, s4                               # a0 is the file name
    mv a1, s10                              # a1 is the address of the mat
    la t0, m1_rows
    lw a2, 0(t0)                            # a2 is the # of rows
    la t0, input_cols
    lw a3, 0(t0)                            # a3 is the # of cols
    mul s1, a2, a3                          # Calculate # of elements in s1 for later use

    jal write_matrix


    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    mv a0, s10
    mv a1, s1
    jal argmax
    mv s2, a0                                # s2 gets the result

    # Free the result of m1 * ReLU(m0 * input)
    mv a0, s10
    jal free

    bne s11, x0, done

    # Print classification
    mv a1, s2                                # a1 is the result
    jal print_int

    # Print newline afterwards for clarity
    li a1, 10                                # a1 is the ascii for newline
    jal print_char

done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    lw s11, 48(sp)
    addi sp, sp, 52

    ret

exception89:
    li a1, 89
    j exit2

exception88:
    li a1, 88
    j exit2