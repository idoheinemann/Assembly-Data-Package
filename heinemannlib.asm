include \masm32\include\masm32rt.inc


.data

Node STRUCT
	value DWORD ? ; value of the node
	next DWORD ? ; pointer to the next node
Node ENDS

Queue STRUCT
	head DWORD ? ; first out (Node*)
	tail DWORD ? ; last in (Node*)
	count DWORD ? ; guess (unsigned int)
Queue ENDS

Stack STRUCT
	pointer DWORD ? ; Node*
	count DWORD ? ; unsigned int
Stack ENDS

List STRUCT
	items DWORD ? ; pointer to array
	count DWORD ? ; unsigned int
List ENDS

;;;; NODE ;;;;

new_node PROTO value:DWORD,next:DWORD

delete_node PROTO node:DWORD

;;;; QUEUE ;;;; 

queue_push PROTO queue:DWORD, value:DWORD

queue_pop PROTO queue:DWORD

delete_queue PROTO queue:DWORD

;;;; STACK ;;;;

stack_push PROTO queue:DWORD, value:DWORD

stack_pop PROTO queue:DWORD

delete_stack PROTO queue:DWORD

;;;; BOTH STACK AND QUEUE

peek PROTO object:DWORD

;;;; BIN TREE ;;;;


;;;; lIST ;;;; 

list_insert PROTO list:DWORD,value:DWORD

list_set PROTO list:DWORD, index:DWORD, value:DWORD

list_index_of PROTO list:DWORD, item:DWORD

list_delete_at PROTO list:DWORD, index:DWORD

list_get_item PROTO list:DWORD, index:DWORD

delete_list PROTO list:DWORD

.code

;;;; NODE ;;;;

new_node PROC ,value:DWORD, next:DWORD ; creates a node and returns a pointer
	invoke Alloc,SIZEOF Node ; allocate node

	push value
	pop DWORD PTR [eax] ; initialize value

	push next
	pop DWORD PTR [eax+4] ; initialize next

	ret
new_node ENDP

delete_node PROC, node:DWORD ; deletes the node and all it's children
	push ebx
	push edx
	push ecx
	push eax
	
	push node ; push the node to go to ebx at first
	delete_child_loop:
		pop ebx ; get the current node pointer
		push DWORD PTR [ebx+4] ; push the next pointer
		invoke Free,ebx ; delete the current node
	cmp DWORD PTR [esp],NULL ; stop if the next node is a nullptr
	jne delete_child_loop

	pop eax
	pop ecx
	pop edx
	pop ebx
	ret
delete_node ENDP

;;;; QUEUE ;;;;

queue_push PROC, queue:DWORD, value:DWORD ; add an element to the end of the queue
	pusha
	
	invoke new_node,value,NULL ; eax = new Node(value = value,next = NULL)

	mov ebx,queue
	inc DWORD PTR [ebx+8] ; count++
	cmp DWORD PTR [ebx+8],1 ; queue is empty
	je HandleNull

	mov edx,[ebx+4] ; edx is a pointer to tail
	mov [edx+4],eax ; tail.next = new node

	jmp final

	HandleNull: ; if head == null
	mov [ebx],eax ; queue.head is the new node

	final:
	mov [ebx+4],eax ; queue.tail is the new node
	popa
	ret
queue_push ENDP

queue_pop PROC,queue:DWORD ; retrives an element from the beginning of the queue
	mov eax,queue
	
	cmp DWORD PTR [eax+8],0 ; if count == 0 return null
	jne notNull
		mov eax,NULL
		ret
	notNull:
	
	dec DWORD PTR [eax+8] ; count--
	mov eax,[eax] ; pointer to head
	mov eax,[eax] ; head.value
	pusha

	mov ebx,queue
	mov edx,[ebx] ; edx = queue.head
	mov edx,[edx+4] ; head.next

	push edx
	invoke Free,[ebx] ; delete node
	pop edx

	mov [ebx],edx ; queue.head = queue.head.next

	popa
	finish:
	ret
queue_pop ENDP

delete_queue PROC, queue:DWORD
	pusha
	
	mov ebx,queue
	mov ecx,[ebx+8] ; queue.count
	push DWORD PTR[ebx]
	delete_nodes_loop:
		pop ebx
		push DWORD PTR [ebx+4] ; ebx = ebx.next
		invoke Free,ebx ; delete node
	loop delete_nodes_loop
	invoke Free,queue
	
	popa
	ret
delete_queue ENDP

;;;; STACK ;;;;

stack_push PROC, stack:DWORD, value:DWORD
	pusha
	mov ebx,stack
	invoke new_node,value,[ebx] ; eax = new Node(value = value,next = stack.pointer)
	mov ebx,stack
	inc DWORD PTR [ebx+4] ; count++
	mov [ebx],eax ; pointer = new Node(value,old pointer)

	final:
	popa
	ret
stack_push ENDP

stack_pop PROC,stack:DWORD
	mov eax,stack
	cmp DWORD PTR [eax+4],0 ; if count is 0
	jne notNull
		mov eax,NULL
		ret
	notNull:
	dec DWORD PTR [eax+4]
	mov eax,[eax] ; pointer to stack pointer
	mov eax,[eax] ; pointer.value
	pusha

	mov ebx,stack
	mov edx,[ebx] ; edx = stack.pointer
	mov edx,[edx+4] ; stack.next

	push edx ; push stack.pointer.next
	push ebx
	invoke Free,[ebx] ; delete node
	pop ebx
	pop DWORD PTR [ebx] ; stack.pointer = stack.pointer.next

	popa
	finish:
	ret
stack_pop ENDP

delete_stack PROC, stack:DWORD
	pusha
	
	mov ebx,stack
	mov ecx,[ebx+4] ; stack.count
	push DWORD PTR [ebx]
	delete_nodes_loop:
		pop ebx
		push DWORD PTR [ebx+4] ; ebx = ebx.next
		invoke Free,ebx ; delete node
	loop delete_nodes_loop
	invoke Free,stack
	
	popa
	ret
delete_stack ENDP

;;;; BOTH ;;;;

peek PROC,object:DWORD ; works on both Queue and Stack
	mov eax,object
	mov eax,[eax] ; pointer to head
	cmp eax,NULL
	je finish
	mov eax,[eax] ; head.value
	finish:
	ret
peek ENDP

;;;; LIST ;;;;

list_insert proc, list:DWORD,value:DWORD ; adds the value to the end of the list
	pusha
	
	mov ebx,list
	inc DWORD PTR [ebx+4] ; count++
	
	mov ecx,[ebx+4]
	shl ecx,2 ; count * sizeof dword
	invoke Alloc, ecx ; allocate new memory
	
	mov edi,eax ; destination = new array
	mov ebx,list
	mov esi,[ebx] ; source = old array
	mov ecx,[ebx+4] 
	dec ecx ; ecx = count-1
	
	push es
	push ds ; data to extra for movsd
	pop es ; flashbacks from codeguru :)
	rep movsd ; copy from old array to new
	pop es ; restore old extra segment
	
	push value
	pop DWORD PTR [edi] ; last element = value
	invoke Free, [ebx] ; delete old array
	
	mov ebx,list
	mov ecx,[ebx+4]
	dec ecx
	shl ecx,2 ; ecx *= 4
	sub edi,ecx ; beginning of the new array
	mov [ebx],edi
	
	popa
	ret
