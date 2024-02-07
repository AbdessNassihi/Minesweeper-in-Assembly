
IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

VMEMADR EQU 0A0000h	
SCRWIDTH EQU 320	
SCRHEIGHT EQU 200	
FRAMESIZE EQU SCRHEIGHT *SCRWIDTH

Square_size EQU 18

SQUAREWIDTH EQU 18
SQUARESIZE EQU SQUAREWIDTH*SQUAREWIDTH

SQUARE_XSTART EQU 80
SQUARE_YSTART  EQU 20

RAND_A = 1103515245
RAND_C = 12345


CODESEG
include "Random.ASM"
include "PosInArr.ASM"
include "Drawings.ASM"
include "Keyb.ASM"
include "Files.ASM"


PROC setVideoMode
	ARG 	@@VM:byte
	USES 	eax

	movzx ax,[@@VM]
	int 10h

	ret
ENDP setVideoMode


proc delay
    USES esi,eax,ecx,ebx,edx

    mov esi,2500000
    @@loopi:
        dec esi
        cmp esi,0
        je @@stop
        jmp @@loopi
    @@stop:
        ret
endp




PROC closeallfiles
	USES eax
	call 	closeFile, offset onehandle
	call 	closeFile, offset twohandle
	call 	closeFile, offset threehandle
	call 	closeFile, offset fourhandle
	call 	closeFile, offset fivehandle
	call 	closeFile, offset filledhandle
	call 	closeFile, offset minehandle
	call 	closeFile, offset zerohandle
	call 	closeFile,offset winhandle
	call 	closeFile, offset flaghandle
	call 	closeFile,offset gameoverhandle
	call 	closeFile, offset bghandle
	call setVideoMode, 03h
	mov	ax,04C00h
	int 21h
	ret
ENDP closeallfiles

PROC terminateProcess
	USES eax
	call setVideoMode, 03h
	mov	ax,04C00h
	int 21h
	ret
ENDP terminateProcess

Proc Mainmenu

	call DisplayText,offset Mainmenu_title,53,1
	call DisplayText,offset Mainmenu_sub,53,4
	call DisplayText,offset section,53,5
	call DisplayText,offset instruction,0,8
	call DisplayText,offset gamemenu,45,20
	
	
	call HandleInput_main
	ret
ENDP Mainmenu

Proc Difficulty

	call	fillBackground, 0
	call DisplayText,offset game_level,51,1
	call DisplayText,offset levels,48,8

	call HandleInput_level
	ret

endp Difficulty

Proc DisplayText
ARG @@mess: dword ,@@x_pos:byte,@@y_pos:byte

	mov ah, 02h
	mov bh, 0 
	mov dh, [@@y_pos]
	mov dl, [@@x_pos] 
	int 10h 


	mov ah, 09h 
	mov bl,0Fh
	mov edx, [@@mess] 
	int 21h 

	ret
endp DisplayText

Proc Totalflags
	ARG @@Val: byte

	mov al,[@@Val]
	mov [flagcount], al

	ret
endp Totalflags

Proc IncFlags
	

	mov ah, [flagcount]
	inc ah
	mov [flagcount], ah
	ret

endp IncFlags

Proc DecFlags
	

	mov ah, [flagcount]
	dec ah
	mov [flagcount], ah

	ret
endp DecFlags

Proc StartGame
	xor edx,edx
	call rand_init
	call DefinePosOfMines
    call DefineRowWithMines
    call PlaceMines

	xor edx,edx 
	xor esi,esi
	call updateColourPalette, 100 , offset palette

	call openFile, offset bgfile, offset bghandle
	call readChunk, FRAMESIZE, offset bghandle, offset bgframe
	call drawBackground, offset buffer, offset bgframe
	call refreshVideo
	
	call MakeField
	ret
endp StartGame

PROC fillBackground

	ARG @@Val: byte
	USES eax, ecx, edi
	mov al,[@@Val]
	mov edi, VMEMADR
	mov ecx, SCRWIDTH *SCRHEIGHT

	rep stosb

	ret
ENDP fillBackground

PROC main
	sti
	cld
	
	push ds
	pop	es
	call	setVideoMode,13h
	call	fillBackground, 0
	call Mainmenu
	call StartGame



	call	HandleInput
ENDP main

; -------------------------------------------------------------------

UDATASEG

	onehandle dw ?
	twohandle dw ?
	threehandle dw ?
	fourhandle dw ?
	fivehandle dw ?
	filledhandle dw ?
	minehandle	dw ?
	zerohandle dw ?
	flaghandle	dw ?
	gameoverhandle	dw ?
	winhandle	dw ?
	bghandle dw ?

    

	
	oneframe 			db SQUARESIZE dup (?)
	twoframe 			db SQUARESIZE dup (?)
	threeframe 			db SQUARESIZE dup (?)
	fourframe 			db SQUARESIZE dup (?)
	fiveframe 			db SQUARESIZE dup (?)
	filledframe 		db SQUARESIZE dup (?)
	mineframe			db SQUARESIZE dup (?)
	zeroframe			db SQUARESIZE dup (?)
	flagframe			db SQUARESIZE dup (?)
	gameoverframe		db FRAMESIZE dup (?)
	winframe			db FRAMESIZE dup (?)
	bgframe				db FRAMESIZE dup (?)
	
		

	buffer db FRAMESIZE dup (?)
	rand_seed   dd ?

