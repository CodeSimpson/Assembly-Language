; 将datasg段中每个单词改为大写字母
assume cs:codesg, ds:datasg

datasg segment
 db 'ibm             '
 db 'dec             '
 db 'dos             '
 db 'vax             '
datasg ends

codesg segment
 start:
	mov ax, datasg
	mov ds, ax
	mov bx, 0
	mov si, 0
	
	mov cx, 4
 s0:
	mov di, cx			; 利用di保存cx的值
	mov si, 0

	mov cx, 3
 s1:
	mov al, [bx+si]		; bx，si作为变量，bx代表每一行字符串的起始地址，si代表每一列字符的地址
	and al, 11011111B
	mov [bx+si], al
	inc si
	loop s1

	add bx, 16
	mov cx, di
	loop s0

	mov ax, 4c00h
	int 21h
codesg ends
end start