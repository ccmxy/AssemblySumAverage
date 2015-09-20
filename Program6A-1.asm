TITLE Low - Level I / O(Program6A.asm)

; Name: Colleen Minor
; Email: minorc@onid.oregonstate.edu
; CS271 - 400 / Assignment 6A							Date: 3 / 15 / 2015
; Description: Program prompts user for 32 - bit numeric input 10 times,
; each time reading the console input as a string of digits, converting
; it from digit to numeric, validating that it is positive and  <10
; digits, and storing into an array of numeric integers.
; It then calculates the sum and average of the integers, converts them
; to digital byte arrays, and displays them as strings.

INCLUDE Irvine32.inc

; ----------------------------------------------------------------------------
; displayString MACRO
; Macro to print the string whos address it receives to the console window.
; ----------------------------------------------------------------------------
displayString MACRO buffer
	push edx
	mov edx, buffer
	call WriteString
	pop edx
ENDM

; ----------------------------------------------------------------------------
; getString MACRO
; Macro to prompt user and return their entry as an array of
; string literals in the passed - in readString.
; ----------------------------------------------------------------------------
getString MACRO lineCount, prompt, readableString, byteCount
	mov    eax, lineCount
	call    writeDec
	displayString prompt
	push    edx
	push    ecx

	mov    edx, readableString
	mov    ecx, byteCount
	call    ReadString
	call    Crlf
	pop    edx
	pop    ecx
ENDM

.data
intro1 BYTE "Programming Assignment 6: Low-Level I/O Procedures ", 0
intro2 BYTE "by Colleen Minor", 0
intro3 BYTE "Please provide 10 unsigned decimel integers.", 0
intro4 BYTE "Each must fit into a 32-bit register.", 0
intro5 BYTE "I will display a list of the integers,", 0
intro6 BYTE "their sum, and their average value.", 0
error1 BYTE "ERROR: Invalid. That is either not a number or is too high.", 0
sum1 BYTE "The sum of these numbers is: ", 0
average1 BYTE "The rounded-down average of these numbers is: ", 0
prompt1    BYTE ". Please enter an unsigned integer that can fit inside of a 32-bit register: ", 0
enteredNums1 BYTE "You entered the following numbers: ", 0
space4 BYTE "    ", 0
goodbye1 BYTE "Thanks for trying out my program!", 0

readArray DWORD 10 DUP(? ); array that users digits are read into
numArray DWORD 10 DUP(? ); array to hold list of numbers
charArray BYTE 10 DUP(? ); array to print to console window

average DWORD ?
sum DWORD ?
listLength DWORD 10

.code
main PROC
	push    OFFSET intro1
	push    OFFSET intro2
	push    OFFSET intro3
	push    OFFSET intro4
	push    OFFSET intro5
	push    OFFSET intro6
	call    introduction

	push    OFFSET error1
	push    OFFSET numArray
	push    SIZEOF readArray
	push    OFFSET readArray
	push    OFFSET prompt1
	call    readVal

	push    OFFSET space4
	push    OFFSET enteredNums1
	push    OFFSET numArray
	push    OFFSET listLength
	call    displayList

	push    OFFSET average
	push    OFFSET numArray
	push    OFFSET sum
	call    getSumAvg

	push    OFFSET charArray
	push    OFFSET sum1
	push    OFFSET sum
	call    writeVal

	push    OFFSET charArray
	call    emptyString

	push    OFFSET charArray
	push    OFFSET average1
	push    OFFSET average
	call    writeVal

	push    OFFSET charArray
	call    emptyString

	push    OFFSET goodbye1
	call    goodbye

	exit
main ENDP
; ----------------------------------------------------------------------------
; introduction PROC
; Procedure to introduce the program.
; receives:
;    @intro1, @intro2, @intro3.... @intro6
; returns:
;    None.
; preconditions:
;    None.
; registers changed :
;    None
; ----------------------------------------------------------------------------
introduction    PROC
	push    ebp
	mov    ebp, esp
	push edx; save edx
	call    Crlf
	displayString[EBP + 28]
	call    Crlf
	displayString[EBP + 24]
; Display description
	call    Crlf
	displayString[EBP + 20]
	call    Crlf
	displayString[EBP + 16]
	call    Crlf
	displayString[EBP + 12]
	call    Crlf
	displayString[EBP + 8]
	call    Crlf
	pop edx
	pop ebp
	ret
introduction    ENDP

