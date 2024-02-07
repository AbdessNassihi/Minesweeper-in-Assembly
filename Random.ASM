CODESEG

PROC DefinePosOfMines

    USES ecx,eax,esi,edx,ebx
    mov ecx, [mode]
    mov esi,0
    @@loopke:
        
        call    rand
 
        xor edx,edx
        mov ebx,8
        div ebx
        mov [PosOfMine + esi],edx
        add esi,4
        dec ecx
        jnz @@loopke
    
    xor edx,edx
    mov eax,[PosOfMine]
    mov ebx,4
    div ebx
    mov [PosOfMine],eax
    ret
ENDP

PROC DefineRowWithMines
    USES ecx,eax,esi,edx,ebx
    mov ecx,0
    mov esi,0
    @@loopke:
        
        call    rand
 
        xor edx,edx
        mov ebx,2
        div ebx

        cmp edx,1
        jne @@continue
        inc ecx
        @@continue:
            add [SelectRow + esi],edx
            add esi,4
            cmp ecx,[mode]
            je @@ret
            cmp esi,32
            je @@esitozero
            jmp @@loopke

        @@esitozero:
            mov esi,0
            jmp @@loopke
        @@ret:
            ret
ENDP

proc PlaceMines
USES ecx,eax,esi,edx,ebx

mov eax,0
mov esi,0
mov ebx,0

@@loopa:
    
    cmp [SelectRow + esi],0
    je @@stop

    mov eax,[index]
    
    xor edx,edx
    mov ebx,32
    mul ebx
    mov [row],eax

    @@loopb:
        mov eax,[pos]
        mov eax, [PosOfMine + eax]
        add [pos],4
        mov ebx,4
        mul ebx
        add eax,[row]

        mov ebx,[SelectRow + esi]
        mov [Field + eax],1
        inc [count]
        cmp [count],ebx
        je @@stop
        jmp @@loopb

    @@stop:
        mov [count],0
        inc [index]
        add esi,4
        cmp [index],8
        je @@finish
        jmp @@loopa

    @@finish:
        ret


ENDP


PROC rand_init
    USES    eax, ecx, edx

    mov     ah, 02ch       
    int     21h

    mov     ax, dx         
    shl     eax, 16
    mov     ax, cx

    mov     ah, 02ah        
    int     21h

    shl     ecx, 16         
    mov     cx, dx
    xor     eax, ecx
    
    mov     [rand_seed], eax

    ret
ENDP rand_init

PROC rand
    USES    ebx, ecx, edx

    mov     eax, [rand_seed]
    mov     ecx, RAND_A
    mul     ecx
    add     eax, RAND_C
    mov		ebx, eax
	shr		ebx, 16
	
	mul		ecx
	add     eax, RAND_C
	mov     [rand_seed], eax
	mov		ax, bx

    ret
ENDP rand
