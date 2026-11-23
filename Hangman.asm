TITLE Hangman Game         (Hangman.asm)
INCLUDE Irvine32.inc

.data
	categoryCount = 3

	; WORD BANK
	soc1 BYTE "FACEBOOK", 0
    soc2 BYTE "INSTAGRAM", 0
    soc3 BYTE "TIKTOK", 0
    soc4 BYTE "SNAPCHAT", 0
    soc5 BYTE "TWITTER", 0
    soc6 BYTE "WHATSAPP", 0
    soc7 BYTE "TELEGRAM", 0
	socialList DWORD OFFSET soc1, OFFSET soc2, OFFSET soc3, OFFSET soc4, OFFSET soc5, OFFSET soc6, OFFSET soc7
	socialCount = LENGTHOF socialList
	socialCat BYTE "Category: SOCIAL MEDIA",0

	eng1 BYTE "COMPUTER", 0
    eng2 BYTE "ELECTRICAL", 0
    eng3 BYTE "ARCHITECTURAL", 0
    eng4 BYTE "MECHANICAL", 0
    eng5 BYTE "CHEMICAL", 0
    eng6 BYTE "CIVIL", 0
    eng7 BYTE "MECHATRONICS", 0
    eng8 BYTE "PETROLEUM", 0
	engList DWORD OFFSET eng1, OFFSET eng2, OFFSET eng3, OFFSET eng4, OFFSET eng5, OFFSET eng6, OFFSET eng7, OFFSET eng8
	engCount = LENGTHOF engList
	engCat BYTE "Category: ENGINEERING MAJORS", 0

	dig1 BYTE "PROCESSOR", 0
    dig2 BYTE "REGISTER", 0
    dig3 BYTE "MEMORY", 0
    dig4 BYTE "ASSEMBLY", 0
    dig5 BYTE "DEBUGGER", 0
    dig6 BYTE "INSTRUCTION", 0
	digList DWORD OFFSET dig1, OFFSET dig2, OFFSET dig3, OFFSET dig4, OFFSET dig5, OFFSET dig6
	digCount = LENGTHOF digList
	digCat BYTE "Category: DIGITAL DESIGN", 0

	MasterTable DWORD OFFSET socialList, OFFSET socialCat, socialCount, OFFSET engList, OFFSET engCat, engCount, OFFSET digList, OFFSET digCat, digCount

	; PROMPTS
	strTitle	 BYTE "*** HANGMAN GAME ***", 0
	strInput	 BYTE "Guess a letter: ", 0
	strWin		 BYTE "CONGRATULATIONS! You saved him!", 0
	strLose		 BYTE "GAME OVER. Try to save him next time. ", 0
	strReveal	 BYTE "The correct word was: ", 0
	strLives	 BYTE "Lives remaining: ", 0
	strWrong     BYTE "Wrong letters: ", 0
	strPlayAgain BYTE "Play again? (y/n): ", 0

	; VARIABLES
	currListPtr		DWORD ?			; Pointer to the current word list
    currNamePtr		DWORD ?			; Pointer to category name
    currListLen		DWORD ?			; How many words in this list
	ptrWord			DWORD ?			; Pointer to the secret word
	wordLen			DWORD ?			; Length of the random word
	hiddenStr		BYTE 21 DUP(0)	; buffer for "E _ G _ _ _ _ R"
	wrongGuesses	BYTE 21 DUP(0)
    wrongCount		DWORD 0
	lives			DWORD 6
	inputChar		BYTE ? 
	
	; Visuals
    gallowsTop      BYTE "  _______",	0
    gallowsRope     BYTE "  |     |",	0
    gallowsPole     BYTE "  |     ",	0     
    gallowsPoleAdj  BYTE "  |    ",		0      
    gallowsBase     BYTE "  |_______",	0

