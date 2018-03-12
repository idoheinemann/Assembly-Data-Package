include \masm32\include\masm32rt.inc


.const
NULL equ 0
FALSE equ 0
TRUE equ 1
.data
Node STRUCT
	value DWORD ?
	next DWORD ?
Node ENDS

Queue STRUCT
	head DWORD ?
	tail DWORD ?
	count DWORD ?
Queue ENDS

Stack STRUCT
	pointer DWORD ?
	count DWORD ?
Stack ENDS

BinTree STRUCT
	value DWORD ?
	left DWORD ?
	right DWORD ?
BinTree ENDS

List STRUCT
	items DWORD ?
	count DWORD ?
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


.code

;;;; NODE ;;;;

new_node PROC ,value:DWORD, next:DWORD
	invoke Alloc,SIZEOF Node

	push value
	pop DWORD PTR [eax]

	push next
	pop DWORD PTR [eax+4]

	ret
new_node ENDP

delete_node PROC, node:DWORD
	push ebx
	push edx
	push node
	delete_child_loop:
		pop ebx
		mov edx,ebx
		push DWORD PTR [ebx+4]
		invoke Free,edx
	cmp ebx,NULL
	jne delete_child_loop

	pop edx
	pop ebx
	ret
delete_node ENDP

;;;; QUEUE ;;;;

queue_push PROC, queue:DWORD, value:DWORD
	pusha
	
	invoke new_node,value,NULL ; eax = new Node(value = value,next = NULL)

	mov ebx,queue
	inc DWORD PTR [ebx+8] ; count++
	cmp DWORD PTR [ebx],NULL ; if head is null
	je HandleNull

	mov edx,[ebx+4] ; edx is a pointer to tail
	mov [edx+4],eax ; tail.next = new node

	jmp final

	HandleNull:
	mov [ebx],eax ; queue.head is the new node

	final:
	mov [ebx+4],eax ; queue.head is the new node
	popa
	ret
queue_push ENDP

queue_pop PROC,queue:DWORD
	mov eax,queue
	cmp DWORD PTR [eax+8],0
	jne notNull
		mov eax,NULL
		ret
	notNull:
	dec DWORD PTR [eax+8]
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
		mov edx,ebx ; edx = old node
		push DWORD PTR [ebx+4] ; ebx = ebx.next
		invoke Free,edx ; delete node
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
	mov ecx,[ebx+4] ; queue.count
	push DWORD PTR [ebx]
	delete_nodes_loop:
		pop ebx
		mov edx,ebx ; edx = old node
		push DWORD PTR [ebx+4] ; ebx = ebx.next
		invoke Free,edx ; delete node
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

list_insert proc, list:DWORD,value:DWORD
	pusha
	
	mov ebx,list
	inc DWORD PTR [ebx+4]
	mov ecx,[ebx+4]
	shl ecx,2
	invoke Alloc, ecx
	mov edi,eax
	mov ebx,list
	mov esi,[ebx]
	mov ecx,[ebx+4]
	dec ecx
	push es
	push ds
	pop es
	rep movsd
	pop es
	push value
	pop DWORD PTR [edi]
	invoke Free, [ebx]
	mov ebx,list
	mov ecx,[ebx+4]
	dec ecx
	shl ecx,2 ; ecx *= 4
	sub edi,ecx
	mov [ebx],edi
	popa
	ret
list_insert ENDP

list_get_item PROC,list:DWORD,index:DWORD
	push ebx
	mov ebx,list
	mov ebx,[ebx]
	mov eax,index
	shl eax,2
	mov eax,[ebx+eax]
	pop ebx
	ret
list_get_item ENDP

list_set PROC,list:DWORD,index:DWORD,value:DWORD
	push EAX
	push ebx
	mov ebx,list
	mov ebx,[ebx]
	mov eax,index
	shl eax,2
	push value
	pop DWORD PTR [ebx+eax]

	pop ebx
	pop eax
	ret
list_set ENDP

list_index_of PROC, list:DWORD , item:DWORD
	push ecx
	push ebx
	push es

	mov ebx,list
	mov ecx,[ebx+4]
	mov eax,item
	mov edi,[ebx]
	push ds
	pop es
	inc ecx
	sub edi,4
	jmp check_loop
	loop_label:
		add edi,4
		cmp [edi],eax ; movsq not supported
	check_loop:loopnz loop_label
	jnz notFound
	sub edi,[ebx]
	mov eax,edi
	shr eax,2 ; edi /= 2
	jmp final
	notFound:
		mov eax,-1
	final:
	pop es
	pop ebx
	pop ecx
	ret
list_index_of endp

list_delete_at PROC, list:DWORD, index:DWORD
	pusha
	mov ebx,list
	push DWORD PTR [ebx+4]
	mov ecx,[esp]
	dec ecx
	shl ecx,2
	invoke Alloc,ecx
	mov edi,eax
	mov ebx,list
	mov esi,[ebx]
	mov ecx,index
	push es
	push ds
	pop es
	rep movsd
	mov ecx,index
	inc ecx
	sub [esp+4],ecx
	mov ecx,[esp+4]
	add esi,4
	rep movsd ; movsq not supported
	pop es
	pop ecx
	add ecx,index
	shl ecx,2
	sub edi,ecx
	mov [ebx],edi
	dec DWORD PTR [ebx+4]
	popa
	ret
list_delete_at ENDP




;;;; MACROS ;;;;


new_stack MACRO
	invoke Alloc,SIZEOF Stack
ENDM

new_queue MACRO
	invoke Alloc,SIZEOF Queue
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