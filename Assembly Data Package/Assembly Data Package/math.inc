include data_structs.inc

.data

;;;; LOGARITHMS AND EXPONENTIALS

ln PROTO x:REAL4
exp PROTO x:REAL4
pow PROTO x:REAL4

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

ln PROC, x:REAL4
	fldl2e
	fld REAL4 ptr x
	FYL2X

	ret
ln ENDP

