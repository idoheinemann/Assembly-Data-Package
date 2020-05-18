include \masm32\include\masm32rt.inc
include heinemannlib.inc
includelib heinemannlib.lib
include \masm32\include\gdiplus.inc
includelib \masm32\lib\gdiplus.lib
include adp_gui.inc

.data

move macro x1,y1
	mov eax,y1
	mov x1,eax
endm

__main_hwnd_ HWND ?
__async_keys_vals_ List<>
__async_keys_funs_ List<>

__init_index_ DWORD 100
__window_open_ DWORD 0

__mouse_move_main_ List<>
__mouse_click_left_main_ List<>
__mouse_click_right_main_ List<>
__mouse_down_left_main_ List<>
__mouse_down_right_main_ List<>
__key_handle_main_ List<>

__button_funcs_ids_ List<>
__button_funcs_offsets_ List<>

__control_handles_ List<>

__wnd_class_name_ BYTE "Sample Window Class",0

__gdipsi_ GdiplusStartupInput <1>

__one_float_ REAL4 1.0

__main_image_ HBITMAP ?
__main_hdc_ HDC ?
__main_graphics_ DWORD ?

__main_window_width_ DWORD ?
__main_window_height_ DWORD ?

.code

__wind_proc_ PROC,hwnd:HWND,msg:UINT, wParam:WPARAM,lParam:LPARAM
	switch msg
	case WM_KEYDOWN
		
		xor ecx,ecx
		jmp _test
		start_loop:
		push ecx
			invoke list_get_item, offset __key_handle_main_,ecx
			push wParam
			call eax
		pop ecx
		inc ecx
		_test:
		cmp ecx,__key_handle_main_.count
		jl start_loop

	case WM_MOUSEMOVE
		xor ecx,ecx
		jmp _test1
		start_loop1:
		push ecx
			invoke list_get_item, offset __mouse_move_main_,ecx
			mov ecx,lParam
			shr ecx,16 ; ecx = y coordinate = top 16 bits
			push ecx
			
			mov ebx,lParam 
			and ebx,00000ffffh ; ebx = x coordinate = bottom 16 bits
			push ebx
			call eax
		pop ecx
		inc ecx
		_test1:
		cmp ecx,__mouse_move_main_.count
		jl start_loop1
			

	case WM_LBUTTONDOWN
		xor ecx,ecx
		jmp _test2
		start_loop2:
		push ecx
			invoke list_get_item, offset __mouse_down_left_main_,ecx
			mov ecx,lParam
			shr ecx,16 ; ecx = y coordinate = top 16 bits
			push ecx
			
			mov ebx,lParam 
			and ebx,00000ffffh ; ebx = x coordinate = bottom 16 bits
			push ebx
			call eax
		pop ecx
		inc ecx
		_test2:
		cmp ecx,__mouse_down_left_main_.count
		jl start_loop2

	case WM_RBUTTONDOWN
		xor ecx,ecx
		jmp _test3
		start_loop3:
		push ecx
			invoke list_get_item, offset __mouse_down_right_main_,ecx
			mov ecx,lParam
			shr ecx,16 ; ecx = y coordinate = top 16 bits
			push ecx
			
			mov ebx,lParam 
			and ebx,00000ffffh ; ebx = x coordinate = bottom 16 bits
			push ebx
			call eax
		pop ecx
		inc ecx
		_test3:
		cmp ecx,__mouse_down_right_main_.count
		jl start_loop3

	case WM_LBUTTONUP
		xor ecx,ecx
		jmp _test4
		start_loop4:
		push ecx
			invoke list_get_item, offset __mouse_click_left_main_,ecx
			mov ecx,lParam
			shr ecx,16 ; ecx = y coordinate = top 16 bits
			push ecx
			
			mov ebx,lParam 
			and ebx,00000ffffh ; ebx = x coordinate = bottom 16 bits
			push ebx
			call eax
		pop ecx
		inc ecx
		_test4:
		cmp ecx,__mouse_click_left_main_.count
		jl start_loop4

	case WM_RBUTTONUP
		xor ecx,ecx
		jmp _test5
		start_loop5:
		push ecx
			invoke list_get_item, offset __mouse_click_right_main_,ecx
			mov ecx,lParam
			shr ecx,16 ; ecx = y coordinate = top 16 bits
			push ecx
			
			mov ebx,lParam 
			and ebx,00000ffffh ; ebx = x coordinate = bottom 16 bits
			push ebx
			call eax
		pop ecx
		inc ecx
		_test5:
		cmp ecx,__mouse_click_right_main_.count
		jl start_loop5

	case WM_COMMAND
		invoke list_index_of,offset __button_funcs_ids_,wParam
		cmp eax,-1
		je not_a_button
			invoke list_get_item,offset __button_funcs_offsets_,eax
			test eax,eax
			je not_a_button
			call eax
		not_a_button:


	case WM_CLOSE
		invoke DestroyWindow,hwnd;
		mov __window_open_,0;
		invoke ExitProcess,0;

	case WM_DESTROY
		invoke PostQuitMessage,0;

	default
		invoke DefWindowProc,hwnd, msg, wParam, lParam
	endsw
	ret