list_insert ENDP

list_get_item PROC,list:DWORD,index:DWORD ; return the item at the index
	push ebx
	
	mov ebx,list
	mov ebx,[ebx] ; items array pointer
	mov eax,index
	shl eax,2
	mov eax,[ebx+eax] ; linear address of items array[index]
	
	pop ebx
	ret
list_get_item ENDP

list_set PROC,list:DWORD,index:DWORD,value:DWORD ; sets the item at the index to the value
	push eax
	push ebx
	
	mov ebx,list
	mov ebx,[ebx] ; pointer to items array
	mov eax,index
	shl eax,2
	push value
	pop DWORD PTR [ebx+eax] ; linear address of items[index]

	pop ebx
	pop eax
	ret
list_set ENDP

list_index_of PROC, list:DWORD , item:DWORD ; returns the index of the first appearance of the item,-1 if item isn't found
	push ecx
	push ebx

	mov ebx,list
	mov ecx,[ebx+4] ; ecx -> count
	
	mov eax,item
	mov edi,[ebx] ; edi -> items
	
	inc ecx
	sub edi,4 ; adding later
	jmp check_loop ; first check then do
	
	loop_label:
		add edi,4
		cmp [edi],eax 
	check_loop:loopnz loop_label ; loop if list[i]!=item, break if item found
	
	jnz notFound 
	; if loop terminated in the middle, ZF will be marked, if loop was terminated because ecx = 0, ZF will not be marked
	
	sub edi,[ebx] ; edi = &item - &first_item = the distance in bytes between the item and the first item
	mov eax,edi
	shr eax,2 ; edi /= 4n = distance above in dwords = index
	jmp final
	
	notFound:
		mov eax,-1 ; case item wasn't found
		
	final:
	pop ebx
	pop ecx
	ret
list_index_of endp

list_delete_at PROC, list:DWORD, index:DWORD ; removes the item at the index from the list and shortens the list by 1 element
	pusha
	
	mov ebx,list
	push DWORD PTR [ebx+4] ; count
	
	mov ecx,[esp]
	dec ecx
	shl ecx,2
	invoke Alloc,ecx ; new array to size count-1
	
	mov edi,eax ; edi = new array
	mov ebx,list
	mov esi,[ebx] ; esi = old array
	
	mov ecx,index
	push es
	push ds ; data to extra (CodeGuru!!!)
	pop es
	rep movsd ; copy from old array to new array right until the index of the item to delete
	
	mov ecx,index
	inc ecx
	sub [esp+4],ecx ; count - index - 1
	mov ecx,[esp+4] ; ecx = items left to copy
	add esi,4 ; skip over the item deleted
	rep movsd ; continue to copy from old array to new
	
	pop es
	pop ecx ; list.count - index - 1
	add ecx,index ; list.count -1
	shl ecx,2 ; byte size of new array
	sub edi,ecx ; point to the beginning of the array
	
	invoke Free,[ebx] ; delete old array
	mov ebx,list
	mov [ebx],edi ; set items as new array
	dec DWORD PTR [ebx+4] ; count--
	
	popa
	ret
list_delete_at ENDP

delete_list PROC,list:DWORD ; deletes the list
	push eax
	
	mov eax,list
	invoke Free,[eax] ; delete the item array
	invoke Free,list
	
	pop eax
	ret
delete_list endp

;;;; MACROS ;;;;

new_stack MACRO
	invoke Alloc,SIZEOF Stack
ENDM

new_queue MACRO
	invoke Alloc,NULL,SIZEOF Queue
ENDM

stack_peek MACRO stack
	push stack
	call peek
ENDM

queue_peek MACRO queue
	push queue
	call peek
ENDM

new_list MACRO
	invoke Alloc,SIZEOF List
ENDM




.686

.data
;;;;;;;;;; NOTE!! ALL MATH FUNCTIONS RETURN REAL4 VALUES THROUGH EAX ;;;;;;;;;

;;;; SERIES ;;;;

factor PROTO x:REAL4

;;;; LOGARITHMS AND EXPONENTIALS

log2 PROTO x:REAL4
ln PROTO x:REAL4
exp PROTO x:REAL4
pow PROTO x:REAL4,y:REAL4 ; x to the power of y
log PROTO x:REAL4,y:REAL4 ; logarithm base x of y

;;;; TRIGONOMETRY ;;;;

cos PROTO x:REAL4
sin PROTO x:REAL4
tan PROTO x:REAL4
tanh PROTO x:REAL4
cosh PROTO x:REAL4
sinh PROTO x:REAL4
acos PROTO x:REAL4
asin PROTO x:REAL4
atan PROTO x:REAL4
atanh PROTO x:REAL4
acosh PROTO x:REAL4
asinh PROTO x:REAL4

;;;; NOT SURE HOW TO DESCRIBE THIS ;;;;

random PROTO

.code
;;;; MEMORY TO MEMORY MACROS ;;;;

st0_to_eax MACRO ; name is self-explaining
	sub esp, 4
	fstp dword ptr [esp]
	pop eax
ENDM

fld_eax MACRO ; name also self-explaining
	push eax
	fld DWORD PTR [esp]
	pop eax
ENDM

f_add MACRO x,y ;x += y for float
	fld REAL4 PTR x
	fadd REAL4 PTR y
	fstp REAL4 PTR x
endm

f_sub MACRO x,y ; x -= y for float
	fld REAL4 PTR x
	fsub REAL4 PTR y
	fstp REAL4 PTR x
endm

f_mul MACRO x,y ; x *= y for float
	fld REAL4 PTR x
	fmul REAL4 PTR y
	fstp REAL4 PTR x
endm

f_div MACRO x,y ; x /= y for float
	fld REAL4 PTR x
	fdiv REAL4 PTR y
	fstp REAL4 PTR x
endm

f_mod MACRO x,y ; x %= y for float
	fld REAL4 PTR x
	fld REAL4 PTR y
	fprem st(1),st
	fstp st(0) ; pop
	fstp REAL4 PTR x
endm

f_to_int MACRO x,y ; x = (int)y ;  for x is int, y is float
	fld REAL4 PTR y
	fistp DWORD PTR x
endm

f_to_float MACRO x,y ; x = (float)y ;  for x is float, y is int
	fild DWORD PTR y
	fstp REAL4 PTR x
endm

ln PROC, x:REAL4 ; ln(x) = ln(2)*log2(x)
	fldln2
	fld REAL4 ptr x
	FYL2X
	st0_to_eax
	ret
