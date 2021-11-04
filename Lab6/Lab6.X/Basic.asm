LIST p = 18f4520
    #include<p18f4520.inc>
	    CONFIG OSC = INTIO67
	    CONFIG WDT = OFF
	    CONFIG LVP = OFF
	    
	    
	    org 0x00

Initial:
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
    clrf TRISD
    clrf LATD
    MOVLF 0x0A, LATD
    
    
checkPress:
    btfsc PORTA, 4
    bra checkPress
    bra lightUp
    
lightUp:
    btg LATD, 0
    btg LATD, 1
    btg LATD, 2
    btg LATD, 3
    DELAY d'180', d'200'
    bra checkPress
    
    
end