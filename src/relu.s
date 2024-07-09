.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    addi t0, a1, -1
    blt t0, x0, exception
    # Prologue
    addi sp, sp, -4
    sw ra, 0(sp)
    addi t0, x0, 0
    jal loop_start

exception:
    addi a1, x0, 78
    jal exit2

loop_start:
    beq t0, a1, loop_end           # t0 is the index; end if t0 == a1
    slli t1, t0, 2                 # t1 is the offset (t0 * 4)
    add t2, a0, t1                 # t2 is the moved pointer to the array (a0 + t1)
    lw t3, 0(t2)                   # t3 is the value of the current item
    bge t3, x0, loop_continue      # continue if TCI >= 0
    addi t3, x0, 0                 # set t3 to zero if TCI < 0
    sw t3, 0(t2)                   # store t3 back to the array

loop_continue:
    addi t0, t0, 1                 # t0++
    jal loop_start

loop_end:
    # Epilogue
    lw ra, 0(sp)
    addi sp, sp, 4
    
	ret
