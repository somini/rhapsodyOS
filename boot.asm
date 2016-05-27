; vim: ts=2:sw=2
; asmsyntax=nasm

global start ; Define a public label

section .text ; Executable code
bits 32 ; Protected Mode (32 bits)
start:
	hlt ; Halt
