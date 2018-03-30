include math.inc

.data

Matrix STRUCT
	elements DWORD ?
	rows DWORD ?
	columns DWORD ?
Matrix ends

new_matrix PROTO rows:DWORD,columns:DWORD

matrix_get_row PROTO mat:dword,row:DWORD

matrix_get_element PROTO mat:DWORD,row:DWORD,col:DWORD

matrix_set_element PROTO mat:DWORD,row:DWORD,col:DWORD,value:DWORD

matrix_set_row PROTO mat:DWORD,row:DWORD,reprow:DWORD

matrix_add PROTO dst:DWORD,scr:DWORD ; +=
.code

new_matrix PROC,rows:DWORD,columns:DWORD
	push ebx
	push ecx
	push edx
	invoke Alloc,SIZEOF Matrix
	push eax
	mov ebx,[esp]
	mov ecx,rows
	mov [ebx+4],ecx
	mov edx,columns
	mov [ebx+8],edx
	invoke Alloc,rows
	mov ebx,[esp]
	mov [ebx],eax
	mov ecx,rows
	rows_loop:
		push ecx
		invoke Alloc,columns
		mov ebx,[esp+4]
		mov ebx,[ebx]
		mov edx,[esp]
		shl edx,2
		mov [ebx+edx-4],eax
		pop ecx
	loop rows_loop
	pop eax
	pop edx
	pop ecx
	pop ebx
	RET
new_matrix ENDP

matrix_get_row PROC,mat:DWORD,row:DWORD
	push ebx
	mov eax,mat
	mov eax,[eax]
	mov ebx,row
	shl ebx,2
	mov eax,[eax+ebx]
	pop ebx
	ret
matrix_get_row endp

matrix_get_element PROC,mat:DWORD,row:DWORD,col:DWORD
	push ebx
	invoke matrix_get_row,mat,row
	mov ebx,col
	shl ebx,2
	mov eax,[eax+ebx]
	pop ebx
	ret
matrix_get_element ENDP

matrix_set_element PROC,mat:DWORD,row:DWORD,col:DWORD,value:DWORD
	push ebx
	push eax
	invoke matrix_get_row,mat,row
	mov ebx,col
	shl ebx,2
	PUSH value
	pop DWORD PTR [eax+ebx]
	pop eax
	pop ebx
	ret
matrix_set_element ENDP

matrix_set_row PROC,mat:DWORD,row:DWORD,reprow:DWORD
	pusha
	invoke matrix_get_row,mat,row
	mov ecx,mat
	mov ecx,[ecx+8]
	push cs
	pop es
	mov edi,eax
	mov esi,reprow
	rep movsd
	popa
	ret
matrix_set_row ENDP

matrix_load PROC,src:DWORD,dst:DWORD
	push eax
	push ecx
	mov ecx,src
	mov ecx,[ecx+4]
	the_loop:
		dec ecx
		invoke matrix_get_row,dst,ecx
		invoke matrix_set_row,src,ecx,eax
		inc ecx
	loop the_loop
	pop ecx
	pop eax
	ret
matrix_load endp

matrix_add PROC,dst:DWORD,src:DWORD ; +=
	pusha
	mov ebx,src
	mov ecx,[ebx+4]
	push DWORD PTR [ebx+8]
	mov eax,dst
	mov ebx,[ebx]
	mov eax,[eax]
	outer_loop:
		push ecx
		dec ecx
		shl ecx,2
		mov edi,[ebx+ecx]
		mov esi,[eax+ecx]
		mov edx,[esp+4]
		inner_loop:
			push edx
			dec edx
			shl edx,2
			f_add [edi+edx],[esi+edx]
			pop edx
		dec edx
		jnz inner_loop
		pop ecx
	loop outer_loop
	pop edx
	popa
	ret
matrix_add ENDP

matrix_plus PROC,src:DWORD,dst:DWORD ; +, returns a pointer to the new martrix
	mov eax,src
	invoke new_matrix,[eax+4],[eax+8]
	invoke matrix_load,eax,src
	invoke matrix_add,eax,dst
	ret
matrix_plus ENDP

matrix_sub PROC,dst:DWORD,src:DWORD ; -=
	pusha
	mov ebx,src
	mov ecx,[ebx+4]
	push DWORD PTR [ebx+8]
	mov eax,dst
	mov ebx,[ebx]
	mov eax,[eax]
	outer_loop:
		push ecx
		dec ecx
		shl ecx,2
		mov edi,[ebx+ecx]
		mov esi,[eax+ecx]
		mov edx,[esp+4]
		inner_loop:
			push edx
			dec edx
			shl edx,2
			f_sub [edi+edx],[esi+edx]
			pop edx
		dec edx
		jnz inner_loop
		pop ecx
	loop outer_loop
	pop edx
	popa
	ret
matrix_sub ENDP

matrix_minus PROC,src:DWORD,dst:DWORD ; -, returns a pointer to the new martrix
	mov eax,src
	invoke new_matrix,[eax+4],[eax+8]
	invoke matrix_load,eax,src
	invoke matrix_sub,eax,dst
	ret
matrix_minus ENDP

matrix_elementwize_mul PROC,dst:DWORD,src:DWORD ; *=
	pusha
	mov ebx,src
	mov ecx,[ebx+4]
	push DWORD PTR [ebx+8]
	mov eax,dst
	mov ebx,[ebx]
	mov eax,[eax]
	outer_loop:
		push ecx
		dec ecx
		shl ecx,2
		mov edi,[ebx+ecx]
		mov esi,[eax+ecx]
		mov edx,[esp+4]
		inner_loop:
			push edx
			dec edx
			shl edx,2
			f_mul [edi+edx],[esi+edx]
			pop edx
		dec edx
		jnz inner_loop
		pop ecx
	loop outer_loop
	pop edx
	popa
	ret
matrix_elementwize_mul ENDP

matrix_elementwize_times PROC,src:DWORD,dst:DWORD ; *, returns a pointer to the new martrix
	mov eax,src
	invoke new_matrix,[eax+4],[eax+8]
	invoke matrix_load,eax,src
	invoke matrix_elementwize_mul,eax,dst
	ret
matrix_elementwize_times ENDP

matrix_mul PROC,mat1:DWORD,mat2:DWORD ; matrix multiplication, returns a new matrix
	push ebx
	push ecx
	push edx
	push esi
	push edi

	mov ebx,mat1
	mov ecx,mat2
	invoke new_matrix,[ebx+4],[ecx+8]
	push eax
	push REAL4 ptr 0 ; float sum = 0
	push DWORD ptr 0; int i = 0
	push DWORD ptr 0 ; int j = 0
	push DWORD ptr 0 ; int k = 0

	outer_loop_1:
		mov [esp+4],DWORD PTR 0
		outer_loop_2:
			mov REAL4 PTR [esp+12],0
			mov [esp],DWORD PTR 0
			inner_loop:
				mov ebx,[esp+8]
				mov ecx,[esp]
				invoke matrix_get_element,mat1,ebx,ecx
				fld_eax
				mov ebx,[esp+4]
				invoke matrix_get_element,mat2,ecx,ebx
				
				fld_eax
				fmulp st(1),st
				fld REAL4 PTR [esp+12]
				faddp st(1),st
				fstp REAL4 PTR [esp+12]

			inc DWORD PTR [esp] ; k++
			mov eax,mat1
			mov eax,[eax+8]
			cmp eax,[esp]
			jnz inner_loop

			mov eax,[esp+16]
			mov ebx,[esp+8]
			mov ecx,[esp+4]
			mov edx,[esp+12]
			invoke matrix_set_element,eax,ebx,ecx,edx

		inc DWORD PTR [esp+4] ; j++
		mov eax,[esp+16]
		mov eax,[eax+8]
		cmp eax,[esp+4]
		jnz outer_loop_2
	
	inc DWORD PTR [esp+8] ; i++
	mov eax,[esp+16]
	mov eax,[eax+4]
	cmp eax,[esp+8]
	jnz outer_loop_1
	add esp,16
	pop eax

	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	ret
matrix_mul endp

