################ CSC258H1F Winter 2024 Assembly Final Project ##################
# This file contains our implementation of Tetris.
#
# Student 1: Yifan Liu, 1007341681
# Student 2: Haochong Yang, 1007787682
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    128
# - Display height in pixels:   256
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
    .space 1024 # to store 128 * 128 board

gameOverMsg: .asciiz "Game Over! Press 'r' to restart !"

.text
start:
    lw $t0, ADDR_DSPL           # Load the display's base address
    li $s6, 0x17161A
    li $s7, 0x1b1b1b
    li $a3, 0x00ff00
draw_initial_board:
    li $s0, 16                  # Side length of the checkerboard (units, not pixels)
    li $s1, 0                   # Row counter for units

outer_loop:                   # This loop will go through each row of units
    li $s2, 0                 # Reset column counter at the beginning of each row of units

inner_loop:                   # This loop will go through each column of units
                              # Determine the color of the 2x2 unit
    add $t4, $s1, $s2         # Add row and column numbers of units
    andi $t4, $t4, 1          # Check if the sum is even or odd
    beq $t4, $zero, even      # If even, choose Color 1
    move $t4, $s7             # Otherwise, choose Color 2
    j paint_unit
even:
    move $t4, $s6             # Choose Color 1 for even

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
    li $a1, 1                   # Starting y-coordinate (row) is 0
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
    li $a1, 1                    # Starting y-coordinate (row) is 0
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
beq $t6, $a0, next_tetris_preview  	# If $t6 == height ($a0), jump to end

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

next_tetris_preview:  
    li $t5, 0 # counter for drawing the black background
    lw $t0, ADDR_DSPL
    addi $s0, $t0, 1024 # Adjust base position if necessary
    move $t1, $s0 # initial position to start drawing the background

    # Draw the black background
    draw_black_loop2:
        bge $t5, 256, end_draw_background # Check if the loop has filled 256 pixels (64x4 for 1x4 stick area)
        sw $s6, 0($t1)
        addi $t1, $t1, 4
        addi $t5, $t5, 1
        j draw_black_loop2

    end_draw_background:
    
    # Correctly position and draw the 1x4 vertical stick centered
    move $t1, $s0 # Reset $t1 to start position for drawing the stick
    addi $t1, $t1, 32 # Center the stick horizontally
    addi $t1, $t1, 384 # Move down to the intended start line vertically

    li $t2, 0 # Initialize counter for drawing 1x4 stick vertically
    draw_stick_loop:
        bge $t2, 4, end_draw_stick # Break loop after drawing 4 vertical segments
        li $s2, 0x0066CC # Color for the stick
        sw $s2, 0($t1) # Draw stick segment
        addi $t1, $t1, 64 # Move to the next line (assuming 16 pixels per line, change as needed)
        addi $t2, $t2, 1
        j draw_stick_loop

    end_draw_stick:

# ----------- main game --------------
draw_random_block:
lw $s0 ADDR_DSPL
li $s1 0xff0000 # red
li $s2 0x00ff00 # green
li $s3 0x0000ff # blue

li $t0 10 # counter for the draw random block
addi $t1 $s0 4 # first address to start
draw_random_block_loop:
    bge $t0 15 tetris_loop
    li $t6 64 # constant
    mul $t2 $t6 $t0 # offset to add
    add $t2 $t1 $t2 # current starting address for the row
    
    move $t3 $t2 # temp to store the current starting point
    li $t5 0 # counter for draw random  loop
    draw_random:
        bge $t5 14 update_draw_random_block
        li $v0, 42
        li $a0, 0
        li $a1, 10
        syscall # generate a random number between 0-9
        bne $a0 1 update_draw_random # if the number is not 1, skip that i.e., 10% chance to draw a block
        sw $s1 0($t3)
        j update_draw_random
    
        update_draw_random:
            addi $t5 $t5 1
            addi $t3 $t3 4
            j draw_random
        
    update_draw_random_block:
        addi $t0 $t0 1
        j draw_random_block_loop

li $s5, -500000 # Global counter for deleting rows

tetris_loop:
li $a0 0 # timing counter
lw $s0 ADDR_DSPL

li $s1 0xff0000 # red
li $s2 0x00ff00 # green
li $s3 0x0000ff # blue
li $s4 10000000 # counter for clock
add $s4, $s4, $s5
# step 0: remove line
addi $t1 $s0 4 # first address to start
li $t0 1 # coutner for the remove line loop



