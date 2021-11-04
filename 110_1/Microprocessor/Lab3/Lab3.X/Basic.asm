LIST p = 18f4520
    #include<p18f4520.inc>
	    CONFIG OSC = INTIO67
	    CONFIG WDT = OFF
	    org 0x00
	    
Initail:
    clrf WREG
    clrf TRISA
    movlw 0xC2
    movwf TRISA
    clrf WREG
    
Start:
    movlw 0xFE
    andwf TRISA, 1
    movlw 0x80
    andwf TRISA, 0
    rrncf TRISA
    addwf TRISA, 1
    
end




