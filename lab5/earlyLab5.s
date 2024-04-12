@ Drew Early
@ CS309, Spring 2024
@ Week of 4-8 to 4-13

@ This program will simulate the one-day operation of a simple teller machine 

.equ READERROR, 0
.global main
main:
@ PROGRAM ENTRY
	MOV r5, #50
	MOV r6, #50
	MOV r7, #0
	MOV r8, #0
prompt:
	LDR r0, =initString		@ Load initial string location to r0
	BL printf			@ Call printf
getinput:
	LDR r0, =numInputPattern	@ Load input capture pattern location to r0
	LDR r1, =intInput		@ Load input capture location to r1
	BL scanf			@ Call scanf
	CMP r0, #READERROR		@ Check r0 for a readerror
	BEQ readerror			@ If r0 has a readerror, branch to readerror handler
	LDR r1, =intInput		@ Otherwise, load input value to r1
	LDR r1, [r1]			@ (cont)
checkvalidity:
	CMP r1, #-9
	BEQ secretcode
	CMP r1, #10			@ Check input against 0
	BLT invalidinput		@ If <0, branch to invalid input
	CMP r1, #200			@ Check input against 100
	BGT invalidinput		@ If >100, branch to invalid input
	MOV r0, r1
divisiblebyten:
	SUB r0, r0, #10
	CMP r0, #0
	BLT invalidinput
	BGT divisiblebyten
validinput:
	MOV r4, r1
	B checktransaction
readerror:
	LDR r0, =strInputPattern	@ Load capture pattern to clear input buffer
	LDR r1, =strInputError		@ Load skip pattern to clear input buffer
	BL scanf			@ Call scanf (to clear input buffer)
invalidinput:
	LDR r0, =invalidInput		@ Load string to notify user of invalid input
	BL printf			@ Call printf
	B prompt			@ Branch to getinput to try again
checktransaction:
	BL getinventory
	CMP r0, r4
	BLT notenoughfunds
	B distributetwenty
notenoughfunds:
	LDR r0, =notEnoughFundsStr
	BL printf
	B prompt
distributetwenty:
	CMP r4, #0
	BEQ distributeten
	CMP r4, #10
	BEQ distributeten
	CMP r5, #0
	BEQ distributeten
	SUB r4, r4, #20
	SUB r5, r5, #1
	LDR r0, =outputTwenty
	BL printf
	B distributetwenty
distributeten:
	CMP r4, #0
	BEQ distributioncomplete
	CMP r6, #0
	BEQ distributioncomplete
	SUB r4, r4, #10
	SUB r6, r6, #1
	LDR r0, =outputTen
	BL printf
	B distributeten
distributioncomplete:
	LDR r0, =newline
	BL printf
	ADD r7, r7, #1
	CMP r7, #10
	BEQ exit
	CMP r5, #0
	CMPEQ r6, #0
	BEQ exit
	B prompt
secretcode:
	MOV r1, r5
	LDR r0, =twentiesInventory
	BL printf
	MOV r1, r6
	LDR r0, =tensInventory
	BL printf
	BL getinventory
	MOV r1, r0
	LDR r0, =remainingFunds
	BL printf	
	MOV r1, r7
	LDR r0, =totalValidStr
	BL printf
	BL getinventory
	MOV r2, #1000
	ADD r2, r2, #500
	SUB r1, r2, r0
	LDR r0, =distTotal
	BL printf
	B prompt
getinventory:
	MOV r3, lr
	MOV r0, r5
	BL multbytwenty
	MOV r2, r0
	MOV r0, r6
	BL multbyten
	ADD r2, r2, r0
	MOV r0, r2
	BX r3
multbyten:
	MOV r1, r0, LSL #3
	ADD r1, r0, LSL #1
	MOV r0, r1
	BX lr
multbytwenty:
	MOV r1, r0, LSL #4
	ADD r1, r0, LSL #2
	MOV r0, r1
	BX lr
exit:
	RSB r1, r5, #50
	LDR r0, =distTwenties
	BL printf
	RSB r1, r6, #50
	LDR r0, =distTens
	BL printf
	BL getinventory
	MOV r1, r0
	LDR r0, =remainingFunds
	BL printf	
	MOV r1, r7
	LDR r0, =totalValidStr
	BL printf
	BL getinventory
	MOV r2, #1000
	ADD r2, r2, #500
	SUB r1, r2, r0
	LDR r0, =distTotal
	BL printf
	MOV r7, #0x01			@ Make SVC exit call 
	SVC 0				@ (cont)

.data
.balign 4
@ String to inform user of the purpose of the program
initString:	.asciz "Welcome to the teller machine. Please enter a withdraw amount that is a multiple of 10 and between 10 and 200.\n"
.balign 4
@ String to inform user that their input is invalid and request another input
invalidInput:	.asciz "Invalid input.\n"
.balign 4
notEnoughFundsStr: .asciz "This machine does not have enough funds to fulfill your request. Please enter a smaller amount.\n"

.balign 4
totalValidStr: .asciz "Valid transactions: %d\n"
.balign 4
distTens: .asciz "Tens distributed: %d\n"
.balign 4
distTwenties: .asciz "Twenties distributed: %d\n"
.balign 4
distTotal: .asciz "Total distributed: $%d\n"
.balign 4
remainingFunds: .asciz "Remaining funds: $%d\n"
.balign 4
tensInventory: .asciz "Tens inventory: %d\n"
.balign 4
twentiesInventory: .asciz "Twenties inventory: %d\n"

.balign 4
outputTen: .asciz "10..."
.balign 4
outputTwenty: .asciz "20..."
.balign 4
newline: .asciz "Done!\n"

.balign 4
@ Location for holding the user-input integer
intInput: .word 0

.balign 4
@ Input capture pattern for an integer
numInputPattern: .asciz "%d"
.balign 4
@ Input capture pattern for anything
strInputPattern: .asciz "%[^\n]"
.balign 4
@ Input skip pattern
strInputError: .skip 100*4

@ printf and scanf from c library
.global printf
.global scanf
