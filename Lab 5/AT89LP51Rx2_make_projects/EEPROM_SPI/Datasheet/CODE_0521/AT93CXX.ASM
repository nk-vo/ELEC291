		NAME	Control_AT93Cxx

; This collection of routines allows an AT89Cx051 microcontroller to read
; and write the AT93Cxx family of serial CMOS EEPROMS. The code is universal,
; supporting both 8-bit and 16-bit accesses to all members of the AT93Cxx
; family. The code meets all AT93Cxx family timing requirements when run
; on a processor with a 12 MHz clock. Code modifications may be required
; if a faster clock is substituted.
;
; All seven AT93Cxx functions are supported: read, write, write all, erase,
; erase all, erase/write enable and erase/write disable. Each function has
; its own entry point. The calling procedure is:
;
;	1) Load the address (if required) into register ADDR_LO (eight bits
;	   or less) or register pair ADDR_HI:ADDR_LO (more than eight bits).
;	2) Load the data (if required) into register DATA_LO (byte) or
;	   register pair DATA_HI:DATA_LO (word).
;	3) Call the function (READ, WRITE, WRAL, ERASE, ERAL, EWEN, EWDS).
;
; If the function returns data, it will be returned in register DATA_LO
; if SIZE=0 or in register pair DATA_HI:DATA_LO if SIZE=1.
;
; Some functions (WRITE, WRAL, ERASE, ERAL) return the carry flag set
; to indicate an error, cleared to indicate success.
;
; The following table shows the number of valid address bits for each
; member of the AT93Cxx family when strapped for 8-bit and 16-bit data:
;
;		   93C46	   93C56	   93C57	   93C66
;----------------------------------------------------------------------------
; Data bits:	8	16	8	16	8	16	8	16
; Address bits:	7	6	9	8	8	7	9	8
;
; The SIZE flag is used to specify eight-bit or sixteen-bit data and must
; follow the state of the AT93Cxx ORG pin: one (set) indicates 16-bit data
; (ORG tied to Vcc or floating), zero (reset) indicates 8-bit data (ORG
; grounded). General purpose bit F0 in the PSW is used for the SIZE flag,
; but any addressable bit may be substituted.
;
; To specify the member of the AT93Cxx family in use, set the value of NADDR
; to the number of address lines required by the device. This information is
; provided in the table above. The number of device address lines depends on
; the data size as determined by the strapping of the ORG pin.
;
; The AT93Cxx control lines (CS, SK, DI, DO) are mapped to microcontroller
; I/O port pins in lines 63-66. To specify the three-wire configuration,
; assign DI and DO to the same pin. To specify the four-wire configuration,
; assign DI and DO to different pins. No other code changes are required.
; Code to initialize the AT93Cxx control lines should be included in the
; user's application in the reset or initialization area.

; Number of valid address bits for the device in use (reference table above).

NADDR		EQU	7		; e.g. AT93C46 strapped for 8-bit data
;NADDR		EQU	6		; e.g. AT93C46 strapped for 16-bit data

; Data size.

size		EQU	f0		; 0 = 8-bit data, 1 = 16-bit data

; Register definitions.

data_lo		EQU	r0		; register for byte data
data_hi		EQU	r1		; extension register for word data
addr_lo		EQU	r2		; register for short address
addr_hi		EQU	r3		; extension register for long address

P1M0			EQU 0C2h
P3M0			EQU 0C6h

; Microcontroller connections to AT93Cxx control pins.
; For a three-wire interface, define DI and DO to be the same pin.
; For a four-wire interface, define DI and DO to be different pins.
; No other code changes are required.

CS		BIT	p1.2		; AT93Cxx chip select
SK		BIT	p1.3		;       serial data clock
DI		BIT	p1.4		;       serial data input
DO		BIT	p1.5		;       serial data output


		DSEG AT 20H

		ORG	20H		; stack origin
stack:		DS	20H		; stack depth


		CSEG

		ORG	0000H		; power on/reset vector
		jmp	on_reset

		ORG	0003H		; external interrupt 0 vector
		reti			; undefined

		ORG	000BH		; timer 0 overflow vector
		reti			; undefined

		ORG	0013H		; external interrupt 1 vector
		reti			; undefined

		ORG	001BH		; timer 1 overflow vector
		reti			; undefined

		ORG	0023H		; serial I/O interrupt vector
		reti			; undefined

		ORG	0080H		; begin code space
		USING	0		; register bank zero
on_reset:
		mov	sp, #(stack-1)	; initialize stack pointer
		mov	P1M0, #0		; P1 is quasi0bidirectional
		mov	P3M0, #0		; P3 is quasi0bidirectional
		; Initialize AT93Cxx control lines.

		clr	CS		; low
		clr	SK		; low
		setb	DI		; high
		setb	DO		; high

		; Initialize SIZE flag.

		clr	size		; specify 8-bit data
;		setb	size		; specify 16-bit data

;
;	Sample function calls.
;

		; Read (byte if SIZE/ORG=0, word if SIZE/ORG=1).

		mov	addr_lo, #0	; address
		call	read

		; Write byte (SIZE/ORG=0).

		mov	addr_lo, #7fh	; address
		mov	data_lo, #55h	; data
		call	write		; check carry after return

		; Write word (SIZE/ORG=1).

		mov	addr_lo, #3fh	; address
		mov	data_lo, #55h	; data
		mov	data_hi, #0aah	; data
		call	write		; check carry after return

		; Fill with byte (SIZE/ORG=0).

		mov	data_lo, #55h	; data
		call	wral		; check carry after return

		; Fill with word (SIZE/ORG=1).

		mov	data_lo, #55h	; data
		mov	data_hi, #0aah	; data
		call	wral		; check carry after return

		; Erase address (byte if SIZE/ORG=0, word if SIZE/ORG=1).

		mov	addr_lo, #0	; address
		call	erase		; check carry after return

		; Erase device.

		call	eral		; check carry after return

		; Enable write.

		call	ewen

		; Disable write.

		call	ewds


read:
	; Read data from addressed byte or word.
	; Called with address in register ADDR_HI:ADDR_LO.
	; Returns data in register DATA_LO if SIZE flag is low,
	; in register pair DATA_HI:DATA_LO if SIZE flag is high.
	; Destroys B, DPTR.

		setb	CS		; raise CS

		; Shift out start bit (1) and op code (10).

		mov	dpl, #110b
		mov	b, #3
		call	outdata

		; Shift out address, MSB first.

		mov	dpl, addr_lo	; low byte
		mov	dph, addr_hi	; high byte (may be undefined)
		mov	b, #NADDR	; bit count
		call	outdata

		; Read output data.

		call	indata		; get return data

		clr	CS		; drop CS
		ret


write:
	; Write data into the addressed byte or word.
	; ERASE is not required before WRITE.
	; Called with address in registers ADDR_HI:ADDR_LO,
	; data in registers DATA_HI:DATA_LO.
	; SIZE flag low indicates valid data in DATA_LO only;
	; high indicates valid data in both DATA_HI and DATA_LO.
	; Returns CY set to indicate error. Destroys B, DPTR.

		setb	CS		; raise CS

		; Shift out start bit (1) and op code (01).

		mov	dpl, #101b
		mov	b, #3
		call	outdata

		; Shift out address, MSB first.

		mov	dpl, addr_lo	; low byte
		mov	dph, addr_hi	; high byte (may be undefined)
		mov	b, #NADDR	; bit count
		call	outdata

		; Shift out data, MSB first.
		; Number of bytes varies according to SIZE flag.

		mov	dpl, data_lo
		jb	size, ee61
		mov	b, #8
		jmp	ee62
	ee61:
		mov	dph, data_hi
		mov	b, #16
	ee62:
		call	outdata

		clr	CS		; drop CS

		; Poll device status.

		call	status		; returns CY
		ret


wral:
	; Write data into all addresses (fill).
	; Valid only when Vcc is 5.0 Volts +/- 10 percent.
	; Called with data in registers DATA_HI:DATA_LO.
	; SIZE flag low indicates valid data in DATA_LO only;
	; high indicates valid data in both DATA_HI and DATA_LO.
	; Returns CY set to indicate error. Destroys B, DPTR.

		setb	CS		; raise CS

		; Shift out start bit (1), op code (00) and 01,
		; followed by a device-specific number of undefined bits.

		mov	dptr, #(10001b SHL (NADDR-2))
		mov	b, #(NADDR+3)
		call	outdata

		; Shift out data, MSB first.
		; Number of bytes varies according to SIZE flag.

		mov	dpl, data_lo
		jb	size, ee71
		mov	b, #8
		jmp	ee72
	ee71:
		mov	dph, data_hi
		mov	b, #16
	ee72:
		call	outdata

		clr	CS		; drop CS

		; Poll device status.

		call	status		; returns CY
		ret


erase:
	; Erase addressed location.
	; An erased byte reads as all ones (FF hex).
	; Called with address in registers ADDR_HI:ADDR_LO.
	; Returns CY set to indicate error. Destroys B, DPTR.

		setb	CS		; raise CS

		; Shift out start bit (1) and op code (11).

		mov	dptr, #111b
		mov	b, #3
		call	outdata

		; Shift out address, MSB first.

		mov	dpl, addr_lo	; low byte
		mov	dph, addr_hi	; high byte (may be undefined)
		mov	b, #NADDR	; bit count
		call	outdata

		clr	CS		; drop CS

		; Poll device status.

		call	status		; returns CY
		ret


eral:
	; Erase all addresses.
	; All data will read as all ones (FF hex).
	; Valid only when Vcc is 5.0 Volts +/- 10 percent.
	; Returns CY set to indicate error. Destroys B, DPTR.

		setb	CS		; raise CS

		; Shift out start bit (1), op code (00) and 10.

		mov	dptr, #(10010b SHL (NADDR-2))
		mov	b, #(NADDR+3)
		call	outdata

		clr	CS		; drop CS

		; Poll device status.

		call	status		; returns CY
		ret


