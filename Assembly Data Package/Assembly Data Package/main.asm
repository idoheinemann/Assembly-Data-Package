include string_functions.inc

.data
buffer byte 100 dup(?)
endl byte 13,10,0
gap byte " ",0
li List<>
.code
linedown macro
	invoke StdOut,offset endl
endm

main PROC
	mov ecx,6
	some_loop_tag:
	push ecx
	invoke StdIn,offset buffer,100
	invoke parse_int,offset buffer
	invoke list_insert,offset li,eax
	pop ecx
	loop some_loop_tag
	mov ecx,li.count
	some_label:
	push ecx
	dec ecx
	invoke list_get_item,offset li, ecx
	invoke int_to_string,eax
	invoke StdOut,eax
	linedown
	pop ecx
	loop some_label
	invoke list_delete_at,offset li,4

	linedown

	mov ecx,li.count
	some_label2:
	push ecx
	dec ecx
	invoke list_get_item,offset li, ecx
	invoke int_to_string,eax
	invoke StdOut,eax
	linedown
	pop ecx
	loop some_label2

	linedown

	invoke list_index_of,offset li,15
	invoke int_to_string,eax
	invoke StdOut,eax

	ret
main ENDP
end main



