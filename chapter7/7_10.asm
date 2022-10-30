; 将datasg段中每个单词的头一个字母改为大写字母
assume cs:codesg, ds:datasg

datasg segment
 db '1. file         '
 db '2. edit         '
 db '3. search       '
 db '4. view         '
 db '5. options      '
 db '6. help         '
datasg ends

codesg segment
 start:
	mov ax, datasg
	mov ds, ax
	mov bx, 0
	
	mov cx, 6
 s0:
	mov al, [bx+3]		; bx作为变量，定位每行的起始位置
	and al, 11011111B
	mov [bx+3], al
	add bx, 16
	loop s0
	
	mov ax, 4c00h
	int 21h
codesg ends
end start