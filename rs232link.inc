
rjmp endrsinc	    ; Skip to the end of this file
.equ UBRR0H = $c5
.equ UBRR0L = $c4
.equ UCSR0A = $c0
.equ UCSR0B = $c1
.equ UCSR0C = $c2
.equ UDR0 = $c6
.equ UDREn = 5


sendcharr17:
  lds r0,UCSR0A     ; read UART status
  sbrs r0,UDREn     ; check whether transmitter empty
  rjmp sendcharr17  ; if not, repeat
  sts UDR0,r17      ; send r17 via UART
  ret


sendr16tolaptop:
  ; init UART if needed
  push r16
  lds r16,UCSR0B
  sbrc r16,3   ; if tx-enable-bit not set, we still need to init the UART
  rjmp skipUARTinit
  ldi r16,0x00
  sts UBRR0H,r16
  ldi r16,0x67
  sts UBRR0L,r16  ; 9600 baud at 16 MHz
  ldi r16,0x08
  sts UCSR0B,r16  ; enable TX
  ldi r16,0x0e
  sts UCSR0C,r16  ; 8 databits, 2 stopbits
  ldi r16,0x40
  sts UDR0,r16    ; send the character '@'

skipUARTinit:
  pop r16

; save registers
  push r0
  push r18
  push r16
  push r17

  ldi r18,$8     ; r18 will count the bits; there are 8 bits in a byte

uartL01:
  ldi r17,$18    ; $18 is half of ascii code for digit '0'
  lsl r16        ; shift bit out of r16...
  rol r17        ; ...and into r17, doubling r17 in the process; r17 is now ascii '0' or '1'
  call sendcharr17

  dec r18    
  brne uartL01   ; repeat until we've sent all 8 bits

  ldi r17,0x0d   ; send Carriage Return
  call sendcharr17
  ldi r17,0x0a   ; send Line Feed
  call sendcharr17

; restore registers and return
  pop r17
  pop r16
  pop r18
  pop r0
  ret

endrsinc:




