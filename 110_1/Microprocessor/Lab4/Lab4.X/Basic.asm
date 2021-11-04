LIST p = 18f4520
    #include<p18f4520.inc>
	    CONFIG OSC = INTIO67
	    CONFIG WDT = OFF
	    org 0x00

Initial:
    MOVLF macro literal, F
	clrf F
	clrf WREG
	movlw literal
	addwf F, 1
	endm
    
    RECT macro addr_x1, addr_y1, addr_x2, addr_y2, F
	clrf WREG
	clrf TRISA
	addwf addr_x1, 0
	subwf addr_x2, 0
	movwf TRISA
	clrf WREG
	addwf addr_y1, 0
	subwf addr_y2, 0
	mulwf TRISA
	clrf WREG
	addwf PRODL, 0
	movwf F
	endm
	
Start:
    clrf 000h
    clrf 001h
    clrf 002h
    clrf 003h
    clrf 004h
    MOVLF 0x03, 000h
    MOVLF 0x09, 001h
    MOVLF 0x07, 002h
    MOVLF 0x0F, 003h
    RECT 000h, 001h, 002h, 003h, 004h
    
    
end
	


