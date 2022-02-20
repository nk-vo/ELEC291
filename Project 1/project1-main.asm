$NOLIST
$MODLP51
$LIST

org 0000H
	ljmp MyProgram
	
	;Timer / Counter 0 overflow interrupt vector
org 0x000B
	ljmp Timer0_ISR

dseg at 0x30
	x: ds 4
	y: ds 4
	bcd: ds 5
	Seed: ds 4
	Period_1: ds 2
	Period_2: ds 2
	BCD_player1left_score: ds 1   ;will need to decimal adjust these with da before putting on lcd
	BCD_player2right_score: ds 1
	
BSEG
	mf: dbit 1
	toneflag: dbit 1
	rightcap_pressed: dbit 1
	leftcap_pressed: dbit 1
	
cseg
	; These 'equ' must match the hardware wiring
	LCD_RS equ P3.2
	;LCD_RW equ PX.X ; Not used in this code, connect the pin to GND
	LCD_E equ P3.3
	LCD_D4 equ P3.4
	LCD_D5 equ P3.5
	LCD_D6 equ P3.6
	LCD_D7 equ P3.7
	
	SEEDBUTTON equ p2.4
	SOUND_OUT equ p1.1
	
	;these input pins on AT89 are connected to output pins of the 555 timers
	;those output pins are putting out a
	INPIN1 equ p2.1              ;player1 aka left side
	INPIN2 equ p2.0              ;player2 aka right side

	;these are the reload rates that ill need to get 2khz and 2.1khz
	CLK EQU 22118400             ; Microcontroller system crystal frequency in Hz
	TIMER0_RATE0 EQU ((2048 * 2) + 100)
	TIMER0_RATE1 EQU ((2048 * 2) - 100)
	TIMER0_RELOAD0 EQU ((65536 - (CLK / TIMER0_RATE0))) ; for 2.1kHz signal (first capacitor to connect wins a point)
	TIMER0_RELOAD1 EQU ((65536 - (CLK / TIMER0_RATE1))) ; for 2kHz signal (first capacitor to connect loses a point)
	

$NOLIST
$include(LCD_4bit.inc)       ; A library of LCD related functions and utility macros
$LIST
	
	
$NOLIST
$include(math32.inc)
$LIST
	
	; 1234567890123456 < - This helps determine the location of the counter
	Initial_Message1: db 'Player 1:', 0
	Initial_Message2: db 'Player 2:', 0
	
	winmessage: db 'win', 0
	
	; - - - - - - - - - - - - FROM LAB 3 EXAMPLE CODE - - - - - - - - - - 
	; When using a 22.1184MHz crystal in fast mode
	; one cycle takes 1.0 / 22.1184MHz = 45.21123 ns
	; (tuned manually to get as close to 1s as possible)
Wait1s:
	mov R2, #176
X3: mov R1, #250
X2: mov R0, #166
X1: djnz R0, X1                ; 3 cycles - >3 * 45.21123ns * 166=22.51519us
	djnz R1, X2                  ; 22.51519us * 250=5.629ms
	djnz R2, X3                  ; 5.629ms * 176=1.0s (approximately)
	ret
	
	;Initializes timer / counter 2 as a 16 - bit COUNTER
InitTimer2_counter:
	mov T2CON, #0b_0000_0010     ; Stop timer / counter. Set as counter (clock input is pin T2)(probly not anymore).
	; Set the reload value on overflow to zero (just in case is not zero)
	mov RCAP2H, #0
	mov RCAP2L, #0
	;setb P1.0 ; P1.0 is connected to T2. Make sure it can be used as input.
	ret
	
	;Initializes timer / counter 2 as a 16 - bit TIMER