ewen:
	; Enable erase/write.
	; Erase/write remains enabled until disabled with EWDS.
	; Returns nothing. Destroys B, DPTR.

		setb	CS		; raise CS

		; Shift out start bit (1), op code (00) and 11.

		mov	dptr, #(10011b SHL (NADDR-2))
		mov	b, #(NADDR+3)
		call	outdata

		clr	CS		; drop CS
		ret


ewds:
	; Disable erase/write.
	; Returns nothing. Destroys B, DPTR.

		setb	CS		; raise CS

		; Shift out start bit (1), op code (00) and 00.

		mov	dptr, #(10000b SHL (NADDR-2))
		mov	b, #(NADDR+3)
		call	outdata

		clr	CS		; drop CS
		ret


status:
	; Read device status.
	; The device output is sampled every 50 microseconds until timeout
	; or ready. Allows a total of approximately 10 milliseconds for
	; the device to signal ready before timing out. 
	; The DO pin is allowed to float before status polling begins.
	; Returns CY cleared to indicate ready, set to indicate timeout.
	; All registers preserved (except flags).

		push	b

		setb	DO		; float pin
		setb	CS		; select device

		mov	b, #220		; 220 * 50 uS = 11 mS

		; Delay 50 microseconds.
	ee40:
		push	b		; 2 uS
		mov	b, #22		; 2 uS
		djnz	b, $		; 2 uS * 22
		pop	b		; 2 uS

		jb	DO, ee41	; jump if DO is high (READY)

		djnz	b, ee40		; next pass
		setb	c		; flag error
		jmp	ee42		; return
	ee41:
		clr	c		; clear error flag
	ee42:
		clr	CS		; deselect device

		pop	b
		ret


indata:
	; Fetch data from the AT93Cxx.
	; The AT93Cxx family presents data most significant bit first.
	; The bit stream is assembled into bytes by function SHIN.
	; The CS pin is controlled by the caller.
	; The DO pin is allowed to float before data is read.
	; If the SIZE flag is cleared, one byte is returned in register
	; DATA_LO. If the SIZE flag is set, two bytes are returned in
	; register pair DATA_HI:DATA_LO.
	; Destroys A.

		setb	DO		; float pin

		; Read and assemble first data byte.

		call	shin
		jnb	size, ee21	; jump if data is only one byte wide

		mov	data_hi, a	; save high byte

		; Read and assemble second data byte.

		call	shin
	ee21:
		mov	data_lo, a	; save low byte
		ret


shin:
	; Shift in eight bits from the AT93Cxx, most significant bit first,
	; and assemble them into a byte. On return, the SK pin is left low.
	; Returns assembled byte in A.

		push	b

		clr	SK		; drop clock
		mov	b, #8		; init loop / delay min one uS
	ee30:
		setb	SK		; raise clock
		nop			; delay min one uS
		mov	c, DO		; read serial data output
		rlc	a		; shift in bit / delay min one uS
		clr	SK		; drop clock
		djnz	b, ee30		; next bit / delay min one uS

		pop	b
		ret


outdata:
	; Massage data and move it out to the AT93Cxx.
	; This function accepts from one to sixteen bits of data and
	; formats it to be shifted out to the AT93Cxx by function SHOUT.
	; The CS pin is controlled by the caller.
	; On entry, expects from one to sixteen bits of data in DPTR,
	; right-justified, and a count of the number of valid bits in B.
	; Returns nothing. Destroys A, DPTR.

		push	b

		mov	a, b		; get bit count
		clr	c		; compare count to eight
		subb	a, #8		;
		jc	ee6		; jump if count less than eight
		jz	ee5		; jump if count equals eight

		; Bit count greater than eight.
		; Use result of first subtraction in compares.

		mov	b, a		; save adjusted bit count
		clr	c		; compare adjusted count to eight
		subb	a, #8		;
		jc	ee2		; jump if count less than eight
		jnz	ee9		; jump if count greater than eight

		; Bit count equals eight.

		mov	a, dph
		jmp	ee4

		; Bit count less than eight.
		; Use count to position data.
	ee2:
		push	b		; save count
		mov	a, dph		; get data
	ee3:
		rr	a		; shift data
		djnz	b, ee3		;
		pop	b		; restore count
	ee4:
		call	shout

		; Did high byte. Do low byte, count equals eight.

		mov	b, #8

		; Bit count equals eight.
	ee5:
		mov	a, dpl
		jmp	ee8

		; Bit count less than eight.
		; Use count to position data.
	ee6:
		push	b		; save count
		mov	a, dpl		; get data
	ee7:
		rr	a		; shift data
		djnz	b, ee7		;
		pop	b		; restore count
	ee8:
		call	shout
	ee9:
		setb	DO		; leave pin floating

		pop	b
		ret


shout:
	; Shift out a byte to the AT93Cxx, most significant bit first.
	; On return, the SK pin is left low.
	; Returns nothing. Destroys A, B.

	ee50:
		clr	SK		; drop clock
		rlc	a		; move bit into CY
		mov	DI, c		; output bit
		nop			; delay min 400 nS
		setb	SK		; raise clock
		djnz	b, ee50		; next bit / delay min one uS

		clr	SK		; drop clock
		ret


		END
