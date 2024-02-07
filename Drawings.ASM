CODESEG




; procedure for drawning the green rectangle(for selecting a specefic square)
PROC drawRectangle
	ARG 	@@x0:word, @@y0:word, @@w:word
	USES 	eax, ecx, edx, edi ; note: MUL uses edx!


	movzx eax, [@@y0]
	mov edx, SCRWIDTH
	mul edx
	add	ax, [@@x0]


	mov edi, VMEMADR
	add edi, eax
	
	
	movzx edx, [@@w]	
	mov	ecx, edx
	mov	al,14
	rep stosb
	sub edi, edx		
	

	movzx ecx,[@@w]
	@@vertLoop:
		mov	[edi],al		
		mov	[edi+edx-1],al	
		add	edi, SCRWIDTH
		loop @@vertLoop

	sub edi, SCRWIDTH

	mov	ecx, edx
	rep stosb
	ret
ENDP drawRectangle

; procedure for moving the green rectangle after a key was pressed
PROC MoveRect
	ARG	@@arg1:dword,@@arg2:dword
	USES eax, ebx, ecx, edx,esi

	
	call GetPosInArray,[@@arg1],[@@arg2]

	mov esi,[Squares + eax]
	mov eax, SQUARE_XSTART 
	mov ebx,SQUARE_YSTART

	add eax,[@@arg1]
	add ebx,[@@arg2]

	cmp esi, -1
	je @@noaction

	
	jmp [ DrawDigit + 4 * esi ]

	

	zero_:
		call openFile, offset zerofile, offset zerohandle
		call readChunk, SQUARESIZE, offset zerohandle, offset zeroframe
		call drawsquare, offset zeroframe,48,eax,ebx
		call 	closeFile, offset zerohandle
		jmp @@return
	one_:
		call openFile, offset onefile, offset onehandle
		call readChunk, SQUARESIZE, offset onehandle, offset oneframe
		call drawsquare, offset oneframe,0,eax,ebx
		call 	closeFile, offset onehandle
		jmp @@return
	two_:
		call openFile, offset twofile, offset twohandle
		call readChunk, SQUARESIZE, offset twohandle, offset twoframe
		call drawsquare, offset twoframe,2,eax,ebx
		call 	closeFile, offset twohandle
		jmp @@return
	three_:
		call openFile, offset threefile, offset threehandle
		call readChunk, SQUARESIZE, offset threehandle, offset threeframe
		call drawsquare, offset threeframe,8,eax,ebx
		call 	closeFile, offset threehandle
		jmp @@return
	four_:
		call openFile, offset fourfile, offset fourhandle
		call readChunk, SQUARESIZE, offset fourhandle, offset fourframe
		call drawsquare, offset fourframe,16,eax,ebx
		call 	closeFile, offset fourhandle
		jmp @@return
	five_:
		call openFile, offset fivefile, offset fivehandle
		call readChunk, SQUARESIZE, offset fivehandle, offset fiveframe
		call drawsquare, offset fiveframe,24,eax,ebx
		call 	closeFile, offset fivehandle
		jmp @@return

	mine_:
		call openFile, offset minefile, offset minehandle
		call readChunk, SQUARESIZE, offset minehandle, offset mineframe
		call drawsquare, offset mineframe,40,eax,ebx
		call closeFile, offset minehandle
		jmp @@return
	flag_:
		call openFile, offset flagfile, offset flaghandle
		call readChunk, SQUARESIZE, offset flaghandle, offset flagframe
		call drawsquare, offset flagframe,40,eax,ebx
		call closeFile, offset flaghandle
		jmp @@return

	@@noaction:
		call openFile, offset filledfile, offset filledhandle
		call readChunk, SQUARESIZE, offset filledhandle, offset filledframe
		call drawsquare, offset filledframe,32,eax,ebx
		call refreshVideo
		call closeFile, offset filledhandle
		ret
	
	@@return:
		call refreshVideo
		ret 

ENDP MoveRect


