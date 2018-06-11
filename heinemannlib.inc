
;;;;;;;;;;;; CREATED BY IDO HEINEMANN ;;;;;;;;;;;;


;;;;;;;;;;;; SOURCE CODE AND MORE AVAILABLE AT https://github.com/idoheinemann ;;;;;;;;;;;;


.686

.data

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MATH FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; MACROS ;;;;

fstp_reg MACRO reg ; fstp to a register
	sub esp, 4
	fstp dword ptr [esp]
	pop reg
ENDM

fst_reg MACRO reg ; fst to a register
	sub esp, 4
	fst dword ptr [esp]
	pop reg
ENDM

fld_reg MACRO reg  ; name also self-explaining
	push reg
	fld DWORD PTR [esp]
	pop reg
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF MATH FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; STRING FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

str_length PROTO string:DWORD

parse_int PROTO string:DWORD ; eax = (int)string

int_to_string PROTO number:DWORD ; eax = pointer to a new string , (string)number

concat PROTO str1:DWORD,str2:DWORD ; eax = pointer to a new string, str1+str2

compare PROTO str1:DWORD,str2:DWORD ; eax = (str1 == str2) , 0 if false 1 if true

index_of PROTO str1:DWORD,substr1:DWORD ; tries to locate the sub string substr1 in str1 and returns the first index where it was found, returns -1 if substring wasn't found


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF STRING FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DATA STRUCTURES AND FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

new_node PROTO value:DWORD,next:DWORD ; creates a new node with the given value and next node, both can be NULL

delete_node PROTO node:DWORD ; safe delete the node and all it's children

;;;; QUEUE ;;;; 

queue_push PROTO queue:DWORD, value:DWORD

queue_pop PROTO queue:DWORD

delete_queue PROTO queue:DWORD ; safe delete the queue

;;;; STACK ;;;;

stack_push PROTO queue:DWORD, value:DWORD 

stack_pop PROTO queue:DWORD

delete_stack PROTO queue:DWORD ; safe delete the stack

;;;; BOTH STACK AND QUEUE

peek PROTO object:DWORD ; can accept both the offset of a queue and the offset of a stack


;;;; LIST ;;;; 

list_insert PROTO list:DWORD,value:DWORD ; list.insert(value), appends the value to the end of the list and increases list.count

list_set PROTO list:DWORD, index:DWORD, value:DWORD ; list[index] = value

list_index_of PROTO list:DWORD, item:DWORD ; gets the first index for which list[index] == item

list_delete_at PROTO list:DWORD, index:DWORD ; removes the item at list[index] from

list_get_item PROTO list:DWORD, index:DWORD ; eax = list[index]

delete_list PROTO list:DWORD ; safe delete the list


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF DATA STRUCTURES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LINEAR ALGEBRA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Matrix STRUCT
	elements DWORD ? ; pointers to the first element in each row
	rows DWORD ?
	columns DWORD ?
Matrix ends

matrix_delete PROTO mat:DWORD ; safe delete a matrix

zero_matrix PROTO rows:DWORD,columns:DWORD ; returns a pointer to a new zero matrix

matrix_get_row PROTO mat:DWORD,row:DWORD ; returns a pointer to the first element in the row

matrix_get_element PROTO mat:DWORD,row:DWORD,col:DWORD ; returns mat[row,col]

matrix_set_element PROTO mat:DWORD,row:DWORD,col:DWORD,value:DWORD ; mat[row,col] = value

matrix_set_row PROTO mat:DWORD,row:DWORD,reprow:DWORD ; copies the row specified by the row pointer reprow to the row of the matrix

matrix_load PROTO dst:DWORD,src:DWORD ; copies the destination matrix to the source matrix

matrix_add PROTO dst:DWORD,src:DWORD ; += instruction for matrices, dst += src

matrix_plus PROTO dst:DWORD,src:DWORD ; +, returns a pointer to the new matrix dst+src

matrix_sub PROTO dst:DWORD,src:DWORD ;  -= instruction for matrices, dst-= src

matrix_minus PROTO dst:DWORD,src:DWORD ; -, returns a pointer to the new matrix dst-src

matrix_elementwize_mul PROTO dst:DWORD,src:DWORD ; *=, multiply dst by src elementwize

matrix_elementwize_times PROTO dst:DWORD,src:DWORD ; *, returns a pointer to the new matrix src*dst (elementwize multiplication)

matrix_mul PROTO mat1:DWORD,mat2:DWORD ; matrix multiplication, returns pointer to a new matrix

matrix_scalar_mul PROTO mat:DWORD,scl:REAL4 ; matrix multiplication by a scalar, mat *= scl

matrix_scalar_times PROTO mat:DWORD,scl:REAL4 ; *, returns a new matrix (scalar multiplication)

matrix_elementwize PROTO mat:DWORD,func:DWORD ; function must be stdcall, and take one REAL4 argument; equivalent to element = f(element) for every element

matrix_element_function PROTO mat:DWORD,func:DWORD ; function must be stdcall, and take one REAL4 argument; returns f(element) for each element

random_matrix PROTO rows:DWORD,columns:DWORD ; returns a new matrix R(rows,columns) of random values between 0 and 1

ones_matrix PROTO rows:DWORD,columns:DWORD ; returns a matrix R(rows,columns) of ones

identity_matrix PROTO rows:DWORD,columns:DWORD ; returns the identity_matrix by the dimensions R(rows,columns)

matrix_transpose PROTO  mat:DWORD ; returns the transpose of the matrix through eax

matrix_concat_rows PROTO mat1:DWORD, mat2:DWORD ; concat mat1 and mat2 by the rows, mat1 is R(n,m), mat2 is R(k,m), return is R(n+k,m)

matrix_concat_columns PROTO mat1:DWORD,mat2:DWORD ; concat mat1 and mat2 by the columns, mat1 is R(n,m), mat2 is R(n,k), return is R(n,m+k)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF LINEAR ALGEBRA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EXTRA LIST METHODS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bubble_sort PROTO list:DWORD ; sorts the list from smallest item to largest using bubble sort

insert_sorted PROTO list:DWORD,value:DWORD ; inserts the new value to the list while keeping it sorted from smallest to largest

list_map PROTO list:DWORD,func:DWORD ; returns a new list, function must be cdecl and can accept item,index

list_filter PROTO list:DWORD,func:DWORD ; returns a new list, function must be cdecl and can accept item,index

list_concat PROTO l1:DWORD,l2:DWORD ; returns a new list

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END OF EXTRA LIST METHODS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




