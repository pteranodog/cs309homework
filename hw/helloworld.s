.global main
main:
	MOV r7, #0x04
	MOV r0, #0x01
	MOV r2, #0x0C
	LDR r1, =string1
	SVC 0

	LDR r0, =string2
	BL printf

	MOV r7, #0X01
	SVC 0

.data
.balign 4
string1: .asciz "Hello World\n"
.balign 4
string2: .asciz "Hello World.\n"

.global printf