ln ENDP

factor PROC, x:REAL4 ; x!
	fld x ; counter
	fld1 ; result
	the_loop:
		fldz
		fcomip st,st(2) ; if counter == 0 return result
		je the_finish
		fmul st,st(1) ; result *= counter
		fld1
		fsubp st(2),st ; counter--
	jmp the_loop
	the_finish:
	st0_to_eax
	fstp st(0) ; pop counter
	ret
factor endp

exp PROC, x:REAL4 ; returns e^x
	; fpu instruction didn't work so this is calculated by the taylor series
	; exp(x) = sum from n = 0 to inf [x^n/n!]
	push ecx
	sub esp,8
	fld1 ; first element of the series, x^0/0! == 1
	fstp DWORD PTR [esp] ; [esp] = result
	mov [esp+4],dword ptr 1 ; [esp+4] counter
	
	the_loop:

		fild DWORD PTR [esp+4]
		st0_to_eax ; eax -> counter as float
		invoke factor,eax
		
		; normalpow x,counter
		
		mov ecx,[esp+4] ; ecx -> counter as int
		fld x
		fld1 ; result of normalpow, temp y = 1
		pow_loop:
			fmul st,st(1) ; y*=x
		loop pow_loop ; repeat counter times, y = x*x*x*x... counter times = x^n
		
		fstp st(1) ; pop, y to st
		fld_eax ; st = n!
		fdivp st(1),st ; st(0) = x^n/n!
		fld DWORD PTR [esp] ; sum 
		fadd st,st(1) ; st = sum + (x^n/n!)
		fstp dword ptr [esp] ; store new sum in sum local variable
		fstp st(0) ; pop 
		inc DWORD PTR [esp+4] ; counter++ 
	cmp [esp+4],DWORD PTR 35 ; maximum factorial that isn't infinity
	jl the_loop

	mov eax,[esp] ; result
	add esp,8 ; delete locals
	
	pop ecx
	ret
exp ENDP

pow PROC, x:REAL4, y:REAL4 ; x^y
	invoke ln,x
	fld y
	fmul x ; y*ln(x)
	st0_to_eax
	invoke exp,eax ; x^y = exp(ln(x)*y)
	ret
pow endp

log PROC, x:REAL4, y:REAL4 ; logx(y) = log2(y)/log2(x)
	fld1
	fld y
	fyl2x ; log2(y)
	fld1
	fld x
	fyl2x ; log2(x)
	fdivp st(1),st ; log2(y)/log2(x)
	st0_to_eax
	ret
log endp

log2 PROC,x:REAL4 ; using fpu instruction
	fld1
	fld x
	fyl2x
	st0_to_eax
	ret
log2 endp

cos PROC,x:REAL4 ; fpu instruction
	fld x
	fcos
	st0_to_eax
	ret
cos endp

sin PROC,x:REAL4 ; fpu instruction
	fld x
	fsin
	st0_to_eax
	ret
sin endp

tan PROC,x:REAL4 ; fpu instruction
	fld x
	fptan
	fstp st(0) ; fptan pushes 1 to the stack
	st0_to_eax
	ret
tan endp

tanh PROC,x:REAL4 ; hyperbolic tangent = (exp(2x)-1)/(exp(2x)+1)
	fld x
	fadd x ; 2x
	st0_to_eax
	invoke exp,eax ; exp(2x)
	fld_eax
	fld_eax
	fld1
	fsub st(2),st ; exp(2x)-1
	fadd st(1),st ; exp(2x)+1
	fstp st(0) ; pop
	fdivp st(1),st ; st = (exp(2x)-1)/(exp(2x)+1)
	st0_to_eax
	ret
tanh endp

sinh PROC,x:REAL4 ; hyperbolic sine = (exp(x)-exp(-x))/2
	invoke exp,x
	fld_eax
	fld1
	fld_eax
	fdivp st(1),st ; exp(-x) = 1/exp(x)
	fsubp st(1),st ; st = exp(x)-exp(-x)
	fld1
	fld1
	faddp st(1),st ; 2.0
	fdivp st(1),st
	st0_to_eax
	ret
sinh ENDP

cosh PROC,x:REAL4 ; hyperbolic cosine = (exp(x)+exp(-x))/2
	invoke exp,x
	fld_eax
	fld1
	fld_eax
	fdivp st(1),st ; exp(-x) = 1/exp(x)
	faddp st(1),st ; st = exp(x)+exp(-x)
	fld1
	fld1
	faddp st(1),st ; 2.0
	fdivp st(1),st
	st0_to_eax
	ret
cosh ENDP

atan PROC,x:REAL4 ; fpu instruction
	fld x
	fld1 ; arctan(x/1) = arctan(x)
	fpatan
	st0_to_eax
	ret
atan ENDP

asin PROC,x:REAL4
	fld x
	fld1
	fld1
	fld x
	fmul x ; x^2
	fsubp st(1),st ; 1-x^2
	fsqrt
	faddp st(1),st ; 1+sqrt(1-x^2)
	fpatan ; arcsin(x) = 2*arctan(x/(1+sqrt(1-x^2)))
	fadd st,st(0) ; mul by 2
	st0_to_eax
	ret
asin ENDP

acos PROC,x:REAL4
	fld1
	fld x
	fmul x ; x^2
	fsubp st(1),st ; 1-x^2
	fsqrt ; st(0) = sqrt(1-x^2)
	fld1
	fld x
	faddp st(1),st ; st(0) = x+1
	fpatan ; arccos(x) = 2*arctan(sqrt(1-x^2)/x+1)
	fadd st,st(0) ; mul by 2
	st0_to_eax
	ret
acos ENDP

atanh PROC,x:REAL4 ; atanh(x) = ln((1+x)/(1-x))/2
	fld x
	fld x
	fld1
	fadd st(2),st ; st(2) = 1+x
	fsub st(1),st ; st(1) = 1-x
	fstp st(0) ; pop
	fdivp st(1),st ; (1+x)/(1-x)
	st0_to_eax
	invoke ln,eax
	fld_eax
	fld1
	fld1
	faddp st(1),st ; 2.0
	fdivp st(1),st ; divide by 2
	st0_to_eax
	ret
atanh ENDP

asinh PROC,x:REAL4
	fld x
	fmul x
	fld1
	faddp st(1),st
	fsqrt ; sqrt(x^2+1)
	fadd x
	st0_to_eax
	invoke ln,eax ; asinh(x) = ln(x+sqrt(x^2+1))
	ret
asinh ENDP

acosh PROC,x:REAL4
	fld x
	fmul x
	fld1
	fsubp st(1),st
	fsqrt ; sqrt(x^2+1)
	fadd x
	st0_to_eax
	invoke ln,eax ; acosh(x) = ln(x+sqrt(x^2-1))
	ret
acosh ENDP

