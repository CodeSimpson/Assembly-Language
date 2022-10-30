assume cs:code

data segment
 dw 1, 2, 3, 4
data ends

code segment
 start:	mov ax, data
		mov ds, ax
		mov bx, 0
		jmp word ptr [bx+1]
		
		mov ax, 4c00h
		int 21h
code ends
end start

