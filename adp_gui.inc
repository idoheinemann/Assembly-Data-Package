.data

;;;;;; CREATED BY IDO HEINEMANN ;;;;;

;;;;;; SOURCE CODE AND MORE AVAILABLE AT https://github.com/idoheinemann ;;;;;;

;; the main window function
;; handles all the events
;; must be run through a loop
;; returns 1 on success, 0 on failure
adp_main PROTO



;; the initialization function
;; opens a window and initializes all variables
;; must be the first adp function to be called (accept for non-gui functions)
;; @param w -> the width of the window, int
;; @param h -> the height of the window, int
;; @param ttl -> the title of the new window, pointer to a string
adp_open_window PROTO w:DWORD,h:DWORD,ttl:DWORD




;; returns 0 if window is closed, 1 if opened
adp_get_window_open PROTO




;; sets a function that will be invoked every time the specified key is pressed
;; @param key -> the key code for the activating key
;; @param func -> the offset of the function to be invoked when the key is pressed
adp_add_async_key_listener PROTO key:DWORD, func:DWORD




;; adds a function to be invoked every time a key is pressed
;; the function must recive one argument (the key code for the pressed key)
;; the function will run synchronized with the window
;; @param func -> the offset of the function to handle key events, func must take one argument
;; NOTE!! you can set multiple functions using adp_add_key_listener, each of them will be invoked with the key code as an argument
adp_add_key_listener PROTO func:DWORD



;; adds a function to be invoked every time the mouse moves
;; the function must recive two arguments (x and y coordinate of the mouse on the window, respectively)
;; the function will run synchronized with the window
;; @param func -> the offset of the function to handle key events, func must take two arguments
;; NOTE!! you can set multiple functions using adp_add_mouse_move_listener, each of them will be invoked with the x,y coordinates as an argument
adp_add_mouse_move_listener PROTO func:DWORD




;; adds a function to be invoked every time the left mouse clicker is clicked
;; the function must recive two arguments (x and y coordinate of the mouse on the window, respectively)
;; the function will run synchronized with the window
;; @param func -> the offset of the function to handle key events, func must take two arguments
;; NOTE!! you can set multiple functions using adp_add_mouse_click_left_listener, each of them will be invoked with the x,y coordinatese as an argument
adp_add_mouse_click_left_listener PROTO func:DWORD



;; adds a function to be invoked every time the right mouse clicker is clicked
;; the function must recive two arguments (x and y coordinate of the mouse on the window, respectively)
;; the function will run synchronized with the window
;; @param func -> the offset of the function to handle key events, func must take two arguments
;; NOTE!! you can set multiple functions using adp_add_mouse_click_right_listener, each of them will be invoked with the x,y coordinates as an argument
adp_add_mouse_click_right_listener PROTO func:DWORD




;; adds a function to be invoked when the left mouse clicker is down
;; the function must recive two arguments (x and y coordinate of the mouse on the window, respectively)
;; the function will run synchronized with the window
;; @param func -> the offset of the function to handle key events, func must take two arguments
;; NOTE!! you can set multiple functions using adp_add_mouse_down_left_listener, each of them will be invoked with the x,y coordinatese as an argument
adp_add_mouse_click_down_listener PROTO func:DWORD



;; adds a function to be invoked when the right mouse clicker is down
;; the function must recive two arguments (x and y coordinate of the mouse on the window, respectively)
;; the function will run synchronized with the window
;; @param func -> the offset of the function to handle key events, func must take two arguments
;; NOTE!! you can set multiple functions using adp_add_mouse_down_right_listener, each of them will be invoked with the x,y coordinates as an argument
adp_add_mouse_down_right_listener PROTO func:DWORD



;; changes the title of the window
;; @param ttl -> the new window title, pointer to a string
adp_set_window_title PROTO ttl:DWORD



;; fills an ellipse on the window
;; @param x -> the x coordinate of the top-left of the ellipse
;; @param y -> the y coordinate of the top-left of the ellipse
;; @param w -> width of the ellipse
;; @param h -> the height of the ellipse
;; @param color -> the rgb color of the ellipse
adp_fill_ellipse PROTO x:DWORD,	y:DWORD, w:DWORD, h:DWORD, color:DWORD



;; fills a rect on the window
;; @param x -> the x coordinate of the top-left of the rect
;; @param y -> the y coordinate of the top-left of the rect
;; @param w -> width of the rect
;; @param h -> the height of the rect
;; @param color -> the rgb color of the rect
adp_fill_rect PROTO x:DWORD,	y:DWORD, w:DWORD, h:DWORD, color:DWORD



;; draws an ellipse border on the window
;; @param x -> the x coordinate of the top-left of the ellipse
;; @param y -> the y coordinate of the top-left of the ellipse
;; @param w -> width of the ellipse
;; @param h -> the height of the ellipse
;; @param color -> the rgb color of the ellipse
adp_draw_ellipse PROTO x:DWORD,	y:DWORD, w:DWORD, h:DWORD, color:DWORD



