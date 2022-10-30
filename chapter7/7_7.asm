; 用si和di实现字符串'Welcome to masm!'复制到它后面的数据区
assume cs:codesg, ds:datasg

datasg segment
 db 'Welcome to masm!'
 db '................'
datasg ends

codesg segment
 start:	
	mov ax, datasg
	mov ds, ax
	mov si, 0
	mov di, 16
	
	mov cx, 8
 s0: 
	mov ax, [si]
	mov [di], ax
	add si, 2
	add di, 2
	loop s0

	mov ax, 4c00h
	int 21h
codesg ends
end start