; ISR_example.asm: a) Increments/decrements a BCD variable every half second using
; an ISR for timer 2; b) Generates a 2kHz square wave at pin P1.1 using
; an ISR for timer 0; and c) in the 'main' loop it displays the variable
; incremented/decremented using the ISR for timer 2 on the LCD.  Also resets it to 
; zero if the 'BOOT' pushbutton connected to P4.5 is pressed.
$NOLIST
$MODLP51
$LIST

; There is a couple of typos in MODLP51 in the definition of the timer 0/1 reload
; special function registers (SFRs), so:
TIMER0_RELOAD_L DATA 0xf2
TIMER1_RELOAD_L DATA 0xf3
TIMER0_RELOAD_H DATA 0xf4
TIMER1_RELOAD_H DATA 0xf5

CLK           EQU 22118400 ; Microcontroller system crystal frequency in Hz
TIMER0_RATE   EQU 338     ; 2048Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD EQU ((65536-(CLK/TIMER0_RATE)))
TIMER2_RATE   EQU 500     ; 1000Hz, for a timer tick of 1ms
TIMER2_RELOAD EQU ((65536-(CLK/TIMER2_RATE)))


; Reset vector
org 0x0000
    ljmp main

; External interrupt 0 vector (not used in this code)
org 0x0003
	reti

; Timer/Counter 0 overflow interrupt vector
org 0x000B
	ljmp Timer0_ISR

; External interrupt 1 vector (not used in this code)
org 0x0013
	reti

; Timer/Counter 1 overflow interrupt vector (not used in this code)
org 0x001B
	reti

; Serial port receive/transmit interrupt vector (not used in this code)
org 0x0023 
	reti
	
; Timer/Counter 2 overflow interrupt vector
org 0x002B
	ljmp Timer2_ISR

; In the 8051 we can define direct access variables starting at location 0x30 up to location 0x7F
dseg at 0x30
Count1ms:       ds 2 ; Used to determine when half second has passed
CLOCK_SECOND:   ds 1 ; The clock incremented in the ISR and displayed in the main loop
CLOCK_MINUTE:   ds 1 ;
CLOCK_HOUR:     ds 1 ;
CLOCK_AMPM:     ds 1 ; 0 for AM, 1 for PM
CLOCK_DAY:      ds 1 ; 0 starts on SUND
cursor_pos:     ds 1 ; position of edit cursor
count0ms:       ds 2 ; Used to determine when small amount of time has passed
; In the 8051 we have variables that are 1-bit in size.  We can use the setb, clr, jb, and jnb
; instructions with these variables.  This is how you define a 1-bit variable:
WE_ALARM_SECOND:       ds 1 ;
WE_ALARM_MINUTE:       ds 1 ;
WE_ALARM_HOUR:         ds 1 ;
WE_ALARM_AMPM:         ds 1 ;
WE_ALARM_DAY:          ds 1 ;

WD_ALARM_SECOND:       ds 1 ;
WD_ALARM_MINUTE:       ds 1 ;
WD_ALARM_HOUR:         ds 1 ;
WD_ALARM_AMPM:         ds 1 ;
WD_ALARM_DAY:          ds 1 ;
bseg
half_seconds_flag: dbit 1 ; Set to one in the ISR every time 500 ms had passed
blinky_flag:       dbit 1 ;
blink_time_flag:   dbit 1 ;

WE_ALARM_STATUS:   dbit 1 ;
WD_ALARM_STATUS:   dbit 1 ;
WE_ALARM_NUM:      dbit 1 ;
WD_ALARM_NUM:      dbit 1 ;

WE_ALARM_SECOND_F: dbit 1 ;
WE_ALARM_MINUTE_F: dbit 1 ;
WE_ALARM_HOUR_F:   dbit 1 ;
WD_ALARM_SECOND_F: dbit 1 ;
WD_ALARM_MINUTE_F: dbit 1 ;
WD_ALARM_HOUR_F:   dbit 1 ;

ALARM1_RING_FLAG:  dbit 1 ;
ALARM2_RING_FLAG:  dbit 1 ;

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
;Initial_Message:  db 'BCD_counter: xx ', 0
Initial_Message:  db 'Welcome!', 0
Template_Clock:	  db 'xx:xx:xx', 0
Boot:             db 'booting...', 0
Clock_String:	  db 'CLOCK', 0
Weekday_String:	  db 'WEEKDAY MODE', 0
Weekend_String:	  db 'WEEKEND MODE', 0
Sunday:           db 'SUNDAY    ', 0
Monday:           db 'MONDAY    ', 0
Tuesday:          db 'TUESDAY   ', 0
Wednesday:        db 'WEDNESDAY ', 0
Thursday:         db 'THURSDAY  ', 0
Friday:           db 'FRIDAY    ', 0
Saturday:         db 'SATURDAY  ', 0
AM:               db 'AM', 0
PM:               db 'PM', 0
b1:               db ' ', 0
bb:               db '  ', 0           ; attempt at making blank
bbday:            db '         ', 0
ON:               db 'Y', 0
OFF:              db 'N', 0
col:              db ':', 0
star:             db '*', 0
xx:               db 'xx', 0
AlarmError:       db 'Input Invalid!', 0
BootButton:       db 'BOOT to continue', 0
;---------------------------------;
; Routine to initialize the ISR   ;
; for timer 0                     ;
;---------------------------------;
Timer0_Init:
	mov a, TMOD
	anl a, #11110000B ; Clear the bits for timer 0
	orl a, #00000001B ; Configure timer 0 as 16-timer
	mov TMOD, a
	mov TH0, #high(TIMER0_RELOAD)
	mov TL0, #low(TIMER0_RELOAD)
	; Set autoreload value
	mov TIMER0_RELOAD_H, #high(TIMER0_RELOAD)
	mov TIMER0_RELOAD_L, #low(TIMER0_RELOAD)

	clr      a
  	mov    count0ms+0, a
  	mov    count0ms+1, a
	; Enable the timer and interrupts
	clr      TF0
    setb     ET0  ; Enable timer 0 interrupt

    ;setb TR0  ; Start timer 0
	ret

;---------------------------------;
; ISR for timer 0.  Set to execute;
; every 1/4096Hz to generate a    ;
; 2048 Hz square wave at pin P1.1 ;
;---------------------------------;
Timer0_ISR:
	;clr TF0  ; According to the data sheet this is done for us already.
  push   acc
  push   psw

  inc    Count0ms+0        ; Increment the low 8-bits first
	mov    a, Count0ms+0     ; If the low 8-bits overflow, then increment high 8-bits
	jnz    Timer0_Inc_Done
	inc    Count0ms+1

Timer0_Inc_Done:
  ; Check if half second has passed
  mov    a, Count0ms+0
  cjne   a, #low(100),    Timer0_ISR_done 	  ; Check if count(down) = 244
  mov    a, Count0ms+1					; Warning: this instruction changes the carry flag!
  cjne   a, #high(100),   Timer0_ISR_done	    ; Check if count(up) = 1

  setb   blink_time_flag                      ; otherwise, mark flag as done
  cpl    LED_OUT                              ; Connected LED to P3.6!
  ;clear the counter
  clr    a
  mov    count0ms+0, a
  mov    count0ms+1, a

Timer0_ISR_done:
  clr    TF0
  pop    psw
  pop    acc
  reti
;---------------------------------;
; Routine to initialize the ISR   ;
; for timer 2                     ;
;---------------------------------;
Timer2_Init:
	mov T2CON, #0 ; Stop timer/counter.  Autoreload mode.
	mov TH2, #high(TIMER2_RELOAD)
	mov TL2, #low(TIMER2_RELOAD)
	; Set the reload value
	mov RCAP2H, #high(TIMER2_RELOAD)
	mov RCAP2L, #low(TIMER2_RELOAD)
	; Init One millisecond interrupt counter.  It is a 16-bit variable made with two 8-bit parts
	clr a
	mov Count1ms+0, a
	mov Count1ms+1, a
	; Enable the timer and interrupts
    setb ET2  ; Enable timer 2 interrupt
    setb TR2  ; Enable timer 2
	ret

;---------------------------------;
; ISR for timer 2                 ;
;---------------------------------;
Timer2_ISR:
  clr  TF2  ; Timer 2 doesn't clear TF2 automatically. Do it in ISR
  ;cpl  P3.6 ; To check the interrupt rate with oscilloscope. It must be precisely a 1 ms pulse.
; The two registers used in the ISR must be saved in the stack
	push   acc
  push   psw

	; Increment the 16-bit one mili second counter
	inc    Count1ms+0        ; Increment the low 8-bits first
	mov    a, Count1ms+0     ; If the low 8-bits overflow, then increment high 8-bits
	jnz    Timer2_Inc_Done
	inc    Count1ms+1

Timer2_Inc_Done:
; Check if half second has passed
  mov    a, Count1ms+0
  cjne   a, #low(500),    Timer2_ISR_done_t 	 ; Check if count(down) = 244
  mov    a, Count1ms+1					; Warning: this instruction changes the carry flag!
  cjne   a, #high(500),   Timer2_ISR_done_t	   ; Check if count(up) = 1

