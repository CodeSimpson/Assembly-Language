; 将datasg中的第一个字符串转化为大写，第二个字符串转化为小写
assume cs:codesg,ds:datasg

datasg segment
 db 'Basic'
 db 'iNfOrMaTiOn'
datasg ends

codesg segment
 start:	
	mov ax, datasg
	mov ds, ax
	mov bx, 0
	mov cx, 5
 s0:
	mov al, [bx]
	and al, 11011111B		; 与操作，将字符转化为大写
	mov [bx], al
	inc bx
	loop s0
	
	mov cx, 11
 s1:
	mov al, [bx]
	or al, 00100000B		; 或操作，将字符转化为小写
	mov [bx], al
	inc bx
	loop s1
		
	mov ax, 4c00h
	int 21h
codesg ends

end start