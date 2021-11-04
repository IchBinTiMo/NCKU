LIST p = 18f4520
    #include<p18f4520.inc>
	    CONFIG OSC = INTIO67
	    CONFIG WDT = OFF
	    org 0x00
	
	
INITIAL:
    clrf WREG
    movlb 0x1
    movwf 000h, 1
    movwf 001h, 1
    movwf 002h, 1
    movwf 003h, 1
    movwf 004h, 1
    movwf 005h, 1
    movwf 006h, 1
    movwf 007h, 1
    movwf 008h, 1
    movwf 010h, 1
    movwf 011h, 1
    movwf 012h, 1
    movwf 013h, 1
    movwf 014h, 1
    movwf 015h, 1
    movwf 016h, 1
    movwf 017h, 1
    movwf 018h, 1
    movwf 020h, 1
    movwf 021h, 1
    movwf 022h, 1
    movwf 023h, 1
    movwf 024h, 1
    movwf 025h, 1
    movwf 026h, 1
    movwf 027h, 1
    movwf 028h, 1
    
start:
    clrf WREG
    movlb 0x1
    lfsr 0, 100
    movlw 0x00
    movwf 000h, 1
    movlw 0x01
    movwf 001h, 1
    movlw 0x02
    movwf 002h, 1
    movlw 0x03
    movwf 003h, 1
    movlw 0x04
    movwf 004h, 1
    movlw 0x05
    movwf 005h, 1
    movlw 0x06
    movwf 006h, 1
    movlw 0x07
    movwf 007h, 1
    movlw 0x08
    movwf 008h, 1
    clrf WREG
Basic:
    addwf POSTINC0, 0
    movwf 018h, 1
    clrf WREG
    addwf POSTINC0, 0
    movwf 017h, 1
    clrf WREG
    addwf POSTINC0, 0
    movwf 016h, 1
    clrf WREG
    addwf POSTINC0, 0
    movwf 015h, 1
    clrf WREG
    addwf POSTINC0, 0
    movwf 014h, 1
    clrf WREG
    addwf POSTINC0, 0
    movwf 013h, 1
    clrf WREG
    addwf POSTINC0, 0
    movwf 012h, 1
    clrf WREG
    addwf POSTINC0, 0
    movwf 011h, 1
    clrf WREG
    addwf POSTINC0, 0
    movwf 010h, 1
    nop
    
Advanced:
    clrf WREG
    lfsr 0, 100h
    addwf POSTINC0, 0
    movwf 020h, 1
    addwf POSTINC0, 0
    movwf 021h, 1
    addwf POSTINC0, 0
    movwf 022h, 1
    addwf POSTINC0, 0
    movwf 023h, 1
    addwf POSTINC0, 0
    movwf 024h, 1
    addwf POSTINC0, 0
    movwf 025h, 1
    addwf POSTINC0, 0
    movwf 026h, 1
    addwf POSTINC0, 0
    movwf 027h, 1
    addwf POSTINC0, 0
    movwf 028h, 1
    nop
 
    
end