DATASEG

	Mainmenu_title	db 	'Minesweeper','$'
	Mainmenu_sub	db	'Instructions','$'
	section			db 	'------------','$'
	instruction		db	'Use the ARROWS to move',13,10,' ',13,10,'Press SPACE to unveil the square',13,10,' ',13,10,'Press F to place/remove a flag','$'



	gamemenu		db 'Press ENTER to start the game','$'
	game_level		db 	'Choose difficulty','$'
	levels			db	'Press E for easy (5 mines)',13,10,' ',13,10
					db	'        Press N for normal (10 mines)',13,10,' ',13,10
					db	'        Press H for hard (15 mines)','$'

	
	newline     db  0dh, 0ah, '$'
	Squares dd 	-1,-1,-1,-1,-1,-1,-1,-1
			dd	-1,-1,-1,-1,-1,-1,-1,-1
			dd	-1,-1,-1,-1,-1,-1,-1,-1
			dd	-1,-1,-1,-1,-1,-1,-1,-1
			dd	-1,-1,-1,-1,-1,-1,-1,-1
			dd	-1,-1,-1,-1,-1,-1,-1,-1
			dd	-1,-1,-1,-1,-1,-1,-1,-1
			dd  -1,-1,-1,-1,-1,-1,-1,-1
			

    Field   dd 0,0,0,0,0,0,0,0
			dd 0,0,0,0,0,0,0,0
			dd 0,0,0,0,0,0,0,0
			dd 0,0,0,0,0,0,0,0
			dd 0,0,0,0,0,0,0,0
			dd 0,0,0,0,0,0,0,0
			dd 0,0,0,0,0,0,0,0
			dd 0,0,0,0,0,0,0,0
	
	mode 		dd 0
	flagcount	db 0
	PosOfMine   dd  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	SelectRow   dd  0,0,0,0,0,0,0,0
	attempt		dd  0

	Neighbour 	dd -36,4,4,24,8,24,4,4,0,-32,4,32,28,4,0,-36,4,28,32,4,0,4,28,4,0,-32,4,32,0
				dd	-4,32,4,0,-36,4,28,0,-4,8,24,4,4,0,4,-8,-24,-4,-4,0
	NumOfMines	dd zero , one, two, three, four,five
	DrawDigit   dd zero_,one_,two_,three_,four_,five_,mine_,flag_
	numofmines  dd 0
	row         dd 0
	count       dd 0
	pos         dd 0
	index       dd 0
	exploredsquares	dd 0



	;Color Palette
palette 		db 0,0,0
				db 63,63,63
				db 40,40,40
				db 23,23,23
				db 43,43,44			;one
				db 2,2,62
				db 49,49,45
				db 21,21,55
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 29,29,29		;two
				db 29,29,29
				db 29,29,29
				db 32,32,32
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 42,41,41	;three
				db 62,3,3
				db 45,49,49
				db 55,20,20
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 42,42,43		;four
				db 2,2,33
				db 48,48,47
				db 24,24,40
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 41,40,40 	;five
				db 33,3,3
				db 47,49,39
				db 21,21,0
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 47,47,47		;filled
				db 43,43,43
				db 38,38,38
				db 20,20,20
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0  		;mine
				db 63,0,0
				db 63,63,63
				db 59,59,59
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 47,47,47			;zero
				db 46,46,46
				db 42,42,42
				db 34,34,34
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0        ;flag
                db 63,0,0
                db 48,48,48
                db 48,48,48
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 63,63,63  ; gameover
				db 16,16,16
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0		;background
				db 50,50,50
				db 0,0,0
				db 40,40,40
				db 23,23,23
				db 0,0,0
				db 0,0,0
				db 0,0,0
				db 0,0,0
	


	
	; Error Messages
	openErrorMsg 	db "could not open file", 13, 10, '$'
	readErrorMsg 	db "could not read data", 13, 10, '$'
	closeErrorMsg 	db "error during file closing", 13, 10, '$'

	; Files
	bgfile				db ".bin/bg.bin", 0
	onefile				db ".bin/one.bin", 0
	twofile				db ".bin/two.bin", 0
	threefile			db ".bin/three.bin", 0
	fourfile			db ".bin/four.bin", 0
	fivefile			db ".bin/five.bin", 0
	filledfile			db ".bin/filled.bin", 0
	zerofile			db ".bin/zero.bin", 0
	minefile			db".bin/mine.bin", 0
	flagfile			db".bin/flag.bin", 0
	gameoverfile		db".bin/gameover.bin", 0
	winfile				db".bin/win.bin", 0
	
; -------------------------------------------------------------------
; STACK
; -------------------------------------------------------------------
STACK 100h

END main