; ----------------------------------------------------------------------------
; readVal PROC
; Procedure to fill numArray with list of numbers.
;    Procedure invokes getString macro to first fill an array(readArray)
;    with the ASCII code for digits of a user - entered number,
;    then translate each digit from ASCII to decimel,
;    tests that each digit is valid and is not beyond the 10 ^ 8ths place
;    in significance, then uses iteratitive multiplication to to calculate
;    the decimel value of the number, and finally places the number in
;    numArray, filling it after ten invocations of getString.
; receives:
;    @error1(BYTE), @numArray(DWORD), sizeOf readArray,
;    @readArray(DWORD), @prompt1(BYTE)
; returns:
;    numArray is filled with integers.
; preconditions:
;    error1 and promtp1 are byte arrays containing appropriate messeges,
;    and readArray and numArray are empty.
; registers changed :
;    None
; ----------------------------------------------------------------------------
readVal PROC
LOCAL count: DWORD, tenCount : DWORD, sig : DWORD, thisNum : BYTE,
listIndex: DWORD, tempNum : DWORD, tempSig : DWORD, tempMul : DWORD
	pushad
	mov count, 1
	mov listIndex, 0; Holds index for array of numArray
	mov tenCount, 10
getNum:
	mov tempNum, 0
	call Crlf
	getString count, [ebp + 8], [ebp + 12], [ebp + 16]
; readArray filled with digits entered for one number
; eax contains length of readArray
	mov  esi, [ebp + 12]
; esi points to most significant digit of recently entered number
	mov  sig, eax; digit significance
	Cld
	mov ecx, sig
L2:
	lodsb
	sub al, 48; ASCII to decimel
	cmp al, 0
	jl errorLoop
	cmp al, 9
	jg errorLoop
	mov thisNum, al; pointer for current digit
	cmp sig, 1
	je onesPlace
	cmp sig, 9
	jg errorLoop
	mov tempMul, 1
	mov eax, sig
	mov tempSig, eax
	multiplyLoop :
	mov eax, tempMul
	mov ebx, 10
	mul ebx
	mov tempMul, eax
	DEC tempSig
	cmp tempSig, 1
	jg multiplyLoop
	mov ebx, tempMul
	movzx eax, thisNum
	mul ebx
	add tempNum, eax
	DEC sig
	jmp L2
onesPlace:
	movzx eax, thisNum
	add tempNum, eax
;add number to 10 - number array to be used later.
	dec ecx
	mov eax, listIndex
	mov ebx, 4
	mul ebx; offset from beginning of numArray
	mov esi, [ebp + 20]; @numArray
	mov ebx, tempNum
	mov[esi + eax], ebx; number added to numArray
	call Crlf
	INC count
	INC listIndex
	mov ecx, listIndex
	add edx, 4
	call Crlf
	DEC tenCount
	cmp tenCount, 0
	jg getNum
	popad
	mov[ebp], esp
	ret 24
errorLoop:
	call Crlf
	displayString[ebp + 24]
	call Crlf
	jmp    getNum
readVal    ENDP

; ----------------------------------------------------------------------------
; writeVal PROC
; Procedure to accept a decimel number and converts it to a string of digits.
;    Procedure uses division by 10 to determine the number of digits in the
;    number, then does it again, but with storing the remainders + 48
;    as the ASCII digits in the passed - in empty BYTE array.Then it uses
;    displayString to display the array.
; receives:
;    @charArray(BYTE), @prompt(BYTE), @number(DWORD)
; returns:
;    charArray is filled with the digits of the passed - in DWORD.
; preconditions:
;    charArray is empty and the @DWORD passed in already contains the
;    number that you wish to parse.
; registers changed :
;    None
; ----------------------------------------------------------------------------
writeVal PROC
	LOCAL digitIndex : DWORD
	pushad
	mov    digitIndex, 0
	mov    eax, [ebp + 8]; sum in eax
	mov eax, [eax]
getDigits:
	mov    edx, 0
	mov    ecx, 10
	div    ecx
	cmp    eax, 0
	jg    incIndex
	mov    eax, [ebp + 8]
	mov eax, [eax]
makeChar:
	cmp eax, 0
	je splayIt
	mov    edx, 0
	mov    ecx, 10
	div    ecx
;assign to passed in array
	mov    edi, [ebp + 16]; @charArray
	add    edi, digitIndex
	add    dl, 48
	mov[edi], dl; @charArray + digit index contains ASCII for number
	sub    digitIndex, 1
	jmp    makeChar
