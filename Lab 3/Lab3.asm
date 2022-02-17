$NOLIST
$MODLP51
$LIST

org 0000H
    ljmp MyProgram
org 0x002B
    ljmp Timer2_ISR
DSEG at 30H
x: ds 4
y: ds 4
bcd: ds 5

BSEG
mf:dbit 1

cseg
; These 'equ' must match the hardware wiring
LCD_RS equ P3.2
;LCD_RW equ PX.X ; Not used in this code, connect the pin to GND
LCD_E  equ P3.3
LCD_D4 equ P3.4
LCD_D5 equ P3.5
LCD_D6 equ P3.6
LCD_D7 equ P3.7
ToggleUnitnF equ P4.5
ToggleUnitpF equ P2.5

$NOLIST
$include(LCD_4bit.inc) ; A library of LCD related functions and utility macros
$include(math32.inc)
$LIST

; In the 8051 we can define direct access variables starting at location 0x30 up to location 0x7F
dseg at 0x30
Timer2_overflow: ds 1 ; 8-bit overflow to measure the frequency of fast signals (over 65535Hz)
Counter: ds 2
Counter1: ds 2

cseg
;                     1234567890123456    <- This helps determine the location of the counter
Initial_Message:  db 'Capacitance (uF): ', 0
Unit_Message: db 'Capacitance (nF): ', 0
Unit_Message2: db 'Capacitance (pF): ', 0

; When using a 22.1184MHz crystal in fast mode
; one cycle takes 1.0/22.1184MHz = 45.21123 ns
; (tuned manually to get as close to 1s as possible)
Wait1s:
    mov R2, #176
X3: mov R1, #250
X2: mov R0, #166
X1: djnz R0, X1 ; 3 cycles->3*45.21123ns*166=22.51519us
    djnz R1, X2 ; 22.51519us*250=5.629ms
    djnz R2, X3 ; 5.629ms*176=1.0s (approximately)
    ret

; Sends 10-digit BCD number in bcd to the LCD
Display_10_digit_BCD:
	Display_BCD(bcd+4)
	Display_BCD(bcd+3)
	Display_BCD(bcd+2)
	Display_BCD(bcd+1)
	Display_BCD(bcd+0)
	ret

;Initializes timer/counter 2 as a 16-bit counter
InitTimer2:
	mov T2CON, #0b_0000_0010 ; Stop timer/counter.  Set as counter (clock input is pin T2).
	; Set the reload value on overflow to zero (just in case is not zero)
	mov RCAP2H, #0
	mov RCAP2L, #0
    setb P1.0 ; P1.0 is connected to T2.  Make sure it can be used as input.
    ret

Timer2_ISR:
    clr TF2
    inc Timer2_overflow
    reti

;---------------------------------;
; Hardware initialization         ;
;---------------------------------;
Initialize_All:
    lcall InitTimer2
    lcall LCD_4BIT ; Initialize LCD
	ret

;---------------------------------;
; Main program loop               ;
;---------------------------------;
MyProgram:
    ; Initialize the hardware:
    mov SP, #7FH
    lcall Initialize_All

	Set_Cursor(1, 1)
    Send_Constant_String(#Initial_Message)
    
    
forever:
    ; Measure the frequency applied to pin T2
    clr TR2 ; Stop counter 2
    clr a
    mov TL2, a
    mov TH2, a
    mov Timer2_overflow, a
    clr TF2
    setb TR2 ; Start counter 2
    lcall Wait1s ; Wait one second
    clr TR2 ; Stop counter 2, TH2-TL2 has the frequency

    mov x+0, TL2
    mov x+1, TH2
    mov x+2, #0
    mov x+3, #0
    
    mov a, TL2
    orl a, TH2
    Load_y(3000)
    lcall mul32
    lcall copy_xy
    Load_X(14400000000)
    lcall div32

    ;nF conversion
    jb ToggleUnitnF, Case1
    Set_Cursor(1, 1)
    Send_Constant_String(#Unit_Message)
    Load_y(1000)
    lcall mul32
    sjmp Default

Case1:
    ;pF conversion
    jb ToggleUnitpF, Case
    Set_Cursor(1, 1)
    Send_Constant_String(#Unit_Message2)
    Load_y(1000000)
    lcall mul32
    sjmp Default

Case:
    Set_Cursor(1, 1)
    Send_Constant_String(#Initial_Message)

Default:
    Load_y(1000)
    lcall div32

	; Convert the result to BCD and display on LCD
	Set_Cursor(2, 1)
	lcall hex2bcd
    lcall Display_10_digit_BCD
    ljmp forever ; Repeat! 
end
