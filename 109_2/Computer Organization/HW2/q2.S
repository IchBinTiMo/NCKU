main:
    addi $a0, $zero, 10 # n = 10
    addi $a1, $zero, 5  # m = 5
    jal pascal          # call pascal(10, 5)
    j exit

pascal:
    addi $sp, $sp, -12
    sw $ra 0x0($sp)    # Save $ra register into stack
    sw $a0 0x4($sp)
    sw $a1 0x8($sp)

    #--------------------------------------#
    #  \^o^/   Write your code here~  \^o^/#
    #--------------------------------------#
    
    beq $a0 $a1 return_1
    beqz $a1 return_1
    
    addi $a0 $a0 -1
    addi $a1 $a1 -1
    
    jal pascal
    
    addi $a0 $a0 1
    addi $a1 $a1 1
    
    addi $a0 $a0 -1
    
    jal pascal
    
    addi $a0 $a0 1    
    
    lw $a1 0x8($sp)    # Load $ra register from stack
    lw $a0 0x4($sp)
    lw $ra 0x0($sp) 
    addi $sp, $sp, 12
    jr $ra


return_1:
    addi $v0 $v0 1
    lw $a1 8($sp)
    lw $a0 4($sp)
    lw $ra 0($sp)
    addi $sp $sp 12
    jr $ra
    
exit:
