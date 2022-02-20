$NOLIST
$MODLP51
$LIST

org 0000H
	ljmp MyProgram
	
	;Timer / Counter 0 overflow interrupt vector
org 0x000B
	ljmp Timer0_ISR
	;Timer / Counter 1 overflow interrupt vector
org 0x001B
	ljmp Timer1_ISR

dseg at 0x30
	x: ds 4
	y: ds 4
	bcd: ds 5
	Seed: ds 4
	Period_1: ds 2
	Period_2: ds 2
	BCD_player1left_score: ds 1   ;will need to decimal adjust these with da before putting on lcd
	BCD_player2right_score: ds 1
	DecimalCounter: ds 2
	CountMs: ds 2
	SecondsCounter: ds 1
	
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
	TIMER1_RATE   EQU 1000     ; 1000Hz, for a timer tick of 1ms
	TIMER1_RELOAD EQU ((65536-(CLK/TIMER1_RATE)))
	

$NOLIST
$include(LCD_4bit.inc)       ; A library of LCD related functions and utility macros
$LIST
	
	
$NOLIST
$include(math32.inc)
$LIST
	
	;					  1234567890123456 < - This helps determine the location of the counter
	ScoreMessage1: db 'Player 1:       ', 0
	ScoreMessage2: db 'Player 2:       ', 0
	;				   1234567890123456
	WrongMessage1: db 'Player 1 -1     ', 0
	WrongMessage2: db 'Player 2 -1     ', 0
	;				   1234567890123456
	RightMessage1: db 'Player 1 +1     ', 0
	RightMessage2: db 'Player 2 +1     ', 0
	;				 1234567890123456
	TimeMessage: db 'Time:           ', 0
	RoundMessage: db 'Play now       ', 0
	;				         1234567890123456
	NoCapPressedMessage: db 'Round Over      ', 0
	;				 1234567890123456
	winmessage1: db 'Player 1 won!   ', 0
	winmessage2: db 'Player 2 won!   ', 0
	
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

Timer1_Init:
	mov a, TMOD
	anl a, #0x0f ; Clear the bits for timer 1
	orl a, #0b00010000 ; Configure timer 0 as 16-timer
	mov TMOD, a
	mov TH1, #high(TIMER1_RELOAD)
	mov TL1, #low(TIMER1_RELOAD)
	; Set autoreload value
	mov RH1, #high(TIMER1_RELOAD)
	mov RL1, #low(TIMER1_RELOAD)
	; Enable the timer and interrupts
    setb ET1 ; Enable timer 0 interrupt
	clr TR1 ; Do not want it on to start
	ret

Timer1_ISR:

	push acc
	clr TF1

	inc CountMs+0    ; Increment the low 8-bits first
	mov a, CountMs+0 ; If the low 8-bits overflow, then increment high 8-bits
	jnz CountMsOF
	inc CountMs+1


CountMSOF:
	mov a, CountMs+0
	cjne a, #low(1000), BCDCounters ; Warning: this instruction changes the carry flag!
	mov a, CountMs+1
	cjne a, #high(1000), BCDCounters

	mov CountMS+0, #0x00
	mov CountMS+1, #0x00

	inc SecondsCounter
	mov a, SecondsCounter
	cjne a, #(1), Not1Second
	clr TR0