remove_line_loop: # step 0: remove line
    bge $t0 15 check_terminate
    li $t6 64 # constant
    mul $t2 $t6 $t0 # offset to add
    add $t2 $t1 $t2 # current starting address for the row
    
    move $t3 $t2 # temp to store the current starting point
    li $t5 0 # counter for detect line loop
    detect_line:
        bge $t5 14 move_all_line_loop # if not break, remove the entire line
        lw $t4 0($t3)
        beq $t4, $s6, update_remove_line_loop
        beq $t4, $s7, update_remove_line_loop
        addi $t3 $t3 4
        addi $t5 $t5 1
        j detect_line
    
    move_all_line_loop: # use the color from previous line
        addi $s5, $s5, -500000
        move $t5 $t0 # current line
        move $t3 $t2 # temp to store the current starting point
        move_all_line:
            ble $t5 0 update_remove_line_loop
            addi $t5 $t5 -1 # decrement counter
            addi $t3 $t3 -64 # starting address for the previous row
            
            li $t6 0 # counter for move line
            move $t7 $t3 # temp to store starting address for the previous row
            move_line:
                bge $t6 14 move_all_line
                lw $t8 0($t7) # value from previous line
                lw $t9 64($t7) # value from current line
                store_value:
                    beq $t9 $s6 update_move_line
                    beq $t9 $s7 update_move_line
                    beq $t8 $s6 to_grey #if previous line is black, change it to grey
                    beq $t8 $s7 to_black #if previous line is grey, change it to black
                    j update_move_line
                to_grey:
                    move $t8 $s7
                    sw $t8 64($t7) # store the color from previous line to current line
                    j update_move_line
                to_black:
                    move $t8 $s6
                    sw $t8 64($t7) # store the color from previous line to current line
                    j update_move_line
                update_move_line:
                    addi $t6 $t6 1
                    addi $t7 $t7 4
                    j move_line

    update_remove_line_loop:
        addi $t0 $t0 1
        j remove_line_loop
    
 # step 1: check for terminate condition       
check_terminate:
    addi $t1 $s0 4 # address to start
    li $t0 0 # coutner for the remove line loop
    check_terminate_loop:
        bge $t0 14 store_board
        lw $t2 0($t1)
        addi $t0 $t0 1
        addi $t1 $t1 4
        beq $t2 $s6 check_terminate_loop
        beq $t2 $s7 check_terminate_loop
        j game_over

# step 2: store the game board
store_board:
    la $t0 BOARD_BUFFER
    li $t1 0 # store y coordinate
    move $t3 $s0 # address to store

store_row_loop:
    bge $t1 16 end_store
    li $t2 0 # store x coordinate
    
    store_column_loop:
        bge $t2 16 update_row
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

# step 3: draw tetris
addi $t1 $s0 32
add $t1 $t1 $zero # temp to store current address
li $t2 0 # store the current direction of tetris
draw_I:
    li $t6 0 # counter to store height
    move $t5 $t1
    draw_height: 
        bge $t6 4 processing_loop
        sw $s3 0($t5) # store the color
        addi $t6 $t6 1
        addi $t5 $t5 64
        j draw_height

