.globl write_matrix

.data
buffer: .space 8

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)


    # Save and compute useful arguments
    addi s0, a1, 0               # s0 is the start of the mat in memory
    addi s1, a2, 0               # s1 is the # of rows
    addi s2, a3, 0               # s2 is the # of cols
    mul s3, s1, s2               # s3 is the # of elements in the mat
    la s5, buffer                # Load the address of buffer in t0
    sw s1, 0(s5)                 # 0(t0) holds the # of rows
    sw s2, 4(s5)                 # 4(t0) holds the # of columns

    # Open the file
    addi a1, a0, 0               # a1 is the file name
    addi a2, x0, 1               # a2 is the permission status
    jal fopen
    addi t0, x0, -1              # Get a -1
    beq a0, t0, exception93
    addi s4, a0, 0               # s4 holds the file descriptor

    # Write # of rows and columns in the file
    addi a1, s4, 0               # a1 is the file descriptor
    addi a2, s5, 0               # a2 is the start of buffer
    addi a3, x0, 2               # a3 is the # of items to write (2 integers)
    addi a4, x0, 4               # a4 is the size of each item (4 bytes)
    jal fwrite
    addi t0, x0, 2               # Get a 2
    bne a0, t0, exception94      # Did I write 2 items?

    # Write elements in the file
    addi a1, s4, 0               # a1 is the file descriptor
    addi a2, s0, 0               # a2 is the start of the mat that we want to write to the file
    addi a3, s3, 0               # a3 is the # of items to write (columns & rows)
    addi a4, x0, 4               # a4 is the size of each item (4 bytes)
    jal fwrite
    bne a0, s3, exception94      # Did I write columns * rows items?

    # Close the file
    addi a1, s4, 0               # a1 is the file descriptor
    jal fclose
    bne a0, x0, exception95

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28

    ret

exception93:
    addi a1, x0, 93
    j exit2

exception94:
    addi a1, x0, 94
    j exit2

exception95:
    addi a1, x0, 95
    j exit2