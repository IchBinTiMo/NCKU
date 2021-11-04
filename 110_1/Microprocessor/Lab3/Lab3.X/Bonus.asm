LIST p = 18f4520
    #include<p18f4520.inc>
	    CONFIG OSC = INTIO67
	    CONFIG WDT = OFF
	    org 0x00

Initial:
    clrf WREG
    clrf 000h
    clrf 001h
    clrf 002h
    clrf TRISA
    clrf TRISB
    clrf TRISC
    movlw 0x40
    movwf 000h
    movwf TRISA
    movlw 0x28
    movwf 001h
    movwf TRISB
    clrf WREG
    addwf TRISB, 0
    
Start:
    cpfsgt TRISA
    goto Swap
    subwf TRISA, 1
    cpfseq TRISA
    goto Start
    goto Finish
    
    
Swap:
    movwf TRISC
    clrf WREG
    addwf TRISA, 0
    movff TRISC, TRISA
    goto Start
    
    
Finish:
    movwf 002h
    nop
    
    
end

