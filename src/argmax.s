.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:
    addi t0, a1, -1             # t0 is a1 - 1
    blt t0, x0, exception
    # Prologue
    addi sp, sp, -4
    sw ra, 0(sp)

    addi t0, x0, 0              # t0 is set to 0
    addi t4, x0, 0              # t4 is set to 0 (maximum value)
    jal loop_start

exception:
    addi a1, x0, 77
    jal exit2

loop_start:
    beq t0, a1, loop_end        # t0 is the index; end if t0 == a0
    slli t1, t0, 2              # t1 is the offset (t0 * 4)
    add t2, a0, t1              # t2 is the moved pointer
    lw t3, 0(t2)                # t3 loads the current item
    bge t4, t3, loop_continue   # continue if maximum value >= TCI
    addi t4, t3, 0              # t4 stores the maximum value
    addi t5, t0, 0              # t5 stores the index of the maximum value

loop_continue:
    addi t0, t0, 1              # t0++
    jal loop_start

loop_end:
    addi a0, t5, 0
    # Epilogue
    lw ra, 0(sp)
    addi sp, sp, 4

    ret