# step 4: enter the main processing loop for each tetris
processing_loop: 
    # movable:
        # add $t1, $t1, 64
        
        # beq $t2, 0, TRYMOVE0 
        # beq $t2, 1, TRYMOVE1 
        # beq $t2, 2, TRYMOVE2 
        # beq $t2, 3, TRYMOVE3
        
        # TRYMOVE0:
            # lw $t9, 192($t1) # Load the byte (color) from the address in $t0 into $t1
            # addi $t1 $t1 -64
            # j not_black
        
        # TRYMOVE1:
            # TRYMOVE10:
                # lw $t9, 0($t1)
                # beq $t9, $s7, TRYMOVE11
                # beq $t9, $s6, TRYMOVE11
                # j EARLYBREAK_1
            # TRYMOVE11:
                # lw $t9, -4($t1)
                # beq $t9, $s7, TRYMOVE12
                # beq $t9, $s6, TRYMOVE12
                # j EARLYBREAK_1
            # TRYMOVE12:
                # lw $t9, -8($t1)
                # beq $t9, $s7, TRYMOVE13
                # beq $t9, $s6, TRYMOVE13
                # j EARLYBREAK_1
            # TRYMOVE13:
                # lw $t9, -12($t1)
                
                # beq $t9, $s7, jump_to_keyboard
                # beq $t9, $s6, jump_to_keyboard
                # EARLYBREAK_1:
                    # addi $t1 $t1 -64
                    # j tetris_loop
        
        # TRYMOVE2:
            # TRYMOVE20:
                # lw $t9, 0($t1)
                # beq $t9, $s7, TRYMOVE21
                # beq $t9, $s6, TRYMOVE21
                # j EARLYBREAK_2
            # TRYMOVE21:
                # lw $t9, -64($t1)
                # beq $t9, $s7, TRYMOVE22
                # beq $t9, $s6, TRYMOVE22
                # j EARLYBREAK_2
            # TRYMOVE22:
                # lw $t9, -128($t1)
                # beq $t9, $s7, TRYMOVE23
                # beq $t9, $s6, TRYMOVE23
                # j EARLYBREAK_2
            # TRYMOVE23:
                # lw $t9, -192($t1)
                # beq $t9, $s7, jump_to_keyboard
                # beq $t9, $s6, jump_to_keyboard
                # EARLYBREAK_2:
                    # addi $t1 $t1 -64
                    # j tetris_loop
        
        # TRYMOVE3:
            # TRYMOVE30:
                # lw $t9, 0($t1)
                # beq $t9, $s7, TRYMOVE31
                # beq $t9, $s6, TRYMOVE31
                # j EARLYBREAK_3
            # TRYMOVE31:
                # lw $t9, 4($t1)
                # beq $t9, $s7, TRYMOVE32
                # beq $t9, $s6, TRYMOVE32
                # j EARLYBREAK_3
            # TRYMOVE32:
                # lw $t9, 8($t1)
                # beq $t9, $s7, TRYMOVE33
                # beq $t9, $s6, TRYMOVE33
                # j EARLYBREAK_3
            # TRYMOVE33:
                # lw $t9, 12($t1)
                # beq $t9, $s7, jump_to_keyboard
                # beq $t9, $s6, jump_to_keyboard
                # EARLYBREAK_3:
                    # addi $t1 $t1 -64
                    # j tetris_loop
        
        # jump_to_keyboard:
            # addi $t1, $t1, -64
            # j check_keyboard
        
        # add $t1 $t1 64
        # beq $t2, 0, try_move_0
        # bne $t2, 0, try_move_123
        
        # try_move_0:
            # lw $t9, 192($t1) # Load the byte (color) from the address in $t0 into $t1
            # addi $t1 $t1 -64
            # j not_black
        # try_move_123:
            # lw $t9, 0($t1)
            # addi $t1 $t1 -64
            # j not_black
        
        # not_black:
            # bne $t9, $s6, not_grey
            # j check_keyboard
        
        # not_grey:
            # bne $t9, $s7, tetris_loop   
        
    movable:
        addi $t1 $t1 64
        
        beq $t2, 0, TRYDOWN0 
        beq $t2, 1, TRYDOWN1 
        beq $t2, 2, TRYDOWN2 
        beq $t2, 3, TRYDOWN3 
   
        TRYDOWN0:
            try_CHECK_DOWN03:
                lw $t9, 192($t1)
                beq $t9, $s7, can_move
                beq $t9, $s6, can_move
                j tetris_loop
            
        TRYDOWN1:
            try_CHECK_DOWN10:
                lw $t9, 0($t1)
                beq $t9, $s7, try_CHECK_DOWN11
                beq $t9, $s6, try_CHECK_DOWN11
                j tetris_loop
            try_CHECK_DOWN11:
                lw $t9, -4($t1)
                beq $t9, $s7, try_CHECK_DOWN12
                beq $t9, $s6, try_CHECK_DOWN12
                j tetris_loop
            try_CHECK_DOWN12:
                lw $t9, -8($t1)
                beq $t9, $s7, try_CHECK_DOWN13
                beq $t9, $s6, try_CHECK_DOWN13
                j tetris_loop
            try_CHECK_DOWN13:
                lw $t9, -12($t1)
                beq $t9, $s7, can_move
                beq $t9, $s6, can_move
                j tetris_loop
        
        TRYDOWN2:
            CHECK_DOWN20:
                lw $t9, 0($t1)
                beq $t9, $s7, can_move
                beq $t9, $s6, can_move
                j tetris_loop
        
        TRYDOWN3:
            try_CHECK_DOWN30:
                lw $t9, 0($t1)
                beq $t9, $s7, try_CHECK_DOWN31
                beq $t9, $s6, try_CHECK_DOWN31
                j tetris_loop
            try_CHECK_DOWN31:
                lw $t9, 4($t1)
                beq $t9, $s7, try_CHECK_DOWN32
                beq $t9, $s6, try_CHECK_DOWN32
                j tetris_loop
            try_CHECK_DOWN32:
                lw $t9, 8($t1)
                beq $t9, $s7, try_CHECK_DOWN33
                beq $t9, $s6, try_CHECK_DOWN33
                j tetris_loop
            try_CHECK_DOWN33:
                lw $t9, 12($t1)
                beq $t9, $s7, can_move
                beq $t9, $s6, can_move
                j tetris_loop
       
        can_move:
            addi $t1, $t1, -64
            j check_keyboard
    
    check_keyboard:
        bge $a0 $s4 gravity # gravity
        addi $a0 $a0 1 # increment timing counter
        lw $t3 ADDR_KBRD
        lw $t4 0($t3) # load first word from keyboard
        beq $t4 0 check_keyboard # no key
        
        lw $t7 4($t3) # load the keyboard value
        beq $t7 0x61 move_left
        beq $t7 0x77 rotate
        beq $t7 0x64 move_right
        beq $t7 0x73 move_down
        beq $t7 0x71 quit
        beq $t7 'p' pause_loop
        j check_keyboard
    
    gravity:
        addi $s4 $s4 -1000000
        li $a0 0
        j move_down
    
    pause_loop:
    
    # Setup for drawing background and initial position remains the same
    li $t6, 0 # counter for drawing the black background
    lw $s0, ADDR_DSPL
    addi $t8, $s0, 1024 # Adjust base position if necessary
    move $t0, $t8 # initial position to start drawing the background

    # Draw the black background
    draw_black_loop3:
        bge $t6, 256, end_draw_background_paused # Check if the loop has filled 256 pixels
        sw $s6, 0($t0)
        addi $t0, $t0, 4
        addi $t6, $t6, 1
        j draw_black_loop3

    end_draw_background_paused:
    
    # Reset the position for drawing "P"
    move $t0, $t8
    addi $t0, $t0, 32 # Center the figure horizontally
    addi $t0, $t0, 384 # Move down to start line vertically

    # Draw vertical backbone of "P"
    li $t3, 0 # Initialize counter for drawing vertical line
    li $s2, 0x0066CC # Color for "P"
    vertical_line_loop_pause:
        bge $t3, 6, draw_top_horizontal_part # Draw 6 segments for the vertical backbone
        sw $s2, 0($t0)
        addi $t0, $t0, 64 # Move to the next line
        addi $t3, $t3, 1
        j vertical_line_loop_pause

    # Draw the top horizontal part of "P"
    draw_top_horizontal_part:
    move $t0, $t8 # Reset position to top of "P"
    addi $t0, $t0, 416 # Adjust for top horizontal part start
    li $t3, 0 # Row counter for horizontal part
    
    horizontal_part_loop:
        bge $t3, 3, end_draw_p # Break after 3 rows
        li $t7, 0 # Column counter
        move $t6, $t0 # Current start position for the row

        # Draw 3x3 top part with a space in the middle row
        column_loop:
            bge $t7, 3, next_row # Break after 3 columns
            # Skip the middle of the top part (second row, second column)
            bne $t3, 1, draw_pixel
            beq $t7, 1, skip_pixel
            
            draw_pixel:
                sw $s2, 0($t6) # Draw pixel
            
            skip_pixel:
                addi $t6, $t6, 4 # Move to next column
                addi $t7, $t7, 1
                j column_loop
        
        next_row:
            addi $t0, $t0, 64 # Move to start of next row
            addi $t3, $t3, 1
            j horizontal_part_loop

    end_draw_p:
    lw $t3 ADDR_KBRD
    lw $t4, 0($t3) # Check if a key is pressed
    beq $t4, 0, pause_loop # Loop until a key is detected

    beq $t4 0 pause_loop
    resume_game:
    # After drawing "P", wait for 'p' press to resume
    lw $t7, 4($t3)
    bne $t7, 'p', pause_loop # If 'p' is not pressed, stay in pause
    
    next_tetris_preview_1:  
    li $t5, 0 # counter for drawing the black background
    addi $t8, $s0, 1024 # Adjust base position if necessary
    move $t0, $t8 # initial position to start drawing the background

    # Draw the black background
    draw_black_loop2_1:
        bge $t5, 256, end_draw_background_1 # Check if the loop has filled 256 pixels (64x4 for 1x4 stick area)
        sw $s6, 0($t0)
        addi $t0, $t0, 4
        addi $t5, $t5, 1
        j draw_black_loop2_1

    end_draw_background_1:
    
    # Correctly position and draw the 1x4 vertical stick centered
    move $t0, $t8 # Reset $t1 to start position for drawing the stick
    addi $t0, $t0, 32 # Center the stick horizontally
    addi $t0, $t0, 384 # Move down to the intended start line vertically

    li $t9, 0 # Initialize counter for drawing 1x4 stick vertically
    draw_stick_loop_1:
        bge $t9, 4, check_keyboard # Break loop after drawing 4 vertical segments
        li $s2, 0x0066CC # Color for the stick
        sw $s2, 0($t0) # Draw stick segment
        addi $t0, $t0, 64 # Move to the next line (assuming 16 pixels per line, change as needed)
        addi $t9, $t9, 1
        j draw_stick_loop_1

    j check_keyboard # Proceed to check other keyboard inputs or resume game
        
        
