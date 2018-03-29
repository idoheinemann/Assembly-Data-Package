include list_methods.inc

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

.code

st0_to_eax MACRO
	sub esp, 4      ; or use space you already reserved
	fstp dword ptr [esp]
	pop eax
ENDM

fld_eax MACRO
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

ln PROC, x:REAL4
	fldln2
	fld REAL4 ptr x
	FYL2X
	st0_to_eax
	ret
ln ENDP

factor PROC, x:REAL4
	fld x
	fld1
	the_loop:
		fld1
		fcomip st,st(2)
		jae finish
		fmul st,st(1)
		fld1
		fsubp st(2),st
	jmp the_loop
	finish:
	st0_to_eax
	fstp st(0) ; pop
	ret
factor endp

exp PROC, x:REAL4
	push ecx
	sub esp,8
	fld1
	fstp DWORD PTR [esp] ; [esp] = result
	mov [esp+4],dword ptr 1 ; counter
	
	the_loop:

		fild DWORD PTR [esp+4]
		st0_to_eax ; eax = counter as float
		invoke factor,eax
		; normalpow x,counter
		mov ecx,[esp+4]
		fld x
		fld1
		pow_loop:
			fmul st,st(1)
		loop pow_loop
		fstp st(1) ; pop
		fld_eax ; st = n!
		fdivp st(1),st ; st(0) = x^n/n!
		fld DWORD PTR [esp] ; sum 
		FADD st,st(1) ; st = sum+(x^n/n!)
		fstp dword ptr [esp]
		fstp st(0) ; pop 
		inc DWORD PTR [esp+4]
	cmp [esp+4],DWORD PTR 35
	jl the_loop

	mov eax,[esp] 
	add esp,8
	pop ecx
	ret
exp ENDP

pow PROC, x:REAL4, y:REAL4
	invoke ln,x
	fld y
	fmul x
	st0_to_eax
	invoke exp,eax ; x^y = exp(ln(x)*y)
	ret
pow endp

log PROC, x:REAL4, y:REAL4
	fld1
	fld x
	fyl2x
	fld1
	fld y
	fyl2x
	fdiv st,st(1)
	st0_to_eax
	ret
log endp

log2 PROC,x:REAL4
	fld1
	fld x
	fyl2x
	st0_to_eax
	ret
log2 endp

cos PROC,x:REAL4
	fld x
	fcos
	st0_to_eax
	ret
cos endp

sin PROC,x:REAL4
	fld x
	fsin
	st0_to_eax
	ret
sin endp

tan PROC,x:REAL4
	fld x
	fptan
	fstp st(0)
	st0_to_eax
	ret
tan endp

tanh PROC,x:REAL4
	fld x
	fadd x ; 2x
	st0_to_eax
	invoke exp,eax
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

sinh PROC,x:REAL4
	invoke exp,x
	fld_eax
	fld1
	fld_eax
	fdivp st(1),st ; exp(-x) = 1/exp(x)
	fsubp st(1),st ; st = exp(x)-exp(-x)
	fld1
	fld1
	faddp st(1),st
	fdivp st(1),st
	st0_to_eax
	ret
sinh ENDP

cosh PROC,x:REAL4
	invoke exp,x
	fld_eax
	fld1
	fld_eax
	fdivp st(1),st ; exp(-x) = 1/exp(x)
	faddp st(1),st ; st = exp(x)+exp(-x)
	fld1
	fld1
	faddp st(1),st
	fdivp st(1),st
	st0_to_eax
	ret
cosh ENDP

atan PROC,x:REAL4
	fld x
	fld1
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
	fpatan ; 2*atan(x/(1+sqrt(1-x^2))) = asin(x)
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
	fpatan
	fadd st,st(0)
	st0_to_eax
	ret
acos ENDP

atanh PROC,x:REAL4
	fld x
	fld x
	fld1
	fadd st(2),st
	fsub st(1),st
	fstp st(0) ; pop
	fdivp st(1),st
	st0_to_eax
	invoke ln,eax
	fld_eax
	fld1
	fld1
	faddp st(1),st
	fdivp st(1),st
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
	invoke ln,eax ; asinh(x) = ln(x+sqrt(x^2+1))
	ret
acosh ENDP
