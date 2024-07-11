.globl read_matrix

.data
buffer: .space 8

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)

    # Save a1, a2 in s4, s5
    addi s4, a1, 0
    addi s5, a2, 0

    # Open the file
    addi a1, a0, 0            # a1 is the filename of the file to open
    addi a2, x0, 0            # a2 is the permission status of the file
    jal fopen                 # Call fopen (returns file descriptor)
    addi t0, x0, -1           # Get a -1
    beq a0, t0, exception90   # Check the return value
    addi s0, a0, 0            # s0 holds the file descriptor for later use

    # Read the first 2 ints
    addi a1, s0, 0            # a1 gets the file descriptor
    la t0, buffer
    addi a2, t0, 0            # a2 gets the pointer to buffer
    addi a3, x0, 8            # a3 is the # of bytes to read from the file
    addi s1, a3, 0            # s1 holds a3 for future use
    addi s2, a2, 0            # s2 holds the memory address for future use
    jal fread                 # Call fread (returns the # of bytes actually read)
    bne a0, s1, exception91   # Check the # of bytes

    # Load the first 2 ints from the allocated memory in a1, a2
    lw a1, 0(s2)
    lw a2, 4(s2)

    # Store the first 2 ints in s4, s5
    sw a1, 0(s4)
    sw a2, 0(s5)

    # Calculate total bytes of the matrix elements
    mul s3, a1, a2            # s3 is the # of elements
    slli s3, s3, 2            # s3 becomes the bytes of the elements

    # Allocate memory for the matrix elements
    addi a0, s3, 0
    jal malloc
    beq a0, x0, exception88

    # Read the matrix elements
    addi a1, s0, 0
    addi a2, a0, 0
    addi a3, s3, 0
    addi s1, a3, 0
    addi s2, a2, 0            # s2 is the memory address
    jal fread
    bne a0, s1, exception91

    # Close the file
    addi a1, s0, 0
    jal fclose
    addi t0, x0, -1
    beq a0, t0, exception92

    # Make a0 the corresponding address
    addi a0, s2, 0

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

exception88:
    addi a1, x0, 88
    j exit2

exception90:
    addi a1, x0, 90
    j exit2

exception91:
    addi a1, x0, 91
    j exit2

exception92:
    addi a1, x0, 92
    j exit2