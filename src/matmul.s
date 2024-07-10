.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

    # Error checks
    addi t0, x0, 1
    blt a1, t0, exception72
    blt a2, t0, exception72
    blt a4, t0, exception73
    blt a5, t0, exception73
    bne a2, a4, exception74

    # Prologue
    addi sp, sp, -40
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

    addi s0, x0, 0                  # s0 is the row iterator
    addi s1, a6, 0                  # s1 is a moving pointer to d
    addi s3, x0, 0                  # s3 is the column iterator
    addi s4, a1, 0                  # s4 is the # of rows of d
    addi s5, a5, 0                  # s5 is the # of cols of d

    addi s2, a0, 0                  # s2 is the start of the row vector
    addi s6, a3, 0                  # s6 is the pointer to the start of the column vector
    addi s8, s6, 0                  # s8 is the start of the column vector
    slli s7, a2, 2                  # s7 is 4 * columns of m0

outer_loop_start:
    beq s0, s4, outer_loop_end
    addi s3, x0, 0                  # s3 is set to zero
    addi s6, s8, 0                  # s6 is set to original position
inner_loop_start:
    beq s3, s5, inner_loop_end

    # Prepare for function dot
    addi a0, s2, 0                  # pass in the row vector
    addi a1, s6, 0                  # pass in the column vector
    addi a3, x0, 1                  # pass in the stride of row vector
    addi a4, a5, 0                  # pass in the stride of column vector

    # Mini-prologue
    addi sp, sp, -8
    sw a2, 0(sp)
    sw a5, 4(sp)

    # Call dot
    jal dot

    # Mini-epilogue
    lw a2, 0(sp)
    lw a5, 4(sp)
    addi sp, sp, 8

    # Store the item in d
    sw a0, 0(s1)

    # Move pointer s1 one item forward
    addi s1, s1, 4
    # Move s6 one item forward
    addi s6, s6, 4
    # Update column index
    addi s3, s3, 1
    # Restart the loop
    j inner_loop_start

inner_loop_end:
    # Move pointer s2 a row downward
    add s2, s2, s7
    # Update row index
    addi s0, s0, 1
    # Restart the loop
    j outer_loop_start

outer_loop_end:
    # Epilogue
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
    addi sp, sp, 40

    ret

exception72:
    addi a1, x0, 72
    j exit2

exception73:
    addi a1, x0, 73
    j exit2

exception74:
    addi a1, x0, 74
    j exit2