; 500 milliseconds have passed.  Set a flag so knowthe main program knows
  setb   half_seconds_flag ; Let the main program  half second had passed
  ljmp   Timer1_ISR_check_flag1

Timer2_ISR_done_t:
  ljmp   Timer2_ISR_done
; check alarm first
Timer1_ISR_check_flag1:
  jnb    ALARM1_RING_FLAG,  Timer1_ISR_check_alarm1
  ljmp   Timer1_ISR_check_flag2                      ; if alarm is ringing, skip checking
  ; if alarm1 on, checks if alarm1 matches
Timer1_ISR_check_alarm1:
  jnb    WD_ALARM_STATUS,    Timer1_ISR_check_flag2   ; check if alarm1 is on
Timer1_ISR_alarm1_daycheck:
  mov    a, CLOCK_DAY
  Timer1_ISR_alarm1_daycheck_monday:
  cjne   a, #0x1,            Timer1_ISR_alarm1_daycheck_tuesday
  sjmp   Timer1_ISR_alarm1_ampmcheck
  Timer1_ISR_alarm1_daycheck_tuesday:
  cjne   a, #0x2,            Timer1_ISR_alarm1_daycheck_wednesday
  sjmp   Timer1_ISR_alarm1_ampmcheck
  Timer1_ISR_alarm1_daycheck_wednesday:
  cjne   a, #0x3,            Timer1_ISR_alarm1_daycheck_thursday
  sjmp   Timer1_ISR_alarm1_ampmcheck
  Timer1_ISR_alarm1_daycheck_thursday:
  cjne   a, #0x4,            Timer1_ISR_alarm1_daycheck_friday
  sjmp   Timer1_ISR_alarm1_ampmcheck
  Timer1_ISR_alarm1_daycheck_friday:
  cjne   a, #0x5,            Timer1_ISR_check_flag2   ; check if alarm1 day is monday - friday
Timer1_ISR_alarm1_ampmcheck:
  mov    a, CLOCK_AMPM
  cjne   a, WD_ALARM_AMPM,   Timer1_ISR_check_flag2   ; check if alarm1 ampm matches
Timer1_ISR_alarm1_hourcheck:
  mov    a, CLOCK_HOUR
  cjne   a, WD_ALARM_HOUR,   Timer1_ISR_check_flag2   ; check if alarm1 hour matches
Timer1_ISR_alarm1_minutecheck:
  mov    a, CLOCK_MINUTE
  cjne   a, WD_ALARM_MINUTE, Timer1_ISR_check_flag2   ; check if alarm1 minute matches
Timer1_ISR_alarm1_secondcheck:
  mov    a, CLOCK_SECOND
  cjne   a, WD_ALARM_SECOND, Timer1_ISR_check_flag2   ; check if alarm1 second matches
Timer1_ISR_setflag1:
  setb   ALARM1_RING_FLAG
  clr    SOUND_OUT

Timer1_ISR_check_flag2:
  jnb    ALARM2_RING_FLAG,  Timer1_ISR_check_alarm2
  sjmp   Timer1_ISR_done                     ; if alarm is ringing, skip checking
  ; checks if alarm2 matches
Timer1_ISR_check_alarm2:
  jnb    WE_ALARM_STATUS,    Timer1_ISR_done    ; check if alarm2 is on
Timer1_ISR_alarm2_daycheck:   ; daycheck still required
Timer1_ISR_alarm2_daycheck_saturday:
  cjne   a, #0x6,            Timer1_ISR_alarm2_daycheck_sunday
  sjmp   Timer1_ISR_alarm2_ampmcheck
Timer1_ISR_alarm2_daycheck_sunday:
  cjne   a, #0x0,            Timer1_ISR_done    ; check if alarm2 day is saturday/sunday
Timer1_ISR_alarm2_ampmcheck:
  mov    a, CLOCK_AMPM
  cjne   a, WE_ALARM_AMPM,   Timer1_ISR_done    ; check if alarm2 ampm matches
Timer1_ISR_alarm2_hourcheck:
  mov    a, CLOCK_HOUR
  cjne   a, WE_ALARM_HOUR,   Timer1_ISR_done    ; check if alarm2 hour matches
Timer1_ISR_alarm2_minutecheck:
  mov    a, CLOCK_MINUTE
  cjne   a, WE_ALARM_MINUTE, Timer1_ISR_done    ; check if alarm2 minute matches
Timer1_ISR_alarm2_secondcheck:
  mov    a, CLOCK_SECOND
  cjne   a, WE_ALARM_SECOND, Timer1_ISR_done    ; check if alarm2 second matches
Timer1_ISR_setflag2:
  setb   ALARM2_RING_FLAG
  clr    SOUND_OUT

Timer1_ISR_done:
  ; cpl    TR0 ; Enable/disable timer/counter0 . This line creates a beep-silence-beep-silence sound.
; Reset to zero the milli-seconds counter, it is a 16-bit variable
  clr    a
  mov    Count1ms+0, a
  mov    Count1ms+1, a
; Increment the BCD counters, check first though
  mov    a, CLOCK_SECOND
  cjne   a, #0x59,        Timer2_second_inc		; check if second will turn 60
  mov    a, #0							                  ; if true, reset seconds and add minute
  da     a

  mov    CLOCK_SECOND, a
  mov    a, CLOCK_MINUTE
  cjne   a, #0x59,        Timer2_minute_inc		; check if minute will turn 60
  mov    a, #0							                  ; if true, reset minute and add hour
  da     a
  mov    CLOCK_MINUTE, a

check_am:                                   ; if AM, allow to reach 12:xx
  mov    a, CLOCK_AMPM                        ; but change am -> pm
  cjne   a, #0x0,         not_am
  mov    a, CLOCK_HOUR
  cjne   a, #0x12,        Timer2_hour_inc	  	; AM: check if hour will turn 13
	mov    a, #0x1							                ; if true, reset hour to 1
  sjmp   do_ampm
  not_am:
  mov    a, CLOCK_HOUR
  cjne   a, #0x11,        Timer2_hour_inc     ; PM: check if hour will turn 12
  mov    a, #0x0                              ; if true, reset hour to 0
  do_ampm:
  da     a
  mov    CLOCK_HOUR, a

  mov    a, CLOCK_AMPM
	cjne   a, #0x1,         Timer2_ampm_inc	  	; check if already pm
	mov    a, #0x0							                ; if true, reset back to pm
	da     a
	mov    CLOCK_AMPM, a

  check_day:
  mov    a, CLOCK_DAY
	cjne   a, #0x6,         Timer2_day_inc	  	 ; check if already Saturday
	mov    a, #0x0							                 ; if true, reset back to Sunday
	da     a
	mov    CLOCK_DAY, a
	sjmp   Timer2_ISR_done

Timer2_hour_inc:
	mov    a, CLOCK_HOUR
	add    a, #0x01
  da     a                ; Decimal adjust instruction.  Check datasheet for more details!
	mov    CLOCK_HOUR, a
	sjmp   Timer2_ISR_done
Timer2_minute_inc:
  mov    a, CLOCK_MINUTE
  add    a, #0x01
  da     a 								; Decimal adjust instruction.  Check datasheet for more details!
  mov    CLOCK_MINUTE, a
  sjmp   Timer2_ISR_done
Timer2_second_inc:
  mov    a, CLOCK_SECOND
  add    a, #0x01
  da     a 								; Decimal adjust instruction.  Check datasheet for more details!
  mov    CLOCK_SECOND, a
  sjmp   Timer2_ISR_done
Timer2_ampm_inc:
	mov    a, CLOCK_AMPM
	add    a, #0x01
	da     a 								; Decimal adjust instruction.  Check datasheet for more details!
	mov    CLOCK_AMPM, a
	sjmp   Timer2_ISR_done
Timer2_day_inc:
  mov    a, CLOCK_DAY
  add    a, #0x01
  da     a 								; Decimal adjust instruction.  Check datasheet for more details!
  mov    CLOCK_DAY, a
Timer2_ISR_done:
	pop    psw
  pop    acc
  reti

