LIST p = 18f4520
    #include<p18f4520.inc>
	    CONFIG OSC = INTIO67
	    CONFIG WDT = OFF
	    org 0x00
	
INITIAL:
    clrf WREG
    clrf TRISA
    movlb 0x1
    movwf 000h, 1
    movwf 001h, 1
    movwf 002h, 1
    movwf 003h, 1
    movwf 004h, 1
    
start:
    movlw 0xB5
    movwf 00h, 1
    movlw 0xF3
    movwf 01h, 1
    movlw 0x64
    movwf 02h, 1
    movlw 0x7F
    movwf 03h, 1
    movlw 0x98
    movwf 04h, 1
    lfsr 0, 101
    
sort:
    indf0 movff FSR0, TRISA
    nop
    
swap:
    
end