move_left:
        jal repaint
        addi $t1 $t1 -4
        
        beq $t2, 0, ASSIGNLEFT0 
        beq $t2, 1, ASSIGNLEFT1 
        beq $t2, 2, ASSIGNLEFT2 
        beq $t2, 3, ASSIGNLEFT3 
   
        ASSIGNLEFT0:
            CHECK_LEFT00:
                lw $t9, 0($t1)
                beq $t9, $s7, CHECK_LEFT01
                beq $t9, $s6, CHECK_LEFT01
                j NOT_SHIFT_LEFT
            CHECK_LEFT01:
                lw $t9, 64($t1)
                beq $t9, $s7, CHECK_LEFT02
                beq $t9, $s6, CHECK_LEFT02
                j NOT_SHIFT_LEFT
            CHECK_LEFT02:
                lw $t9, 128($t1)
                beq $t9, $s7, CHECK_LEFT03
                beq $t9, $s6, CHECK_LEFT03
                j NOT_SHIFT_LEFT
            CHECK_LEFT03:
                lw $t9, 192($t1)
                beq $t9, $s7, SHIFT_DRAW
                beq $t9, $s6, SHIFT_DRAW
                j NOT_SHIFT_LEFT
            
        ASSIGNLEFT1:
            CHECK_LEFT10:
                lw $t9, 0($t1)
                beq $t9, $s7, CHECK_LEFT11
                beq $t9, $s6, CHECK_LEFT11
                j NOT_SHIFT_LEFT
            CHECK_LEFT11:
                lw $t9, -4($t1)
                beq $t9, $s7, CHECK_LEFT12
                beq $t9, $s6, CHECK_LEFT12
                j NOT_SHIFT_LEFT
            CHECK_LEFT12:
                lw $t9, -8($t1)
                beq $t9, $s7, CHECK_LEFT13
                beq $t9, $s6, CHECK_LEFT13
                j NOT_SHIFT_LEFT
            CHECK_LEFT13:
                lw $t9, -12($t1)
                beq $t9, $s7, SHIFT_DRAW
                beq $t9, $s6, SHIFT_DRAW
                j NOT_SHIFT_LEFT
        
        ASSIGNLEFT2:
            CHECK_LEFT20:
                lw $t9, 0($t1)
                beq $t9, $s7, CHECK_LEFT21
                beq $t9, $s6, CHECK_LEFT21
                j NOT_SHIFT_LEFT
            CHECK_LEFT21:
                lw $t9, -64($t1)
                beq $t9, $s7, CHECK_LEFT22
                beq $t9, $s6, CHECK_LEFT22
                j NOT_SHIFT_LEFT
            CHECK_LEFT22:
                lw $t9, -128($t1)
                beq $t9, $s7, CHECK_LEFT23
                beq $t9, $s6, CHECK_LEFT23
                j NOT_SHIFT_LEFT
            CHECK_LEFT23:
                lw $t9, -192($t1)
                beq $t9, $s7, SHIFT_DRAW
                beq $t9, $s6, SHIFT_DRAW
                j NOT_SHIFT_LEFT
        
        ASSIGNLEFT3:
            CHECK_LEFT30:
                lw $t9, 0($t1)
                beq $t9, $s7, CHECK_LEFT31
                beq $t9, $s6, CHECK_LEFT31
                j NOT_SHIFT_LEFT
            CHECK_LEFT31:
                lw $t9, 4($t1)
                beq $t9, $s7, CHECK_LEFT32
                beq $t9, $s6, CHECK_LEFT32
                j NOT_SHIFT_LEFT
            CHECK_LEFT32:
                lw $t9, 8($t1)
                beq $t9, $s7, CHECK_LEFT33
                beq $t9, $s6, CHECK_LEFT33
                j NOT_SHIFT_LEFT
            CHECK_LEFT33:
                lw $t9, 12($t1)
                beq $t9, $s7, SHIFT_DRAW
                beq $t9, $s6, SHIFT_DRAW
                j NOT_SHIFT_LEFT
       
        NOT_SHIFT_LEFT:
            jal Sound_effect
            addi $t1, $t1, 4
        SHIFT_DRAW:
            beq $t2 0 draw_I 
            beq $t2 1 draw_1
            beq $t2 2 draw_2
            beq $t2 3 draw_3
        
    move_right:
        jal repaint
        addi $t1 $t1 4
        
        beq $t2, 0, ASSIGNRIGHT0 
        beq $t2, 1, ASSIGNRIGHT1 
        beq $t2, 2, ASSIGNRIGHT2 
        beq $t2, 3, ASSIGNRIGHT3 
   
        ASSIGNRIGHT0:
            CHECK_RIGHT00:
                lw $t9, 0($t1)
                beq $t9, $s7, CHECK_RIGHT01
                beq $t9, $s6, CHECK_RIGHT01
                j NOT_SHIFT_RIGHT
            CHECK_RIGHT01:
                lw $t9, 64($t1)
                beq $t9, $s7, CHECK_RIGHT02
                beq $t9, $s6, CHECK_RIGHT02
                j NOT_SHIFT_RIGHT
            CHECK_RIGHT02:
                lw $t9, 128($t1)
                beq $t9, $s7, CHECK_RIGHT03
                beq $t9, $s6, CHECK_RIGHT03
                j NOT_SHIFT_RIGHT
            CHECK_RIGHT03:
                lw $t9, 192($t1)
                beq $t9, $s7, SHIFT_DRAW
                beq $t9, $s6, SHIFT_DRAW
                j NOT_SHIFT_RIGHT
            
        ASSIGNRIGHT1:
            CHECK_RIGHT10:
                lw $t9, 0($t1)
                beq $t9, $s7, CHECK_RIGHT11
                beq $t9, $s6, CHECK_RIGHT11
                j NOT_SHIFT_RIGHT
            CHECK_RIGHT11:
                lw $t9, -4($t1)
                beq $t9, $s7, CHECK_RIGHT12
                beq $t9, $s6, CHECK_RIGHT12
                j NOT_SHIFT_RIGHT
            CHECK_RIGHT12:
                lw $t9, -8($t1)
                beq $t9, $s7, CHECK_RIGHT13
                beq $t9, $s6, CHECK_RIGHT13
                j NOT_SHIFT_RIGHT
            CHECK_RIGHT13:
                lw $t9, -12($t1)
                beq $t9, $s7, SHIFT_DRAW
                beq $t9, $s6, SHIFT_DRAW
                j NOT_SHIFT_RIGHT
        
        ASSIGNRIGHT2:
            CHECK_RIGHT20:
                lw $t9, 0($t1)
                beq $t9, $s7, CHECK_RIGHT21
                beq $t9, $s6, CHECK_RIGHT21
                j NOT_SHIFT_RIGHT
            CHECK_RIGHT21:
                lw $t9, -64($t1)
                beq $t9, $s7, CHECK_RIGHT22
                beq $t9, $s6, CHECK_RIGHT22
                j NOT_SHIFT_RIGHT
            CHECK_RIGHT22:
                lw $t9, -128($t1)
                beq $t9, $s7, CHECK_RIGHT23
                beq $t9, $s6, CHECK_RIGHT23
                j NOT_SHIFT_RIGHT
            CHECK_RIGHT23:
                lw $t9, -192($t1)
                beq $t9, $s7, SHIFT_DRAW
                beq $t9, $s6, SHIFT_DRAW
                j NOT_SHIFT_RIGHT
        
        ASSIGNRIGHT3:
            CHECK_RIGHT30:
                lw $t9, 0($t1)
                beq $t9, $s7, CHECK_RIGHT31
                beq $t9, $s6, CHECK_RIGHT31
                j NOT_SHIFT_RIGHT
            CHECK_RIGHT31:
                lw $t9, 4($t1)
                beq $t9, $s7, CHECK_RIGHT32
                beq $t9, $s6, CHECK_RIGHT32
                j NOT_SHIFT_RIGHT
            CHECK_RIGHT32:
                lw $t9, 8($t1)
                beq $t9, $s7, CHECK_RIGHT33
                beq $t9, $s6, CHECK_RIGHT33
                j NOT_SHIFT_RIGHT
            CHECK_RIGHT33:
                lw $t9, 12($t1)
                beq $t9, $s7, SHIFT_DRAW
                beq $t9, $s6, SHIFT_DRAW
                j NOT_SHIFT_RIGHT
       
        NOT_SHIFT_RIGHT:
            jal Sound_effect
            addi $t1, $t1, -4
        SHIFT_DRAW:
            beq $t2 0 draw_I 
            beq $t2 1 draw_1
            beq $t2 2 draw_2
            beq $t2 3 draw_3
    
    move_down:
        jal repaint
        addi $t1 $t1 64
        
        beq $t2, 0, ASSIGNDOWN0 
        beq $t2, 1, ASSIGNDOWN1 
        beq $t2, 2, ASSIGNDOWN2 
        beq $t2, 3, ASSIGNDOWN3 
   
        ASSIGNDOWN0:
            CHECK_DOWN00:
                lw $t9, 0($t1)
                beq $t9, $s7, CHECK_DOWN01
                beq $t9, $s6, CHECK_DOWN01
                j NOT_SHIFT_DOWN
            CHECK_DOWN01:
                lw $t9, 64($t1)
                beq $t9, $s7, CHECK_DOWN02
                beq $t9, $s6, CHECK_DOWN02
                j NOT_SHIFT_DOWN
            CHECK_DOWN02:
                lw $t9, 128($t1)
                beq $t9, $s7, CHECK_DOWN03
                beq $t9, $s6, CHECK_DOWN03
                j NOT_SHIFT_DOWN
            CHECK_DOWN03:
                lw $t9, 192($t1)
                beq $t9, $s7, SHIFT_DRAW
                beq $t9, $s6, SHIFT_DRAW
                j NOT_SHIFT_DOWN
            
        ASSIGNDOWN1:
            CHECK_DOWN10:
                lw $t9, 0($t1)
                beq $t9, $s7, CHECK_DOWN11
                beq $t9, $s6, CHECK_DOWN11
                j NOT_SHIFT_DOWN
            CHECK_DOWN11:
                lw $t9, -4($t1)
                beq $t9, $s7, CHECK_DOWN12
                beq $t9, $s6, CHECK_DOWN12
                j NOT_SHIFT_DOWN
            CHECK_DOWN12:
                lw $t9, -8($t1)
                beq $t9, $s7, CHECK_DOWN13
                beq $t9, $s6, CHECK_DOWN13
                j NOT_SHIFT_DOWN
            CHECK_DOWN13:
                lw $t9, -12($t1)
                beq $t9, $s7, SHIFT_DRAW
                beq $t9, $s6, SHIFT_DRAW
                j NOT_SHIFT_DOWN
        
        ASSIGNDOWN2:
            CHECK_DOWN20:
                lw $t9, 0($t1)
                beq $t9, $s7, CHECK_DOWN21
                beq $t9, $s6, CHECK_DOWN21
                j NOT_SHIFT_DOWN
            CHECK_DOWN21:
                lw $t9, -64($t1)
                beq $t9, $s7, CHECK_DOWN22
                beq $t9, $s6, CHECK_DOWN22
                j NOT_SHIFT_DOWN
            CHECK_DOWN22:
                lw $t9, -128($t1)
                beq $t9, $s7, CHECK_DOWN23
                beq $t9, $s6, CHECK_DOWN23
                j NOT_SHIFT_DOWN
            CHECK_DOWN23:
                lw $t9, -192($t1)
                beq $t9, $s7, SHIFT_DRAW
                beq $t9, $s6, SHIFT_DRAW
                j NOT_SHIFT_DOWN
        
        ASSIGNDOWN3:
            CHECK_DOWN30:
                lw $t9, 0($t1)
                beq $t9, $s7, CHECK_DOWN31
                beq $t9, $s6, CHECK_DOWN31
                j NOT_SHIFT_DOWN
            CHECK_DOWN31:
                lw $t9, 4($t1)
                beq $t9, $s7, CHECK_DOWN32
                beq $t9, $s6, CHECK_DOWN32
                j NOT_SHIFT_DOWN
            CHECK_DOWN32:
                lw $t9, 8($t1)
                beq $t9, $s7, CHECK_DOWN33
                beq $t9, $s6, CHECK_DOWN33
                j NOT_SHIFT_DOWN
            CHECK_DOWN33:
                lw $t9, 12($t1)
                beq $t9, $s7, SHIFT_DRAW
                beq $t9, $s6, SHIFT_DRAW
                j NOT_SHIFT_DOWN
       
        NOT_SHIFT_DOWN:
            jal Sound_effect
            addi $t1, $t1, -64
        SHIFT_DRAW:
            beq $t2 0 draw_I 
            beq $t2 1 draw_1
            beq $t2 2 draw_2
            beq $t2 3 draw_3
            
 ################################ ROTATE ####################################   
    rotate:
        jal repaint
        
        beq $t2 0 check_rotate_0_1
        beq $t2 1 check_rotate_1_2
        beq $t2 2 check_rotate_2_3
        beq $t2 3 check_rotate_3_0
        
        check_rotate_0_1:
            CHECK_ROTATE11:
                lw $t9, -4($t1)
                beq $t9, $s7, CHECK_ROTATE12
                beq $t9, $s6, CHECK_ROTATE12
                j draw_I
            CHECK_ROTATE12:
                lw $t9, -8($t1)
                beq $t9, $s7, CHECK_ROTATE13
                beq $t9, $s6, CHECK_ROTATE13
                j draw_I
            CHECK_ROTATE13:
                lw $t9, -12($t1)
                beq $t9, $s7, ROTATE_CHECKED
                beq $t9, $s6, ROTATE_CHECKED
                j draw_I
        
        check_rotate_1_2:
            CHECK_ROTATE21:
                lw $t9, -64($t1)
                beq $t9, $s7, CHECK_ROTATE22
                beq $t9, $s6, CHECK_ROTATE22
                j draw_1
            CHECK_ROTATE22:
                lw $t9, -128($t1)
                beq $t9, $s7, CHECK_ROTATE23
                beq $t9, $s6, CHECK_ROTATE23
                j draw_1
            CHECK_ROTATE23:
                lw $t9, -192($t1)
                beq $t9, $s7, ROTATE_CHECKED
                beq $t9, $s6, ROTATE_CHECKED
                j draw_1
        
        check_rotate_2_3:
            CHECK_ROTATE31:
                lw $t9, 4($t1)
                beq $t9, $s7, CHECK_ROTATE32
                beq $t9, $s6, CHECK_ROTATE32
                j draw_2
            CHECK_ROTATE32:
                lw $t9, 8($t1)
                beq $t9, $s7, CHECK_ROTATE33
                beq $t9, $s6, CHECK_ROTATE33
                j draw_2
            CHECK_ROTATE33:
                lw $t9, 12($t1)
                beq $t9, $s7, ROTATE_CHECKED
                beq $t9, $s6, ROTATE_CHECKED
                j draw_2
        
        check_rotate_3_0:
            CHECK_ROTATE01:
                lw $t9, 64($t1)
                beq $t9, $s7, CHECK_ROTATE02
                beq $t9, $s6, CHECK_ROTATE02
                j draw_3
            CHECK_ROTATE02:
                lw $t9, 128($t1)
                beq $t9, $s7, CHECK_ROTATE03
                beq $t9, $s6, CHECK_ROTATE03
                j draw_3
            CHECK_ROTATE03:
                lw $t9, 192($t1)
                beq $t9, $s7, ROTATE_CHECKED
                beq $t9, $s6, ROTATE_CHECKED
                j draw_3
        
        ROTATE_CHECKED:
        
        # rotate based on current direction
        beq $t2 0 rotate_0_1
        beq $t2 1 rotate_1_2
        beq $t2 2 rotate_2_3
        beq $t2 3 rotate_3_0
        
        rotate_0_1:
            li $t2 1 # change direction
            jal Sound_effect1
            j draw_1
        rotate_1_2:
            li $t2 2
            jal Sound_effect1
            j draw_2
        
        rotate_2_3:
            li $t2 3
            jal Sound_effect1
            j draw_3
            
        rotate_3_0:
            li $t2 0
            jal Sound_effect1
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
        lw $s0, ADDR_DSPL
        move $t6 $s0 # address to access
        
    repaint_row:
        bge $t3 16 end_repaint
        li $t4 0 # store x coordinate 
        
        repaint_column:
            bge $t4 16 update_row_repaint
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

    quit:
        li $v0 10
        syscall
    
game_over:
    la $a0, gameOverMsg
    li $v0, 4
    syscall
    
    li $t0, 0 # counter for drawing the black background
    move $t1, $s0 # initial position to start
    addi $t1, $t1, 1024
    draw_black_loop:
        bge $t0, 512, draw_R # Adjusted target label
        sw $s6, 0($t1)
        addi $t1, $t1, 4
        addi $t0, $t0, 1
        j draw_black_loop
    
    # Start drawing R
    draw_R:
    move $t1, $s0
    addi $t1, $t1, 1024
    addi $t1, $t1, 32 # Center the R horizontally
    addi $t1, $t1, 320 # Adjust vertical start position
    
    # Draw vertical backbone of R
    li $t2, 0 # Initialize counter for vertical line
    draw_R_vertical:
        bge $t2, 6, draw_R_top_horizontal # Stop after 6 segments
        sw $s2, 0($t1) # Draw segment
        addi $t1, $t1, 64 # Move to the next line
        addi $t2, $t2, 1
        j draw_R_vertical
    
    # Draw the top horizontal part of R
    draw_R_top_horizontal:
    move $t1, $s0 # Reset position to top of R
    addi $t1, $t1, 1024
    addi $t1, $t1, 352 # Move to start of top horizontal part
    li $t2, 0 # Counter for horizontal part
    draw_R_horizontal_loop:
        bge $t2, 3, draw_R_diagonal # Stop after 3 rows, then start drawing diagonal leg
        li $t3, 0 # Column counter
        move $t4, $t1 # Current start position for row

        # Draw 3x3 top part, skipping middle cell on second row
        draw_R_horizontal_column:
            bge $t3, 3, next_R_row
            # Skip drawing in the middle of the top part (2nd row, 2nd column)
            bne $t2, 1, draw_R_pixel
            beq $t3, 1, skip_R_pixel

            draw_R_pixel:
                sw $s2, 0($t4)
            
            skip_R_pixel:
                addi $t4, $t4, 4
                addi $t3, $t3, 1
                j draw_R_horizontal_column

        next_R_row:
            addi $t1, $t1, 64
            addi $t2, $t2, 1
            j draw_R_horizontal_loop

    # Draw the diagonal leg of R
    draw_R_diagonal:
    move $t1, $s0
    addi $t1, $t1, 1024
    addi $t1, $t1, 548 # Adjust position for the diagonal leg's start
    li $t2, 0
    draw_R_diagonal_leg:
        bge $t2, 3, wait_retry # Stop after 3 segments
        sw $s2, 0($t1)
        addi $t1, $t1, 68 # Adjust for diagonal down-right movement
        addi $t2, $t2, 1
        j draw_R_diagonal_leg
        
    wait_retry:
        lw $t3, ADDR_KBRD
        lw $t4, 0($t3) # load first word from keyboard
        beq $t4, 0, wait_retry # no key detected
        
        lw $t7, 4($t3) # load the keyboard value
        beq $t7, 'r', restart
        j wait_retry
    
    restart:
        li $s5, -500000 # Reset or set up for game restart logic
        j start # Assuming 'start' is the label for game start logic

    
    Sound_effect:
    	li $v0, 31 #Play audio syscall code
    	li $a0, 53 #pitch
    	li $a1, 50 #Duration
    	li $a2, 14 #Instrument
    	li $a3, 127 #Volume 
    	syscall
    	
    	jr $ra
    Sound_effect1:
    	li $v0, 31 #Play audio syscall code
    	li $a0, 100 #pitch
    	li $a1, 50 #Duration
    	li $a2, 14 #Instrument
    	li $a3, 127 #Volume 
    	syscall
    	
    	jr $ra