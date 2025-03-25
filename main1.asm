.model small
.stack 1024
.data
	msg db "Istedigim kadar yazabilirim o halde degil mi?", 255
.code
start:
	mov ax, @data		; data segment işi
	mov ds, ax
	mov ax, @code		; code segment işi
	mov es, ax
	
	mov si, offset msg	; mesajın adresi
	call printstr
	call new_line
	
	mov ah, 4Ch		; terminate
	mov al, 0		; return code
	int 21h

printchar:
	push dx			; fonksiyon başında ve sonunda değişmeden kullanalım diye
	push ax			; stack'e yolluyoruz ve fonksiyon içinde değiştirebiliyoruz
		mov ah, 02h	; output char servisi
		mov dl, al	; al'deki karakteri yaz
		int 21h		; dos interrupt
	pop ax			; stack'e yollama sıramıza göre geri çekmemiz önemli
	pop dx			; yoksa değerler karışır
	ret
printstr:
	mov al, ds:[si]		; data segmentten, atadığımız si'yi yani msg'nin adresindeki ilk karakteri yüklüyoruz
				; masm ile [ds:si], tasm ile ds:[si]
	cmp al, 255		; "sona geldik mi?" kontrolü (yazdığın str'nin sonuna o sayıyı koyman lazım)
	jz print_done		; başka karakter yoksa geri dön
	call printchar		; karakteri yazdır
	inc si			; sonraki karakter
	jmp printstr		; tekrar et bitene kadar
print_done:
	ret
new_line:
	push dx
	push ax
		mov ah, 02h
		mov dl, 13
		int 21h
		mov dl, 10
		int 21h
	pop ax
	pop dx
	ret
end start