__wind_proc_ endp

adp_main PROC
	local msg:MSG,hdc:HDC
	pusha

	mov hdc,rv(GetDC,__main_hwnd_)
	invoke BitBlt,hdc, 0, 0, __main_window_width_, __main_window_height_, __main_hdc_, 0, 0, SRCCOPY;

	invoke ReleaseDC,__main_hwnd_,hdc

	xor ecx,ecx
	jmp _test
	start_loop:
	push ecx
		invoke list_get_item, offset __async_keys_vals_,ecx
		invoke GetAsyncKeyState,eax
		test eax,eax
		jz key_up
			mov eax,[esp]
			invoke list_get_item,offset __async_keys_funs_,eax
			call eax
		key_up:
	pop ecx
	inc ecx
	_test:
	cmp ecx,__async_keys_vals_.count
	jl start_loop
	invoke PeekMessage, addr msg, __main_hwnd_, 0, 0, PM_REMOVE
		test eax,eax ; if exit code
		jz exit_window
        invoke TranslateMessage, addr msg
        invoke DispatchMessage, addr msg
	exit_window:
	popa
	ret
adp_main ENDP

adp_open_window PROC,w:DWORD,h:DWORD, ttl:DWORD
	LOCAL wc:WNDCLASS,gdiplusToken:DWORD,hdc:HDC
	push ebx
	push ecx
	push edx	
	mov __window_open_ ,1

	move __main_window_width_,w
	move __main_window_height_,h

	invoke GdiplusStartup, addr gdiplusToken, offset __gdipsi_, NULL

	mov wc.lpfnWndProc, __wind_proc_;
	mov wc.hInstance, rv(GetModuleHandle, 0) ; get the module handle to hInstance
	mov wc.lpszClassName, offset __wnd_class_name_
	mov wc.hbrBackground, rv(GetStockObject,WHITE_BRUSH);
	mov wc.hCursor, rv(LoadCursor,NULL, IDC_ARROW);
	mov wc.hIcon,rv(LoadIcon,NULL,IDI_APPLICATION)


	invoke RegisterClass,addr wc

	

	invoke CreateWindowEx, NULL, wc.lpszClassName, ttl, ; create the window
    WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX or WS_VISIBLE or WS_CLIPCHILDREN,
    50, 50, w, h,        ; x, y, w, h
    NULL, NULL, wc.hInstance, NULL

	mov __main_hwnd_,eax

	.if __main_hwnd_ == NULL
		pop edx
		pop ecx
		pop ebx
		mov eax,0
		ret	
	.endif
	
	invoke ShowWindow,__main_hwnd_, 1
	invoke UpdateWindow,__main_hwnd_

	mov hdc, rv(GetDC,__main_hwnd_);
	
	mov __main_hdc_ ,rv(CreateCompatibleDC,hdc)

	mov __main_image_,rv(CreateCompatibleBitmap,hdc, w, h)

	invoke SelectObject,__main_hdc_, __main_image_;

	invoke ReleaseDC,__main_hwnd_, hdc

	invoke GdipCreateFromHDC,__main_hdc_, addr __main_graphics_

	pop edx
	pop ecx
	pop ebx
	mov eax,1
	ret	
	