random PROC ; returns a random number between 0 and 1
	push edx
	
	rdtsc ; edx:eax = systime
	ror eax,8 ; most changing number as the highest parts of the integer
	and eax,01111111111111111111111111111111b ; remove sign
	push eax
	fild DWORD PTR [esp] ; load random integer
	push DWORD PTR 01111111111111111111111111111111b
	fild DWORD PTR [esp] ; load int max value
	pop edx ; clear from stack
	fdivp st(1),st ; random number / max
	fstp dword ptr [esp] ; store result in stack
	pop eax ; result to eax
	
	pop edx
	ret
random ENDP




.data

Matrix STRUCT
	elements DWORD ? ; pointers to the first element in each row
	rows DWORD ?
	columns DWORD ?
Matrix ends

zero_matrix PROTO rows:DWORD,columns:DWORD

matrix_get_row PROTO mat:dword,row:DWORD

matrix_get_element PROTO mat:DWORD,row:DWORD,col:DWORD

matrix_set_element PROTO mat:DWORD,row:DWORD,col:DWORD,value:DWORD

matrix_set_row PROTO mat:DWORD,row:DWORD,reprow:DWORD

matrix_add PROTO dst:DWORD,scr:DWORD ; +=
.code


matrix_delete PROC,mat:DWORD ; name is self-exlaining
	pusha
	mov ebx,mat
	mov ebx,[ebx]
	
	invoke Free,[ebx] ; the byte data

	mov ebx,mat ; the pointers to the first element of every row
	invoke Free,[ebx]

	invoke Free,mat ; the matrix data (rows,columns,pointer to pointers
	popa
	RET
matrix_delete ENDP

zero_matrix PROC,rows:DWORD,columns:DWORD ; returns a pointer to a new zero matrix
	push ebx
	push ecx
	push edx

	invoke Alloc,SIZEOF Matrix ; create a new matrix
	push eax
	
	mov ebx,eax ; ebx is a pointer to the new matrix
	mov ecx,rows
	mov [ebx+4],ecx
	mov edx,columns
	mov [ebx+8],edx ; initialize rows and columns counters
	
	invoke Alloc,rows ; allocate room for pointers
	mov ebx,[esp]
	mov [ebx],eax ; place pointer to pointer in matrix.elements
	
	mov ecx,rows
	shl columns,2
	mov eax,columns
	mul ecx ; eax = rows*columns*4, byte size of the matrix
	invoke Alloc,eax
	mov edx,eax
	
	mov ebx,[esp]
	mov ebx,[ebx] ; ebx = pointers
	mov ecx,rows ; repeat rows times
	row_loop:
		mov [ebx],edx ; initialize the pointer
		add edx,columns ; jump up the matrix by columns*4
		add ebx,4 ; jump up the pointers by 4
	loop row_loop ; repeat rows times

	pop eax
	pop edx
	pop ecx
	pop ebx
	ret
zero_matrix ENDP

matrix_get_row PROC,mat:DWORD,row:DWORD ; returns a pointer to the first element in the row
	push ebx
	mov eax,mat
	mov eax,[eax] ; eax = pointer to pointers
	mov ebx,row
	shl ebx,2 ; ebx = rows*4
	mov eax,[eax+ebx] ; linear address of the pointer
	pop ebx
	ret
matrix_get_row endp

matrix_get_element PROC,mat:DWORD,row:DWORD,col:DWORD ; returns mat[row,col]
	push ebx
	
	invoke matrix_get_row,mat,row ; retrive the specific row to eax
	mov ebx,col
	shl ebx,2 ; linear location (row[col*4])
	mov eax,[eax+ebx]
	
	pop ebx
	ret
matrix_get_element ENDP

matrix_set_element PROC,mat:DWORD,row:DWORD,col:DWORD,value:DWORD ; mat[row,col] = value
	push ebx
	push eax
	
	invoke matrix_get_row,mat,row ; retrive to specific row to eax
	mov ebx,col
	shl ebx,2 ; linear location (row[col*4])
	push value
	pop DWORD PTR [eax+ebx] ; move the value
	
	pop eax
	pop ebx
	ret
matrix_set_element ENDP

matrix_set_row PROC,mat:DWORD,row:DWORD,reprow:DWORD ; copies the row specified by the row pointer reprow to the row of the matrix
	pusha
	
	invoke matrix_get_row,mat,row ; get the pointer to the row to eax
	mov ecx,mat
	mov ecx,[ecx+8] ; columns
	push ds
	pop es ; extra to data (thanks to CodeGuru Extreme for the idea)
	mov edi,eax ; destination = mat[row]
	mov esi,reprow ; source = reprow
	rep movsd ; copy dword from reprow to row columns times
	
	popa
	ret
matrix_set_row ENDP

matrix_load PROC,dst:DWORD,src:DWORD ; copies the destination matrix to the source matrix
	push eax
	push ecx
	
	mov ecx,dst
	mov ecx,[ecx+4] ; ecx = rows
	the_loop:
		dec ecx ; matrix is 0 based indexed, loop instruction is 1 based
		invoke matrix_get_row,src,ecx ; get the row pointer at src[ecx] to eax
		invoke matrix_set_row,dst,ecx,eax ; copy the row to dst[ecx]
		inc ecx
	loop the_loop ; repeat rows times
	
	pop ecx
	pop eax
	ret
matrix_load endp

matrix_add PROC,dst:DWORD,src:DWORD ; += instruction for matrices, dst += src
	pusha
	
	mov ebx,src
	mov ecx,[ebx+4] ; rows 
	push DWORD PTR [ebx+8] ; columns
	mov eax,dst
	mov ebx,[ebx] ; pointer to row pointers of source matrix
	mov eax,[eax] ; pointer to row pointers of destination matrix
	
	outer_loop: ; loop through every row
		push ecx
		dec ecx ; matrix is 0 bases, loop instruction is 1 based
		shl ecx,2
		mov edi,[eax+ecx] ; row from dst
		mov esi,[ebx+ecx] ; row from src 
		mov edx,[esp+4] ; temporary columns variable pushed to the stack earlier
		
		inner_loop: ; loop through every column
			push edx ; for every element in the row
			dec edx
			shl edx,2 ; linear location, row[col*4]
			f_add [edi+edx],[esi+edx] ; float addition macro, add element in source to element in destination
			pop edx
		dec edx ; loops backwords (from columns-1 to 0)
		jnz inner_loop
		
		pop ecx
	loop outer_loop
	pop edx ; delete temporary columns variable from the stack
	
	popa
	ret
matrix_add ENDP

matrix_plus PROC,dst:DWORD,src:DWORD ; +, returns a pointer to the new matrix dst+src
	mov eax,dst
	invoke zero_matrix,[eax+4],[eax+8] ; new zero matrix to size of the matrices
	invoke matrix_load,eax,dst ; copy the destination matrix
	invoke matrix_add,eax,src ; add the source matrix
	ret
matrix_plus ENDP

matrix_sub PROC,dst:DWORD,src:DWORD ;  -= instruction for matrices, dst-= src
	pusha
	
	mov ebx,src
	mov ecx,[ebx+4] ; ecx = rows
	push DWORD PTR [ebx+8] ; temporary columns variable
	mov eax,dst
	mov ebx,[ebx] ; pointer to the row pointers of source matrix
	mov eax,[eax] ; pointer to the row pointers of destination matrix
	
	outer_loop:
		push ecx
		dec ecx ; matrix is 0 based index, loop instruction is 1 based
		shl ecx,2 ; linear location
		mov edi,[eax+ecx] ; edi = dst[ecx]
		mov esi,[ebx+ecx] ; esi = dst[ecx]
		mov edx,[esp+4]
		
		inner_loop:
			push edx
			dec edx
			shl edx,2 ; linear location
			f_sub [edi+edx],[esi+edx] ; using the float sub macro
			pop edx
		dec edx
		jnz inner_loop
		
		pop ecx
	loop outer_loop
	
	pop edx ; delete temporary column variable
	
	popa
	ret
matrix_sub ENDP

matrix_minus PROC,dst:DWORD,src:DWORD ; -, returns a pointer to the new matrix dst-src
	mov eax,dst
	invoke zero_matrix,[eax+4],[eax+8] ; create a new matrix to size of the matrices
	invoke matrix_load,eax,dst ; copy the destination matrix to the new matrix
	invoke matrix_sub,eax,src ; substruct the source matrix
	ret
matrix_minus ENDP

matrix_elementwize_mul PROC,dst:DWORD,src:DWORD ; *=, multiply dst by src elementwize
	pusha
	
	mov ebx,src
	mov ecx,[ebx+4] ; rows
	push DWORD PTR [ebx+8] ; temp columns constant
	mov eax,dst
	mov ebx,[ebx]
	mov eax,[eax]
	
	outer_loop: ; loop for every row
		push ecx
		dec ecx ; matrix zero bases, loop 1 based
		shl ecx,2 ; linear location
		mov edi,[eax+ecx] ; row of destination
		mov esi,[ebx+ecx] ; row of source
		mov edx,[esp+4] ; columns
		
		inner_loop: ; loop for every column
			push edx
			dec edx
			shl edx,2 ; linear location
			f_mul [edi+edx],[esi+edx] ; float multiply macro
			pop edx
		dec edx
		jnz inner_loop
		
		pop ecx
	loop outer_loop
	
	pop edx ; remove temp columns constant
	popa
	ret
matrix_elementwize_mul ENDP

matrix_elementwize_times PROC,dst:DWORD,src:DWORD ; *, returns a pointer to the new matrix src*dst
	mov eax,dst
	invoke zero_matrix,[eax+4],[eax+8] ; new matrix to size of the destination matrix
	invoke matrix_load,eax,dst ; copy of the destination matrix
	invoke matrix_elementwize_mul,eax,src ; multiply elementwize by the source matrix
	ret
matrix_elementwize_times ENDP

matrix_mul PROC,mat1:DWORD,mat2:DWORD ; matrix multiplication, returns pointer to a new matrix
	push ebx
	push ecx
	push edx
	push esi
	push edi

	; mat1 is R(n*m), mat2 is R(m*k)
	; the returned matrix is R(n*k)
	mov ebx,mat1
	mov ecx,mat2
	invoke zero_matrix,[ebx+4],[ecx+8] ; new matrix with the amount of rows in mat1 and columns of mat2
	push eax ; pointer to the new matrix
	push REAL4 ptr 0 ; float sum = 0
	push DWORD ptr 0; int i = 0, row counter for mat1
	push DWORD ptr 0 ; int j = 0, column counter for mat2
	push DWORD ptr 0 ; int k = 0, row/column counter for mat2/mat1, respectively

	outer_loop_1: ; row loop for mat1
		mov [esp+4],DWORD PTR 0 ; j = 0
		
		outer_loop_2: ; column loop for mat2
			mov REAL4 PTR [esp+12],0 ; sum = 0
			mov [esp],DWORD PTR 0 ; k = 0
			
			inner_loop: ; sum loop
				mov ebx,[esp+8] ; ebx = i
				mov ecx,[esp] ; ecx = k
				invoke matrix_get_element,mat1,ebx,ecx ; mat1[i,k]
				fld_eax ; load to fpu stack
				
				mov ebx,[esp+4] ; ebx = j
				invoke matrix_get_element,mat2,ecx,ebx ; mat2[k,j]
				fld_eax ; load to fpu stack
				
				fmulp st(1),st ; mat1[i,k]*mat2[k,j]
				fld REAL4 PTR [esp+12] ; load sum
				faddp st(1),st ; add mat1[i,k]*mat2[k,j] to sum
				fstp REAL4 PTR [esp+12] ; store result in sum

			inc DWORD PTR [esp] ; k++
			mov eax,mat1
			mov eax,[eax+8] ; mat1.columns
			cmp eax,[esp] ; repeat until k = mat1.columns
			jnz inner_loop

			mov eax,[esp+16] ; the return matrix
			mov ebx,[esp+8] ; i
			mov ecx,[esp+4] ; j
			mov edx,[esp+12] ; sum
			invoke matrix_set_element,eax,ebx,ecx,edx ; return matrix at [i,j] = sum

		inc DWORD PTR [esp+4] ; j++
		mov eax,[esp+16]
		mov eax,[eax+8] ; new matrix columns
		cmp eax,[esp+4] ; repeat for j = 0 to columns
		jnz outer_loop_2
	
	inc DWORD PTR [esp+8] ; i++
	mov eax,[esp+16]
	mov eax,[eax+4] ; new matrix rows
	cmp eax,[esp+8] ; repeat for i=0 to rows
	jnz outer_loop_1
	
	add esp,16 ; delete temporary variables
	pop eax ; restore result matrix to eax

	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	ret
matrix_mul endp

matrix_scalar_mul PROC,mat:DWORD,scl:REAL4 ; matrix multiplication by a scalar, mat *= scl
	pusha
	
	mov ebx,mat
	mov ecx,[ebx+4] ; ecx = rows
	push DWORD PTR [ebx+8] ; temp column constant
	mov ebx,[ebx] ; ebx = pointer to rows pointers
	
	outer_loop: ; for every row
		push ecx
		dec ecx
		shl ecx,2 ; linear address of the row
		mov edi,[ebx+ecx] ; edi = row
		
		mov edx,[esp+4] ; edx = columns
		
		inner_loop: ; for every column
			push edx
			dec edx
			shl edx,2 ; linear address
			f_mul [edi+edx],scl ; float multiplication macro
			pop edx
		dec edx
		jnz inner_loop
		
		pop ecx
	loop outer_loop
	
	pop edx ; delete temp column constant
	
	popa
	ret	
matrix_scalar_mul ENDP

matrix_scalar_times PROC,mat:DWORD,scl:REAL4 ; *, returns a new matrix
	mov eax,mat
	invoke zero_matrix,[eax+4],[eax+8]
	invoke matrix_load,eax,mat
	invoke matrix_scalar_mul,eax,scl
	ret
matrix_scalar_times endp

matrix_elementwize PROC,mat:DWORD,func:DWORD ; function must be stdcall, and take one REAL4 argument; equivalent to element = f(element) for every element
	pusha
	
	mov ebx,mat
	mov ecx,[ebx+4] ; ecx = rows
	push DWORD PTR [ebx+8] ; temp columns
	mov ebx,[ebx] ; row pointers
	
	outer_loop: ; rows
		push ecx
		dec ecx
		shl ecx,2 ; linear address
		mov edi,[ebx+ecx] ; edi = row pointer
		
		mov edx,[esp+4] ; columns
		inner_loop: ; columns
			push edx
			dec edx
			shl edx,2 ; linear location
			
			push edi ; protect values
			push edx
			
			push REAL4 PTR [edi+edx] ; call the function with mat[row,col] as an argument
			call func
			
			pop edx
			pop edi ; restore values
			mov [edi+edx],eax ; move the result to the element location, mat[row,col] = f(mat[row,col])
			pop edx
		dec edx
		jnz inner_loop
		
		pop ecx
	loop outer_loop
	
	pop edx ; delete temp
	popa
	ret
matrix_elementwize ENDP

matrix_element_function PROC,mat:DWORD,func:DWORD ; function must be stdcall, and take one REAL4 argument; returns f(element) for each element
	mov eax,mat
	invoke zero_matrix,[eax+4],[eax+8] ; new matrix by dimensions of the source
	invoke matrix_load,eax,mat ; copy matrix
	invoke matrix_elementwize,eax,func ; perform the function on every element and get the result
	ret
matrix_element_function endp

random_matrix PROC,rows:DWORD,columns:DWORD ; returns a new matrix R(rows,columns) of random values between 0 and 1
	push ebx
	push ecx
	push edx
	
	invoke Alloc,SIZEOF Matrix ; create new matrix
	push eax
	
	mov ebx,eax
	mov ecx,rows
	mov [ebx+4],ecx
	mov edx,columns
	mov [ebx+8],edx ; initialize rows and column fields of the matrix
	
	invoke Alloc,rows ; allocate rows pointer
	mov ebx,[esp]
	mov [ebx],eax ; initialize rows pointer
	
	mov ecx,rows
	shl columns,2
	mov eax,columns
	mul ecx ; byte size of the matrix = rows*columns*4
	push eax
	invoke Alloc,eax ; allocate raw data
	
	pop ecx ; size of matrix
	mov edx,eax
	push edx ; edx = raw data pointer
	rand_loop: ; for every element set to random number between 0 and 1
		invoke random ; random number to eax
		mov [edx],eax ; store in element
		add edx,4
	loop rand_loop
	
	pop edx ; restore raw data pointer
	mov ebx,[esp] ; return matrix
	mov ebx,[ebx] ; row pointers
	mov ecx,rows
	row_loop: ; initialize row pointers
		mov [ebx],edx
		add edx,columns ; beginning of next row
		add ebx,4 ; next row pointer
	loop row_loop
	
	pop eax ; new matrix pointer to eax
	pop edx
	pop ecx
	pop ebx
	ret
random_matrix ENDP

ones_matrix PROC,rows:DWORD,columns:DWORD ; returns a matrix R(rows,columns) of ones
	push ebx
	push ecx
	push edx
	
	invoke Alloc,SIZEOF Matrix
	push eax ; new matrix
	
	mov ebx,eax
	mov ecx,rows
	mov [ebx+4],ecx
	mov edx,columns
	mov [ebx+8],edx ; initialize rows and columns fields
	
	invoke Alloc,rows ; allocate rows pointers
	mov ebx,[esp]
	mov [ebx],eax ; initialize rows pointers
	
	mov ecx,rows
	shl columns,2
	mov eax,columns
	mul ecx ; byte size = rows*columns*4
	push eax
	invoke Alloc,eax ; allocate raw data
	
	pop ecx ; matrix size
	mov edx,eax
	push edx
	ones_loop:
		fld1
		fstp REAL4 PTR [edx] ; store 1 in the element
		add edx,4
	loop ones_loop ; loop for every element
	
	pop edx ; first element pointer
	mov ebx,[esp] ; return matrix
	mov ebx,[ebx] ; rows pointers
	mov ecx,rows
	row_loop: ; set pointer for every row
		mov [ebx],edx
		add edx,columns ; next row
		add ebx,4 ; next pointer
	loop row_loop
	
	pop eax ; return matrix
	pop edx
	pop ecx
	pop ebx
	ret
ones_matrix ENDP

identity_matrix PROC,rows:DWORD,columns:DWORD ; returns the identity_matrix by the dimensions R(rows,columns)
	push ecx
	push edx
	
	invoke zero_matrix,rows,columns ; new matrix to dimensions R(rows,columns)

	mov ecx,rows
	cmp ecx,columns
	jl afterFoundMin ; get min(rows,columns) to ecx, number of times to loop
		mov ecx,columns
	afterFoundMin:

	fld1
	push DWORD PTR 0
	fstp DWORD PTR [esp]
	pop edx ; edx = 1.0

	ones_loop:
		dec ecx
		invoke matrix_set_element,eax,ecx,ecx,edx ; set mat[ecx,ecx] to 1
		inc ecx
	loop ones_loop ; loop min(rows,columns) times


	pop edx
	pop ecx
	ret
identity_matrix ENDP 

matrix_transpose PROC, mat:DWORD ; returns the transpose of the matrix through eax
	push ebx
	push ecx
	push edx

	mov ebx,mat
	invoke zero_matrix,[ebx+8],[ebx+4] ; new matrix by the transpose dimensions of mat
	
	mov ecx,[ebx+4] ; rows
	push DWORD PTR [ebx+8] ; columns
	mov ebx,eax ; return matrix
	
	outer_loop:
		mov edx,[esp] ; columns
		inner_loop:
			dec edx
			dec ecx
			invoke matrix_get_element,mat,ecx,edx ; get element at mat[ecx,edx]
			invoke matrix_set_element,ebx,edx,ecx,eax ; set return matrix at [edx,ecx] to mat[ecx,edx]
			inc edx
			inc ecx
		dec edx
		jnz inner_loop ; for every column
	loop outer_loop ; for every row
	
	mov eax,ebx ; return matrix

	pop edx ; delete temp columns

	pop edx
	pop ecx
	pop ebx
	ret
matrix_transpose ENDP

matrix_concat_rows PROC,mat1:DWORD, mat2:DWORD ; concat mat1 and mat2 by the rows, mat1 is R(n,m), mat2 is R(k,m), return is R(n+k,m)
	push ebx
	push ecx
	push edx

	mov ebx,mat1
	mov ecx,[ebx+4]
	mov ebx,mat2
	add ecx,[ebx+4] ; ecx = mat1.rows+mat2.rows, amount of rows in the new matrix
	
	invoke zero_matrix,ecx,[ebx+8] ; new matrix R(n+k,m)
	mov edx,eax
	mov eax,mat1
	mov ecx,[eax+4] ; ecx = mat1.rows
	
	loop_1: ; load from mat1 to return matrix
		dec ecx
		invoke matrix_get_row,mat1,ecx ; copy row from mat1 to return matrix
		invoke matrix_set_row,edx,ecx,eax
		inc ecx
	loop loop_1 ; loop mat1.rows times

	mov ebx,mat1
	mov ebx,[ebx+4] ; mat1.rows
	mov ecx,mat2
	mov ecx,[ecx+4] ; mat2.rows
	
	loop_2: ; load from mat2 to return matrix
		dec ecx
		invoke matrix_get_row,mat2,ecx ; get row at ecx
		add ecx,ebx ; set row at mat1.rows+ecx to mat2[ecx]
		; rows at 0 to mat1.rows-1 have been filled by rows at mat1
		invoke matrix_set_row,edx,ecx,eax
		sub ecx,ebx
		inc ecx
	loop loop_2 ; loop for each row in mat2

	mov eax,edx ; return matrix

	pop edx
	pop ecx
	pop ebx
	ret
matrix_concat_rows ENDP

matrix_concat_columns PROC,mat1:DWORD,mat2:DWORD ; concat mat1 and mat2 by the columns, mat1 is R(n,m), mat2 is R(n,k), return is R(n,m+k)
	push ebx
	
	; linear identity
	; [a;b] = [a.T,b.T].T 
	
	invoke matrix_transpose,mat1; mat1.T
	mov ebx,eax
	
	invoke matrix_transpose,mat2; mat2.T
	push eax ; to delete later
	
	invoke matrix_concat_rows,ebx,eax ; eax = [mat1.T, mat2.T]
	
	invoke matrix_delete,ebx ; delete mat1.T
	pop ebx
	invoke matrix_delete,ebx ; delete mat2.T
	mov ebx,eax
	invoke matrix_transpose,eax ; transpose of [mat1.T, mat2.T]
	invoke matrix_delete,ebx ; delete [mat1.T, mat2.T]

	pop ebx
	ret
matrix_concat_columns ENDP


.const

INT_MIN_VALUE equ 10000000000000000000000000000000b

NOT_INT_MIN_VALUE equ -(INT_MIN_VALUE)-1

.data

str_length PROTO string:DWORD

parse_int PROTO string:DWORD

int_to_string PROTO number:DWORD

concat PROTO st1:DWORD,st2:DWORD

compare PROTO st1:DWORD,st2:DWORD

index_of PROTO st1:DWORD,patt:DWORD
.code

str_length PROC,string:DWORD ; returns the length of the string
	push ebx
	push ecx
	
	mov ebx,string
	xor ecx,ecx

	get_length_loop:
	mov al,[ebx+ecx]
	test al,al ; search for the null char
	jz finish ; finish if found
	inc ecx ; add 1 to counter if not found
	jmp get_length_loop

	finish:
	mov eax,ecx
	
	pop ecx
	pop ebx
	ret
str_length ENDP

parse_int PROC, string:DWORD ; returns (int)string
	push ebx
	push ecx
	push edx
	push edi
	push esi
	
	invoke str_length,string

	xor esi,esi
	mov ecx,eax ; ecx = length
	xor eax,eax
	mov edx,string
	xor edi,edi

	; check if negative
	cmp byte ptr [edx],"-"
	jnz AfterNeg ; if negative
		inc esi ; boolean indicating weather the number is negative
		inc edx ; skip the "-" sign
		dec ecx ; length is lenght-1 without the "-" sign
	AfterNeg:
	eval_loop:
		xor ebx,ebx
		mov bl,[edx+edi] ; the char
		sub bl,"0" ; from ascii to digit
		
		push edi
		push ecx
		push eax
		push edx
		
		mov eax,1 ; eax = exponent
		mov edi,10

		jmp check_pow_loop
		pow_loop:
			mul edi ; get 10^(ecx-1) to eax
			dec ecx
		check_pow_loop:
			cmp ecx,1
			jnz pow_loop
		after_pow_loop:
		
		mul ebx 
		mov ebx,eax ; ebx = digit*10^(ecx-1)
		
		pop edx
		pop eax
		pop ecx
		pop edi
		
		add eax,ebx ; add the number to the total sum
		
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

int_to_string PROC, number:DWORD ; returns (string)number, pointer to the string through eax
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
		; length is amount of times needed to divide the number by 10 (the base) until it becomes zero
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
		negativeAlloc: ; allocate one more byte for the - sign
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
		neg eax ; get absolute value
	afterNegation:

	push edx
	mov edi,10
	write_string_loop:
		xor edx,edx
		div edi ; remainder is the current units digit
		add dl,"0" ; to ascii
		mov [ebx+ecx-1],dl
	loop write_string_loop
	pop edx

	test number,10000000000000000000000000000000b ; if negative
	jz finish_1
		dec ebx ; if the number is negative the pointer should be one below for the "-" sign
	finish_1:
	mov eax,ebx
	
	pop edi
	pop edx
	pop ecx
	pop ebx
	; restore values
	ret
int_to_string ENDP

concat PROC,st1:DWORD,st2:DWORD ; st1+st2, pointer to the new string through eax
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
	push ecx
	push eax
	push ebx
	invoke Alloc,ecx ; new string
	
	mov edi,eax ; new string
	pop ecx ; st1 len
	mov esi,st1 ; first string
	
	push ds
	pop es
	
	rep movsb ; copy from first string
	mov esi,st2
	pop ecx ; st2 len
	rep movsb ; copy from second string

	mov eax,edi
	pop ebx ; total length
	sub eax,ebx
	
	pop es
	pop esi
	pop edi
	pop edx
	pop ecx
	pop ebx
	ret
concat endp

compare PROC,st1:DWORD,st2:DWORD ; returns st1 == st2
	push ecx
	push edi
	push esi
	push es
	
	invoke str_length,st1
	push eax
	invoke str_length,st2
	cmp eax,[esp] ; if sizes don't match return false
	je afterFalse
	
		pop eax ; clear stack
		xor eax,eax ; zero eax
		; restore values
		pop es
		pop esi
		pop edi
		pop ecx
		ret
	afterFalse:
	
	pop ecx ; length
	push ds
	pop es ; extra to data
	
	mov esi,st1
	mov edi,st2
	repe cmpsb ; while edi[i] == esi[i] && ecx != 0
	je rettrue ; if loop was terminated because ecx reached 0 then ZF is still signed
	; if loop was terminated because edi[i] != esi[i] then ZF is not signed
	
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

index_of PROC, st1:DWORD,patt:DWORD ; first appearance of the pattern in the string, not a regex pattern btw
	push ecx
	
	invoke str_length,st1
	push eax
	invoke str_length,patt
	cmp eax,[esp] ; if length of patt is larger the st1 then the input is iligal
	jle ligalInput
		pop eax
		mov eax, -1 ; return -1 for iligal input
		pop ecx
		ret
	ligalInput:
	
	pop ecx ; st1 length
	
	push ebx
	push edx
	push esi
	push edi

	mov edi,st1
	mov esi,patt
	xor edx,edx
	xor ebx,ebx

	scan_loop:
		xor ebx,ebx ; index in patt
		push edi
		tempmatch_loop:
			cmp ebx,eax ; if reached the end of patt; eax = length of patt
			jz found
			mov dl,[edi] ; next char
			cmp dl,[esi+ebx] ; compare chars
			jnz nextloop ; if chars don't match the index wasn't a match
			inc edi
			inc ebx
		jmp tempmatch_loop
		nextloop:
		pop edi 
		inc edi ; previous index + 1
	loop scan_loop
	mov eax,-1 ; if loop reached it's end without finding a match
	jmp final
	found:
		invoke str_length,st1
		sub eax,ecx ; ecx is a backwords counter
		pop edi ; jumped while something was in the stack
		
	final:
	pop edi
	pop esi
	pop edx
	pop ebx
	pop ecx
	ret
index_of ENDP

.data

bubble_sort PROTO list:DWORD ; sorts the list from smallest item to largest using bubble sort
insert_sorted PROTO list:DWORD,value:DWORD ; inserts the new value to the list while keeping it sorted from smallest to largest
list_map PROTO list:DWORD,func:DWORD ; returns a new list, function must be cdecl and can accept item,index
list_filter PROTO list:DWORD,func:DWORD ; returns a new list, function must be cdecl and can accept item,index
list_concat PROTO l1:DWORD,l2:DWORD ; returns a new list

.code

bubble_sort PROC,list:DWORD
	pusha
	mov ebx,list
	mov ecx,[ebx+4] ; ecx = count
	jmp check_loop_first
	bubble_loop:
		push ecx
		mov edx,ecx
		dec edx
		invoke list_get_item,list,ecx
		xchg ebx,eax;ebx = list[edx+1]
		invoke list_get_item,list,edx ; list[edx]
		cmp eax,ebx ; if list[edx]>list[edx+1]
		jle afterSort
		sort_loop:
			invoke list_set,list,ecx,eax ; list[edx+1] = list[edx]  ; BTW there is a temp variable
			invoke list_set,list,edx,ebx ; list[edx] = list[edx+1]
			; replace order of items
			mov edx,ecx
			inc ecx
			mov ebx,list
			cmp ecx,[ebx+4]
			je afterSort
			invoke list_get_item,list,ecx
			xchg ebx,eax;ebx = list[edx+1]
			invoke list_get_item,list,edx ; list[edx]
			cmp eax,ebx ; if list[edx]>list[edx+1]
			jg sort_loop
		afterSort:

		pop ecx
	check_loop_first:
	loop bubble_loop
	popa
	ret
bubble_sort ENDP

insert_sorted PROC,list:DWORD,value:DWORD
	pusha
	mov ecx,list
	mov ecx,[ecx+4]
	inc ecx
	shl ecx,2
	invoke Alloc,ecx
	mov ebx,eax
	mov edx,list

	push [edx+4]
	inc DWORD PTR [edx+4]
	
	check_insert_loop_1:
		cmp ecx,[esp]
		je after_first_insert
		invoke list_get_item,list,ecx
		cmp eax,value
		jg after_first_insert
		shl ecx,2
		mov [ebx+ecx],eax
		shr ecx,2
		inc ecx
	jmp check_insert_loop_1

	after_first_insert:
		shl ecx,2
		mov eax,value
		mov [ebx+ecx],eax
		shr ecx,2
	insert_loop_2:
		cmp ecx,[esp]
		je finish
		invoke list_get_item,list,ecx
		shl ecx,2
		mov [ebx+ecx+4],eax
		shr ecx,2
		inc ecx
	jmp insert_loop_2
	finish:
	mov ss:[esp], ebx
	invoke Free,[edx]
	mov edx,list
	pop DWORD PTR [edx]

	
	popa
	ret
insert_sorted ENDP

list_map PROC,list:DWORD,func:DWORD
	push ebx
	push ecx
	push edx

	new_list
	push eax
	mov ecx,list
	mov ecx,[ecx+4]
	shl ecx,2
	invoke Alloc,ecx
	mov ebx,[esp]
	mov [ebx],eax
	mov ecx,list
	mov ecx,[ecx+4]
	mov [ebx+4],ecx
	inc ecx
	jmp check_loop
	for_each_loop:
		invoke list_get_item,list,ecx
		push ebx
		push ecx
		push ecx ; bpth protect and argument
		dec DWORD PTR [esp]
		push eax ; argument for func
		call func
		add esp,8 ; clear stack
		pop ecx
		pop ebx
		invoke list_set,ebx,ecx,eax
	check_loop:
	loop for_each_loop

	pop eax
	pop edx
	pop ecx
	pop ebx

	ret
list_map ENDP

list_filter PROC,list:DWORD,func:DWORD
	push ebx
	push ecx
	push edx

	new_list
	mov ebx, eax
	mov ecx,list
	mov ecx,[ecx+4]
	inc ecx
	jmp check_loop_1
	for_each_loop:
		dec ecx
		invoke list_get_item,list,ecx
		inc ecx
		push eax
		push ebx
		push ecx ; both protect and argument
		push eax ; argument for func
		call func
		pop ecx ; clear stack from arguments
		pop ecx
		pop ebx
		test eax,eax ; if function returned false
		jz check_loop
		mov eax,[esp]
		invoke list_insert,ebx,eax
	check_loop:
	pop eax
	check_loop_1:
	loop for_each_loop

	mov eax,ebx
	pop edx
	pop ecx
	pop ebx

	ret
list_filter ENDP

list_concat PROC l1:DWORD,l2:DWORD
	push ebx
	push ecx
	push esi
	push edi

	new_list
	push eax
	mov ebx,l1
	mov ecx,[ebx+4]
	mov ebx,l2
	add ecx,[ebx+4]
	shl ecx,2
	push ecx

	invoke Alloc,ecx
	mov edi,eax
	mov esi,l1
	push es
	push ds
	pop es

	mov ecx,[esi+4]
	mov esi,[esi]
	rep movsd

	mov esi, l2
	mov ecx,[esi+4]
	mov esi,[esi]
	rep movsd

	pop es

	pop ecx
	sub edi,ecx
	pop eax
	mov [eax],edi
	shr ecx,2
	mov [eax+4],ecx

	pop edi
	pop esi
	pop ecx
	pop ebx
	ret
list_concat ENDP

end
