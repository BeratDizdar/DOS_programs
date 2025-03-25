.model small	; assembler memory model
.stack 1024		; stack pointer area

.code
bitmap_test:
	db 11110000b, 00000000b, 00000000b, 00001111b
	db 11000000b, 00000000b, 00000000b, 00000011b
	db 00000000b, 00000000b, 00000000b, 00000000b
	db 00000000b, 00000000b, 00000000b, 00000000b
	db 00000000b, 00000000b, 00000000b, 00000000b
	db 00000000b, 00000000b, 00000000b, 00000000b
	db 00000000b, 00000000b, 00000000b, 00000000b
	db 00000000b, 00000010b, 10000000b, 00000000b
	db 00000000b, 00000010b, 10000000b, 00000000b
	db 00000000b, 00000000b, 00000000b, 00000000b
	db 00000000b, 00000000b, 00000000b, 00000000b
	db 00000000b, 00000000b, 00000000b, 00000000b
	db 00000000b, 00000000b, 00000000b, 00000000b
	db 00000000b, 00000000b, 00000000b, 00000000b
	db 11000000b, 00000000b, 00000000b, 00000011b
	db 11110000b, 00000000b, 00000000b, 00001111b

start:
	call screen_init
	
	push ds
	push es
		mov bh, 24		; x pos
		mov bl, 48		; y pos
		call get_screen_pos
		
		mov ch, 4		; width
		mov cl, 16		; height
		
		mov ax, @code
		mov ds, ax
		mov si, offset bitmap_test
draw_bitmap_y_again:	; ds:si = source bitmap
		push di
		push cx
draw_bitmap_x_again:
			movsb		; ds:si -> es:di
			dec ch
			jnz draw_bitmap_x_again
		pop cx
		pop di
		call get_screen_next_line
		inc bl
		dec cl
		jnz draw_bitmap_y_again
	pop es
	pop ds
	
	call program_end

get_screen_pos:
	push bx
	push ax
		mov ah, 0
		mov al, bh			; x_pos
		mov di, ax
		
		mov al, bl			; y_pos
		and al, 11111110b
		
		and bl, 00000001b
		jz get_screen_pos_oddline
		xor di, 2000h		; alternate lines at offset 2000h

get_screen_pos_oddline:
		mov bx, 80/2		; 80 bytes per 2 lines (y_pos * 40)
		mul bx				; as lines are interlaced
		add di, ax
		
		mov ax, 0b800h		; screen base
		mov es, ax
	pop ax
	pop bx
	ret
	
get_screen_next_line:
	push ax
		mov ax, di
		and ax, 2000h		; see if we're doing interlaced part
		mov ax, di
		jz get_screen_next_line_done
		add ax, 80			; 80 bytes per line (40 * 2)
get_screen_next_line_done:
		xor ax, 2000h		; alternate lines at offset 2000h
		mov di, ax
	pop ax
	ret
	
screen_init:
	mov ah, 0	; set video mode (AL = mode)
	mov al, 4	; mode 13 (CGA 320x200 4 color)
	int 10h		; bios interrupt
	
	mov ah, 0bh	; B = Renk Paleti
	mov bh, 1	; 1 = 4 palet modu
	mov bl, 0	; 0 = sıcak renkler (R,G,Y), 1 = soğuk renkler (C,M,W)
	int 10h
	
	mov ah, 0bh	; B = Renk Paleti
	mov bh, 0	; 0 = parlaklık
	mov bl, 10h	; yüksek yoğunluk, 0h = düşük yoğunluk
	int 10h
	ret

program_end:
	mov ah, 4Ch	; terminate
	mov al, 0	; return code
	int 21h		; dos interrupt
	
end start