adp_open_window ENDP

adp_set_window_title PROC,txt:DWORD
	pusha
	invoke SetWindowText,__main_hwnd_,txt
	popa
	ret
adp_set_window_title ENDP

adp_get_window_open PROC
	mov eax,__window_open_
	ret
adp_get_window_open ENDP

adp_add_async_key_listener PROC key:DWORD, func:DWORD
	invoke list_insert,offset __async_keys_vals_,key;
	invoke list_insert,offset __async_keys_funs_,func;
	ret
adp_add_async_key_listener ENDP

adp_add_key_listener PROC,func:DWORD
	invoke list_insert, offset  __key_handle_main_,func
	ret
adp_add_key_listener endp

adp_add_mouse_move_listener PROC,func:DWORD
	invoke list_insert, offset  __mouse_move_main_,func
	ret
adp_add_mouse_move_listener endp

adp_add_mouse_click_left_listener PROC,func:DWORD
	invoke list_insert, offset __mouse_click_left_main_,func
	ret
adp_add_mouse_click_left_listener endp

adp_add_mouse_click_right_listener PROC,func:DWORD
	invoke list_insert,offset  __mouse_click_right_main_,func
	ret
adp_add_mouse_click_right_listener endp

adp_add_mouse_down_left_listener PROC,func:DWORD
	invoke list_insert, offset __mouse_down_left_main_,func
	ret
adp_add_mouse_down_left_listener endp

adp_add_mouse_down_right_listener PROC,func:DWORD
	invoke list_insert,offset  __mouse_down_right_main_,func
	ret
adp_add_mouse_down_right_listener endp

adp_fill_ellipse PROC, x:dword,y:dword,w:dword, h:dword, color:dword
	local brsh:HBRUSH,pn:HPEN
	pusha
	mov brsh, rv(CreateSolidBrush,color);
	mov pn, rv(CreatePen,0, 0, color);
	invoke SelectObject,__main_hdc_, pn
	invoke SelectObject,__main_hdc_, brsh
	mov eax,x
	add w,eax
	mov eax,y
	add h,eax
	invoke Ellipse,__main_hdc_, x, y, w, h
	invoke DeleteObject,brsh
	invoke DeleteObject,pn
	popa
	ret
adp_fill_ellipse endp

adp_fill_rect PROC, x:dword,y:dword,w:dword, h:dword, color:dword
	local brsh:HBRUSH,pn:HPEN
	pusha
	mov brsh, rv(CreateSolidBrush,color);
	mov pn, rv(CreatePen,0, 0, color);
	invoke SelectObject,__main_hdc_, pn
	invoke SelectObject,__main_hdc_, brsh
	mov eax,x
	add w,eax
	mov eax,y
	add h,eax
	invoke Rectangle,__main_hdc_, x, y, w, h
	invoke DeleteObject,brsh
	invoke DeleteObject,pn
	popa
	ret
adp_fill_rect endp

adp_draw_ellipse PROC, x:dword,y:dword,w:dword, h:dword, color:dword
	local pn:HPEN
	pusha
	invoke SelectObject,__main_hdc_,rv(GetStockObject,NULL_BRUSH)
	mov pn, rv(CreatePen,0, 1, color);
	invoke SelectObject,__main_hdc_, pn
	mov eax,x
	add w,eax
	mov eax,y
	add h,eax
	invoke Ellipse,__main_hdc_, x, y, w, h
	invoke DeleteObject,pn
	popa
	ret
adp_draw_ellipse endp

adp_draw_rect PROC, x:dword,y:dword,w:dword, h:dword, color:dword
	local pn:HPEN
	pusha
	invoke SelectObject,__main_hdc_,rv(GetStockObject,NULL_BRUSH)
	mov pn, rv(CreatePen,0, 1, color);
	invoke SelectObject,__main_hdc_, pn
	mov eax,x
	add w,eax
	mov eax,y
	add h,eax
	invoke Rectangle,__main_hdc_, x, y, w, h
	invoke DeleteObject,pn
	popa
	ret
adp_draw_rect endp