matrix_scalar_mul PROC,mat:DWORD,scl:REAL4 ; *= 
	pusha
	mov ebx,mat
	mov ecx,[ebx+4]
	push DWORD PTR [ebx+8]
	mov ebx,[ebx]
	outer_loop:
		push ecx
		dec ecx
		shl ecx,2
		mov edi,[ebx+ecx]
		mov edx,[esp+4]
		inner_loop:
			push edx
			dec edx
			shl edx,2
			f_mul [edi+edx],scl
			pop edx
		dec edx
		jnz inner_loop
		pop ecx
	loop outer_loop
	pop edx
	popa
	ret	
matrix_scalar_mul ENDP

matrix_scalar_times PROC,mat:DWORD,scl:REAL4 ; *, returns a new matrix
	mov eax,mat
	invoke new_matrix,[eax+4],[eax+8]
	invoke matrix_load,eax,mat
	invoke matrix_scalar_mul,eax,scl
	ret
matrix_scalar_times endp

matrix_elementwize PROC,mat:DWORD,func:DWORD ; function must be stdcall, and take one REAL4 argument; equivelent to matrix = f(matrix)
	pusha
	mov ebx,mat
	mov ecx,[ebx+4]
	push DWORD PTR [ebx+8]
	mov ebx,[ebx]
	outer_loop:
		push ecx
		dec ecx
		shl ecx,2
		mov edi,[ebx+ecx]
		mov edx,[esp+4]
		inner_loop:
			push edx
			dec edx
			shl edx,2
			push edi
			push edx
			push REAL4 PTR [edi+edx]
			call func
			pop edx
			pop edi
			mov [edi+edx],eax
			pop edx
		dec edx
		jnz inner_loop
		pop ecx
	loop outer_loop
	pop edx
	popa
	ret
matrix_elementwize ENDP

matrix_element_function PROC,mat:DWORD,func:DWORD ; function must be stdcall, and take one REAL4 argument; returns f(matrix)
	mov eax,mat
	invoke new_matrix,[eax+4],[eax+8]
	invoke matrix_load,eax,mat
	invoke matrix_elementwize,eax,func
	ret
matrix_element_function endp

random_matrix PROC,rows:DWORD,columns:DWORD
	push ebx
	push ecx
	push edx
	invoke Alloc,SIZEOF Matrix
	push eax
	mov ebx,[esp]
	mov ecx,rows
	mov [ebx+4],ecx
	mov edx,columns
	mov [ebx+8],edx
	invoke Alloc,rows
	mov ebx,[esp]
	mov [ebx],eax
	mov ecx,rows
	rows_loop:
		push ecx
		invoke Alloc,columns
		mov ebx,[esp+4]
		mov ebx,[ebx]
		mov edx,[esp]
		shl edx,2
		mov [ebx+edx-4],eax
		mov ebx,eax
		mov ecx,columns
		columns_loop:
			push ecx
			dec ecx
			shl ecx,2
			invoke random
			mov [ebx+ecx],eax
			pop ecx
		loop columns_loop
		pop ecx
	loop rows_loop
	pop eax
	pop edx
	pop ecx
	pop ebx
	RET
random_matrix ENDP

ones_matrix PROC,rows:DWORD,columns:DWORD
	push ebx
	push ecx
	push edx
	invoke Alloc,SIZEOF Matrix
	push eax
	mov ebx,[esp]
	mov ecx,rows
	mov [ebx+4],ecx
	mov edx,columns
	mov [ebx+8],edx
	invoke Alloc,rows
	mov ebx,[esp]
	mov [ebx],eax
	mov ecx,rows
	rows_loop:
		push ecx
		invoke Alloc,columns
		mov ebx,[esp+4]
		mov ebx,[ebx]
		mov edx,[esp]
		shl edx,2
		mov [ebx+edx-4],eax
		mov ebx,eax
		mov ecx,columns
		columns_loop:
			push ecx
			dec ecx
			shl ecx,2
			fld1
			fstp REAL4 PTR [ebx+ecx]
			pop ecx
		loop columns_loop
		pop ecx
	loop rows_loop
	pop eax
	pop edx
	pop ecx
	pop ebx
	RET
ones_matrix ENDP
