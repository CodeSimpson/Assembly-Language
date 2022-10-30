; 在屏幕中间分别显示绿色、绿底红色、白底蓝色的字符串 "welcome to masm!"。
assume cs:codesg, ds:datasg

datasg segment
 db 'welcome to masm!'
 db 2h, 24h, 71h	; 要求三个颜色对应的16进制代码
datasg ends

stacksg segment
 db 16 dup (0)
stacksg ends

codesg segment
		; 设置显示缓冲区
start:	mov ax, 0B800h
		mov ds, ax
		
		; 设置data段
		mov ax, datasg
		mov es, ax
		
		; 设置栈段
		mov ax, stacksg
		mov ss, ax
		mov sp, 10h		; 指向栈顶

		mov bx, 0722h	; 指向第一行首地址，ds:[bx]
		mov si, 10h		; 颜色的偏移量，es:[si]为颜色
	
		mov cx, 3
	s0: mov ah, es:[si]	; ax高8位保存颜色
		push si			; 保存颜色的偏移量
		push cx

		mov cx, 10h
		mov di, 0
		mov si, 0
	s1:	mov al, es:[di]
		mov [bx+si], ax	; [bx+si]保证bx始终指向当前行的首地址
		
		add si, 2
		inc di
		loop s1

		pop cx
		pop si
		inc si
		add bx, 0A0h	; 更新bx，使之指向显存下一行的首地址
		loop s0

		mov ax, 4c00h
		int 21h
codesg ends
end start