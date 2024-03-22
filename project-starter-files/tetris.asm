################ CSC258H1F Winter 2024 Assembly Final Project ##################
# This file contains our implementation of Tetris.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number (if applicable)
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       TODO
# - Unit height in pixels:      TODO
# - Display width in pixels:    TODO
# - Display height in pixels:   TODO
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Tetris game.
main:
    lw $t0, ADDR_DSPL        # Load the display's base address
li $t6, 0x17161A              # Color 1 (Dark Grey)
li $t7, 0x1b1b1b              # Color 2 (Lighter Grey)

li $s0, 30                    # Side length of the checkerboard (units, not pixels)
li $s1, 3                    # Row counter for units

outer_loop:                   # This loop will go through each row of units
    li $s2, 0                 # Reset column counter at the beginning of each row of units

inner_loop:                   # This loop will go through each column of units
    # Determine the color of the 2x2 unit
    add $t4, $s1, $s2         # Add row and column numbers of units
    andi $t4, $t4, 1          # Check if the sum is even or odd
    beq $t4, $zero, even      # If even, choose Color 1
    move $t4, $t7             # Otherwise, choose Color 2
    j paint_unit
even:
    move $t4, $t6             # Choose Color 1 for even

paint_unit:
    # Paint the 2x2 unit
    # Calculate top left pixel of the unit
    sll $a1, $s1, 8           # Multiply unit row by 256 (2^8) to account for 2x2 pixels
    sll $a0, $s2, 3           # Multiply unit column by 8 (2^3) to account for 2x2 pixels
    add $t3, $a0, $a1         # Add x and y offsets for the top left pixel of the unit
    add $t3, $t0, $t3         # Add base display address to get the final address for the top left pixel

    # Paint the 2x2 pixels of the unit with the same color
    sw $t4, 0($t3)            # Paint the top left pixel
    sw $t4, 4($t3)            # Paint the top right pixel
    addi $t5, $t3, 128        # Calculate the address for the bottom left pixel
    sw $t4, 0($t5)            # Paint the bottom left pixel
    sw $t4, 4($t5)            # Paint the bottom right pixel

    addi $s2, $s2, 1          # Move to the next unit column
    blt $s2, $s0, inner_loop  # If we have not reached the end of the unit row, repeat

    addi $s1, $s1, 1          # Move to the next unit row
    blt $s1, $s0, outer_loop  # If we have not reached the end of the checkerboard units, repeat

end:

addi $a0, $zero, 0
addi $a1, $zero, 30
addi $a2, $zero, 64
sll $t1, $a0, 2
sll $t2, $a1, 7
sll $t5, $a2, 2
add $t5, $t1, $t5
top:
add $t3, $t1, $t2
add $t3, $t0, $t3
li $t4, 0x000000
sw $t4, 0($t3)
addi $t1, $t1, 4
beq $t1, $t5, final
j top
final:
################# Vertical
lw $t0, ADDR_DSPL       # Load the base address into $t0
li $t4, 0x000000             # Load the color black into $t4

li $a0, 0                    # x-coordinate (column) is 0 for the leftmost column
li $a1, 0                    # Starting y-coordinate (row) is 0
li $a2, 31                   # Ending y-coordinate (31 rows in total)

vertical_line_loop:
    sll $t2, $a1, 7          # Shift left y-coordinate by 7 (assuming 128 pixels per row, thus 2^7)
    add $t3, $t1, $t2        # Add x-coordinate offset to y-coordinate offset
    addu $t3, $t0, $t3       # Add base display address to the offset (use addu to avoid overflow error)
    
    sw $t4, 0($t3)           # Store the color at the calculated address
    
    addi $a1, $a1, 1         # Increment the y-coordinate to move down to the next row
    bne $a1, $a2, vertical_line_loop # Continue looping until the last row is reached

final1:
lw $t0, ADDR_DSPL       # Load the base address into $t0
li $t4, 0x000000             # Load the color black into $t4

li $a0, 1                    # x-coordinate (column) is 1 for the second leftmost column
li $a1, 0                    # Starting y-coordinate (row) is 0
li $a2, 31                   # Ending y-coordinate (31 rows in total)

sll $t1, $a0, 2              # Shift left x-coordinate by 2 to account for word size (4 bytes per pixel)

second_vertical_line_loop:
    sll $t2, $a1, 7          # Shift left y-coordinate by 7 (assuming 128 pixels per row, thus 2^7)
    add $t3, $t1, $t2        # Add x-coordinate offset to y-coordinate offset
    addu $t3, $t0, $t3       # Add base display address to the offset (use addu to avoid overflow error)
    
    sw $t4, 0($t3)           # Store the color at the calculated address
    
    addi $a1, $a1, 1         # Increment the y-coordinate to move down to the next row
    bne $a1, $a2, second_vertical_line_loop # Continue looping until the last row is reached

final2:
lw $t0, ADDR_DSPL       # Load the base address into $t0
li $t4, 0x000000             # Load the color black into $t4

li $a0, 31                    # x-coordinate (column) is 1 for the second leftmost column
li $a1, 0                    # Starting y-coordinate (row) is 0
li $a2, 31                   # Ending y-coordinate (31 rows in total)

sll $t1, $a0, 2              # Shift left x-coordinate by 2 to account for word size (4 bytes per pixel)

third_vertical_line_loop:
    sll $t2, $a1, 7          # Shift left y-coordinate by 7 (assuming 128 pixels per row, thus 2^7)
    add $t3, $t1, $t2        # Add x-coordinate offset to y-coordinate offset
    addu $t3, $t0, $t3       # Add base display address to the offset (use addu to avoid overflow error)
    
    sw $t4, 0($t3)           # Store the color at the calculated address
    
    addi $a1, $a1, 1         # Increment the y-coordinate to move down to the next row
    bne $a1, $a2, third_vertical_line_loop # Continue looping until the last row is reached

final3:
lw $t0, ADDR_DSPL       # Load the base address into $t0
li $t4, 0x000000             # Load the color black into $t4

li $a0, 30                    # x-coordinate (column) is 1 for the second leftmost column
li $a1, 0                    # Starting y-coordinate (row) is 0
li $a2, 31                   # Ending y-coordinate (31 rows in total)

sll $t1, $a0, 2              # Shift left x-coordinate by 2 to account for word size (4 bytes per pixel)

fourth_vertical_line_loop:
    sll $t2, $a1, 7          # Shift left y-coordinate by 7 (assuming 128 pixels per row, thus 2^7)
    add $t3, $t1, $t2        # Add x-coordinate offset to y-coordinate offset
    addu $t3, $t0, $t3       # Add base display address to the offset (use addu to avoid overflow error)
    
    sw $t4, 0($t3)           # Store the color at the calculated address
    
    addi $a1, $a1, 1         # Increment the y-coordinate to move down to the next row
    bne $a1, $a2, fourth_vertical_line_loop # Continue looping until the last row is reached

final4:
li $v0 10
syscall

game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    b game_loop
