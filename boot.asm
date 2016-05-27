; vim: ts=2:sw=2
; asmsyntax=nasm

global start ; Define a public label

; mov: Copy memory around
;; mov size place, thing

;; Colors:
;; | Value | Color          |
;; |-------|----------------|
;; | 0x0   | black          |
;; | 0x1   | blue           |
;; | 0x2   | green          |
;; | 0x3   | cyan           |
;; | 0x4   | red            |
;; | 0x5   | magenta        |
;; | 0x6   | brown          |
;; | 0x7   | gray           |
;; | 0x8   | dark gray      |
;; | 0x9   | bright blue    |
;; | 0xA   | bright green   |
;; | 0xB   | bright cyan    |
;; | 0xC   | bright red     |
;; | 0xD   | bright magenta |
;; | 0xE   | yellow         |
;; | 0xF   | white          |

section .text ; Executable code
bits 32 ; Protected Mode (32 bits)
start:
	; Memory-Mapped Screen @ 0xb8000
	;;  _ background color
	;; /  __foreground color
	;; | /
	;; V V
	;; 0 2 48 <- letter, in ASCII
	; Print the following chars:
	mov word [0xb8000], 0x0248 ; H
	mov word [0xb8002], 0x0265 ; e
	mov word [0xb8004], 0x026c ; l
	mov word [0xb8006], 0x026c ; l
	mov word [0xb8008], 0x026f ; o
	mov word [0xb800a], 0x022c ; ,
	mov word [0xb800c], 0x0220 ;
	mov word [0xb800e], 0x0257 ; W
	mov word [0xb8010], 0x026f ; o
	mov word [0xb8012], 0x0272 ; r
	mov word [0xb8014], 0x026c ; l
	mov word [0xb8016], 0x0264 ; d
	mov word [0xb8018], 0x0221 ; !

	hlt ; Halt