InitTimer2_timer:
	mov T2CON, #0b_0000_0000     ; Stop timer / counter. Set as timer (clock input is pin 22.1184MHz)
	; Set the reload value on overflow to zero (just in case is not zero)
	mov RCAP2H, #0
	mov RCAP2L, #0
	;setb P1.0 ; P1.0 is connected to T2. Make sure it can be used as input.
	ret
	
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;
	; Routine to initialize the ISR ;
	; for timer 0 ;
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;
InitTimer0:
	mov a, TMOD
	anl a, #0xf0                 ; 11110000 Clear the bits for timer 0
	orl a, #0x01                 ; 00000001 Configure timer 0 as 16 - timer
	mov TMOD, a
	mov TH0, #high(TIMER0_RELOAD1)
	mov TL0, #low(TIMER0_RELOAD1)
	; Set autoreload value
	mov RH0, #high(TIMER0_RELOAD1)
	mov RL0, #low(TIMER0_RELOAD1)
	; Enable the timer and interrupts
	setb ET0                     ; Enable timer 0 interrupt
	;setb TR0 ; Start timer 0
	clr TR0                      ; have TR0 at 0 at the start to stop alarm from ringing all the time, will activate later
	ret
	
	
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;
	; ISR for timer 0. Set to execute;
	; every 1 / 4096Hz to generate a ;
	; 2048 Hz square wave at pin P1.1 ;
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;
Timer0_ISR:
	cpl SOUND_OUT                ; Connect speaker to P1.1!
	reti
	
	; When using a 22.1184MHz crystal in fast mode
	; one cycle takes 1.0 / 22.1184MHz = 45.21123 ns
WaitHalfSec:
	mov R2, #89
LC: mov R1, #250
LB: mov R0, #166
LA: djnz R0, LA               	 ; 3 cycles - >3 * 45.21123ns * 166=22.51519us
	djnz R1, LB                  ; 22.51519us * 250=5.629ms
	djnz R2, LC                  ; 5.629ms * 89=0.5s (approximately)
	ret
	
	;Converts the hex number in TH2 - TL2 to BCD in R2 - R1 - R0 (STORES IT ACROSS THESE 3 REGISTERS)
hex2bcd3:
	clr a
	mov R0, #0                   ;Set BCD result to 00000000
	mov R1, #0
	mov R2, #0
	mov R3, #16                  ;Loop counter.
	
hex2bcd3_loop:
	mov a, TL2                   ;Shift TH0 - TL0 left through carry
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
	
	djnz R3, hex2bcd3_loop       ;DECREMENT R3 AND IF RESULT ISN'T 0 LOOP AGAIN, THIS IS USED LIKE i IN FOR LOOPS, ITS A LOOP COUNTER VARIABLE
	ret

	; Dumps the 5 - digit packed BCD number in R2 - R1 - R0 into the LCD