;; draws a rect border on the window
;; @param x -> the x coordinate of the top-left of the rect
;; @param y -> the y coordinate of the top-left of the rect
;; @param w -> width of the rect
;; @param h -> the height of the rect
;; @param color -> the rgb color of the rect
adp_draw_rect PROTO x:DWORD, y:DWORD, w:DWORD, h:DWORD, color:DWORD




;; draws text on the windpw
;; @param x -> x coordinate of top-left corner
;; @param y -> y coordinate of top-left cornet
;; @param txt -> text to be drawen, pointer to a string
;; @param psize -> size of the text
;; @param color -> color of the text
adp_draw_text PROTO x:DWORD, y:DWORD, txt:DWORD, psize:DWORD, color:DWORD



;; draws a line between the first and second point
;; @param x1 -> x coordinate of the first point
;; @param y1 -> y coordinate of the first point
;; @param x2 -> x coordinate of the second point
;; @param y2 -> y coordinate of the second point
;; @param color -> color of the line
adp_draw_line PROTO x1:DWORD, y1:DWORD, x2:DWORD, y2:DWORD, color:DWORD




;; represents a button on the screen
Button STRUCT
	x DWORD ? ; x coordinate of the button (can be changed using the adp_button_set_x function)
	y DWORD ? ; y coordinate of the button (can be changed using the adp_button_set_y function)
	w DWORD ? ; width of the button (can be changed using the adp_button_set_w function)
	h DWORD ? ; height of the button (can be changed using the adp_button_set_h function)
	handle DWORD ? ; handle to the button
	id DWORD ? ; id of the button
Button ENDS



;; creates a button and places it on the screen
;; loads the information about the button to the given button object
;; @param button -> the button to load the information to, pointer to a Button
;; @param x -> x coordinate of the button
;; @param y -> y coordinate of the button
;; @param w -> width of the button
;; @param h -> height of the button 
;; @param txt -> the text of the button, pointer to a string, can be NULL
;; @param func -> the function to be triggered when the button is pressed, can be NULL, can be modified at any time using the adp_button_set_function function, function will be invoked synchronized to the window
adp_create_button PROTO button:DWORD, x:DWORD, y:DWORD, w:DWORD, h:DWORD, txt:DWORD, func:DWORD



;; sets the x coordinate of the button and update the button's information
;; @param button -> the button, pointer to a Button
;; @param x -> the new x coordinate
adp_button_set_x PROTO button:DWORD, x:DWORD



;; sets the y coordinate of the button and update the button's information
;; @param button -> the button, pointer to a Button
;; @param y -> the new x coordinate
adp_button_set_y PROTO button:DWORD, y:DWORD



;; sets the width of the button and update the button's information
;; @param button -> the button, pointer to a Button
;; @param w -> the new width
adp_button_set_w PROTO button:DWORD, w:DWORD



;; sets the height of the button and update the button's information
;; @param button -> the button, pointer to a Button
;; @param h -> the new height
adp_button_set_h PROTO button:DWORD, h:DWORD



;; sets the text of the button
;; @param button -> the button, pointer to a Button
;; @param txt -> the new text
adp_button_set_text PROTO button:DWORD, txt:DWORD



;; sets the onclick function coordinate of the button
;; @param button -> the button, pointer to a Button
;; @param func -> the new function
adp_button_set_function PROTO button:DWORD, func:DWORD



;; returns a pointer to a new string containing the button's text
;; @param button -> the button, pointer to a Button
adp_button_get_text PROTO button:DWORD



;; represents a textfield on the screen
TextField STRUCT
	x DWORD ? ; x coordinate of the textfield (can be changed using the adp_button_set_x function)
	y DWORD ? ; y coordinate of the textfield (can be changed using the adp_button_set_y function)
	w DWORD ? ; width of the textfield (can be changed using the adp_button_set_w function)
	h DWORD ? ; height of the buttontextfield (can be changed using the adp_button_set_h function)
	handle DWORD ? ; handle to the textfield
TextField ENDS




;; creates a textfield and places it on the screen
;; loads the information about the textfield to the given textfield object
;; @param textfield -> the textfield to load the information to, pointer to a TextField
;; @param x -> x coordinate of the textfield
;; @param y -> y coordinate of the textfield
;; @param w -> width of the textfield
;; @param h -> height of the textfield 
adp_create_textfield PROTO textfield:DWORD, x:DWORD, y:DWORD, w:DWORD, h:DWORD



;; sets the x coordinate of the textfield and update the textfield's information
;; @param textfield -> the textfield, pointer to a TextField
;; @param x -> the new x coordinate
adp_textfield_set_x PROTO textfield:DWORD, x:DWORD



