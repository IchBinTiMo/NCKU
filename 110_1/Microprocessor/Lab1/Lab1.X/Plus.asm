LIST p = 18f4520
    #include<p18f4520.inc>
	    CONFIG OSC = INTIO67
	    CONFIG WDT = OFF
	    org 0x00

start:
    clrf WREG
    clrf TRISA
    clrf TRISB
    clrf TRISC
    clrf TRISD
    clrf TRISE
    clrf 001h
    clrf 002h
    clrf 003h
            
here:
    movlw 0xCF
    movwf 001h
    movlw 0xFB
    movwf 002h
    movlw 0x08
    movwf TRISA
    movlw 0x01
    movwf TRISB
    goto reverse
    

reverse:
    movlw 0x00
    rlncf TRISC, 1
    rrncf 002h, 1
    addwf 002h, 0
    andwf TRISB, 0
    addwf TRISC, 1
    movlw 0x01
    movwf TRISB
    decfsz TRISA, 1
    goto reverse
    
    rrncf TRISC, 1
    movlw 0x08
    movwf TRISA
    movlw 0x00
    addwf 001h, 0
    xorwf TRISC, 0
    goto check
    
check:
    rrncf WREG, 1
    btfss WREG, 0
    goto loop
    goto false
    
loop:
    decfsz TRISA, 1
    goto check
    goto true
    
true:   
    movlw 0xFF
    movwf 003h
    goto finish
    
false:
    movlw 0x01
    movwf 003h
    goto finish
    
finish:
    NOP
    
end