DisplayBCD_LCD:
	; 5th digit:
	mov a, R2
	anl a, #0FH
	orl a, #'0'                  ; convert to ASCII
	lcall ?WriteData
	; 4th digit:
	mov a, R1
	swap a
	anl a, #0FH
	orl a, #'0'                  ; convert to ASCII
	lcall ?WriteData
	; 3rd digit:
	mov a, R1
	anl a, #0FH
	orl a, #'0'                  ; convert to ASCII
	lcall ?WriteData
	; 2nd digit:
	mov a, R0
	swap a
	anl a, #0FH
	orl a, #'0'                  ; convert to ASCII
	lcall ?WriteData
	; 1st digit:
	mov a, R0
	anl a, #0FH
	orl a, #'0'                  ; convert to ASCII
	lcall ?WriteData
	
	ret
	
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;
	; Hardware initialization ;
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;
Initialize_All:
	lcall InitTimer2_timer
	lcall LCD_4BIT               ; Initialize LCD (NOTE THIS IS CONFUSING, LCD_4BIT IS THE NAME OF A MACRO WITHIN THE LCD_4bit.inc file, WE ARE CALLING THE MACRO HERE
	ret
	
Random:
	; perform this operation to get a new random number each time from our previous seed. Seed=214013 * Seed + 2531011
	mov x + 0, Seed + 0
	mov x + 1, Seed + 1
	mov x + 2, Seed + 2
	mov x + 3, Seed + 3
	Load_y(214013)
	lcall mul32
	Load_y(2531011)
	lcall add32
	mov Seed + 0, x + 0
	mov Seed + 1, x + 1
	mov Seed + 2, x + 2
	mov Seed + 3, x + 3
	ret
	
	
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;
	; Main program loop ;
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;
MyProgram:
	; Initialize the hardware:
	mov SP, #7FH
	lcall Initialize_All
	lcall InitTimer0
	lcall InitTimer2_timer
	; Make sure the two input pins are configured for input
	setb P2.0                    ; Pin is used as input
	setb P2.1                    ; Pin is used as input
	setb EA
	
	Set_Cursor(1, 1)
	Send_Constant_String(#Initial_Message1)
	Set_Cursor(2, 1)
	Send_Constant_String(#Initial_Message2)
	
	;display the initial point counts as zero here

	;code to get an initial seed by pressing SEEDBUTTON
	;run timer 2 as a timer and you randomly pause it and take the values stored in TH2 and TL2 as your actual first random number 'seed'
	;then do some math magic to make them a bit more random
	
	setb TR2                     ;start timer2
	jb SEEDBUTTON, $             ;wait for seedbutton to be pressed
	clr TR2                      ;stop timer2
	mov Seed + 0, TH2            ;put TH2 into lower byte of Seed
	mov Seed + 1, #0x01          ;this and one below are arbitrary filler numbers
	mov Seed + 2, #0x87
	mov Seed + 3, TL2
	
	;lcall InitTimer2_counter
	lcall InitTimer2_timer
	
	;dunno if need this
	setb TR2
	
	Set_Cursor(2, 12)
	mov a, #0x0
	;da a ;the decimal adjust was messing it up for some reason
	mov BCD_player2right_score, a
	Display_BCD(BCD_player2right_score)
	
	Set_Cursor(1, 12)
	mov a, #0x0
	;da a
	mov BCD_player1left_score, a
	Display_BCD(BCD_player1left_score)

forever:
	;clr rightcap_pressed and leftcap_pressed
	clr rightcap_pressed
	clr leftcap_pressed
	
	Set_Cursor(1, 15)
	WriteData(#'S')
	
	;randomly choose btwn TIMER0_RELOAD1 and TIMER0_RELOAD0 to put into RH0 and RL0
	;call random and generate a random number from our seed and use that to choose btwn TIMER0_RELOAD1 and TIMER0_RELOAD0
	
	lcall Random
	mov a, Seed + 1
	mov c, acc.3                 ;using the carry flag to store the bit here just so we can use the jc instruction
	mov toneflag, c              ;store which tone i picked in a flag (0=tone0, 1=tone1) bc carry flag can be altered by things
	jc tone1                     ;branch to tone1 if the carry flag is set, otherwise continue and execute tone0 (2.1khz aka TIMER0_RELOAD0 aka first capacitor to connect gets a point)
	;set RH0 and RLO
	mov RH0, #high(TIMER0_RELOAD0)
	mov RL0, #low(TIMER0_RELOAD0)
	ljmp skiptone1
	
tone1:
	mov RH0, #high(TIMER0_RELOAD1)
	mov RL0, #low(TIMER0_RELOAD1)

skiptone1:
	setb TR0                     ;sound the speaker
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	
	; Measure the period applied to pin P2.0 (right 555 timer)
	clr TR2                      ; Stop counter 2
	mov TL2, #0
	mov TH2, #0                  ; clear the counter
	jb P2.0, $
	jnb P2.0, $
	setb TR2                     ; Start counter 0
	jb P2.0, $                   ;loop until p2.0 is asserted
	jnb P2.0, $                  ;loop until p2.0 is not asserted (measure one cycle of the wave)
	clr TR2                      ; Stop counter 2, TH2 - TL2 has the period
	; save the period of P2.0 for later use
	mov Period_2 + 0, TL2
	mov Period_2 + 1, TH2
	
	;store period as a 32 bit number
	mov x + 0, TL2
	mov x + 1, TH2
	mov x + 2, #0                ;load high bits with zero
	mov x + 3, #0                ;load high bits with zero
	
	Load_y(5000)
	;Load_y(6000)
	
	lcall x_gt_y                 ; if x>y set mf=1
	
	jnb mf, skipy                ;branch to skipy if mf is 0
	;set flag for capacitor pressed here
	setb rightcap_pressed
	clr tr0                      ;turn off speaker ie. clr tr0
	Set_Cursor(2, 16)
	WriteData(#'A')
	
skipy:
	; Measure the period applied to pin P2.1 (left 555 timer)
	
	clr TR2                      ; Stop counter 2
	mov TL2, #0
	mov TH2, #0
	jb P2.1, $
	jnb P2.1, $
	setb TR2                     ; Start counter 0
	jb P2.1, $
	jnb P2.1, $
	clr TR2                      ; Stop counter 2, TH2 - TL2 has the period
	; save the period of P2.1 for later use
	mov Period_1 + 0, TL2
	mov Period_1 + 1, TH2
	
	;store period as a 32 bit number
	mov x + 0, TL2
	mov x + 1, TH2
	mov x + 2, #0                ;load high bits with zero
	mov x + 3, #0                ;load high bits with zero
	
	Load_y(5000)
	;Load_y(6000)
	
	lcall x_gt_y                 ; if x>y set mf=1
	
	jnb mf, skipy2               ;branch to skipy if mf is 0
	;set flag for capacitor pressed here
	setb leftcap_pressed
	clr tr0                      ;turn off speaker ie. clr tr0
	Set_Cursor(1, 16)
	WriteData(#'B')
	
skipy2:
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	
	; tone0 (incrementing point tone) stuff
	jb toneflag, labelz          ;continue executing if toneflag=0, if toneflag=1 skip to labelz.
	jnb leftcap_pressed, labelz_1;if left side hit ie if leftcap_pressed=1 continue executing, otherwise branch
	;if BCD_player1left_score = 4, display player 1 wins
	;if BCD_player1left_score not !=4, 
	mov a, BCD_player1left_score
	cjne a, #0x04, cont1         ;jump to cont1 if a is not 5
	Set_Cursor(1, 9)
	Send_Constant_String(#winmessage)
	lcall wait1s
	lcall wait1s
	lcall wait1s
	lcall wait1s
	lcall wait1s
cont1:
	inc BCD_player1left_score
	;ljmp forever ; this should jump to the bottom to display the scores instead of to forever
	ljmp labelky
	
	;if right side hit
labelz_1:                     ;skip flag for which side hit for tone 0
	jnb rightcap_pressed, labelz ;if rightcap pressed continue executing, if neither cap pressed just skip
	mov a, BCD_player2right_score
	cjne a, #0x04, cont3         ;jump to cont3 if a is not 5
	Set_Cursor(2, 9)
	Send_Constant_String(#winmessage)
	lcall wait1s
	lcall wait1s
	lcall wait1s
	lcall wait1s
	lcall wait1s
cont3:
	inc BCD_player2right_score
	;ljmp forever
	ljmp labelky
	
labelz:                       ;skip flag for tone type
	
	; tone1 (decrementing point tone) stuff
	jnb toneflag, labelky        ;continue executing if toneflag=1
	jnb leftcap_pressed, labelz_2
	;if BCD_player1left_score = 0 then jump to labelky
	;mov x + 0, BCD_player1left_score
	;mov x + 1, #0
	;mov x + 2, #0
	;mov x + 3, #0
	;Load_y(0)
	;lcall x_eq_y ;mf=1 if x=0
	;jnb mf, labelky ;branch to labelky if mf=0
	mov a, BCD_player1left_score
	cjne a, #0x0, cont           ;jump to cont if a is not 0
	ljmp labelky
cont:
	dec BCD_player1left_score    ;include what to do if score is 0
	;ljmp forever
	ljmp labelky
	
labelz_2:
	jnb rightcap_pressed, labelky
	mov a, BCD_player2right_score
	cjne a, #0x0, cont2          ;jump to cont2 if a is not 0
	ljmp labelky
cont2:
	dec BCD_player2right_score
	;ljmp forever
	
labelky:
	;clr the cap pressed flags here?
	
	;DISPLAY UDPATED SCORES (dont use the display bcd function i made in this file, us the one from the lcd include)
	Set_Cursor(1, 12)
	;clr a
	mov a, BCD_player1left_score
	;da a ;decimal adjust was screwing things up here too, don't use it
	mov BCD_player1left_score, a
	Display_BCD(BCD_player1left_score)
	;if BCD_player1left_score = 5, display player 1 wins instead
	
	Set_Cursor(2, 12)
	;clr a
	mov a, BCD_player2right_score
	;da a
	mov BCD_player2right_score, a
	Display_BCD(BCD_player2right_score)
	;if BCD_player2right_score = 5, display player 2 wins instead
	
	lcall wait1s
	lcall wait1s
	lcall wait1s
	
	ljmp forever                 ; Repeat!
end
