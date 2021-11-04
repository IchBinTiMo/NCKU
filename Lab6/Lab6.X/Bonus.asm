LIST p = 18f4520
    #include<p18f4520.inc>
	    CONFIG OSC = INTIO67
	    CONFIG WDT = OFF
	    CONFIG LVP = OFF
	    
	    
	    
	    org 0x00

Initial:
    outer_state equ 0x01
    inner_state equ 0x02
    MOVLF macro literal, F
	movlw literal
	movwf F
    endm
    DELAY macro i, j
	local outerloop
	local innerloop
	movlw i
	movwf 0x14
	outerloop:
	    movlw j
	    movwf 0x15
	innerloop:
	    nop
	    nop
	    nop
	    nop
	    nop
	    decfsz 0x15, 1
	    goto innerloop
	    decfsz 0x14, 1
	    goto outerloop
	    
    endm
    
    RLR4 macro F
	rlncf F
	btfsc F, 4
	bsf F, 0
	bcf F, 4
    endm
    
start:
    MOVLF 0x0F, ADCON1
    clrf PORTA
    MOVLF 0x10, TRISA
    clrf outer_state
    clrf TRISD
    clrf LATD

pressButton:
    btfsc PORTA, 4
    goto pressButton
    rcall nextState
    goto pressButton

nextState:
    btfsc outer_state, 2
    goto resetState
    rcall changeState
    return
    
changeState:
    movff outer_state, LATD
    MOVLF 0x04, inner_state
    rlncf LATD
    bsf LATD, 0
    rcall rotate
    movff LATD, outer_state
    return
    
rotate:
    ;DELAY d'200', d'360'
    RLR4 LATD
    ;decfsz inner_state, 1
    btfsc PORTA, 4   
    goto rotate
    goto pressButton 
    return
    
resetState:
    clrf outer_state
    clrf LATD
    return
    
    
end
    
