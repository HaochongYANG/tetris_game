.data
displayAddress: .word 0x10008000

.text
lw $t0, displayAddress
li $t1, 0xff0000 # assign the colors
li $t2, 0x00ff00
li $t3, 0x0000ff
# sw $t1, 12($t0) # write to the bitmap
# sw $t2, 16($t0)
# sw $t3, 0($t0)
# Some experiment
add $t4, $t1, $t2 # Yellow change the color




# Example: Draw a rectangle
lw $t0, displayAddress  # Stores the base address for display
addi $t0, $t0, 512   # Start 4 lines down
# Assume the height and width of the rectangle are in a0 and a1
addi $a0, $zero, 6 # Set height to 6
addi $a1, $zero, 10 # Set height to 10
# Draw a line, Set index value $t5 to 0

add $t6, $zero, $zero
draw_rec_loop:
beq $t6, $a0, exit
add $t5, $zero, $zero
draw_line_loop:
beq $t5, $a1, end_draw_line # While $t5 != width ($a1):
sw $t4, 0($t0)              
addi $t0, $t0, 4 
addi $t5, $t5, 1 #   Draw a pixel at memory location $t0, and then increment t0 by 4, increment t5 by 1.
#   Jump to start of line drawing loop
j draw_line_loop

end_draw_line:
addi $t0, $t0, 88  # Set pixel to the next pixel of the next line
addi $t6, $t6, 1
j draw_rec_loop


sw $t1, 0($t0)
addi $t0, $t0, 4
sw $t2, 0($t0)

addi $t7, $t6, 10 # Add a constant
addi $t7, $zero, 8 # Initialize to a constant 8
addi $t8, $zero, 3

mult $t7, $t8  # calculate t7 * t8 and store the value into hi lo
mflo $t9 # Store the result of multiplication lo into t9

div $t7, $t8  # calculate t7 / t8 and store the value into hi lo
mflo $t9 # Store the result of multiplication lo into t9

or $t9, $t1, $t2 # t1 OR t2 stored in t9 bitwise
and $t9, $t1, $t2 # t1 AND t2 stored in t9 bitwise
xori $t9, $t1, 0xffffffff # Bitwise flip the bits
sll $t9, $t9, 1
srl $t9, $t9, 1


addi $t5, $zero, 0  #Set up the loop variables
addi $t6, $zero, 16
paint:
beq $t5, 16, exit  # Branching, test if $5 == 16? checking condition
add $t4, $t1, $t2
sw $t1, 0($t0)
addi $t0, $t0, 4
sw $t2, 0($t0)
addi $t0, $t0, 124
sw $t3, 0($t0)
addi $t0, $t0, 4
sw $t4, 0($t0)
addi $t0, $t0, -124

addi $t5, $t5, 1 # Increment

j paint



exit:
li $v0 10
syscall