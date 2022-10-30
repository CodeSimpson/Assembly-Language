; 将datasg段中每个单词改为大写字母
assume cs:codesg, ds:datasg, ss:stacksg

datasg segment
 db 'ibm             '
 db 'dec             '
 db 'dos             '
 db 'vax             '
datasg ends

stacksg segment
 dw 0, 0, 0, 0, 0, 0, 0, 0
stacksg ends

codesg segment
 start:
	mov ax, stacksg			; SS:SP指向栈底
	mov ss, ax
	mov sp, 16
	mov ax, datasg
	mov ds, ax
	mov bx, 0
	mov si, 0

	mov cx, 4
 s0:
	push cx					; 利用栈保存cx的值
	mov si, 0

	mov cx, 3
 s1:
	mov al, [bx+si]
	and al, 11011111B
	mov [bx+si], al
	inc si
	loop s1

	add bx, 16
	pop cx
	loop s0

	mov ax, 4c00h
	int 21h
codesg ends
end start