.code
main PROC
	call Randomize

	StartNewGame:
		call ResetGame
		call PickRandomCat		; Selects a random category
		call PickRandomWord		; Selects a random word from the selected list
		call SetupHiddenStr		; Fills hiddenstr with underscores "_ _ _"

	GameLoop:
		call DrawScreen
		mov	 edx , OFFSET strInput
		call WriteString
		call ReadChar
		call WriteChar
		call CrLf

		; Convert to ALL CAPS
		cmp al , 'a'
		jb  ProcessInput	; Jump if al less than 'a' ASCII = 61h
		cmp al , 'z'
		ja  ProcessInput	; Jump if al greater than 'z' ASCII = 7Ah
		sub al , 32			; Convert to UPPERCASE

	ProcessInput:
		mov		inputChar, al
		call	CheckGuess
		cmp		al, 1
		je		GoodGuess

		; Bad Guess
		dec		lives		
		mov		edi, OFFSET wrongGuesses
		add		edi, wrongcount
		mov		al, inputChar
		mov		BYTE PTR [EDI], al
		inc		wrongCount
		jmp		CheckGameState

	GoodGuess:					; (hiddenStr updated inside CheckGuess)
	CheckGameState:
		mov		edi, OFFSET hiddenStr
		mov		ecx, wordLen
		mov		al, '_'
		repne	scasb			; If there is no underscore remaining, ZF = 1
		jnz		PlayerWon		; Jumps when ZF = 1
		cmp		lives, 0		; Check if player lost
		jle		PlayerLost		; Jump if lives <= 0
		jmp		GameLoop

	PlayerWon:
		call DrawScreen       
		call Crlf
		mov  edx, OFFSET strWin
		call WriteString
		call Crlf
		jmp  AskPlayAgain

	PlayerLost:
		call DrawScreen         
		call Crlf
		mov  edx, OFFSET strLose
		call WriteString
		call Crlf
    
		mov  edx, OFFSET strReveal
		call WriteString
		mov  edx, ptrWord
		call WriteString
		call Crlf
		jmp	 AskPlayAgain
		
	AskPlayAgain:
		call Crlf
		mov  edx, OFFSET strPlayAgain
		call WriteString
		call ReadChar
		call WriteChar          
		call Crlf
		cmp  al, 'y'
		je   StartNewGame
		cmp  al, 'Y'
		je   StartNewGame

QuitGame:
	exit
main ENDP

ResetGame PROC
	mov  lives, 6
    mov  wrongCount, 0
    
    mov  ecx, LENGTHOF wrongGuesses
    mov  edi, OFFSET wrongGuesses
    mov  al, 0
    rep  stosb
    
    mov  ecx, LENGTHOF hiddenStr
    mov  edi, OFFSET hiddenStr
    mov  al, 0
    rep  stosb
    ret
ResetGame ENDP

PickRandomCat PROC

	mov	 eax, categoryCount
	call RandomRange				; EAX = 0 / 1 / 2
	mov	 ebx, 12					; Each entry is 12 bytes
	mul	 ebx
	mov	 esi, OFFSET MasterTable	; Point to entire table
	add	 esi, eax
	mov	 eax, [esi]					; First 4 bytes: List Pointer
	mov	 currListPtr, eax
	mov	 eax, [esi+4]				; Next 4 bytes: Name of Category Pointer
    mov  currNamePtr, eax
    mov  eax, [esi+8]				; Next 4 bytes: Word Count
    mov  currListLen, eax 
	ret

PickRandomCat ENDP

PickRandomWord PROC

	mov		eax , currListLen
	call	RandomRange			; EAX = 0 to currListLen - 1
	mov		ebx, 4				; EBX scaled by 4 (DWORD TYPE)
	mul		ebx
	mov		esi, currListPtr
    add		esi, eax			; ESI points to the specific pointer in the array
    mov		eax, [esi]			; Dereference to get secret word address
    mov		ptrWord, eax
	INVOKE	Str_length, ptrWord
    mov		wordLen, eax
	ret

PickRandomWord ENDP