PROC drawsquare
	ARG @@packedframe:dword, @@offset:byte,@@x:dword,@@y:dword
	USES eax, ebx, ecx, edx, edi
	
	xor ebx, ebx
	xor edx, edx
	xor eax, eax
	xor ecx, ecx
	xor edi, edi

	mov ebx, [@@packedframe]	; source pointer -> bin file 
	
	mov eax, [@@y]
	xor edx, edx
	mov edx, SCRWIDTH
	mul edx ; scale y location with frame width length
	add eax,[@@x]
	mov edi, offset buffer
	add edi, eax				; destination pointer 
	
	mov ecx, SQUAREWIDTH
@@screenloop:
	push ecx
	mov ecx, SQUAREWIDTH
	@@printLine:
		mov	al, [ebx] ; index in the colour palette
		add al,[@@offset]
		cmp al, 8
		je @@skip
		jmp @@print
		@@skip:
		inc edi
		jmp @@end
		@@print:
		stosb ; store pixel
		@@end:
		add ebx, 1 ; increment
		loop @@printLine
	mov edx, SCRWIDTH-SQUAREWIDTH		; move one row down in the video memory
	add edi, edx
	pop ecx
	loop @@screenloop
	
	ret 
ENDP drawsquare


; Procedure for drawing the 64 squares
PROC drawBackground
	ARG @@destptr:dword, @@packedframe: dword
	USES eax, ebx, ecx, edi 
	
	mov ebx, [@@packedframe]		; source pointer
	mov edi, [@@destptr]			; destination pointer
	
	mov ecx, FRAMESIZE				; amount of pixels in ecx
	@@printPixel:					
		add ebx,1
		mov	al,[ebx]
		add al,82
		stosb
		loop @@printPixel
	ret 
ENDP drawBackground

PROC updateColourPalette
	ARG	 	@@Ncolours: word, @@palette: dword
	USES 	eax, ecx, edx, esi

	mov esi, [@@palette]	; pointer to source palette
	movzx ecx, [@@Ncolours] ; amount of colors to read (movzx = zero extend)
	
	; multiply ecx by 3 (three color components per color)
	; do it efficiently (2*ecx + ecx)
	mov eax, ecx
	sal eax, 1
	add ecx, eax

	mov dx, 03C8h 	; DAC write port
	xor al, al		; index of first color to change (0)
	out dx, al		; write to IO

	inc dx
	rep outsb		; update all colors

	ret
ENDP updateColourPalette

PROC GameOverBackground
    ARG @@destptr:dword, @@packedframe: dword
    USES eax, ebx, ecx, edi 

    mov ebx, [@@packedframe]        ; source pointer
    mov edi, [@@destptr]            ; destination pointer

    mov ecx, FRAMESIZE                ; amount of pixels in ecx
    @@printPixel:
        add ebx,1
        mov    al,[ebx]
        add al,64
        stosb
        loop @@printPixel
    ret 
ENDP GameOverBackground  

Proc MakeField
	USES 	eax, ecx, edx, esi

	call openFile, offset filledfile, offset filledhandle
	call readChunk, SQUARESIZE, offset filledhandle, offset filledframe

	mov eax,SQUARE_XSTART
	mov ebx,SQUARE_YSTART 
	mov edx,18

	mov esi,0
	mov cx,0
	@@loopi:
		inc esi
		call drawsquare, offset filledframe,32,eax,ebx
		add eax,edx
		cmp esi,7
		jle @@loopi
		xor esi,esi

		inc cx
		mov eax, SQUARE_XSTART
		add ebx,edx
		cmp cx,7
		jle @@loopi
	
	call refreshVideo
	call drawRectangle,SQUARE_XSTART,SQUARE_YSTART ,Square_size

	ret

ENDP MakeField


PROC refreshVideo
	USES ecx, edi, esi

	cld
	mov esi, offset buffer
	mov edi, VMEMADR
	mov ecx, FRAMESIZE  
	rep movsb

	ret
ENDP refreshVideo
