; debug查看字符串对应的ASCII码
assume cs:code,ds:data

data segment
	db 'unIX'	; 相当于 db 75H, 6EH, 49H, 58H
    db 'foRK'	;        db 66H, 6FH, 52H, 4BH
data ends

code segment
start:	mov al, 'a'		; 相当于 mov al, 61H
		mov bl, 'b'		; 相当于 mov al, 62H
		mov ax, 4c00h
		int 21h
code ends

end start