clearscreen:
	push acc
	WriteCommand(#0x01)
	Wait_Milli_Seconds(#2)
	pop acc
	ret
LED_OUT       equ P0.1
BOOT_BUTTON   equ P4.5
SOUND_OUT     equ P1.1
MODE_BUTTON   equ P0.0
EDIT_BUTTON   equ P2.2
INCR_BUTTON   equ P2.0
SWITCH_BUTTON equ P0.2

; function that prints the default clock layout
clock_print_layout:
  Set_Cursor(  1 , 1  )
  Display_BCD(CLOCK_HOUR)  ; Macro located in 'LCD_4bit.inc'
  Set_Cursor(  1 , 4  )
  Display_BCD(CLOCK_MINUTE)
  Set_Cursor(  1 , 7  )
  Display_BCD(CLOCK_SECOND)
  Set_Cursor(  1 , 10  )
  mov   a, CLOCK_AMPM
  cjne  a, #0x0,       not_am_time
  Send_Constant_String(#AM)
  ljmp clock_show_day
not_am_time:
  Send_Constant_String(#PM)

; prints the clock day
clock_show_day:
  Set_Cursor(  2 , 1  )
  mov    a, CLOCK_DAY
  cjne   a, #0x0,         not_sunday
  Send_Constant_String(#Sunday)
  ret
  not_sunday:
  cjne   a, #0x1,         not_monday
  Send_Constant_String(#Monday)
  ret
  not_monday:
  cjne   a, #0x2,         not_tuesday
  Send_Constant_String(#Tuesday)
  ret
  not_tuesday:
  cjne   a, #0x3,         not_wednesday
  Send_Constant_String(#Wednesday)
  ret
  not_wednesday:
  cjne   a, #0x4,         not_thursday
  Send_Constant_String(#Thursday)
  ret
  not_thursday:
  cjne   a, #0x5,         not_friday
  Send_Constant_String(#Friday)
  ret
  not_friday:
  Send_Constant_String(#Saturday)
  ret

;---------------------------------;
; Main program. Includes hardware ;
; initialization and 'forever'    ;
; loop.                           ;
;---------------------------------;
main:
	; Initialization
  mov SP, #0x7F
  lcall Timer0_Init
  lcall Timer2_Init
  ; In case you decide to use the pins of P0, configure the port in bidirectional mode:
  mov P0M0, #0
  mov P0M1, #0
  setb EA   ; Enable Global interrupts
  lcall LCD_4BIT
  ; For convenience a few handy macros are included in 'LCD_4bit.inc':
	setb    half_seconds_flag
  setb    blink_time_flag


  mov     CLOCK_SECOND,       #0x0000
	mov     CLOCK_MINUTE,       #0x0059
	mov     CLOCK_HOUR,         #0x0011
  mov     CLOCK_DAY,          #0x0003
  mov     CLOCK_AMPM,         #0x0001

  mov     blinky_flag,        #0x0000

  mov     WE_ALARM_SECOND,    #0x0000
  mov     WE_ALARM_MINUTE,    #0x0000
  mov     WE_ALARM_HOUR,      #0x0000
  mov     WE_ALARM_AMPM,      #0x0000
  mov     WE_ALARM_DAY,       #0x0000

  mov     WD_ALARM_SECOND,    #0x0000
  mov     WD_ALARM_MINUTE,    #0x0000
  mov     WD_ALARM_HOUR,      #0x0000
  mov     WD_ALARM_AMPM,      #0x0000
  mov     WD_ALARM_DAY,       #0x0000

  clr     WE_ALARM_STATUS
  clr     WD_ALARM_STATUS
  clr     WE_ALARM_NUM
  clr     WD_ALARM_NUM

  clr     WE_ALARM_HOUR_F
  clr     WE_ALARM_MINUTE_F
  clr     WE_ALARM_SECOND_F
  clr     WD_ALARM_HOUR_F
  clr     WD_ALARM_MINUTE_F
  clr     WD_ALARM_SECOND_F

  clr     ALARM1_RING_FLAG
  clr     ALARM2_RING_FLAG

  mov     R5, #121
  clr     TR0

	

main_load:
    setb    TR2
    clr     TR0
    lcall   clearscreen
    Wait_Milli_Seconds(#100)
    Set_Cursor(  1 , 1  )
    Send_Constant_String(#Template_Clock)
    Set_Cursor(  2 , 1  )
    Send_Constant_String(#Boot)
main_loop:
  ; main loop begins
  main_alarm_check:
    jnb     ALARM1_RING_FLAG, main_alarm_check2
    ljmp    main_alarm_check_button
    main_alarm_check2:
    jnb     ALARM2_RING_FLAG, main_mode_check
    main_alarm_check_button:
    jb      BOOT_BUTTON, main_mode_check                ; if boot button is not pressed, end alarm check
    Wait_Milli_Seconds(#50)                   ; Debounce delay.
    jb      BOOT_BUTTON, main_mode_check                ; if boot button is not pressed, end alarm check
    jnb     BOOT_BUTTON, $                              ; if boot button pressed, wait til release
  main_alarm_power:
    clr     ALARM1_RING_FLAG
    clr     ALARM2_RING_FLAG
    setb     SOUND_OUT
  main_mode_check:
    jb      MODE_BUTTON,      main_edit_check   ; if mode button is not pressed, check edit
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb      MODE_BUTTON,      main_edit_check   ; if mode button is not pressed, check edit
    jnb     MODE_BUTTON,      $                 ; if mode button is pressed, wait til depress
    ljmp    alarm1_load
  main_edit_check:
    jb      EDIT_BUTTON,      main_loop_show    ; if edit button is not pressed, start display
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb      EDIT_BUTTON,      main_loop_show    ; if edit button is not pressed, start display
    jnb     EDIT_BUTTON,      $                 ; if edit button is pressed, wait til depress
    ljmp    main_edit
  ; redirects if not the second half of a minisecond
  main_loop_show:
    jnb     WD_ALARM_STATUS,   main_loop_noalarm1 ; check if alarm1 is on | rel: Alarm1 is off
    jnb     WE_ALARM_STATUS,   main_loop_alarm1   ; (Alarm1 on) check if alarm2 is on | rel: Alarm 2 is off
    ljmp    main_loop_alarm12                     ; Alarm 1 and 2 are on
    main_loop_noalarm1:
    jnb     WE_ALARM_STATUS,   main_loop_noalarms_t ; (Alarm1 off) check if alarm2 is on | No Alarms on
    ljmp    main_loop_alarm2                      ; (Alarm1 off) Alarm 2 is on

    main_loop_noalarms_t:
    ljmp    main_loop_noalarms

  ; only when alarm1 is on
  main_loop_alarm1:
    setb    TR0                                 ; Start TR0 to blink
    jb      blink_time_flag,   main_loop_alarm1_pass    ; if not the time, skip all
    ljmp    main_loop_alarm_done
    main_loop_alarm1_pass:
    clr     blink_time_flag
    jnb     blinky_flag,       main_loop_alarm1_blink
    ljmp    main_loop_alarm1_show
    main_loop_alarm1_blink:
    Set_Cursor(  2 , 15  )
    Send_Constant_String(#b1)
    Set_Cursor(  2 , 16  )
    Send_Constant_String(#b1)
    setb    blinky_flag
    ljmp    main_loop_alarm_done
    main_loop_alarm1_show:
    Set_Cursor(  2 , 15  )
    Send_Constant_String(#star)
    Set_Cursor(  2 , 16  )
    Send_Constant_String(#b1)
    clr     blinky_flag
    ljmp    main_loop_alarm_done

  ; only when alarm2 is on
  main_loop_alarm2:
    setb    TR0                                 ; Start TR0 to blink
    jb      blink_time_flag,   main_loop_alarm2_pass    ; if not the time, skip all
    ljmp    main_loop_alarm_done
    main_loop_alarm2_pass:
    clr     blink_time_flag
    jnb     blinky_flag,       main_loop_alarm2_blink
    ljmp    main_loop_alarm2_show
    main_loop_alarm2_blink:
    Set_Cursor(  2 , 15  )
    Send_Constant_String(#b1)
    Set_Cursor(  2 , 16  )
    Send_Constant_String(#b1)
    setb    blinky_flag
    ljmp    main_loop_alarm_done
    main_loop_alarm2_show:
    Set_Cursor(  2 , 15  )
    Send_Constant_String(#b1)
    Set_Cursor(  2 , 16  )
    Send_Constant_String(#star)
    clr     blinky_flag
    ljmp    main_loop_alarm_done

  ; when alarm1 and alarm2 is on
  main_loop_alarm12:
    setb    TR0                                 ; Start TR0 to blink
    jb      blink_time_flag,   main_loop_alarm12_pass    ; if not the time, skip all
    ljmp    main_loop_alarm_done
    main_loop_alarm12_pass:
    clr     blink_time_flag
    jnb     blinky_flag,       main_loop_alarm12_blink
    ljmp    main_loop_alarm12_show
    main_loop_alarm12_blink:
    Set_Cursor(  2 , 15  )
    Send_Constant_String(#b1)
    Set_Cursor(  2 , 16  )
    Send_Constant_String(#b1)
    setb    blinky_flag
    ljmp    main_loop_alarm_done
    main_loop_alarm12_show:
    Set_Cursor(  2 , 15  )
    Send_Constant_String(#star)
    Set_Cursor(  2 , 16  )
    Send_Constant_String(#star)
    clr     blinky_flag
    ljmp    main_loop_alarm_done

  ; when no alarms are on
  main_loop_noalarms:
    clr     TR0
    Set_Cursor(  2 , 15  )
    Send_Constant_String(#b1)
    Set_Cursor(  2 , 16  )
    Send_Constant_String(#b1)

  main_loop_alarm_done:
    jnb     half_seconds_flag, main_loop_t
    ljmp    main_halfsec_pass
    main_loop_t:
    ljmp    main_loop
  ; prints the clock hours, minutes, and seconds
  main_halfsec_pass:
    clr     half_seconds_flag                   ; Clear flag in the main loop
    lcall   clock_print_layout
    ljmp    main_loop

main_edit:
    setb    TR0
    clr     TR2
    mov     cursor_pos, #0x1                    ; reset cursor position to 1 (hour)
    lcall   clock_print_layout
medit_loop:
  ; use TR0 to check half seconds for blinky command
    jb      blink_time_flag, medit_halfsec_pass ; at every interval, blink/show
    ljmp    medit_show_done
  ; prints the clock hours, minutes, and seconds
  medit_halfsec_pass:
    clr     blink_time_flag                     ; Clear half second flag
    jnb     blinky_flag, medit_loop_blink       ; blinky_flag 0 means not yet disappear
    ljmp    medit_loop_show                     ; blinky_flag 1 means already disappear
  ; causes disappearing display of the LCD being targeted (disappear if > half second)
  medit_loop_blink:
    mov     a, cursor_pos; check where the cursor is placed
    medit_blinkhour:
    cjne    a, #0x1,        medit_blinkminute
    Set_Cursor(  1 , 1  )
    Send_Constant_String(#bb)
    sjmp    medit_doneblink
    medit_blinkminute:
    cjne    a, #0x2,        medit_blinksecond
    Set_Cursor(  1 , 4  )
    Send_Constant_String(#bb)
    sjmp    medit_doneblink
    medit_blinksecond:
    cjne    a, #0x3,        medit_blinkampm
    Set_Cursor(  1 , 7  )
    Send_Constant_String(#bb)
    sjmp    medit_doneblink
    medit_blinkampm:
    cjne    a, #0x4,        medit_blinkday
    Set_Cursor(  1 , 10  )
    Send_Constant_String(#bb)
    sjmp    medit_doneblink
    medit_blinkday:
    Set_Cursor(  2 , 1  )
    Send_Constant_String(#bbday)
    medit_doneblink:
    setb    blinky_flag                         ; set blinky_flag to 1
    ljmp    medit_show_done
  medit_loop_show:
    clr     blinky_flag                         ; reset blinky_flag to 0
    lcall   clock_print_layout
  medit_show_done:
    jb      EDIT_BUTTON,     medit_loop_inc     ; if edit button is not pressed, check other buttons
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb      EDIT_BUTTON,     medit_loop_inc     ; if edit button is not pressed, check other buttons
    jnb     EDIT_BUTTON,     $                  ; if edit button is pressed, exit edit
    ljmp    medit_exit
  ; checks increment button
    medit_loop_inc:
    jb      INCR_BUTTON,     medit_loop_switch  ; if inc button is not pressed, check other buttons
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb      INCR_BUTTON,     medit_loop_switch  ; if inc button is not pressed, check other buttons
    jnb     INCR_BUTTON,     $                  ; if inc button is pressed, check cursor position
    ljmp    medit_poscheck
  ; checks switch button
    medit_loop_switch:
    jb      SWITCH_BUTTON,   medit_loop_transfer; if switch button is not pressed, replay loop
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb      SWITCH_BUTTON,   medit_loop_transfer; if switch button is not pressed, replay loops
    jnb     SWITCH_BUTTON,   $                  ; if switch button is pressed, increment cursor position
    ljmp    medit_switch

    medit_switch:
      mov     a, cursor_pos
      cjne    a, #0x5,         medit_normal_switch; limits cursor_pos to 1-5
      mov     cursor_pos, #0x1                    ; if cursor_pos is already 5, reset to 0
      ljmp    medit_loop
      medit_normal_Switch:
      inc     cursor_pos
      medit_loop_transfer:
      ljmp    medit_loop

; Function 1 Edit: Clock Edit
medit_exit:
    setb    TR2                                 ; Resume Timer 2
    clr     TR0                                 ; Stop TR0
    ljmp    main_loop                           ; Exit edit mode

      medit_poscheck:
        mov     a, cursor_pos
        cjne    a, #0x1,       medit_poscheck1    ; if not pos1 (hour), check other
        sjmp    medit_hour
      medit_poscheck1:
        cjne    a, #0x2,       medit_poscheck2    ; if not pos2 (minute), check other
        sjmp    medit_minute
      medit_poscheck2:
        cjne    a, #0x3,       medit_poscheck3    ; if not pos3 (second), check other
        sjmp    medit_second
      medit_poscheck3:
        cjne    a, #0x4,       medit_poscheck4    ; if not pos4 (am/pm), check other
        sjmp    medit_ampm
      medit_poscheck4:
        sjmp    medit_day                         ; has to be pos5, otherwise retarded

      medit_second:
        mov     a, CLOCK_SECOND
    	  cjne    a, #0x59,      medit_second_inc  	; check if second will turn 60
    	  mov     a, #0							                  ; if true, special increment
    	  da      a
    	  mov     CLOCK_SECOND, a
        ljmp    medit_loop
      medit_minute:
    	  mov     a, CLOCK_MINUTE
    	  cjne    a, #0x59,      medit_minute_inc		; check if minute will turn 60
    	  mov     a, #0							                  ; if true, special increment
    	  da      a
    	  mov     CLOCK_MINUTE, a
        ljmp    medit_loop
      medit_hour:                                   ; if AM, allow to reach 12:xx
        mov     a, CLOCK_AMPM                       ; but change am -> pm
        cjne    a, #0x0,       medit_not_am
        mov     a, CLOCK_HOUR
    	  cjne    a, #0x11,      medit_hour_inc	  	; AM: check if hour will turn 12
    	  mov     a, #0x0							                ; if true, special increment
        ljmp    medit_do_ampm
        medit_not_am:
        mov     a, CLOCK_HOUR
        cjne    a, #0x12,      medit_hour_inc     ; PM: check if hour will turn 13
        mov     a, #0x1                             ; if true, special increment
        medit_do_ampm:
        da      a
        mov     CLOCK_HOUR, a
        ljmp    medit_loop
      medit_ampm:
        mov     a, CLOCK_AMPM
    	  cjne    a, #0x1,       medit_ampm_inc	  	; check if already pm
    	  mov     a, #0x0							                ; if true, special increment
    	  da      a
    	  mov     CLOCK_AMPM, a
        ljmp   medit_loop
      medit_day :
        mov     a, CLOCK_DAY
    	  cjne    a, #0x6,       medit_day_inc	    ; check if already Saturday
    	  mov     a, #0x0							                ; if true, special increment
    	  da      a
    	  mov     CLOCK_DAY, a
        ljmp    medit_loop

      medit_hour_inc:
        mov     a, CLOCK_HOUR
        add     a, #0x1
        da      a
        mov     CLOCK_HOUR, a
        ljmp    medit_loop
      medit_minute_inc:
        mov     a, CLOCK_MINUTE
        add     a, #0x1
        da      a
        mov     CLOCK_MINUTE, a
        ljmp    medit_loop
      medit_second_inc:
        mov     a, CLOCK_SECOND
        add     a, #0x1
        da      a
        mov     CLOCK_SECOND, a
        ljmp    medit_loop
      medit_ampm_inc:
        mov     a, CLOCK_AMPM
        add     a, #0x1
        da      a
        mov     CLOCK_AMPM, a
        ljmp    medit_loop
      medit_day_inc:
        mov     a, CLOCK_DAY
        add     a, #0x1
        da      a
        mov     CLOCK_DAY, a
        ljmp    medit_loop

; **************************************************************************************************
; ********** FUNCTION 2 - WEEKDAY ALARM ************************************************************
; **************************************************************************************************

alarm1_load:                          ; ALARM1: WEEKDAY ALARM (WD_ALARM_**)
    lcall   clearscreen
    clr     TR0
alarm1_invalid:                                  ; reset gets directed here - complete display check
    Set_Cursor(  1 , 4  )
    Send_Constant_String(#Template_Clock)        ; prints the default alarm template
    Set_Cursor(  2 , 2  )
    Send_Constant_String(#Weekday_String)        ; prints "Weekday" string (2nd row)
    ljmp    alarm1_loop
    jb      WD_ALARM_NUM, alarm1_valid   ; checks if there are numbers in alarm (jump if num = 1)
    Set_Cursor(  2 , 15  )
    Send_Constant_String(#bb)   ; if alarm is not valid, don't print status
    ljmp    alarm1_loop
alarm1_valid:
    Set_Cursor(  1 , 4  )
    Display_BCD(WD_ALARM_HOUR)
    Set_Cursor(  1 , 7  )
    Display_BCD(WD_ALARM_MINUTE)
    Set_Cursor(  1 , 10  )
    Display_BCD(WD_ALARM_SECOND)
    Set_Cursor(  1 , 13  )
    mov     a, WD_ALARM_AMPM
    cjne    a, #0x0,         alarm1_valid_pm
    Send_Constant_String(#AM)
    sjmp    alarm1_valid_pmdone
    alarm1_valid_pm:
    Send_Constant_String(#PM)
    alarm1_valid_pmdone:
    Set_Cursor(  2 , 16  )
    jb      WD_ALARM_STATUS, alarm1_set_on      ; checks if the alarm is on/off (jump if a = 1)
    alarm1_set_off:
    clr     TR0
    Send_Constant_String(#OFF)                  ; prints "N" if alarm is off
    ljmp    alarm1_loop                         ; skips colon blinking animation
    alarm1_set_on:
    Send_Constant_String(#ON)                   ; prints "Y" if alarm is off
    ; clr     blinky_flag                         ; clears blinky_flag before using

alarm1_on_preloop:
  ; the dots ":" will blink as long as alarm is on
  ; use TR0 to check partial seconds for blinky display
    setb    TR0   ; Starts blinking timer TR0
    jb      blink_time_flag, alarm1_preloop_pass ; checks if its time to blink (check ovf flag)
  ; if there are valid numbers in the alarm, prints entire alarm BCD
    ljmp    alarm1_loop                          ; skips anims if its not time
  ; prints  the colons
  alarm1_preloop_pass:
    clr     blink_time_flag
    jnb     blinky_flag, alarm1_preloop_blink      ; blinky_flag 0 means not yet disappear
    ljmp    alarm1_preloop_show                    ; blinky_flag 1 means already disappear
  alarm1_preloop_blink:   ; blinks colons at position 6, 9
    Set_Cursor(  1 , 6  )
    Send_Constant_String(#b1)
    Set_Cursor(  1 , 9  )
    Send_Constant_String(#b1)
    setb    blinky_flag                         ; blinky_flag 1 indicates disappeared
    ljmp    alarm1_loop
  alarm1_preloop_show:    ; shows colons at positions 6, 9
    Set_Cursor(  1 , 6  )
    Send_Constant_String(#col)
    Set_Cursor(  1 , 9  )
    Send_Constant_String(#col)
    clr     blinky_flag                         ; blinky_flag 0 indicates appeared/showed
alarm1_loop:
  alarm1_alarm_check:
    jnb     ALARM1_RING_FLAG, alarm1_alarm_check2
    ljmp    alarm1_alarm_check_button
  alarm1_alarm_check2:
    jnb     ALARM2_RING_FLAG, alarm1_mode_check
  alarm1_alarm_check_button:
    jb      BOOT_BUTTON, alarm1_mode_check                ; if boot button is not pressed, end alarm check
    Wait_Milli_Seconds(#50)                   ; Debounce delay.
    jb      BOOT_BUTTON, alarm1_mode_check                ; if boot button is not pressed, end alarm check
    jnb     BOOT_BUTTON, $                              ; if boot button pressed, wait til release
  alarm1_alarm_power:
    clr     ALARM1_RING_FLAG
    clr     ALARM2_RING_FLAG
    setb     SOUND_OUT
  alarm1_mode_check:
  ; weekday alarm mode  -  only needs to detect if any button pressed, no moving display!
    jb      MODE_BUTTON,     alarm1_edit_check  ; if mode button is not pressed, start display
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb      MODE_BUTTON,     alarm1_edit_check  ; if mode button is not pressed, start display
    jnb     MODE_BUTTON, $                      ; if mode button is pressed, wait til depress
    ljmp    alarm2_load
  alarm1_edit_check:
    jb      EDIT_BUTTON,     alarm1_incr_check  ; if mode button is not pressed, start display
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb      EDIT_BUTTON,     alarm1_incr_check  ; if mode button is not pressed, start display
    jnb     EDIT_BUTTON, $                      ; if mode button is pressed, wait til depress
    ljmp    alarm1_edit
  alarm1_incr_check:
    jb      INCR_BUTTON,     alarm1_invalid_t   ; if mode button is not pressed, start display
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb      INCR_BUTTON,     alarm1_invalid_t   ; if mode button is not pressed, start display
    jnb     INCR_BUTTON, $                      ; if mode button is pressed, wait til depress
    ljmp    alarm1_quick

    alarm1_invalid_t:
    jb      WD_ALARM_NUM,    alarm1_valid_t
    ljmp    alarm1_invalid
    alarm1_valid_t:
    ljmp    alarm1_valid

; when edit is clicked
alarm1_edit:
    setb    TR0
    mov     cursor_pos, #0x1                     ; reset cursor position to 1 (hour)

  alarm1_e_loop:
  ; use TR0 to check partial seconds for blinky display
    jb      blink_time_flag, alarm1_e_pass      ; checks if its time to blink (check ovf flag)
    ljmp    alarm1_show_done
  ; prints the alarm hours, minutes, and seconds
  alarm1_e_pass:
    clr     blink_time_flag                     ; if pass, clear overflow flag and check if blink/show
    jnb     blinky_flag,     alarm1_loop_blink  ; blinky_flag 0 means not yet disappear (if blinky_flag = 0, jump )
    ljmp    alarm1_e_show                       ; blinky_flag 1 means already disappear
  alarm1_loop_blink:
    mov     a, cursor_pos ; checks location to blink
    alarm1_blinkhour:
    cjne    a, #0x1,         alarm1_blinkminute
    Set_Cursor(  1 , 4  )
    Send_Constant_String(#bb)
    sjmp    alarm1_doneblink
    alarm1_blinkminute:
    cjne    a, #0x2,         alarm1_blinksecond
    Set_Cursor(  1 , 7  )
    Send_Constant_String(#bb)
    sjmp    alarm1_doneblink
    alarm1_blinksecond:
    cjne    a, #0x3,         alarm1_blinkampm
    Set_Cursor(  1 , 10  )
    Send_Constant_String(#bb)
    sjmp    alarm1_doneblink
    alarm1_blinkampm:
    cjne    a, #0x4,         alarm1_blinkstatus
    Set_Cursor(  1 , 13  )
    Send_Constant_String(#bb)
    sjmp    alarm1_doneblink
    alarm1_blinkstatus:
    Set_Cursor(  2 , 16  )
    Send_Constant_String(#b1)
    alarm1_doneblink:
    setb    blinky_flag                         ; blinky_flag 1 indicates disappeared
    ljmp    alarm1_show_done
  alarm1_e_show:
    clr     blinky_flag                         ; blinky_flag 0 indicates appeared/showed
  ; prints to screen based on alarm on/off and valid/invalid
    jb      WD_ALARM_NUM,      alarm1_e_valid_t ; checks if alarm is valid (jump if a = 1, valid)
    sjmp    alarm1_e_invalid
    alarm1_e_valid_t:
    ljmp    alarm1_e_valid
    alarm1_e_invalid:
    Set_Cursor(  1 , 4  )
    jb      WD_ALARM_HOUR_F, alarm1_e_valid_hour; jumps if = 1 (valid)
    Send_Constant_String(#xx)
    ljmp    alarm1_e_invalid_minute
    alarm1_e_valid_hour:
    Display_BCD(WD_ALARM_HOUR)
    alarm1_e_invalid_minute:
    Set_Cursor(  1 , 7  )
    jb      WD_ALARM_MINUTE_F, alarm1_e_valid_minute
    Send_Constant_String(#xx)
    ljmp    alarm1_e_invalid_second
    alarm1_e_valid_minute:
    Display_BCD(WD_ALARM_MINUTE)
    alarm1_e_invalid_second:
    Set_Cursor(  1 , 10  )
    jb      WD_ALARM_SECOND_F, alarm1_e_valid_second
    Send_Constant_String(#xx)
    ljmp    alarm1_e_invalid_next
    alarm1_e_valid_second:
    Display_BCD(WD_ALARM_SECOND)
    alarm1_e_invalid_next:
    Set_Cursor(  1 , 13  )
    mov     a, WD_ALARM_AMPM
    cjne    a, #0x0,          alarm1_e_invalid_pm  ; display AM/PM
    Send_Constant_String(#AM)
    sjmp    alarm1_e_invalid_pmdone
    alarm1_e_invalid_pm:
    Send_Constant_String(#PM)
    alarm1_e_invalid_pmdone:
    Set_Cursor(  2 , 16  )
    Send_Constant_String(#b1)
    ljmp    alarm1_show_done

    alarm1_e_valid:
  ; if there are valid numbers in the alarm
    Set_Cursor(  1 , 4  )
    Display_BCD(WD_ALARM_HOUR)    ; prints all WD_alarm
    Set_Cursor(  1 , 7  )
    Display_BCD(WD_ALARM_MINUTE)
    Set_Cursor(  1 , 10  )
    Display_BCD(WD_ALARM_SECOND)
    Set_Cursor(  1 , 13  )
    mov     a, WD_ALARM_AMPM
    cjne    a, #0x0,        alarm1_e_valid_pm
    Send_Constant_String(#AM)
    sjmp    alarm1_e_statuscheck
    alarm1_e_valid_pm:
    Send_Constant_String(#PM)
    alarm1_e_statuscheck:   ; checks which status display to print
    Set_Cursor(  2 , 16  )
    jb     WD_ALARM_STATUS, alarm1_e_set_on     ; checks if the alarm is on/off (jump if a = 1)
    alarm1_e_set_off:
    Send_Constant_String(#OFF)
    ljmp    alarm1_show_done
    alarm1_e_set_on:
    Send_Constant_String(#ON)
  alarm1_show_done:
    jb     EDIT_BUTTON,     alarm1_loop_inc     ; if edit button is not pressed, check other buttons
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb     EDIT_BUTTON,     alarm1_loop_inc     ; if edit button is not pressed, check other buttons
    jnb    EDIT_BUTTON,     $                   ; if edit button is pressed, exit edit
    clr    TR0
    ljmp   alarm1_e_exit
  ; checks increment button
    alarm1_loop_inc:
    jb     INCR_BUTTON,     alarm1_loop_switch  ; if inc button is not pressed, check other buttons
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb     INCR_BUTTON,     alarm1_loop_switch  ; if inc button is not pressed, check other buttons
    jnb    INCR_BUTTON,     $                   ; if inc button is pressed, check cursor position
    ljmp   alarm1_e_poscheck
  ; checks switch button
    alarm1_loop_switch:
    jb     SWITCH_BUTTON,   alarm1_loop_trans   ; if switch button is not pressed, replay loop
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb     SWITCH_BUTTON,   alarm1_loop_trans   ; if switch button is not pressed, replay loops
    jnb    SWITCH_BUTTON,   $                   ; if switch button is pressed, increment cursor position
    ljmp   alarm1_e_switch

    alarm1_e_exit:
      jb      WD_ALARM_NUM,   alarm1_e_exit_valid
      ljmp    alarm1_error
      alarm1_e_exit_valid:
      ljmp    alarm1_invalid

    alarm1_e_switch:
      mov     a, cursor_pos
      jb      WD_ALARM_NUM,   alarm1_e_switch_valid
      cjne    a, #0x4,        alarm1_e_normal_switch  ; limits cursor_pos to 1-4
      mov     cursor_pos, #0x1
      ljmp    alarm1_e_loop
      alarm1_e_switch_valid:
      cjne    a, #0x5,        alarm1_e_normal_switch  ; limits cursor_pos to 1-5
      mov     cursor_pos, #0x1
      ljmp    alarm1_e_loop
      alarm1_e_normal_switch:
      inc     cursor_pos
      alarm1_loop_trans:
      ljmp    alarm1_e_validity   ; ends by evaluating other edit buttons and blinking

    alarm1_e_poscheck:
      mov    a, cursor_pos
      cjne   a, #0x1,     alarm1_e_poscheck1     ; if not pos1 (hour), check other
      sjmp   alarm1_e_hour
    alarm1_e_poscheck1:
      cjne   a, #0x2,     alarm1_e_poscheck2     ; if not pos2 (minute), check other
      sjmp   alarm1_e_minute
    alarm1_e_poscheck2:
      cjne   a, #0x3,     alarm1_e_poscheck3     ; if not pos3 (second), check other
      sjmp   alarm1_e_second
    alarm1_e_poscheck3:
      cjne   a, #0x4,     alarm1_e_poscheck4     ; if not pos4 (second), check other
      sjmp   alarm1_e_ampm
    alarm1_e_poscheck4:
      sjmp   alarm1_e_status

    alarm1_e_second:
      mov    a, WD_ALARM_SECOND
      cjne   a, #0x59,    alarm1_e_second_inc    ; check if second will turn 60
      mov    a, #0							                   ; if true, special increment
      da     a                                     ; if not, jump to increment
      mov    WD_ALARM_SECOND, a
      ljmp   alarm1_e_validity
    alarm1_e_minute:
      mov    a, WD_ALARM_MINUTE
      cjne   a, #0x59,    alarm1_e_minute_inc	   ; check if minute will turn 60
      mov    a, #0							                   ; if true, special increment
      da     a                                     ; if not, jump to increment
      mov    WD_ALARM_MINUTE, a
      ljmp   alarm1_e_validity
    alarm1_e_hour:                                 ; if AM, allow to reach 12:xx
      mov    a, WD_ALARM_AMPM                      ; but change am -> pm
      cjne   a, #0x0,     alarm1_e_not_am
      mov    a, WD_ALARM_HOUR
      cjne   a, #0x11,    alarm1_e_hour_inc	  	 ; AM: check if hour will turn 12
      mov    a, #0x0							                 ; if true, special increment
      ljmp   alarm1_e_do_ampm
      alarm1_e_not_am:
      mov    a, WD_ALARM_HOUR
      cjne   a, #0x12,    alarm1_e_hour_inc      ; PM: check if hour will turn 13
      mov    a, #0x1                               ; if true, special increment
      alarm1_e_do_ampm:
      da     a
      mov    WD_ALARM_HOUR, a
      ljmp   alarm1_e_validity
    alarm1_e_ampm:
      mov    a, WD_ALARM_AMPM
      cjne   a, #0x1,     alarm1_e_ampm_inc	  	 ; check if already pm
      mov    a, #0x0							                 ; if true, special increment
      da     a
      mov    WD_ALARM_AMPM, a
      ljmp   alarm1_e_validity
    alarm1_e_status:
      jb     WD_ALARM_STATUS, alarm1_e_status_inc; check if already on
      setb   WD_ALARM_STATUS                       ; if true, special increment
      ljmp   alarm1_e_validity

    alarm1_e_hour_inc:
      jb     WD_ALARM_HOUR_F, alarm1_e_hour_inc_n
      mov    a, WD_ALARM_AMPM
      cjne   a, #0x1,         alarm1_e_hour_inc_am
      mov    WD_ALARM_HOUR, #0x0001
      sjmp   alarm1_e_hour_inc_pm
      alarm1_e_hour_inc_am:
      mov    WD_ALARM_HOUR, #0x0000
      alarm1_e_hour_inc_pm:
      setb   WD_ALARM_HOUR_F
      ljmp   alarm1_e_validity
      alarm1_e_hour_inc_n:
      mov    a, WD_ALARM_HOUR
      add    a, #0x1
      da     a
      mov    WD_ALARM_HOUR, a
      ljmp   alarm1_e_validity
    alarm1_e_minute_inc:
      jb     WD_ALARM_MINUTE_F, alarm1_e_minute_inc_n
      mov    WD_ALARM_MINUTE, #0x0000
      setb   WD_ALARM_MINUTE_F
      ljmp   alarm1_e_validity
      alarm1_e_minute_inc_n:
      mov    a, WD_ALARM_MINUTE
      add    a, #0x1
      da     a
      mov    WD_ALARM_MINUTE, a
      ljmp   alarm1_e_validity
    alarm1_e_second_inc:
      jb     WD_ALARM_SECOND_F, alarm1_e_second_inc_n
      mov    WD_ALARM_SECOND, #0x0000
      setb   WD_ALARM_SECOND_F
      ljmp   alarm1_e_validity
      alarm1_e_second_inc_n:
      mov    a, WD_ALARM_SECOND
      add    a, #0x1
      da     a
      mov    WD_ALARM_SECOND, a
      ljmp   alarm1_e_validity
    alarm1_e_ampm_inc:
      mov    a, WD_ALARM_AMPM
      add    a, #0x1
      da     a
      mov    WD_ALARM_AMPM, a
      ljmp   alarm1_e_validity
    alarm1_e_status_inc:
      clr   WD_ALARM_STATUS
      ljmp   alarm1_e_loop

    alarm1_e_validity:
      jnb    WD_ALARM_HOUR_F,   alarm1_e_validity_no
      alarm1_minute_valid:
      jnb    WD_ALARM_MINUTE_F, alarm1_e_validity_no
      alarm1_second_valid:
      jnb    WD_ALARM_SECOND_F, alarm1_e_validity_no
      setb   WD_ALARM_NUM
      ljmp   alarm1_e_loop
      alarm1_e_validity_no:
      clr    WD_ALARM_NUM
      ljmp   alarm1_e_loop

alarm1_quick:
    jnb     WD_ALARM_NUM,       alarm1_error
  alarm1_quick_valid:
    jnb     WD_ALARM_STATUS,    alarm1_quick_off
    clr     WD_ALARM_STATUS
    ljmp    alarm1_invalid
  alarm1_quick_off:
    setb    WD_ALARM_STATUS
    ljmp    alarm1_invalid

  ; shows error screen when alarm is not set correctly
alarm1_error:
    lcall   clearscreen
  alarm1_error_loop:
    Set_Cursor(1,1)
    Send_Constant_String(#AlarmError)
    Set_Cursor(2,1)
    Send_Constant_String(#BootButton)
    jb      BOOT_BUTTON,     alarm1_error_loop  ; if mode button is not pressed, do nothing
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb      BOOT_BUTTON,     alarm1_error_loop  ; if mode button is not pressed, do nothing
    jnb     BOOT_BUTTON, $                      ; if mode button is pressed, wait til depress
    ljmp    alarm1_load

; **************************************************************************************************
; ********** FUNCTION 3 - WEEKEND ALARM ************************************************************
; **************************************************************************************************

alarm2_load:                          ; alarm2: WEEKEND ALARM (WE_ALARM_**)
    lcall   clearscreen
    clr     TR0
alarm2_invalid:                                  ; reset gets directed here - complete display check
    Set_Cursor(  1 , 4  )
    Send_Constant_String(#Template_Clock)        ; prints the default alarm template
    Set_Cursor(  2 , 2  )
    Send_Constant_String(#Weekend_String)        ; prints "WEEKEND" string (2nd row)
    ljmp    alarm2_loop
    jb      WE_ALARM_NUM, alarm2_valid   ; checks if there are numbers in alarm (jump if num = 1)
    Set_Cursor(  2 , 15  )
    Send_Constant_String(#bb)   ; if alarm is not valid, don't print status
    ljmp    alarm2_loop
alarm2_valid:
    Set_Cursor(  1 , 4  )
    Display_BCD(WE_ALARM_HOUR)
    Set_Cursor(  1 , 7  )
    Display_BCD(WE_ALARM_MINUTE)
    Set_Cursor(  1 , 10  )
    Display_BCD(WE_ALARM_SECOND)
    Set_Cursor(  1 , 13  )
    mov     a, WE_ALARM_AMPM
    cjne    a, #0x0,         alarm2_valid_pm
    Send_Constant_String(#AM)
    sjmp    alarm2_valid_pmdone
    alarm2_valid_pm:
    Send_Constant_String(#PM)
    alarm2_valid_pmdone:
    Set_Cursor(  2 , 16  )
    jb      WE_ALARM_STATUS, alarm2_set_on      ; checks if the alarm is on/off (jump if a = 1)
    alarm2_set_off:
    clr     TR0
    Send_Constant_String(#OFF)                  ; prints "N" if alarm is off
    ljmp    alarm2_loop                         ; skips colon blinking animation
    alarm2_set_on:
    Send_Constant_String(#ON)                   ; prints "Y" if alarm is off
    ; clr     blinky_flag                         ; clears blinky_flag before using

alarm2_on_preloop:
  ; the dots ":" will blink as long as alarm is on
  ; use TR0 to check partial seconds for blinky display
    setb    TR0   ; Starts blinking timer TR0
    jb      blink_time_flag, alarm2_preloop_pass ; checks if its time to blink (check ovf flag)
  ; if there are valid numbers in the alarm, prints entire alarm BCD
    ljmp    alarm2_loop                          ; skips anims if its not time
  ; prints  the colons
  alarm2_preloop_pass:
    clr     blink_time_flag
    jnb     blinky_flag, alarm2_preloop_blink      ; blinky_flag 0 means not yet disappear
    ljmp    alarm2_preloop_show                    ; blinky_flag 1 means already disappear
  alarm2_preloop_blink:   ; blinks colons at position 6, 9
    Set_Cursor(  1 , 6  )
    Send_Constant_String(#b1)
    Set_Cursor(  1 , 9  )
    Send_Constant_String(#b1)
    setb    blinky_flag                         ; blinky_flag 1 indicates disappeared
    ljmp    alarm2_loop
  alarm2_preloop_show:    ; shows colons at positions 6, 9
    Set_Cursor(  1 , 6  )
    Send_Constant_String(#col)
    Set_Cursor(  1 , 9  )
    Send_Constant_String(#col)
    clr     blinky_flag                         ; blinky_flag 0 indicates appeared/showed
alarm2_loop:
  alarm2_alarm_check:
    jnb     ALARM1_RING_FLAG, alarm2_alarm_check2
    ljmp    alarm2_alarm_check_button
    alarm2_alarm_check2:
    jnb     ALARM2_RING_FLAG, alarm2_mode_check
    alarm2_alarm_check_button:
    jb      BOOT_BUTTON, alarm2_mode_check                ; if boot button is not pressed, end alarm check
    Wait_Milli_Seconds(#50)                   ; Debounce delay.
    jb      BOOT_BUTTON, alarm2_mode_check                ; if boot button is not pressed, end alarm check
    jnb     BOOT_BUTTON, $                              ; if boot button pressed, wait til release
  alarm2_alarm_power:
    clr     ALARM1_RING_FLAG
    clr     ALARM2_RING_FLAG
    setb     SOUND_OUT
  alarm2_mode_check:
  ; WEEKEND alarm mode  -  only needs to detect if any button pressed, no moving display!
    jb      MODE_BUTTON,     alarm2_edit_check  ; if mode button is not pressed, start display
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb      MODE_BUTTON,     alarm2_edit_check  ; if mode button is not pressed, start display
    jnb     MODE_BUTTON, $                      ; if mode button is pressed, wait til depress
    ljmp    main_load
  alarm2_edit_check:
    jb      EDIT_BUTTON,     alarm2_incr_check  ; if mode button is not pressed, start display
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb      EDIT_BUTTON,     alarm2_incr_check  ; if mode button is not pressed, start display
    jnb     EDIT_BUTTON, $                      ; if mode button is pressed, wait til depress
    ljmp    alarm2_edit
  alarm2_incr_check:
    jb      INCR_BUTTON,     alarm2_invalid_t   ; if mode button is not pressed, start display
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb      INCR_BUTTON,     alarm2_invalid_t   ; if mode button is not pressed, start display
    jnb     INCR_BUTTON, $                      ; if mode button is pressed, wait til depress
    ljmp    alarm2_quick

    alarm2_invalid_t:
    jb      WE_ALARM_NUM,    alarm2_valid_t
    ljmp    alarm2_invalid
    alarm2_valid_t:
    ljmp    alarm2_valid

; when edit is clicked
alarm2_edit:
    setb    TR0
    mov     cursor_pos, #0x1                     ; reset cursor position to 1 (hour)

  alarm2_e_loop:
  ; use TR0 to check partial seconds for blinky display
    jb      blink_time_flag, alarm2_e_pass      ; checks if its time to blink (check ovf flag)
    ljmp    alarm2_show_done
  ; prints the alarm hours, minutes, and seconds
  alarm2_e_pass:
    clr     blink_time_flag                     ; if pass, clear overflow flag and check if blink/show
    jnb     blinky_flag,     alarm2_loop_blink  ; blinky_flag 0 means not yet disappear (if blinky_flag = 0, jump )
    ljmp    alarm2_e_show                       ; blinky_flag 1 means already disappear
  alarm2_loop_blink:
    mov     a, cursor_pos ; checks location to blink
    alarm2_blinkhour:
    cjne    a, #0x1,         alarm2_blinkminute
    Set_Cursor(  1 , 4  )
    Send_Constant_String(#bb)
    sjmp    alarm2_doneblink
    alarm2_blinkminute:
    cjne    a, #0x2,         alarm2_blinksecond
    Set_Cursor(  1 , 7  )
    Send_Constant_String(#bb)
    sjmp    alarm2_doneblink
    alarm2_blinksecond:
    cjne    a, #0x3,         alarm2_blinkampm
    Set_Cursor(  1 , 10  )
    Send_Constant_String(#bb)
    sjmp    alarm2_doneblink
    alarm2_blinkampm:
    cjne    a, #0x4,         alarm2_blinkstatus
    Set_Cursor(  1 , 13  )
    Send_Constant_String(#bb)
    sjmp    alarm2_doneblink
    alarm2_blinkstatus:
    Set_Cursor(  2 , 16  )
    Send_Constant_String(#b1)
    alarm2_doneblink:
    setb    blinky_flag                         ; blinky_flag 1 indicates disappeared
    ljmp    alarm2_show_done
  alarm2_e_show:
    clr     blinky_flag                         ; blinky_flag 0 indicates appeared/showed
  ; prints to screen based on alarm on/off and valid/invalid
    jb      WE_ALARM_NUM,      alarm2_e_valid_t ; checks if alarm is valid (jump if a = 1, valid)
    sjmp    alarm2_e_invalid
    alarm2_e_valid_t:
    ljmp    alarm2_e_valid
    alarm2_e_invalid:
    Set_Cursor(  1 , 4  )
    jb      WE_ALARM_HOUR_F, alarm2_e_valid_hour; jumps if = 1 (valid)
    Send_Constant_String(#xx)
    ljmp    alarm2_e_invalid_minute
    alarm2_e_valid_hour:
    Display_BCD(WE_ALARM_HOUR)
    alarm2_e_invalid_minute:
    Set_Cursor(  1 , 7  )
    jb      WE_ALARM_MINUTE_F, alarm2_e_valid_minute
    Send_Constant_String(#xx)
    ljmp    alarm2_e_invalid_second
    alarm2_e_valid_minute:
    Display_BCD(WE_ALARM_MINUTE)
    alarm2_e_invalid_second:
    Set_Cursor(  1 , 10  )
    jb      WE_ALARM_SECOND_F, alarm2_e_valid_second
    Send_Constant_String(#xx)
    ljmp    alarm2_e_invalid_next
    alarm2_e_valid_second:
    Display_BCD(WE_ALARM_SECOND)
    alarm2_e_invalid_next:
    Set_Cursor(  1 , 13  )
    mov     a, WE_ALARM_AMPM
    cjne    a, #0x0,          alarm2_e_invalid_pm  ; display AM/PM
    Send_Constant_String(#AM)
    sjmp    alarm2_e_invalid_pmdone
    alarm2_e_invalid_pm:
    Send_Constant_String(#PM)
    alarm2_e_invalid_pmdone:
    Set_Cursor(  2 , 16  )
    Send_Constant_String(#b1)
    ljmp    alarm2_show_done

    alarm2_e_valid:
  ; if there are valid numbers in the alarm
    Set_Cursor(  1 , 4  )
    Display_BCD(WE_ALARM_HOUR)    ; prints all WE_ALARM
    Set_Cursor(  1 , 7  )
    Display_BCD(WE_ALARM_MINUTE)
    Set_Cursor(  1 , 10  )
    Display_BCD(WE_ALARM_SECOND)
    Set_Cursor(  1 , 13  )
    mov     a, WE_ALARM_AMPM
    cjne    a, #0x0,        alarm2_e_valid_pm
    Send_Constant_String(#AM)
    sjmp    alarm2_e_statuscheck
    alarm2_e_valid_pm:
    Send_Constant_String(#PM)
    alarm2_e_statuscheck:   ; checks which status display to print
    Set_Cursor(  2 , 16  )
    jb     WE_ALARM_STATUS, alarm2_e_set_on     ; checks if the alarm is on/off (jump if a = 1)
    alarm2_e_set_off:
    Send_Constant_String(#OFF)
    ljmp    alarm2_show_done
    alarm2_e_set_on:
    Send_Constant_String(#ON)
  alarm2_show_done:
    jb     EDIT_BUTTON,     alarm2_loop_inc     ; if edit button is not pressed, check other buttons
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb     EDIT_BUTTON,     alarm2_loop_inc     ; if edit button is not pressed, check other buttons
    jnb    EDIT_BUTTON,     $                   ; if edit button is pressed, exit edit
    clr    TR0
    ljmp   alarm2_e_exit
  ; checks increment button
    alarm2_loop_inc:
    jb     INCR_BUTTON,     alarm2_loop_switch  ; if inc button is not pressed, check other buttons
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb     INCR_BUTTON,     alarm2_loop_switch  ; if inc button is not pressed, check other buttons
    jnb    INCR_BUTTON,     $                   ; if inc button is pressed, check cursor position
    ljmp   alarm2_e_poscheck
  ; checks switch button
    alarm2_loop_switch:
    jb     SWITCH_BUTTON,   alarm2_loop_trans   ; if switch button is not pressed, replay loop
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb     SWITCH_BUTTON,   alarm2_loop_trans   ; if switch button is not pressed, replay loops
    jnb    SWITCH_BUTTON,   $                   ; if switch button is pressed, increment cursor position
    ljmp   alarm2_e_switch

    alarm2_e_exit:
      jb      WE_ALARM_NUM,   alarm2_e_exit_valid
      ljmp    alarm2_error
      alarm2_e_exit_valid:
      ljmp    alarm2_invalid

    alarm2_e_switch:
      mov     a, cursor_pos
      jb      WE_ALARM_NUM,   alarm2_e_switch_valid
      cjne    a, #0x4,        alarm2_e_normal_switch  ; limits cursor_pos to 1-4
      mov     cursor_pos, #0x1
      ljmp    alarm2_e_loop
      alarm2_e_switch_valid:
      cjne    a, #0x5,        alarm2_e_normal_switch  ; limits cursor_pos to 1-5
      mov     cursor_pos, #0x1
      ljmp    alarm2_e_loop
      alarm2_e_normal_switch:
      inc     cursor_pos
      alarm2_loop_trans:
      ljmp    alarm2_e_validity   ; ends by evaluating other edit buttons and blinking

    alarm2_e_poscheck:
      mov    a, cursor_pos
      cjne   a, #0x1,     alarm2_e_poscheck1     ; if not pos1 (hour), check other
      sjmp   alarm2_e_hour
    alarm2_e_poscheck1:
      cjne   a, #0x2,     alarm2_e_poscheck2     ; if not pos2 (minute), check other
      sjmp   alarm2_e_minute
    alarm2_e_poscheck2:
      cjne   a, #0x3,     alarm2_e_poscheck3     ; if not pos3 (second), check other
      sjmp   alarm2_e_second
    alarm2_e_poscheck3:
      cjne   a, #0x4,     alarm2_e_poscheck4     ; if not pos4 (second), check other
      sjmp   alarm2_e_ampm
    alarm2_e_poscheck4:
      sjmp   alarm2_e_status

    alarm2_e_second:
      mov    a, WE_ALARM_SECOND
      cjne   a, #0x59,    alarm2_e_second_inc    ; check if second will turn 60
      mov    a, #0							                   ; if true, special increment
      da     a                                     ; if not, jump to increment
      mov    WE_ALARM_SECOND, a
      ljmp   alarm2_e_validity
    alarm2_e_minute:
      mov    a, WE_ALARM_MINUTE
      cjne   a, #0x59,    alarm2_e_minute_inc	   ; check if minute will turn 60
      mov    a, #0							                   ; if true, special increment
      da     a                                     ; if not, jump to increment
      mov    WE_ALARM_MINUTE, a
      ljmp   alarm2_e_validity
    alarm2_e_hour:                                 ; if AM, allow to reach 12:xx
      mov    a, WE_ALARM_AMPM                         ; but change am -> pm
      cjne   a, #0x0,     alarm2_e_not_am
      mov    a, WE_ALARM_HOUR
      cjne   a, #0x11,    alarm2_e_hour_inc	  	 ; AM: check if hour will turn 12
      mov    a, #0x0							                 ; if true, special increment
      ljmp   alarm2_e_do_ampm
      alarm2_e_not_am:
      mov    a, WE_ALARM_HOUR
      cjne   a, #0x12,    alarm2_e_hour_inc      ; PM: check if hour will turn 13
      mov    a, #0x1                               ; if true, special increment
      alarm2_e_do_ampm:
      da     a
      mov    WE_ALARM_HOUR, a
      ljmp   alarm2_e_validity
    alarm2_e_ampm:
      mov    a, WE_ALARM_AMPM
      cjne   a, #0x1,     alarm2_e_ampm_inc	  	 ; check if already pm
      mov    a, #0x0							                 ; if true, special increment
      da     a
      mov    WE_ALARM_AMPM, a
      ljmp   alarm2_e_validity
    alarm2_e_status:
      jb     WE_ALARM_STATUS, alarm2_e_status_inc; check if already on
      setb   WE_ALARM_STATUS                               ; if true, special increment
      ljmp   alarm2_e_validity

    alarm2_e_hour_inc:
      jb     WE_ALARM_HOUR_F, alarm2_e_hour_inc_n
      mov    a, WE_ALARM_AMPM
      cjne   a, #0x1,         alarm2_e_hour_inc_am
      mov    WE_ALARM_HOUR, #0x0001
      sjmp   alarm2_e_hour_inc_pm
      alarm2_e_hour_inc_am:
      mov    WE_ALARM_HOUR, #0x0000
      alarm2_e_hour_inc_pm:
      setb   WE_ALARM_HOUR_F
      ljmp   alarm2_e_validity
      alarm2_e_hour_inc_n:
      mov    a, WE_ALARM_HOUR
      add    a, #0x1
      da     a
      mov    WE_ALARM_HOUR, a
      ljmp   alarm2_e_validity
    alarm2_e_minute_inc:
      jb     WE_ALARM_MINUTE_F, alarm2_e_minute_inc_n
      mov    WE_ALARM_MINUTE, #0x0000
      setb   WE_ALARM_MINUTE_F
      ljmp   alarm2_e_validity
      alarm2_e_minute_inc_n:
      mov    a, WE_ALARM_MINUTE
      add    a, #0x1
      da     a
      mov    WE_ALARM_MINUTE, a
      ljmp   alarm2_e_validity
    alarm2_e_second_inc:
      jb     WE_ALARM_SECOND_F, alarm2_e_second_inc_n
      mov    WE_ALARM_SECOND, #0x0000
      setb   WE_ALARM_SECOND_F
      ljmp   alarm2_e_validity
      alarm2_e_second_inc_n:
      mov    a, WE_ALARM_SECOND
      add    a, #0x1
      da     a
      mov    WE_ALARM_SECOND, a
      ljmp   alarm2_e_validity
    alarm2_e_ampm_inc:
      mov    a, WE_ALARM_AMPM
      add    a, #0x1
      da     a
      mov    WE_ALARM_AMPM, a
      ljmp   alarm2_e_validity
    alarm2_e_status_inc:
      clr   WE_ALARM_STATUS
      ljmp   alarm2_e_loop

    alarm2_e_validity:
      jnb    WE_ALARM_HOUR_F,   alarm2_e_validity_no
      alarm2_minute_valid:
      jnb    WE_ALARM_MINUTE_F, alarm2_e_validity_no
      alarm2_second_valid:
      jnb    WE_ALARM_SECOND_F, alarm2_e_validity_no
      setb   WE_ALARM_NUM
      ljmp   alarm2_e_loop
      alarm2_e_validity_no:
      clr    WE_ALARM_NUM
      ljmp   alarm2_e_loop

alarm2_quick:
    jnb     WE_ALARM_NUM,       alarm2_error
  alarm2_quick_valid:
    jnb     WE_ALARM_STATUS,    alarm2_quick_off
    clr     WE_ALARM_STATUS
    ljmp    alarm2_invalid
  alarm2_quick_off:
    setb    WE_ALARM_STATUS
    ljmp    alarm2_invalid

  ; shows error screen when alarm is not set correctly
alarm2_error:
    lcall   clearscreen
  alarm2_error_loop:
    Set_Cursor(1,1)
    Send_Constant_String(#AlarmError)
    Set_Cursor(2,1)
    Send_Constant_String(#BootButton)
    jb      BOOT_BUTTON,     alarm2_error_loop  ; if mode button is not pressed, do nothing
    Wait_Milli_Seconds(#50)              ; Debounce delay.
    jb      BOOT_BUTTON,     alarm2_error_loop  ; if mode button is not pressed, do nothing
    jnb     BOOT_BUTTON, $                      ; if mode button is pressed, wait til depress
    ljmp    alarm2_load
END
