#include "xc.inc"
GLOBAL _divide
    
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
    
    

_divide:
    clrf TRISA
    movlw 0x08
    movwf TRISA
    SFTL 001h, 002h
    rcall loop
    rrncf 002h
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
    
    
