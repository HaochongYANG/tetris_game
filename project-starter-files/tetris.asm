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

BOARD_BUFFER:
    .space 16384 # to store 128 * 128 board

.text

draw_initial_board:
    lw $t0, ADDR_DSPL           # Load the display's base address
    li $t6, 0x17161A            # Color 1 (Dark Grey)
    li $t7, 0x1b1b1b            # Color 2 (Lighter Grey)

    li $s0, 16                  # Side length of the checkerboard (units, not pixels)
    li $s1, 0                   # Row counter for units

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
    sll $a1, $s1, 6           # Multiply unit row by 256 (2^8) to account for 2x2 pixels
    sll $a0, $s2, 2           # Multiply unit column by 8 (2^3) to account for 2x2 pixels
    add $t3, $a0, $a1         # Add x and y offsets for the top left pixel of the unit
    add $t3, $t0, $t3         # Add base display address to get the final address for the top left pixel

    # Paint the 2x2 pixels of the unit with the same color
    sw $t4, 0($t3)            # Paint the top left pixel
    sw $t4, 4($t3)            # Paint the top right pixel
    addi $t5, $t3, 16        # Calculate the address for the bottom left pixel
    sw $t4, 0($t5)            # Paint the bottom left pixel
    sw $t4, 4($t5)            # Paint the bottom right pixel

    addi $s2, $s2, 1          # Move to the next unit column
    blt $s2, $s0, inner_loop  # If we have not reached the end of the unit row, repeat

    addi $s1, $s1, 1          # Move to the next unit row
    blt $s1, $s0, outer_loop  # If we have not reached the end of the checkerboard units, repeat

end:
    addi $a0, $zero, 0
    addi $a1, $zero, 16
    addi $a2, $zero, 16
    sll $t1, $a0, 2
    sll $t2, $a1, 7
    sll $t5, $a2, 2
    add $t5, $t1, $t5
top:
    add $t3, $t1, $t2
    add $t3, $t0, $t3
    li $t4, 0x00ff00
    sw $t4, 0($t3)
    addi $t1, $t1, 4
    beq $t1, $t5, final
    j top

final:
################# Vertical
    lw $t0, ADDR_DSPL       # Load the base address into $t0
    li $t4, 0x00ff00            # Load the color black into $t4
    
    li $a0, 0                    # x-coordinate (column) is 0 for the leftmost column
    li $a1, 0                    # Starting y-coordinate (row) is 0
    li $a2, 16                   # Ending y-coordinate (31 rows in total)
    sll $t1, $a0, 2              # Shift left x-coordinate by 2 to account for word size (4 bytes per pixel)

vertical_line_loop:
    sll $t2, $a1, 6          # Shift left y-coordinate by 7 (assuming 128 pixels per row, thus 2^7)
    add $t3, $t1, $t2        # Add x-coordinate offset to y-coordinate offset
    addu $t3, $t0, $t3       # Add base display address to the offset (use addu to avoid overflow error)
    
    sw $t4, 0($t3)           # Store the color at the calculated address
    
    addi $a1, $a1, 1         # Increment the y-coordinate to move down to the next row
    bne $a1, $a2, vertical_line_loop # Continue looping until the last row is reached

final1:
    lw $t0, ADDR_DSPL       # Load the base address into $t0
    li $t4, 0x00ff00             # Load the color black into $t4
    
    li $a0, 15                   # x-coordinate (column) is 1 for the second leftmost column
    li $a1, 0                    # Starting y-coordinate (row) is 0
    li $a2, 16                   # Ending y-coordinate (31 rows in total)
    
    sll $t1, $a0, 2              # Shift left x-coordinate by 2 to account for word size (4 bytes per pixel)
    
second_vertical_line_loop:
    sll $t2, $a1, 6          # Shift left y-coordinate by 7 (assuming 128 pixels per row, thus 2^7)
    add $t3, $t1, $t2        # Add x-coordinate offset to y-coordinate offset
    addu $t3, $t0, $t3       # Add base display address to the offset (use addu to avoid overflow error)
    
    sw $t4, 0($t3)           # Store the color at the calculated address
    
    addi $a1, $a1, 1         # Increment the y-coordinate to move down to the next row
    bne $a1, $a2, second_vertical_line_loop # Continue looping until the last row is reached


lw $t0, ADDR_DSPL 	# $t0 stores the base address for display
addi $t0, $t0, 960	# start drawing 4 lines down.

# Assume that the height and width of the rectangle are in $a0 and $a1
addi $a0, $zero, 1	# set height = 6
addi $a1, $zero, 16	# set width = 10

# Draw a rectangle:
add $t6, $zero, $zero	# Set index value ($t6) to zero
draw_rect_loop:
beq $t6, $a0, tetris_loop  	# If $t6 == height ($a0), jump to end

