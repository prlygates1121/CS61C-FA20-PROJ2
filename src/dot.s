.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:
    # Prologue
    addi sp, sp, -28
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    # Exceptions
    addi s0, a2, -1
    blt s0, x0, exception75
    addi s0, a3, -1
    blt s0, x0, exception76
    addi s0, a4, -1
    blt s0, x0, exception76


init:
    slli a3, a3, 2                   # convert strides to bytes
    slli a4, a4, 2                   # convert strides to bytes
    addi s0, x0, 0
    addi s1, x0, 0
    addi s2, x0, 0
    addi s3, x0, 0
    j loop_start

loop_start:
    bge s0, a2, loop_end
    add s5, a0, s1
    add s6, a1, s2
    lw s5, 0(s5)
    lw s6, 0(s6)
    mul s5, s5, s6
    add s3, s3, s5
    addi s0, s0, 1
    add s1, s1, a3
    add s2, s2, a4
    j loop_start

loop_end:
    addi a0, s3, 0

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    addi sp, sp, 28
    ret

exception75:
    addi a1, x0, 75
    jal exit2

exception76:
    addi a1, x0, 76
    jal exit2