Not1Second:
	mov a, SecondsCounter
	cjne a, #(5), BCDCounters
	mov SecondsCounter, #0x00
	Set_Cursor(1,1)
	Send_Constant_String(#NoCapPressedMessage)
	mov CountMS+0, #0x00
	mov CountMS+0, #0x00
	mov DecimalCounter+0, #0x00
	mov DecimalCounter+0, #0x00

	lcall wait1s
	lcall wait1s
	lcall wait1s
	ljmp StartRound

BCDCounters:

	mov a, DecimalCounter
	add a, #0x01
	mov DecimalCounter, a

	xrl a, #0b10011010 ;XOR with 100. If a = 100 ,will set the value 0 in a
	jnz INC_done
	mov DecimalCounter, #0x00


	mov a, DecimalCounter+1
	inc a
	mov DecimalCounter+1, a
	xrl a, #0b10011010
	jnz INC_done

	mov DecimalCounter+1, #0x00

Inc_Done:

	mov a, DecimalCounter
	da a
	mov DecimalCounter, a
	mov a, DecimalCounter+1
	da a
	mov DecimalCounter+1, a

	pop acc
	reti
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
	lcall LCD_4BIT
	; Make sure the two input pins are configured for input
	setb P2.0                    ; Pin is used as input
	setb P2.1                    ; Pin is used as input
	setb EA
	
	Set_Cursor(1, 1)
	Send_Constant_String(#ScoreMessage1)
	Set_Cursor(2, 1)
	Send_Constant_String(#ScoreMessage2)
	
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
	lcall Timer1_Init
	
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

StartRound:

	Set_Cursor(1,1)
	Send_Constant_String(#RoundMessage)

	lcall Random
	mov a, Seed + 1
	mov c, acc.3                 ;using the carry flag to store the bit here just so we can use the jc instruction
	mov toneflag, c              ;store which tone i picked in a flag (0=tone0, 1=tone1) bc carry flag can be altered by things
	jc tone1                     ;branch to tone1 if the carry flag is set, otherwise continue and execute tone0 (2.1khz aka TIMER0_RELOAD0 aka first capacitor to connect gets a point)
	;set RH0 and RLO
	mov RH0, #high(TIMER0_RELOAD0)
	mov RL0, #low(TIMER0_RELOAD0)
	sjmp skiptone1
	
tone1:
	mov RH0, #high(TIMER0_RELOAD1)
	mov RL0, #low(TIMER0_RELOAD1)

skiptone1:
	setb TR0                     ;sound the speaker
	setb TR1 ; Start timer1 for timekeeping purpooses
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	

CheckRightCap:
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
	
	jnb mf, CheckLeftCap                ;branch to check left capacitor if mf is 0
	;set flag for capacitor pressed here
	setb rightcap_pressed

	ljmp CapPressed
	
CheckLeftCap:
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
	
	jnb mf, CheckRightCap               ;Keep checking until a capacitor is pressed or round ends
	;set flag for capacitor pressed here
	setb leftcap_pressed


CapPressed:
	clr tr0
	clr TR1

	Set_Cursor(2,1)
	Send_Constant_String(#TimeMessage)
	Set_Cursor(2,7)
	Display_BCD(DecimalCounter+1)
	Set_Cursor(2,9)
	Display_BCD(DecimalCounter+0)

	jnb leftcap_pressed, LeftPressedLabel
	ljmp RightPressedLabel

LeftPressedLabel:
	clr leftcap_pressed

	jnb toneflag, LeftWrong

	; Left Got it right
	Set_Cursor(1,1)
	Send_Constant_String(#RightMessage1)

	lcall wait1s
	lcall wait1s
	lcall wait1s

	mov a, BCD_player1left_score
	cjne a, #0x05, IncP1Score           ;jump to inc if a is not 5

	Set_Cursor(1,1)
	Send_Constant_String(#winmessage1)

	mov BCD_player1left_score, #0x00
	mov BCD_player2right_score, #0x00

	lcall wait1s
	lcall wait1s
	lcall wait1s

	ljmp StartRound

IncP1Score:
	inc BCD_player1left_score
	ljmp DisplayScore

LeftWrong:
	Set_Cursor(1,1)
	Send_Constant_String(#WrongMessage1)

	lcall wait1s
	lcall wait1s
	lcall wait1s

	mov a, BCD_player1left_score
	cjne a, #0x0, DecP1Score           ;Dec if a is not 0
	ljmp DisplayScore
DecP1Score:
	dec BCD_player1left_score
	ljmp DisplayScore

RightPressedLabel:
	clr rightcap_pressed

	jnb toneflag, RightWrong

	; Left Got it right
	Set_Cursor(1,1)
	Send_Constant_String(#RightMessage2)

	lcall wait1s
	lcall wait1s
	lcall wait1s

	mov a, BCD_player2right_score
	cjne a, #0x05, IncP2Score           ;jump to inc if a is not 5

	Set_Cursor(1,1)
	Send_Constant_String(#winmessage2)

	mov BCD_player1left_score, #0x00
	mov BCD_player2right_score, #0x00

	lcall wait1s
	lcall wait1s
	lcall wait1s
	ljmp StartRound

IncP2Score:
	inc BCD_player2right_score
	ljmp DisplayScore

RightWrong:
	Set_Cursor(1,1)
	Send_Constant_String(#WrongMessage2)

	lcall wait1s
	lcall wait1s
	lcall wait1s

	mov a, BCD_player2right_score
	cjne a, #0x0, DecP2Score           ;Dec if a is not 0
	ljmp DisplayScore

DecP2Score:
	dec BCD_player2right_score
	ljmp DisplayScore

DisplayScore:

	Set_Cursor(1,1)
	Send_Constant_String(#ScoreMessage1)
	Set_Cursor(2,1)
	Send_Constant_String(#ScoreMessage2)

	Set_Cursor(1,10)
	Display_BCD(BCD_player1left_score)
	Set_Cursor(2,10)
	Display_BCD(BCD_player2right_score)


	ljmp StartRound
end