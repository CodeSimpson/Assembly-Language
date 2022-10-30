; 将datasg段中每个单词的前4个字母改为大写字母
assume cs:codesg, ds:datasg, ss:stacksg

datasg segment
 db '1. display      '
 db '2. brows        '
 db '3. replace      '
 db '4. modify       '
datasg ends

stacksg segment
 dw 0, 0, 0, 0, 0, 0, 0, 0
stacksg ends

codesg segment
 start:
	mov ax, stacksg
	mov ss, ax
	mov sp, 16

	mov ax, datasg
	mov ds, ax
	mov bx, 0
	mov si, 0
		
	mov cx, 4
 s0:
	mov si, 0
	push cx
		
	mov cx, 4
 s1:
	mov al, [bx+si+3]		; [bx+si+idata]定位内存地址
	and al, 11011111B
	mov [bx+si+3], al
	inc si
	loop s1

	add bx, 16
	pop cx
	loop s0
	
	mov ax, 4c00h
	int 21h	
codesg ends

end start
