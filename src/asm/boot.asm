; vim: ts=2:sw=2
; asmsyntax=nasm

global start ; Define a public label
extern kmain

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
		; Setup Memory Paging
		; Point the first entry on level 4 to the first entry on level 3
		mov eax, p3_table ; Copy the location of the level 3 table to the 1st register
		or eax, 0b11 ; Set the two least significant bits to 1
		;          ^ Present: This page is in memory
		;         ^  Writable
		mov dword [p4_table + 0], eax ; Store the level 3 table on the 0th location of the level 4 table
		; Do the same for level 3/level 2 page tables
		mov eax, p2_table
		or eax, 0b11
		mov dword [p3_table + 0], eax
		; Point each level 2 entry to a physical memory page
		mov ecx, 0 ; Counter
		.map_p2_table: ; Start loop
			mov eax, 0x200000 ; 2MiB - Page Size
			mul ecx ; Calculate the current index
			or eax, 0b10000011 ; Metadata about the pages - Similar to the upper setup
			;         ^ Huge pages : Bigger than 4KiB
			mov [p2_table + ecx * 8], eax ; Copy the current metadata-marked index to the level 2 entry location
			inc ecx ; Increment the counter
			cmp ecx, 512 ; Loop 512 times
			jne .map_p2_table ; Loop
		; Map 512 * 2MiB = 1024MiB = 1GiB
		; Tell the hardware about the level 4 page table
		mov eax, p4_table ; The Control Register only accepts mov from other registers
		mov cr3, eax
		; Enable Physical Address Extension (PAE)
		mov eax, cr4
		or eax, 1 << 5 ; 0b10000
		mov cr4, eax
		; Set long mode
		mov ecx, 0xC0000080
		rdmsr ; Read Model-Specific Register
		or eax, 1 << 8
		wrmsr ; Write Model-Specific Register
		; Enable paging
		mov eax, cr0
		or eax, 1 << 31
		or eax, 1 << 16
		mov cr0, eax

		; Setup a GDT
		lgdt [gdt64.pointer]

		; Memory-Mapped Screen @ 0xb8000
		;;  _ background color
		;; /  __foreground color
		;; | /
		;; V V
		;; 0 2 48 <- letter, in ASCII
		; Print the following chars:
		; mov word [0xb8000], 0x0248 ; H
		; mov word [0xb8002], 0x0265 ; e
		; mov word [0xb8004], 0x026c ; l
		; mov word [0xb8006], 0x026c ; l
		; mov word [0xb8008], 0x026f ; o
		; mov word [0xb800a], 0x022c ; ,
		; mov word [0xb800c], 0x0220 ;
		; mov word [0xb800e], 0x0257 ; W
		; mov word [0xb8010], 0x026f ; o
		; mov word [0xb8012], 0x0272 ; r
		; mov word [0xb8014], 0x026c ; l
		; mov word [0xb8016], 0x0264 ; d
		; mov word [0xb8018], 0x0221 ; !

		; Update the segment registers
		mov ax, gdt64.data ;Load the target location into a register
		mov ss, ax ; Stack segment
		mov ds, ax ; Data Segment
		mov es, ax ; Extra segment
		; There's still the "cs" code segment register to be updated
		; That can only be done with a long jump
		; Do a long jump into Rustland
		jmp gdt64.code:kmain

		hlt ; Halt

section .bss ; Block started by symbol
	align 4096

	p4_table: ; Level 4 Page Table
		resb 4096 ;Reserve bytes
	p3_table:
		resb 4096
	p2_table:
		resb 4096
section .rodata ; Read-only data
	gdt64:
		dq 0 ; Define quad (64bits)
		; Define code segment
		.code: equ $ - gdt64
			dq (1<<44) | (1<<47) | (1<<41) | (1<<43) | (1<<53)
			; 44: Descriptor type (1 for code and data)
			; 47: Present
			; 41: Read/Write (even though it's read-only)
			; 43: Executable
			; 53: 64-bits
			; Define data segment
		.data: equ $ - gdt64
			dq (1<<44) | (1<<47) | (1<<41)
			; Equal to the code section, except
			; 41: Writable
		.pointer:
		dw .pointer - gdt64 - 1
		dq gdt64
section .text
	bits 64
	long_mode_start:
		; This is true 64-bits mode!

		; This will print "OKAY" with fancy backgrounds and all
		mov rax, 0x2f592f412f4b2f4f
		mov qword [0xb8000], rax

		hlt ; Halt
