main:
    addi $a0, $zero, 19654 # a0= 19654
    addi $a1, $zero, 100654  # a1=100654
    addi $a2, $zero, 10065  # a2= 10065
    jal average     # call average
    j exit

average:
    addi $sp, $sp, -4
    sw $ra, 0x0($sp)    # Save $ra register into stack

    #--------------------------------------#
    #  \^o^/   Write your code here~  \^o^/#
    #--------------------------------------#
    
    add $t0 $a0 $a1
    add $t0 $t0 $a2
    
    jal check_sign
    jal loop
    
    mult $t4 $t9
    mflo $v0 
    
    sw $v0 0($t1)

    lw $ra, 0x0($sp)    # Load $ra register from stack
    addi $sp, $sp, 4
    jr $ra

check_sign:
    addi $sp, $sp, -4
    sw $ra, 0x0($sp)
    beqz $t0 is_zero
    bnez $t0 else
    lw $ra, 0x0($sp)
    addi $sp, $sp, 4

is_zero:
    li $v0 0
    jr $ra

else:
    slt $t1 $t0 $zero
    bnez $t1 less
    li $t2 3
    li $t9 1
    jr $ra
    
less:
    li $t2 -3
    li $t9 -1
    jr $ra

loop:
    addi $sp, $sp, -4
    sw $ra, 0x0($sp)
    jal check_bound
    beqz $t5 return 
    add $t3 $t3 $t2
    add $t4 $t4 $t9
    jal loop

return:
    lw $ra, 0x0($sp)
    addi $sp, $sp, 4
    jr $ra
    
check_bound:
    addi $sp, $sp, -4
    sw $ra, 0x0($sp)
    slti $t5 $t0 0
    bnez $t5 negative
    slt $t5 $t3 $t0
    lw $ra, 0x0($sp)
    addi $sp, $sp, 4
    jr $ra
    
negative:
    slt $t5 $t0 $t3
    jr $ra
exit:
