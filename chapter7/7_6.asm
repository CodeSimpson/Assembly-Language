; 将datasg中定义的第一个字符串转化为大写，第二个字符串转化为小写
assume cs:codesg, ds:datasg

datasg segment
 db 'BasiC'
 db	'MinIX'
datasg ends

codesg segment
 start:
	mov ax, datasg
	mov ds, ax
	mov bx, 0
	mov cx, 5
 s0:
	mov al, [bx]
	and al, 11011111B
	mov [bx], al
	
	mov al,[bx+5]		; [bx+idata]的内存定位方式
	or 	al, 00100000B
	mov [bx+5], al
	inc bx
	loop s0
	
	mov ax, 4c00h
	int 21h
codesg ends
end start