@ Drew Early
@ CS309, Spring 2024
@ Week of 3-24 to 3-30

@ This program will print the sum of the integers from 1 to a user-entered number.

.equ READERROR, 0
.global main
main:
@ PROGRAM ENTRY
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
	CMP r1, #0			@ Check input against 0
	BLT invalidinput		@ If <0, branch to invalid input
	CMP r1, #100			@ Check input against 100
	BGT invalidinput		@ If >100, branch to invalid input
validinput:
	LDR r0, =youEntered		@ Otherwise, load "you entered" string
	BL printf			@ Call printf
	LDR r1, =intInput		@ Load input value to r1
	LDR r1, [r1]			@ (cont)
	LDR r0, =followingIs		@ Load "following is" string
	BL printf			@ Call printf
	LDR r0, =numSum			@ Load "Number	Sum" string
	BL printf			@ Call printf
	B setuploop			@ Branch to beginning of loop
readerror:
	LDR r0, =strInputPattern	@ Load capture pattern to clear input buffer
	LDR r1, =strInputError		@ Load skip pattern to clear input buffer
	BL scanf			@ Call scanf (to clear input buffer)
invalidinput:
	LDR r0, =invalidInput		@ Load string to notify user of invalid input
	BL printf			@ Call printf
	B getinput			@ Branch to getinput to try again
setuploop:
	MOV r4, #1			@ Set r4 to 1, for current value
	MOV r5, #0			@ Set r5 to 0, for cumulative sum
	LDR r6, =intInput		@ Load input value to r6
	LDR r6, [r6]			@ (cont)
continueloop:
	MOV r1, r4			@ Copy current to r1 for printf
	LDR r0, =numTabOut		@ Load number+tab output string location to r0 for printf
	BL printf			@ Call printf
	ADD r5, r5, r4			@ Add current to cumulative sum
	MOV r1, r5			@ Copy cumulative sum to r1 for printf
	LDR r0, =numEndlOut		@ Load number+endl output string location to r0 for printf
	BL printf			@ Call printf
	ADD r4, r4, #1			@ Increment current
	CMP r4, r6			@ Compare current to input value
	BGT exit			@ If current is greater than input value, branch to exit
	B continueloop			@ Otherwise, branch to continueloop
exit:
	MOV r7, #0x01			@ Make SVC exit call 
	SVC 0				@ (cont)

.data
.balign 4
@ String to inform user of the purpose of the program
initString:	.asciz "This program will print the sum of the integers from 1 to a number you enter. Please enter an integer from 0 to 100.\n"
.balign 4
@ String to inform user of the number they entered
youEntered:	.asciz "You entered %d. "
.balign 4
@ String to inform user of the structure of the remainder of the output
followingIs:	.asciz "Following is the number and the sum of the integers from 1 to %d.\n"
.balign 4
@ String containing the column header for the remainder of the output
numSum:		.asciz "Number\tSum\n"
.balign 4
@ String contianing an integer placeholder and a tab
numTabOut:	.asciz "%d\t"
.balign 4
@ String containing an integer placeholder and a newline
numEndlOut:	.asciz "%d\n"
.balign 4
@ String to inform user that their input is invalid and request another input
invalidInput:	.asciz "Invalid input. Please enter an integer from 0 to 100.\n"

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
