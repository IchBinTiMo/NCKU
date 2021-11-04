#include "xc.inc"
GLOBAL _divide_signed
    
PSECT mytext, local, class=CODE, reloc=2

Initial:
    SFTL macro F1, F2
	rlncf F2, 1
	bcf F2, 0
	btfsc F1, 7
	bsf F2, 0
	rlncf F1, 1
	bcf F1, 0
	endm
    
    

_divide_signed:
    clrf TRISA
    clrf TRISC
    clrf TRISD
    clrf 002h
    clrf 003h
    movff 001h, 003h
    movwf 001h
    movlw 0x08
    movwf TRISA
    clrf WREG
    btfsc 003h, 7
    movlw 0x01
    movwf TRISD
    clrf WREG
    btfsc 001h, 7
    movlw 0x01
    movwf TRISC
    movlw 0x01
    btfsc TRISC, 0
    negf 001h
    btfsc TRISD, 0
    negf 003h
    clrf WREG
    addwf 003h, W
    SFTL 001h, 002h
    rcall loop
    rrncf 002h
    btfsc TRISC, 0
    negf 001h
    btfsc TRISD, 0
    negf 001h
    btfsc TRISC, 0
    negf 002h
    movlw 0x0F
    andwf 002h, 1
	RETURN


loop:
    clrf WREG
    addwf 003h, W
    subwf 002h, 1
    btfss 002h, 7
    goto greater_than_0
    goto less_than_0
    
    
less_than_0:
    clrf WREG
    addwf 003h, W
    addwf 002h, 1
    SFTL 001h, 002h
    bcf 001h, 0
    goto counter
    
    
    
greater_than_0:
    SFTL 001h, 002h
    bsf 001h, 0
    goto counter
    
  
    
counter:
    decfsz TRISA, 1
    goto loop
    return
    
    



