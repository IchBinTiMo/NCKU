LIST p = 18f4520
    #include<p18f4520.inc>
	    CONFIG OSC = INTIO67
	    CONFIG WDT = OFF
	    org 0x00
	    
	    
Initial:
    clrf WREG
    clrf TRISA
    clrf TRISB 
    clrf TRISC
    clrf TRISD
    clrf TRISE
    movlw 0x0D
    movwf TRISB
    movlw 0x06
    movwf TRISC
    movlw 0x04
    movwf TRISD
    movlw 0x04
    movwf TRISE
    clrf WREG
    
Start:
    movlw 0x01
    andwf TRISC, 0
    bz Counter
    clrf WREG
    addwf TRISB, 0
    addwf TRISA, 1
    
    
    
Counter:
    rlncf TRISB
    rrncf TRISC    
    clrf WREG
    decf TRISD, 1
    addwf TRISD, 0
    bnz Start
    bz Finish
        
Finish:
    nop
end


