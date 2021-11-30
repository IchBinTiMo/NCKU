
; PIC18F4520 Configuration Bit Settings

; Assembly source line config statements

#include "p18f4520.inc"

; CONFIG1H
  CONFIG  OSC = INTIO67         ; Oscillator Selection bits (Internal oscillator block, port function on RA6 and RA7)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRT = OFF            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOREN = SBORDIS       ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
  CONFIG  BORV = 3              ; Brown Out Reset Voltage bits (Minimum setting)

; CONFIG2H
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = PORTC        ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-001FFFh) not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-001FFFh) not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block (000000-0007FFh) not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-001FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) not protected from table reads executed in other blocks)
;PUSH "RA4 BUTTON" 3 times (use TIMER 0)
  ; => "RD1 LED" light on for 0.5 seconds
  
 CNTVAL equ d'255'
 L1 equ 0x14
 L2 equ 0x15
 flag equ 0x03
 org 0x00
 
 nop
 goto INITIAL
 
 delay MACRO num1, num2
 local LOOP1
 local LOOP2
 movlw num2
 movwf L2
 LOOP2:
    movlw num1
    movwf L1
    LOOP1:
	nop
	nop
	nop
	nop
	decfsz L1, 1
	goto LOOP1
    decfsz L2
    goto LOOP2
endm
    
ISR:
    org 0x08
    COMF flag, F
    bcf INTCON, INT0IF
    retfie
    
INITIAL:
    clrf PORTB
    clrf LATB
    clrf TRISB
    bsf TRISB, 0
    clrf TRISD
    clrf PORTD
    
    ;set up T0CON
    movlw b'11111000'
    movwf T0CON, 0
   
    ;set up external interrupt flag
    bsf RCON, IPEN
    bsf INTCON, GIE
    bsf INTCON, PEIE
    bsf INTCON, INT0IE 
    bcf INTCON2, RBPU
    bsf INTCON2, INTEDG0
    
    ;setting initial signal for RD0 and initial flag
    clrf flag
    bsf PORTD, 0, 0 
    
MAIN:
    BTFSS PORTD, 4
    goto cont2
    bcf PORTD, 4
    bsf PORTD, 7
cont2:
    RLNCF PORTD 
    delay d'200', d'90'
    BTFSS PORTD, 3
    goto cont
    bcf PORTD, 3
    bsf PORTD, 7
    
cont:
    BTFSS flag, 0
    goto MAIN
    
second:
    BTFSS PORTD, 7
    goto cont3
    bcf PORTD, 7
    bsf PORTD, 4
cont3:
    RRNCF PORTD 
    delay d'200', d'90'
    BTFSS PORTD, 0
    goto cont1
    bcf PORTD, 0
    bsf PORTD, 4
cont1:
    BTFSS flag, 0
    goto MAIN
    goto second
end






