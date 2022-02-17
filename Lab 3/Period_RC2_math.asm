$NOLIST
$MODLP51
$LIST

org 0000H
   ljmp MyProgram

; These register definitions needed by 'math32.inc'
DSEG at 30H
x:   ds 4
y:   ds 4
bcd: ds 5

BSEG
mf: dbit 1

$NOLIST
$include(math32.inc)
$LIST

cseg
; These 'equ' must match the hardware wiring
LCD_RS equ P3.2
;LCD_RW equ PX.X ; Not used in this code, connect the pin to GND
LCD_E  equ P3.3
LCD_D4 equ P3.4
LCD_D5 equ P3.5
LCD_D6 equ P3.6
LCD_D7 equ P3.7

$NOLIST
$include(LCD_4bit.inc) ; A library of LCD related functions and utility macros
$LIST

;                     1234567890123456    <- This helps determine the location of the counter
Initial_Message:  db 'Frequency(Hz): ', 0
No_Signal_Str:    db 'No signal      ', 0

; Sends 10-digit BCD number in bcd to the LCD
Display_10_digit_BCD:
	Display_BCD(bcd+4)
	Display_BCD(bcd+3)
	Display_BCD(bcd+2)
	Display_BCD(bcd+1)
	Display_BCD(bcd+0)
	ret

;Initializes timer/counter 2 as a 16-bit timer
InitTimer2:
	mov T2CON, #0 ; Stop timer/counter.  Set as timer (clock input is pin 22.1184MHz).
	; Set the reload value on overflow to zero (just in case is not zero)
	mov RCAP2H, #0
	mov RCAP2L, #0
    ret

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
    setb P0.0 ; Pin is used as input

	Set_Cursor(1, 1)
    Send_Constant_String(#Initial_Message)
    
forever:
    ; synchronize with rising edge of the signal applied to pin P0.0
    clr TR2 ; Stop timer 2
    mov TL2, #0
    mov TH2, #0
    clr TF2
    setb TR2
synch1:
	jb TF2, no_signal ; If the timer overflows, we assume there is no signal
    jb P0.0, synch1
synch2:    
	jb TF2, no_signal
    jnb P0.0, synch2
    
    ; Measure the period of the signal applied to pin P0.0
    clr TR2
    mov TL2, #0
    mov TH2, #0
    clr TF2
    setb TR2 ; Start timer 2
measure1:
	jb TF2, no_signal
    jb P0.0, measure1
measure2:    
	jb TF2, no_signal
    jnb P0.0, measure2
    clr TR2 ; Stop timer 2, [TH2,TL2] * 45.21123ns is the period

	; Using integer math, convert the period to frequency:
	mov x+0, TL2
	mov x+1, TH2
	mov x+2, #0
	mov x+3, #0
	; Make sure [TH2,TL2]!=0
	mov a, TL2
	orl a, TH2
	jz no_signal
	Load_y(45211) ; One clock pulse is 45.21123ns
	lcall mul32
	Load_y(1000)
	lcall div32
	; Convert from ns to Hz
	lcall copy_xy
	Load_x(1000000000)
	lcall div32

	; Convert the result to BCD and display on LCD
	Set_Cursor(2, 1)
	lcall hex2bcd
	lcall Display_10_digit_BCD
    ljmp forever ; Repeat! 
    
no_signal:	
	Set_Cursor(2, 1)
    Send_Constant_String(#No_Signal_Str)
    ljmp forever ; Repeat! 

end
