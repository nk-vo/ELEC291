$NOLIST
$MODLP51
$LIST

START_BUTTON   	equ P0.0
P1_BUTTON		equ	P2.4
P2_BUTTON	    equ	P2.6
RESTART_BUTTON  equ P2.0

CLK           EQU 22118400 
TIMER0_RATE   EQU 4096     ; 2048Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD EQU ((65536-(CLK/TIMER0_RATE)))
TIMER2_RATE   EQU 1000     ; 1000Hz, for a timer tick of 1ms
TIMER2_RELOAD EQU ((65536-(CLK/TIMER2_RATE)))

org 0000H
    ljmp MyProgram
;org 0x000B
;    ljmp Timer0_ISR
;org 0x001B
;    ljmp Timer1_ISR
org 0x002B
    ljmp Timer2_ISR

DSEG at 30H
x: ds 4
y: ds 4
bcd: ds 5
Seed: ds 4
T2ov: ds 2
T1ov: ds 2
T0ov: ds 0
p1_point: ds 1
p2_point: ds 1

BSEG
mf: dbit 1
tone: dbit 1
wait: dbit 1
update_score: dbit 1

cseg
; These 'equ' must match the hardware wiring
LCD_RS equ P3.2
;LCD_RW equ PX.X ; Not used in this code, connect the pin to GND
LCD_E  equ P3.3
LCD_D4 equ P3.4
LCD_D5 equ P3.5
LCD_D6 equ P3.6
LCD_D7 equ P3.7
SOUND_OUT equ P1.1

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
Initial_Message_Top:    db 'Player1:          ', 0
Initial_Message_Bottom: db 'Player2:          ', 0

Player1_Win:    db 'Winner!', 0
Player1_Lose:   db 'Loser!', 0
Player2_Win:    db 'Winner!', 0
Player2_Lose:   db 'Loser!', 0
Play_again:     db 'Play again?', 0
Clear:          db '                ', 0
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
Random:
    mov x+0, Seed+0
    mov x+1, Seed+1
    mov x+2, Seed+2
    mov x+3, Seed+3
    Load_y(214013)
    lcall mul32
    Load_y(2451011)
    lcall add32
    mov Seed+0, x+0
    mov Seed+1, x+1
    mov Seed+2, x+2
    mov Seed+3, x+3
    ret
Wait_random:
    Wait_Milli_Seconds(Seed+0)
    Wait_Milli_Seconds(Seed+1)
    Wait_Milli_Seconds(Seed+2)
    Wait_Milli_Seconds(Seed+3)
    ret

; Sends 10-digit BCD number in bcd to the LCD
Display_10_digit_BCD:
	Display_BCD(bcd+4)
	Display_BCD(bcd+3)
	Display_BCD(bcd+2)
	Display_BCD(bcd+1)
	Display_BCD(bcd+0)
	ret

InitTimer0:
    mov a, TMOD
    anl a, #0x00
    orl a, #0x01
    mov TMOD, a
    setb ET0
    ; disable timer
    clr TR0
    ret

;Timer0_ISR:
;    push acc
;    push psw
;    jb Wait, Wait_Period
;    cpl Sound_Out
;    reti

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
    Send_Constant_String(#Initial_Message_Top)
    Set_Cursor(2, 1)
    Send_Constant_String(#Initial_Message_Bottom)

    setb TR2
    jb P4.5, $
    mov Seed+0, TH2
    mov Seed+1, #0x01
    mov Seed+2, #0x87
    mov Seed+3, TL2
    clr TR2

loop:
    Set_Cursor(1, 11)
    Display_BCD(p1_point)
    Set_Cursor(2, 11)
    Display_BCD(p2_point)
    cpl SOUND_OUT
    jb START_BUTTON, Start_Game
    Wait_Milli_Seconds(#50)
    jb START_BUTTON, Start_Game
    jnb START_BUTTON, $
    ljmp loop

Start_Game:
    lcall Random
    lcall Wait_random
    mov a, seed+1
    mov c, acc.3
    jc lose_sound
    ljmp win_sound

lose_sound:
    ljmp no_hit1
win_sound:
    ljmp hit1

hit1:
    jb P1_BUTTON, hit2
    Wait_Milli_Seconds(#50)
    jb P1_BUTTON, hit2
    jnb P1_BUTTON, $
    clr a
    mov a, p1_point
    add a, #0x01
    mov p2_point, a
    cjne a, #0x5, p1_win
    clr a
    ljmp Start_Game

p1_win:
    ljmp p1win

hit2:
    jb P2_BUTTON, hit1
    Wait_Milli_Seconds(#50)
    jb P2_BUTTON, hit1
    jnb P2_BUTTON, $
    clr a 
    mov a, p2_point
    add a, #0x01
    mov p2_point, a
    cjne a, #0x05, p2_win
    clr a
    ljmp Start_Game

p2_win:
    ljmp p2win

no_hit1:
    jb P1_BUTTON, no_hit2
    Wait_Milli_Seconds(#50)
    jb P1_BUTTON, no_hit2
    jnb P1_BUTTON, $
    clr a 
    mov a, p1_point
    cjne a, #0x00, Start_Game
    mov x, a
    Load_y(1)
    lcall sub32
    mov a, x
    da a
    mov p1_point, a
    clr a
    ljmp Start_Game

no_hit2:
    jb P2_BUTTON, no_hit1
    Wait_Milli_Seconds(#50)
    jb P2_BUTTON, no_hit1
    jnb P2_BUTTON, $
    clr a 
    mov a, p2_point
    cjne a, #0x00, start
    mov x, a
    Load_y(1)
    lcall sub32
    mov a, x
    da a
    mov p2_point, a
    clr a
    ljmp start

start:
    ljmp Start_Game

p1win:
    Set_Cursor(1, 9)
    Send_Constant_String(#Player1_Win)
    Set_Cursor(2,9)
    Send_Constant_String(#Player2_Lose)
    Wait_Milli_Seconds(#50)
    Set_Cursor(1, 1)
    Send_Constant_String(#Play_again)
    Set_Cursor(2, 1)
    Send_Constant_String(#Clear)
    jnb RESTART_BUTTON, p1w
    Wait_Milli_Seconds(#50)
    jnb RESTART_BUTTON, p1w
    jb RESTART_BUTTON, $
    ljmp restart
p1w:
    ljmp p1win
p2win:
    Set_Cursor(1, 9)
    Send_Constant_String(#Player2_Win)
    Set_Cursor(2,9)
    Send_Constant_String(#Player1_Lose)
    Wait_Milli_Seconds(#50)
    Set_Cursor(1, 1)
    Send_Constant_String(#Play_again)
    Set_Cursor(2, 1)
    Send_Constant_String(#Clear)
    jnb RESTART_BUTTON, p2w
    Wait_Milli_Seconds(#50)
    jnb RESTART_BUTTON, p2w
    jb RESTART_BUTTON, $
    ljmp restart
p2w:
    ljmp p2win
restart:
    mov p1_point, #0x00
    mov p2_point, #0x00
    ljmp Start_Game
end