incIndex:
	add    digitIndex, 1
	jmp    getDigits
splayIt :
	call Crlf
	displayString[ebp + 12]
	displayString[ebp + 16]
	call    Crlf
	popad
	mov    esp, ebp
	ret    12
writeVal ENDP

; ----------------------------------------------------------------------------
; getSumAvg PROC
; Procedure to calculate the sum and average of the user - entered numbers.
;    Procedure runs through each element of passed - in array and adds it
;    to sum, then divides the sum by the length of the array and stores
;    the quotient in average.
; receives:
;    @average(DWORD), @numArray(DWORD), @sum(DWORD)
; returns:
;    sum contains the sum of all numbers in passed - in array, and
;    average contains the average of the numbers.
; preconditions:
;    numArray is filled with a list of 10 numbers.
; registers changed :
;    None
; ----------------------------------------------------------------------------
getSumAvg PROC
	push    ebp
	mov    ebp, esp
	pushad

	mov edi, [ebp + 12]; @numArray
	mov edx, 0
	mov ebx, [ebp + 8]
	mov[ebx], edx; sum is 0
addSum:
	mov eax, [edi + edx]; num to be added is in eax
	mov ebx, [ebp + 8]
	add[ebx], eax
	add edx, 4
	cmp edx, 40; 40 is end of numArray
	jl addSum
;get the average
	mov edx, 0
	mov eax, sum
	mov ecx, 10
	div ecx
	mov ebx, eax; ebx holds average
	mov edx, [ebp + 16]
	add[edx], ebx
	popad
	pop ebp
	ret 12
getSumAvg ENDP
; ----------------------------------------------------------------------------
; emptyString PROC
; Procedure to clear the passed - in string with STOSB.
;    Procedure uses STOSB to fill all elements of the passed - in string
;    with 0s.
; citation:
;    assembly language for x86 processors(7th ed.) pg. 356
;    by Kip R.Irvine
; receives:
;    @charArray(BYTE)
; returns:
;    charArray is filled with 0s.
; preconditions:
;    None.
; registers changed :
;    None
; ----------------------------------------------------------------------------
emptyString PROC
	push ebp
	mov ebp, esp
	pushad
	mov al, 0
	mov edi, [ebp + 8]; edi points to charArray
	mov ecx, 10
	cld
	rep stosb
	popad
	pop ebp
	ret 4
emptyString ENDP
; ----------------------------------------------------------------------------
; displayList PROC
; Procedure to display the list of numbers from the passed - in DWORD array
; to the console window.
;    Procedure reserves space at the bottom of the stack to hold the listlength
;    and the element count as it runs through the array printing numbers,
;    doing comparisons between the two to check if the list is over.
; receives:
;    @space4(BYTE), @enteredNums1(BYTE), @numArray(DWORD), @listLength(DWORD)
; returns:
;    None.
; preconditions:
;    numArray is filled.
; registers changed :
;    None
; ----------------------------------------------------------------------------
displayList PROC
	push ebp
	mov ebp, esp
	sub esp, 8
	pushad
	displayString[ebp + 16]
	Call crlf
	mov esi, [ebp + 12]
	mov ebx, [ebp + 8]
	mov ebx, [ebx]
	mov DWORD PTR[ebp - 4], 0

	mov eax, [ebp + 20]
	mov eax, [eax]
	mov DWORD PTR[ebp - 8], eax
	mov ecx, 0
L0:
	cmp ecx, ebx
	je L1
	mov eax, [esi]
	call writeDec
	displayString[ebp + 20]
	add esi, 4
	inc ecx
	inc DWORD PTR[ebp - 4]
	mov eax, DWORD PTR[ebp - 8]
	cmp DWORD PTR[ebp - 4], eax
	je L1
	jmp L0
L1 :
	call Crlf
	popad
	mov esp, ebp; remove locals from stack
	pop ebp
	ret
displayList ENDP

; ----------------------------------------------------------------------------
; goodbye PROC
; Procedure to say goodbye.
; receives:
;    @goodbye1(BYTE)
; returns:
;    None.
; preconditions:
;    None.
; registers changed :
;    None
; ----------------------------------------------------------------------------
goodbye PROC
	push ebp
	mov ebp, esp
	push edx
	call Crlf
	displayString[EBP + 8]
	call Crlf
	pop edx
	pop ebp
	ret
goodbye    ENDP

END main