;; sets the y coordinate of the textfield and update the textfield's information
;; @param textfield -> the textfield, pointer to a TextField
;; @param y -> the new x coordinate
adp_textfield_set_y PROTO textfield:DWORD, y:DWORD



;; sets the width of the textfield and update the textfield's information
;; @param textfield -> the textfield, pointer to a TextField
;; @param w -> the new width
adp_textfield_set_w PROTO textfield:DWORD, w:DWORD



;; sets the height of the textfield and update the textfield's information
;; @param textfield -> the textfield, pointer to a TextField
;; @param h -> the new height
adp_textfield_set_h PROTO textfield:DWORD, h:DWORD



;; sets the input of the textfield
;; @param textfield -> the textfield, pointer to a TextField
;; @param txt -> the new text
adp_textfield_set_text PROTO textfield:DWORD, txt:DWORD




;; returns a pointer to a new string containing the textfield's input
;; @param textfield -> the textfield, pointer to a TextField
adp_textfield_get_text PROTO textfield:DWORD




Img STRUCT
	w DWORD ? ; width of the image
	h DWORD ? ; height of the image
	info DWORD ? ; pointer to an image info object associated with the image
Img ENDS



;; loads an image from a file
;; @param img -> the image object that the image should be loaded into , pointer to an Img
;; @param src -> name of the file, pointer to a string
adp_load_image PROTO img:DWORD, src:DWORD



;; draws the full image in scale of 1:1 (same width and height as in the Img object)
;; @param img -> the image to be drawn, pointer to an Img
;; @param x -> the top-left x coordinate
;; @param y -> the top-left y coordinate
adp_draw_image PROTO img:DWORD, x:DWORD, y:DWORD




;; draws the full image by the specified width and height
;; @param img -> the image to be drawn, pointer to an Img
;; @param x -> the top-left x coordinate
;; @param y -> the top-left y coordinate
;; @param w -> width to draw the image, in pixels
;; @param h -> height to draw the image, in pixels
adp_draw_image_scale PROTO img:DWORD, x:DWORD, y:DWORD, w:DWORD, h:DWORD



;; draws the specified part of the image by a scale of 1:1
;; @param img -> the image to be drawn, pointer to an Img
;; @param x -> the top-left x coordinate
;; @param y -> the top-left y coordinate
;; @param crop_x -> the top-left x coordinate to start cropping from
;; @param crop_y -> the top-left y coordinate to start cropping from
;; @param crop_w -> width to crop the image from starting point, in pixels 
;; @param crop_h -> height to crop the image from starting point, in pixels
adp_draw_image_crop PROTO img:DWORD, x:DWORD, y:DWORD, crop_x:DWORD, crop_y:DWORD, crop_w:DWORD,crop_h:DWORD

;; draws the specified part of the image by the specified width and height
;; @param img -> the image to be drawn, pointer to an Img
;; @param draw_x -> the top-left x coordinate
;; @param draw_y -> the top-left y coordinate
;; @param draw_w -> width to draw the image, in pixels
;; @param draw_h -> height to draw the image, in pixels
;; @param crop_x -> the top-left x coordinate to start cropping from
;; @param crop_y -> the top-left y coordinate to start cropping from
;; @param crop_w -> width to crop the image from starting point, in pixels 
;; @param crop_h -> height to crop the image from starting point, in pixels
adp_draw_image_scale_crop PROTO img:DWORD, draw_x:DWORD, draw_y:DWORD, draw_w:DWORD, draw_h:DWORD, crop_x:DWORD, crop_y:DWORD, crop_w:DWORD,crop_h:DWORD


;; paints the entire window to the specified color
;; @param color -> the color to paint the window
adp_clear_screen_to_color PROTO color:DWORD



;; safe deletes a button and resets all it's fields to 0
;; @param button -> the button to delete, pointer to a Button
adp_button_delete PROTO,button:DWORD



;; safe deletes a textfield and resets all it's fields to 0
;; @param textfield -> the textfield to delete, pointer to a TextField
adp_textfield_delete PROTO,textfield:DWORD


;; returns the main window hwnd
adp_get_main_hwnd PROTO


;; returns the main device handler
adp_get_main_hdc PROTO


;; safe deletes an image object and sets all it's fields to 0
;; @param img -> the image to erase, pointer to an Img
adp_image_delete PROTO img:DWORD


;; returns the color at the specified pixel
;; @param x -> the x coordinate of the pixel
;; @param y -> the y coordinate of the pixel
adp_get_pixel PROTO x:DWORD, y:DWORD


;; sets the icon for the application
;; @param src -> the source of the icon image, pointer to a string 
;; NOTE! icon images must be of type icon (.ico)
adp_set_icon PROTO src:DWORD