# Draw a line:
add $t5, $zero, $zero	# Set index value ($t5) to zero
draw_line_loop:
beq $t5, $a1, end_draw_line  # If $t5 == width ($a1), jump to end
sw $t4, 0($t0)		#   - Draw a pixel at memory location $t0
addi $t0, $t0, 4	#   - Increment $t0 by 4
addi $t5, $t5, 1	#   - Increment $t5 by 1
j draw_line_loop	#   - Jump to start of line drawing loop
end_draw_line:

addi $t0, $t0, 88	# Set $t0 to the first pixel of the next line.
			# Note: This value really should be calculated.
addi $t6, $t6, 1	#   - Increment $t6 by 1
j draw_rect_loop	#   - Jump to start of rectangle drawing loop


tetris_loop:
lw $s0 ADDR_DSPL

li $s1 0xff0000 # red
li $s2 0x00ff00 # green
li $s3 0x0000ff # blue

li $s4 0 # initial y position
li $s5 32 # initial x position

# step 1: check for terminate condition
# step 2: store the game board
store_board:
    la $t0 BOARD_BUFFER
    li $t1 0 # store y coordinate
    move $t3 $s0 # address to store

store_row_loop:
    bge $t1 128 end_store
    li $t2 0 # store x coordinate
    
    store_column_loop:
        bge $t2 128 update_row
        lw $t4 0($t3) # Load the pixel color from the display
        sw $t4, 0($t0)  # Store it in the buffer
        
        addi $t0 $t0 4 # move to next buffer loacation
        addi $t3 $t3 4 # move to next board address
        addi $t2 $t2 1 # move to next column
        j store_column_loop
    
    update_row:
        addi $t1 $t1 1
        j store_row_loop
        
end_store:
    
add $t1 $s5 $s0 # temp to store current address
li $t2 0 # store the current direction of tetris
draw_I: # step 3: draw tetris
    li $t6 0 # counter to store height
    move $t5 $t1
    draw_height: 
        bge $t6 4 processing_loop
        sw $s3 0($t5) # store the color
        addi $t6 $t6 1
        addi $t5 $t5 64
        j draw_height

processing_loop: # step 4: enter the main processing loop for each tetris

    check_keyboard:
        lw $t3 ADDR_KBRD
        lw $t4 0($t3) # load first word from keyboard
        beq $t4 0 check_keyboard # no key
        
        lw $t7 4($t3) # load the keyboard value
        beq $t7 0x61 move_left
        beq $t7 0x77 rotate
        beq $t7 0x64 move_right
        beq $t7 0x73 move_down
        
    move_left:
        jal repaint
        addi $t1 $t1 -4
        beq $t2 0 draw_I
        beq $t2 1 draw_1
        beq $t2 2 draw_2
        beq $t2 3 draw_3
        
    move_right:
        jal repaint
        addi $t1 $t1 4
        beq $t2 0 draw_I
        beq $t2 1 draw_1
        beq $t2 2 draw_2
        beq $t2 3 draw_3
    
    move_down:
        jal repaint
        add $t1 $t1 64
        beq $t2 0 draw_I
        beq $t2 1 draw_1
        beq $t2 2 draw_2
        beq $t2 3 draw_3
    
    rotate:
        jal repaint
        
        # rotate based on current direction
        beq $t2 0 rotate_0_1
        beq $t2 1 rotate_1_2
        beq $t2 2 rotate_2_3
        beq $t2 3 rotate_3_0
        
        rotate_0_1:
            li $t2 1 # change direction
            j draw_1
        rotate_1_2:
            li $t2 2
            j draw_2
        
        rotate_2_3:
            li $t2 3
            j draw_3
            
        rotate_3_0:
            li $t2 0
            j draw_I
        
        draw_1:
            li $t6 0 # counter to store height
            move $t5 $t1
            draw_height_1: 
                bge $t6 4 processing_loop
                sw $s3 0($t5) # store the color
                addi $t6 $t6 1
                addi $t5 $t5 -4
                j draw_height_1
                
        draw_2:
            li $t6 0 # counter to store height
            move $t5 $t1
            draw_height_2: 
                bge $t6 4 processing_loop
                sw $s3 0($t5) # store the color
                addi $t6 $t6 1
                addi $t5 $t5 -64
                j draw_height_2
        
        draw_3:
            li $t6 0 # counter to store height
            move $t5 $t1
            draw_height_3: 
                bge $t6 4 processing_loop
                sw $s3 0($t5) # store the color
                addi $t6 $t6 1
                addi $t5 $t5 4
                j draw_height_3
   
    repaint:
        la $t0 BOARD_BUFFER
        li $t3 0 # store y coordinate
        move $t6 $s0 # address to access
        
    repaint_row:
        bge $t3 128 end_repaint
        li $t4 0 # store x coordinate 
        
        repaint_column:
            bge $t4 128 update_row_repaint
            lw $t5 0($t0) # read color from buffer
            sw $t5 0($t6) # store color to address
            
            addi $t0 $t0 4
            addi $t4 $t4 1
            addi $t6 $t6 4
            j repaint_column
    
        update_row_repaint:
            addi $t3 $t3 1
            j repaint_row
  
    end_repaint:
        jr $ra
