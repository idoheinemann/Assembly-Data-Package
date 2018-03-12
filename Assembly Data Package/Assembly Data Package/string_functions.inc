include math.inc
.data

str_length PROTO string:DWORD

parse_int PROTO string:DWORD

int_to_string PROTO number:DWORD

concat PROTO st1:DWORD,st2:DWORD

compare PROTO st1:DWORD,st2:DWORD

index_of PROTO st1:DWORD,patt:DWORD
.code

str_length PROC,string:DWORD
	push ebx
	push ecx
	mov ebx,string
	xor ecx,ecx

	get_length_loop:
	mov al,[ebx+ecx]
	cmp al,0
	jz finish
	inc ecx
	jmp get_length_loop

	finish:
	mov eax,ecx
	pop ecx
	pop ebx
	ret
str_length ENDP

parse_int PROC, string:DWORD
	invoke str_length,string
	push ebx
	push ecx
	push edx
	push edi
	push esi

	xor esi,esi
	mov ecx,eax
	xor eax,eax
	mov edx,string
	xor edi,edi

	; check if negative
	cmp byte ptr [edx],"-"
	jnz AfterNeg ; if negative
		inc esi
		inc edx
		dec ecx
	AfterNeg:
	eval_loop:
		xor ebx,ebx
		mov bl,[edx+edi]
		sub bl,"0"
		push edi
		push ecx
		push eax
		push edx
		mov eax,1
		mov edi,10

		jmp check_pow_loop
		pow_loop:
			mul edi
			dec ecx
		check_pow_loop:
			cmp ecx,1
			jnz pow_loop
		after_pow_loop:
		mul ebx
		mov ebx,eax
		pop edx
		pop eax
		pop ecx
		pop edi
		add eax,ebx
		
		inc edi
	loop eval_loop

	test esi,esi
	jz finish ; positive
		neg eax


	finish:
	pop esi
	pop edi
	pop edx
	pop ecx
	pop ebx
	ret
parse_int ENDP

int_to_string PROC, number:DWORD
	push ebx
	push ecx
	push edx
	push edi
	; protect values
	mov edi,10 ; for division

	xor ecx,ecx ; counter
	mov eax,number
	test eax,10000000000000000000000000000000b ; if negative
	jz get_length_loop
	neg eax

	get_length_loop:
		inc ecx
		xor edx,edx
		div edi
	test eax,eax
	jnz get_length_loop

	afterCount:

	inc ecx ; one after must be 0
	push ecx
	mov eax,number
	test eax,10000000000000000000000000000000b ; if negative
	jnz negativeAlloc
		invoke Alloc,ecx
		jmp afterAlloc
		negativeAlloc:
			inc ecx
			invoke Alloc,ecx
			mov byte ptr [eax],"-"
			inc eax ; skip the "-" sign
	afterAlloc:
	pop ecx
	dec ecx

	mov ebx,eax ; ebx = string pointer
	mov eax,number
	test eax,10000000000000000000000000000000b ; if negative
	jz afterNegation
		neg eax ; if negative
	afterNegation:

	push edx
	mov edi,10
	write_string_loop:
		xor edx,edx
		div edi
		add dl,"0" ; to ascii
		mov [ebx+ecx-1],dl
	loop write_string_loop
	pop edx

	test number,10000000000000000000000000000000b ; if negative
	jz finish
		dec ebx ; if the number is negative
	finish:
	mov eax,ebx
	pop edi
	pop edx
	pop ecx
	pop ebx
	; restore values
	ret
int_to_string ENDP

concat PROC,st1:DWORD,st2:DWORD
	push ebx
	push ecx
	push edx
	push edi
	push esi
	push es

	invoke str_length,st1
	mov ebx,eax
	invoke str_length,st2
	mov ecx,eax
	add ecx,ebx
	push eax
	push ebx
	mov ebx,ecx
	invoke Alloc,ecx ; new string
	mov edi,eax
	pop ecx ; st1 len
	mov esi,st1
	push ds
	pop es
	rep movsb
	mov esi,st2
	pop ecx ; st2 len
	rep movsb

	mov eax,edi
	sub eax,ebx
	pop es
	pop esi
	pop edi
	pop edx
	pop ecx
	pop ebx
	ret
concat endp

compare PROC,st1:DWORD,st2:DWORD
	push ecx
	push edi
	push esi
	push es
	invoke str_length,st1
	push eax
	invoke str_length,st2
	cmp eax,[esp]
	je afterFalse
		pop eax
		xor eax,eax
		pop es
		pop esi
		pop edi
		pop ecx
		ret
	afterFalse:
	pop ecx
	push ds
	pop es
	mov esi,st1
	mov edi,st2
	repe cmpsb
	je rettrue
	retfalse:
	xor eax,eax
	jmp finish
	rettrue:
	mov eax,1
	finish:
	pop es
	pop esi
	pop edi
	pop ecx
	ret
	
compare endp

index_of PROC, st1:DWORD,patt:DWORD
	push ecx
	invoke str_length,st1
	push eax
	invoke str_length,patt
	cmp eax,[esp]
	jle ligalInput
		pop eax
		mov eax, -1
		pop ecx
		ret
	ligalInput:
	
	pop ecx
	
	push ebx
	push edx
	push esi
	push edi

	mov edi,st1
	mov esi,patt
	xor edx,edx
	xor ebx,ebx

	scan_loop:
		xor ebx,ebx
		push edi
		tempmatch_loop:
			cmp ebx,eax
			jz found
			mov dl,[edi]
			cmp dl,[esi+ebx]
			jnz nextloop
			inc edi
			inc ebx
		jmp tempmatch_loop
		nextloop:
		pop edi
		inc edi
	loop scan_loop
	mov eax,-1
	jmp final
	found:
		invoke str_length,st1
		sub eax,ecx
		pop edi
	final:
	pop edi
	pop esi
	pop edx
	pop ebx
	pop ecx
	ret
index_of ENDP