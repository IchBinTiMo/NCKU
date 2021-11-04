LIST p = 18f4520
    #include<p18f4520.inc>
	    CONFIG OSC = INTIO67
	    CONFIG WDT = OFF
	    org 0x00
	    
Initial:
    
start:
    clrf WREG
    clrf TRISD
    
here:
    movlw 0x0F
    addwf TRISD, 1
    clrf WREG
    goto loop

loop:
    addwf TRISD, 0
    decfsz TRISD, 1
    goto loop
    NOP
    
    
end
    