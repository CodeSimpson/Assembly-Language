assume cs:codesg

stacksg segment
	dw 8 dup (0)
stacksg ends

codesg segment
 start:	mov ax, stacksg
		mov ss, ax
		mov sp, 16
		mov ds, ax
		mov ax, 0
		call word ptr ds:[0EH]
		inc ax
		inc ax
		inc ax
		
		mov ax, 4c00h
		int 21h

codesg ends
end start
