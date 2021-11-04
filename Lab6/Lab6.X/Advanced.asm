LIST p = 18f4520
    #include<p18f4520.inc>
	    CONFIG OSC = INTIO67
	    CONFIG WDT = OFF
	    CONFIG LVP = OFF
	    
	    
	    
	    org 0x00

Initial:
    state equ 0x01
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
start:
    MOVLF 0x0F, ADCON1
    clrf PORTA
    MOVLF 0x10, TRISA
    clrf state
    clrf TRISD
    clrf LATD
pressButton:
    btfsc PORTA, 4
    goto pressButton
    rcall nextState
    goto pressButton
nextState:
    btfsc state, 3
    goto resetState
    rcall changeState
    return
    
changeState:
    movff state, LATD
    rlncf LATD
    bsf LATD, 0
    DELAY d'200', d'360'
    rcall clearState
    return
    
clearState:
    movff LATD, state
    clrf LATD
    return
    
resetState:
    DELAY d'200', d'360'
    clrf state
    clrf LATD
    return
    
    
end