SetupHiddenStr PROC

    mov  ecx, wordLen       
    mov  edi, OFFSET hiddenStr
	SetupLoop:
		mov  BYTE PTR [edi], '_'
		inc  edi
		loop SetupLoop
		mov  BYTE PTR [edi], 0  
		ret
SetupHiddenStr ENDP

DrawScreen PROC

    call Clrscr
    mov  edx, OFFSET strTitle
    call WriteString
    call Crlf
    mov  edx, currNamePtr		; Display category name
    call WriteString
    call Crlf
    call Crlf
    call DrawHangman			; Draw Hangman
    call Crlf
    mov  ecx, wordLen
    mov  esi, 0

	PrintHiddenStrLoop:
		mov  al, hiddenStr[esi]
		call WriteChar
		mov  al, ' '
		call WriteChar
		inc  esi
		loop PrintHiddenStrLoop
	call Crlf
	call Crlf
    mov  edx, OFFSET strWrong	; Display Wrong Letters
    call WriteString
    mov  ecx, wrongCount
    cmp  ecx, 0
    je   SkipWrongDisplay 
    mov  esi, 0

	PrintWrongLoop:
		mov  al, wrongGuesses[esi]
		call WriteChar
		mov  al, ' '            
		call WriteChar
		inc  esi
		loop PrintWrongLoop

	SkipWrongDisplay:
		call Crlf
    
    mov  edx, OFFSET strLives	; Display lives left
    call WriteString
    mov  eax, lives
    call WriteDec
    call Crlf
    call Crlf
    ret

DrawScreen ENDP

DrawHangman PROC
    mov  edx, OFFSET gallowsTop
    call WriteString
    call Crlf
    mov  edx, OFFSET gallowsRope
    call WriteString
    call Crlf

    ; HEAD
    mov  edx, OFFSET gallowsPole
    call WriteString
    cmp  lives, 5
    jg   Line3Done          
    mov  al, 'O'
    call WriteChar
	Line3Done:
		call Crlf

    ; ARMS / BODY
    mov  edx, OFFSET gallowsPoleAdj
    call WriteString
    
    ; LEFT ARM
    cmp  lives, 3
    jg   CheckBody
    mov  al, '/'
    call WriteChar
    jmp  CheckBodyPart

	CheckBody:
		mov  al, ' '            
		call WriteChar
	CheckBodyPart:
		cmp  lives, 4
		jg   CheckRightArm
		mov  al, '|'
		call WriteChar
		jmp  CheckRightArmPart

	CheckRightArm:
		mov  al, ' '            
		call WriteChar
	CheckRightArmPart:
		cmp  lives, 2
		jg   Line4Done
		mov  al, '\'
		call WriteChar
	Line4Done:
		call Crlf

    ; LEGS
    mov  edx, OFFSET gallowsPoleAdj
    call WriteString
    
    ; LEFT LEG
    cmp  lives, 1
    jg   CheckLegSpacer
    mov  al, '/'
    call WriteChar
    jmp  CheckRightLeg

	CheckLegSpacer:		; Keeps space between two legs
		mov  al, ' '
		call WriteChar
	CheckRightLeg:
		mov  al, ' '            
		call WriteChar

    ; RIGHT LEG
    cmp  lives, 0
    jg   Line5Done
    mov  al, '\'
    call WriteChar
	Line5Done:
		call Crlf

    ; BASE
    mov  edx, OFFSET gallowsBase
    call WriteString
    call Crlf
    ret
DrawHangman ENDP

CheckGuess PROC
    mov  esi, ptrWord
    mov  edi, OFFSET hiddenStr
    mov  ecx, wordLen
    mov  bl, inputChar      
    mov  bh, 0              
    mov  edx, 0             

	CheckLoop:
		mov  al, [esi + edx]    
		cmp  al, bl             
		jne  NextChar
    
	mov  [edi + edx], bl    ; Reveal letter
	mov  bh, 1              ; Set found flag

	NextChar:
		inc  edx
		loop CheckLoop

	mov  al, bh             
    ret
CheckGuess ENDP

END main