$NOLIST
$MOD52
$LIST

org 0000H
   ljmp MyProgram

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
$include(LCD_4bit_MS.inc) ; A library of LCD related functions and utility macros
$LIST

;                     1234567890123456    <- This helps determine the location of the counter
Initial_Message:  db 'Frequency (Hz): ', 0


; When using a 22.1184MHz crystal in the 8052
; one cycle takes 12.0/22.1184MHz = 542.5 ns
Wait1s:
    mov R2, #100
X3: mov R1, #99
X2: mov R0, #93
X1: djnz R0, X1 ; 2 cycles->2*542.5ns*93=100.9us
    djnz R1, X2 ; 100.9us*99=9.99ms
    djnz R2, X3 ; 9.99ms*100=1.0s (approximately)
    ret

;Initializes timer/counter 2 as a 16-bit counter
InitTimer2x:
	mov T2CON, #0b_0000_0010 ; Stop timer/counter.  Set as counter (clock input is pin T2).
	; Set the reload value on overflow to zero (just in case is not zero)
	mov RCAP2H, #0
	mov RCAP2L, #0
    setb P1.0 ; P1.0 is connected to T2.  Make sure it can be used as input.
    ret

;Initializes timer/counter 2 as a 16-bit timer
InitTimer2:
	mov T2CON, #0b_0000_0000 ; Stop timer/counter.  Set as timer (clock input is pin 22.1184MHz).
	; Set the reload value on overflow to zero (just in case is not zero)
	mov RCAP2H, #0
	mov RCAP2L, #0
    ret

;Converts the hex number in TH2-TL2 to BCD in R2-R1-R0
hex2bcd:
	clr a
    mov R0, #0  ;Set BCD result to 00000000 
    mov R1, #0
    mov R2, #0
    mov R3, #16 ;Loop counter.

hex2bcd_loop:
    mov a, TL2 ;Shift TH0-TL0 left through carry
    rlc a
    mov TL2, a
    
    mov a, TH2
    rlc a
    mov TH2, a
      
	; Perform bcd + bcd + carry
	; using BCD numbers
	mov a, R0
	addc a, R0
	da a
	mov R0, a
	
	mov a, R1
	addc a, R1
	da a
	mov R1, a
	
	mov a, R2
	addc a, R2
	da a
	mov R2, a
	
	djnz R3, hex2bcd_loop
	ret

; Dumps the 5-digit packed BCD number in R2-R1-R0 into the LCD
DisplayBCD_LCD:
	; 5th digit:
    mov a, R2
    anl a, #0FH
    orl a, #'0' ; convert to ASCII
	lcall ?WriteData
	; 4th digit:
    mov a, R1
    swap a
    anl a, #0FH
    orl a, #'0' ; convert to ASCII
	lcall ?WriteData
	; 3rd digit:
    mov a, R1
    anl a, #0FH
    orl a, #'0' ; convert to ASCII
	lcall ?WriteData
	; 2nd digit:
    mov a, R0
    swap a
    anl a, #0FH
    orl a, #'0' ; convert to ASCII
	lcall ?WriteData
	; 1st digit:
    mov a, R0
    anl a, #0FH
    orl a, #'0' ; convert to ASCII
	lcall ?WriteData
    
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

	Set_Cursor(1, 1)
    Send_Constant_String(#Initial_Message)
    
forever:
    ; Measure the frequency applied to pin T2
    clr TR2 ; Stop counter 2
    clr a
    mov TL2, a
    mov TH2, a
    clr TF2
    setb TR2 ; Start counter 2
    lcall Wait1s ; Wait one second
    clr TR2 ; Stop counter 2, TH2-TL2 has the frequency

	; Convert the result to BCD and display on LCD
	Set_Cursor(2, 1)
	lcall hex2bcd
    lcall DisplayBCD_LCD
    sjmp forever ; Repeat! 
end
