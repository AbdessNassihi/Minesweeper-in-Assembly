CODESEG
PROC startpos
	mov eax, SQUARE_XSTART
	mov ebx, SQUARE_YSTART 

	ret
ENDP startpos

; procedure that executes the right function after the user pressed 
PROC HandleInput
	USES 	eax
	
	@@waitForKeystroke:
		mov	ah,00h
		int	16h
	
		cmp al,27
		je @@exit

		cmp ah,4dh
		je @@right_arrow

		cmp ah,4bh
		je @@left_arrow

		cmp ah,48h
		je @@up_arrow

		cmp ah,50h
		je @@down_arrow

		cmp ah,39h
		je @@opensquare


		cmp ah,21h
		je @@placeflag
		

		jmp	@@waitForKeystroke
	
	@@right_arrow:
		call MoveRect,edx,esi			
		call startpos

		cmp edx,126
		je @@border

		add edx,18
		add ebx,esi
		add eax,edx
		
		call	drawRectangle,eax,ebx,Square_size 
		jmp @@waitForKeystroke

	@@left_arrow:

		call MoveRect,edx,esi
		call startpos

		cmp edx,0
		je @@border

		sub edx,18
		add eax,edx
		add ebx,esi
		
			
		call	drawRectangle,eax,ebx,Square_size 
		jmp @@waitForKeystroke


	@@up_arrow:
		call MoveRect,edx,esi
		call startpos

		cmp esi,0
		je @@border

		sub esi,18
		add eax,edx
		add ebx,esi

		call	drawRectangle,eax,ebx,Square_size 
		jmp @@waitForKeystroke

	@@down_arrow:
		call MoveRect,edx,esi
		call startpos

		cmp esi,126
		je @@border

		add esi,18

		add eax,edx
		add ebx,esi

		call	drawRectangle,eax,ebx,Square_size 
		jmp @@waitForKeystroke
	
	@@border:
		add eax,edx
		add ebx,esi
		call	drawRectangle,eax,ebx,Square_size 
		jmp @@waitForKeystroke

	@@opensquare:
		call startpos

		add eax,edx
		add ebx,esi

		call CheckIfBomb,edx,esi
		call MoveRect,edx,esi
		call	drawRectangle,eax,ebx,Square_size
		jmp @@waitForKeystroke
	
	@@placeflag:
		call startpos

		add eax,edx
		add ebx,esi

		call flag,edx,esi
		call MoveRect,edx,esi
		call	drawRectangle,eax,ebx,Square_size 

		jmp @@waitForKeystroke
	@@exit:
		call	terminateProcess

	ret
ENDP HandleInput



PROC HandleInput_main
	USES 	eax
	
	@@waitForKeystroke:
		mov	ah,00h
		int	16h

		cmp al,27
		je @@exit

		cmp ah,1Ch
		je @@start


		jmp	@@waitForKeystroke
	
	@@start:
	
		call Difficulty
		ret
	@@exit:
		call	terminateProcess

	ret
ENDP HandleInput_main

PROC HandleInput_level
	USES 	eax
	
	@@waitForKeystroke:
		mov	ah,00h
		int	16h

		cmp al,27
		je @@exit

		cmp ah,12h
		je @@easy


		cmp ah,31h
		je @@normal

		cmp ah,23h
		je @@hard

		jmp	@@waitForKeystroke
	
	@@easy:
	
		mov [mode],5
		call Totalflags, 5
		ret

	@@normal:
	
		mov [mode],10
		call Totalflags, 10
		ret 

	@@hard:
	
		mov [mode],15
		call Totalflags, 15
		ret 
	@@exit:
		call	terminateProcess
		ret

ENDP HandleInput_level

