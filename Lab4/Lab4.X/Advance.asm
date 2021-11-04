LIST p = 18f4520
    #include<p18f4520.inc>
	    CONFIG OSC = INTIO67
	    CONFIG WDT = OFF
	    org 0x00
Initial:
    SWPFF macro F1, F2
	clrf TRISD
	movff F2, TRISD
	movff F1, F2
	movff TRISD, F1
	endm
	
    MOVLF macro literal, F
	clrf WREG
	movlw literal
	movwf F
	endm
	
    ADDFF macro F1, F2
	clrf WREG
	addwf F2, 0
	addwf F1, 1
	endm



    
Start:
    clrf 000h
    MOVLF 0x06, TRISC
    MOVLF 0x00, TRISA
    MOVLF 0x01, TRISB
    rcall Fib
    rcall Finish
    
    
    
Fib:
    ADDFF TRISA, TRISB
    SWPFF TRISA, TRISB
    movlw 0x18
    decfsz TRISC, 1
    movwf PCL
    return
    
Finish:
    nop
    movff TRISA, 000h
    end


