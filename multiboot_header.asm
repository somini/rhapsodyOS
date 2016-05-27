; vim: ts=2:sw=2
; asmsyntax=nasm

; dd: Define double word (32bits)
; dw: Define word (16bits)

section .multiboot_header
header_start:
	dd 0xe85250d6                ; Magic Number - Multiboot Header
	dd 0                         ; Protected Mode code
	dd header_start - header_end ; Header Length

	; Checksum
	; Unsigned integer
	dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

	; End Tag
	dw 0 ; Type
	dw 0 ; Flags
	dw 8 ; Size
header_end:
