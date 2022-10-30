; 将datasg段中每个单词改为大写字母
assume cs:codesg, ds:datasg

datasg segment
 db 'ibm             '
 db 'dec             '
 db 'dos             '
 db 'vax             '
 dw 0
datasg ends

codesg segment
 start:
	mov ax, datasg
	mov ds, ax
	mov bx, 0
	mov si, 0

	mov cx, 4
 s0:
	mov ds:[40H], cx		; 利用内存保存cx的值，优于利用寄存器保存。
	mov si, 0

	mov cx, 3
 s1:
	mov al, [bx+si]
	and al, 11011111B
	mov [bx+si], al
	inc si
	loop s1

	add bx, 16
	mov cx, ds:[40H]
	loop s0

	mov ax, 4c00h
	int 21h
codesg ends
end start