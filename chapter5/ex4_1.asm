; 向内存0:200 ~ 0:23F依次传送数据0 ~ 63(3FH)

assume cs:code

code segment

	mov ax, 0020h
	mov ds, ax
	mov bx, 0

	mov cx, 40h
s:  
	mov ds:[bx], bl
	inc bx
	loop s
	
	mov ax, 4c00h
	int 21h

code ends

end