adp_draw_text PROC, x:DWORD, y:DWORD, text:dword, tsize:dword, color:dword
	local fontn:HFONT,rectc:RECT
	pusha
	invoke SetBkMode,__main_hdc_, TRANSPARENT;
	mov fontn, rv(CreateFont,tsize, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	invoke SelectObject,__main_hdc_, fontn
	invoke SetTextColor,__main_hdc_, color
	move rectc.left, x
	move rectc.top, y
	mov rectc.right, 0FFFFh
	mov rectc.bottom, 0FFFFh
	invoke DrawText, __main_hdc_, text, -1, addr rectc, DT_SINGLELINE or DT_LEFT or DT_TOP
	invoke DeleteObject, fontn
	popa
	ret

adp_draw_text ENDP

adp_draw_line PROC,x1:dword, y1:dword, x2:dword,y2:dword, color:dword
	LOCAL ppen:DWORD
	pusha
	or color,0ff000000h
	
	invoke GdipCreatePen1,color,__one_float_,UnitPixel,addr ppen
	
	
	invoke GdipDrawLineI, __main_graphics_,  ppen , x1,y1,x2,y2

	invoke GdipDeletePen,ppen

	popa
	ret
adp_draw_line ENDP

adp_create_button PROC , butt:DWORD, x:DWORD, y:DWORD, w:DWORD, h:DWORD,text:DWORD, func:DWORD
	pusha
	invoke list_insert, offset __button_funcs_ids_, __init_index_
	invoke list_insert, offset __button_funcs_offsets_, func
	mov ebx,butt
	buto equ [ebx.Button]
	move buto.x, x;
	move buto.y , y;
	move buto.w, w;
	move buto.h, h;
	move buto.id , __init_index_;
	invoke CreateWindowEx , 0, reparg("BUTTON"), text, WS_CHILD or WS_VISIBLE, x, y, w, h, __main_hwnd_, __init_index_, rv(GetModuleHandle,NULL), NULL
	mov buto.handle,eax
	invoke list_insert,offset __control_handles_, eax
	inc __init_index_
	popa
	ret
adp_create_button ENDP

adp_button_set_x PROC,butt:DWORD, x:DWORD
	pusha
	mov ebx,butt
	buto equ [ebx.Button]
	invoke MoveWindow, buto.handle, x, buto.y, buto.w, buto.h, 0;
	move buto.x , x;
	popa
	ret
adp_button_set_x endp

adp_button_set_y PROC,butt:DWORD, y:DWORD
	pusha
	mov ebx,butt
	buto equ [ebx.Button]
	invoke MoveWindow, buto.handle, buto.x, y, buto.w, buto.h, 0;
	move buto.y , y;
	popa
	ret
adp_button_set_y endp

adp_button_set_w PROC,butt:DWORD, w:DWORD
	pusha
	mov ebx,butt
	buto equ [ebx.Button]
	invoke MoveWindow, buto.handle, buto.x, buto.y, w, buto.h, 0;
	move buto.w , w;
	popa
	ret
adp_button_set_w endp

adp_button_set_h PROC,butt:DWORD, h:DWORD
	pusha
	mov ebx,butt
	buto equ [ebx.Button]
	invoke MoveWindow, buto.handle, buto.x, buto.y, buto.w, h, 0;
	move buto.h , h;
	popa
	ret
adp_button_set_h endp

adp_button_set_text PROC, butt:DWORD, text:DWORD
	pusha
	mov ebx,butt
	invoke SendMessage, [ebx.Button].handle, WM_SETTEXT, 0,text;
	popa
	ret
adp_button_set_text endp

adp_button_set_function PROC, butt:DWORD , func:DWORD
	pusha
	mov ebx,butt
	invoke list_index_of,offset __button_funcs_ids_,[ebx.Button].id
	cmp eax,-1
	je the_end
	invoke list_set, offset __button_funcs_offsets_,eax ,  func
	the_end:
	popa
	ret
adp_button_set_function ENDP

adp_button_get_text PROC, butt:DWORD
	push ebx
	push ecx
	push edx
	invoke Alloc,512
	push eax
	mov ebx,butt
	invoke SendMessage,[ebx.Button].handle, WM_GETTEXT, 512, eax;
	pop eax
	pop edx
	pop ecx
	pop ebx
	ret
adp_button_get_text endp

adp_create_textfield PROC , butt:DWORD, x:DWORD, y:DWORD, w:DWORD, h:DWORD
	local fontn:HFONT
	pusha
	mov ebx,butt
	buto equ [ebx.TextField]
	move buto.x, x;
	move buto.y , y;
	move buto.w, w;
	move buto.h, h;
	invoke CreateWindowEx , 0, reparg("EDIT"), NULL, WS_CHILD or WS_VISIBLE or WS_BORDER, x, y, w, h, __main_hwnd_, __init_index_, rv(GetModuleHandle,NULL), NULL
	mov buto.handle,eax
	sub h,4
	mov fontn, rv(CreateFont,h, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	invoke SendMessage,buto.handle,WM_SETFONT,fontn,FALSE
	invoke DeleteObject,fontn
	invoke list_insert,offset __control_handles_, eax
	inc __init_index_
	popa
	ret
adp_create_textfield ENDP

adp_textfield_set_x PROC,butt:DWORD, x:DWORD
	pusha
	mov ebx,butt
	buto equ [ebx.TextField]
	invoke MoveWindow, buto.handle, x, buto.y, buto.w, buto.h, 0;
	move buto.x , x;
	popa
	ret
adp_textfield_set_x endp

adp_textfield_set_y PROC,butt:DWORD, y:DWORD
	pusha
	mov ebx,butt
	buto equ [ebx.TextField]
	invoke MoveWindow, buto.handle, buto.x, y, buto.w, buto.h, 0;
	move buto.y , y;
	popa
	ret
adp_textfield_set_y endp

adp_textfield_set_w PROC,butt:DWORD, w:DWORD
	pusha
	mov ebx,butt
	buto equ [ebx.TextField]
	invoke MoveWindow, buto.handle, buto.x, buto.y, w, buto.h, 0;
	move buto.w , w;
	popa
	ret
adp_textfield_set_w endp

adp_textfield_set_h PROC,butt:DWORD, h:DWORD
	pusha
	mov ebx,butt
	buto equ [ebx.TextField]
	invoke MoveWindow, buto.handle, buto.x, buto.y, buto.w, h, 0;
	move buto.h , h;
	popa
	ret
adp_textfield_set_h endp

adp_textfield_set_text PROC, butt:DWORD, text:DWORD
	pusha
	mov ebx,butt
	invoke SendMessage, [ebx.TextField].handle, WM_SETTEXT, 0,text;
	popa
	ret
adp_textfield_set_text endp

adp_textfield_get_text PROC, butt:DWORD
	push ebx
	push ecx
	push edx
	invoke Alloc,512
	push eax
	mov ebx,butt
	invoke SendMessage,[ebx.TextField].handle, WM_GETTEXT, 512, eax;
	pop eax
	pop edx
	pop ecx
	pop ebx
	ret
adp_textfield_get_text endp

adp_load_image PROC, img:DWORD, src:DWORD
	pusha
	invoke str_length,src
	shl eax,1
	invoke Alloc,eax
	push eax
	invoke lstrlen,src
	mov ebx,[esp]
	invoke crt_mbstowcs, ebx, src, eax
	mov eax,[esp]
	mov ebx,img
	add ebx,8
	invoke GdipLoadImageFromFile,eax,ebx
	call Free
	mov ebx,img
	mov eax,img
	invoke GdipGetImageWidth,[ebx.Img].info,eax
	mov ebx,img
	mov eax,img
	add eax,4
	invoke GdipGetImageHeight,[ebx.Img].info,eax
	popa
	ret
adp_load_image ENDP

adp_draw_image PROC,img:DWORD,x:DWORD,y:DWORD
	pusha
	mov ebx,img
	invoke GdipDrawImageRectI,__main_graphics_,[ebx.Img].info,x,y,[ebx.Img].w,[ebx.Img].h


	popa
	ret
adp_draw_image endp

adp_draw_image_scale PROC,img:DWORD,x:DWORD,y:DWORD,w:DWORD,h:DWORD
	pusha
	mov ebx,img
	invoke GdipDrawImageRectI,__main_graphics_,[ebx.Img].info,x,y,w,h

	popa
	ret
adp_draw_image_scale endp

adp_draw_image_crop PROC,img:DWORD,x:DWORD,y:DWORD,x1:DWORD,y1:DWORD,w1:DWORD,h1:DWORD
	pusha
	mov ebx,img
	invoke GdipDrawImageRectRectI,__main_graphics_,[ebx.Img].info,x,y,[ebx.Img].w,[ebx.Img].h,x1,y1,w1,h1,UnitPixel,NULL,NULL,NULL


	popa
	ret
adp_draw_image_crop endp

adp_clear_screen_to_color PROC,color:DWORD
	pusha
	or color,0FF000000h
	
	INVOKE GdipGraphicsClear,__main_graphics_,color	

	popa
	ret
adp_clear_screen_to_color endp

adp_draw_image_scale_crop PROC,img:DWORD,x:DWORD,y:DWORD,w:DWORD,h:DWORD,x1:DWORD,y1:DWORD,w1:DWORD,h1:DWORD
	pusha
	mov ebx,img
	invoke GdipDrawImageRectRectI,__main_graphics_,[ebx.Img].info,x,y,w,h,x1,y1,w1,h1,UnitPixel,NULL,NULL,NULL

	popa
	ret
adp_draw_image_scale_crop endp

adp_button_delete PROC,button:DWORD
	pusha
	mov ebx,button
	invoke DestroyWindow, [ebx.Button].handle
	mov ebx,[button]
	but equ [ebx.Button]
	mov but.x,0
	mov but.y,0
	mov but.w,0
	mov but.h,0
	mov but.handle,0
	mov but.id,0
	popa
	ret
adp_button_delete ENDP

adp_textfield_delete PROC,tf:DWORD
	pusha
	mov ebx,tf
	invoke DestroyWindow, [ebx.TextField].handle
	mov ebx,[tf]
	but equ [ebx.TextField]
	mov but.x,0
	mov but.y,0
	mov but.w,0
	mov but.h,0
	mov but.handle,0
	popa
	ret
adp_textfield_delete ENDP

adp_get_main_hwnd PROC
	mov eax,__main_hwnd_
	ret
adp_get_main_hwnd ENDP

adp_get_main_hdc PROC
	mov eax,__main_hdc_
	ret
adp_get_main_hdc endp

adp_get_pixel PROC,x:DWORD,y:DWORD
	push ebx
	push ecx
	push edx
	invoke GetPixel, __main_hdc_,x,y
	and eax,0ffffffh
	pop edx
	pop ecx
	pop ebx
	ret
adp_get_pixel ENDP

adp_image_delete PROC, img:DWORD
	pusha
	mov ebx,img
	invoke GdipDisposeImage,[ebx.Img].info
	mov [ebx.Img].w,0
	mov [ebx.Img].h,0
	mov [ebx.Img].info,0
	popa
	ret
adp_image_delete ENDP

adp_set_icon PROC, src:DWORD
	local icon:HICON
	pusha
	mov icon,rv(LoadImage,NULL,src,IMAGE_ICON,0,0,LR_LOADFROMFILE or LR_DEFAULTSIZE or LR_SHARED )
	invoke SendMessage,__main_hwnd_,WM_SETICON,TRUE,icon
	invoke SendMessage,__main_hwnd_,WM_SETICON,FALSE,icon
	popa
	ret
adp_set_icon ENDP

adp_get_screen_image PROC,src:DWORD
	push ebx
	push ecx
	push edx
	invoke CopyImage,__main_image_, IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE
	push eax
	mov ebx,src
	invoke GdipCreateBitmapFromHBITMAP,eax,NULL,[ebx.Img].info
	mov ebx,src
	mov eax,src
	invoke GdipGetImageWidth,[ebx.Img].info,eax
	mov ebx,src
	mov eax,src
	add eax,4
	invoke GdipGetImageHeight,[ebx.Img].info,eax
	call DeleteObject
	pop edx
	pop ecx
	pop edx
adp_get_screen_image ENDP
end
