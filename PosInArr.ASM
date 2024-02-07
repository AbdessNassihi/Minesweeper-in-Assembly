CODESEG


; procedure that identifies to wich element in the array corresponds the actual square
PROC GetPosInArray
    ARG	@@arg1:dword,@@arg2:dword

    xor edx,edx
	
	mov ebx,18
	mov eax,[@@arg1]
	div ebx


	mov esi, eax 


	xor eax,eax
	mov eax,[@@arg2]
	div ebx 
	
	
	xor ebx,ebx
	mov ebx,8
	mul ebx
	add eax,esi

	xor ebx,ebx
	mov ebx,4
	mul ebx

    ret

ENDP

proc flag
	ARG	@@arg1:dword,@@arg2:dword
	USES eax, ebx, ecx, edx,esi
	
	call GetPosInArray,[@@arg1],[@@arg2]
	cmp [Squares + eax],7
	je @@remove
	cmp [flagcount],0
	je @@return 
	cmp [Squares + eax],-1
	jne @@return
	mov[Squares + eax],7
	call DecFlags
	ret

	@@remove:	
	mov[Squares + eax],-1
	call IncFlags

	@@return:
	
	ret
	
endp


Proc CheckIfBomb

	ARG	@@arg1:dword,@@arg2:dword
	USES eax, ebx, ecx, edx,esi

	cmp [attempt],0
	je @@removemine

	call GetPosInArray,[@@arg1],[@@arg2]
	cmp [Field + eax],1
	je @@GameOver


	call CheckNeighbours,[@@arg1],[@@arg2]

	ret

	@@GameOver:
		mov[Squares + eax],6
		call MoveRect,[@@arg1],[@@arg2]
		call delay
		xor eax,eax
		xor edx,edx
		xor ebx,ebx
		xor esi,esi
		@@findallmines:
			cmp [Field + eax],1
			je @@openmine
			inc  ebx
			cmp ebx,8
			je @@updateoffset
		@@cont:
			add edx,18
			add eax,4
			cmp eax,256
			je @@finish
			jmp @@findallmines
		
		@@openmine:
			mov[Squares + eax],6
			call MoveRect,edx,esi
			call delay
			inc ebx
			cmp ebx,8
			je @@updateoffset
			jmp @@cont

		@@updateoffset:
			mov edx,0
			mov ebx,0
			add esi,18
			add eax,4
			cmp eax,256
			je @@finish
			jmp @@findallmines

@@removemine:
	inc [attempt]
	call GetPosInArray,[@@arg1],[@@arg2]
	cmp [Field + eax],0
	je @@issafe
	mov [Field + eax],0
	call changelocofmine
	call CheckNeighbours,[@@arg1],[@@arg2]
	@@issafe:
		call CheckNeighbours,[@@arg1],[@@arg2]
		ret
@@finish:
	call delay
	call openFile, offset gameoverfile, offset gameoverhandle
	call readChunk, FRAMESIZE, offset gameoverhandle, offset gameoverframe
	call GameOverBackground, offset buffer,offset gameoverframe
	call refreshVideo
	mov ah,00h
	int 16h
	call setVideoMode, 03h
	mov	ax,04C00h
	int 21h
	ret

	
ENDP CheckIfBomb


proc changelocofmine
USES eax
mov eax,0
@@lookforemptysquare:
	
	cmp [Field + eax],1
	add eax,4
	je @@lookforemptysquare
	mov [Field +eax],1
ret
endp

PROC CountMines
ARG @@arg1: dword
USES esi, eax

mov esi,[@@arg1]
mov ebx,0
@@loop:
	cmp [Neighbour + esi],0
	je @@endproc
	add eax,[Neighbour + esi]
	add esi,4
	cmp [Field + eax],1
	je @@increment
	jmp @@loop
	
@@increment:
	inc ebx
	jmp @@loop

@@endproc:
	ret 

ENDP

PROC CheckNeighbours

	ARG	@@arg1:dword,@@arg2:dword
	USES eax, ebx, ecx, edx,esi

	xor edx,edx
	
	mov ebx,18
	mov eax,[@@arg1]
	div ebx
	mov esi, eax 
	xor eax,eax
	mov eax,[@@arg2]
	div ebx 

    

	cmp esi,0
	je @@LeftBorder
	cmp esi,7
	je @@RightBorder
	cmp eax,0
	je @@TopBorder
	cmp eax,7
	je @@BottomBorder

	call GetPosInArray,[@@arg1],[@@arg2]
	call CountMines,0
	jmp @@count
	


@@LeftBorder:
	cmp eax,0
	je @@TopLeftCorner
	cmp eax,7
	je @@BottomLeftCorner

	call GetPosInArray,[@@arg1],[@@arg2]
	call CountMines,36
	jmp @@count
@@RightBorder:
	cmp eax,0
	je @@TopRightCorner 
	cmp eax,7
	je @@BottomRightCorner

	call GetPosInArray,[@@arg1],[@@arg2]
	call CountMines,60
	jmp @@count

@@TopLeftCorner:
	call GetPosInArray,[@@arg1],[@@arg2]
	call CountMines,84
	jmp @@count
@@BottomLeftCorner:
	call GetPosInArray,[@@arg1],[@@arg2]
	call CountMines,100
	jmp @@count

@@TopRightCorner:
	call GetPosInArray,[@@arg1],[@@arg2]
	call CountMines,116
	jmp @@count

@@BottomRightCorner:
	call GetPosInArray,[@@arg1],[@@arg2]
	call CountMines,132
	jmp @@count

@@TopBorder:
	call GetPosInArray,[@@arg1],[@@arg2]
	call CountMines,148
	jmp @@count

@@BottomBorder:
	call GetPosInArray,[@@arg1],[@@arg2]
	call CountMines,172
	


@@count:
	cmp [Squares + eax],-1
	jne @@skip

	jmp [ NumOfMines + 4 * ebx ]
	
	zero:
		mov [Squares + eax],0
		jmp @@return
	one:
		mov [Squares + eax],1
		jmp @@return
	two:

		mov [Squares + eax],2
		jmp @@return
	three:

		mov [Squares + eax],3
		jmp @@return
	four:
		mov [Squares + eax],4
		jmp @@return

	five:
		mov [Squares + eax],5
		jmp @@return

@@return:
	mov eax,64
	sub eax,[mode]
	inc [exploredsquares]
	cmp [exploredsquares],eax
	je @@win
@@skip:
	ret
@@win:
	call openFile, offset winfile, offset winhandle
	call readChunk, FRAMESIZE, offset winhandle, offset winframe
	call GameOverBackground, offset buffer, offset winframe
	call refreshVideo

	mov ah,00h
	int 16h
	call setVideoMode, 03h
	mov	ax,04C00h
	int 21h
	ret

		
ENDP

