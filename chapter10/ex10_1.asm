; 编写一个通用的子程序来实现显示字符串的功能
assume cs:code

data segment
 db 'Welcome to masm!', 0
data ends

stack segment
 db 10 dup (0)
stack ends

code segment
start:	mov dh, 8
		mov dl, 3
		mov cl, 2
		mov ax, data
		mov ds, ax
		mov si, 0
		call show_str
		
		mov ax, 4c00h
		int 21h
; 名称：显示字符串
; 功能：在指定位置，用指定的颜色，显示一个用0结束的字符串
; 参数：(dh) = 行号 (0 ~ 24)
; 	    (dl) = 列号 (0 ~ 79)
; 	    (cl) = 颜色
;	    ds:si指向字符串的首地址
; 返回：无
show_str:	push dx
			push cx
			push ax
			push si
			
			; 设置显示缓冲区
			mov ax, 0B800h
			mov es, ax
			
			; 通过dh，dl计算显示首地址
			mov al, dh
			mov ch, 160	; 每行80个字符，一个字符占两个字节
			mul ch		; 8位乘法，结果保存于ax中
			mov bx, ax	; 保存乘法结果
			
			mov al, dl
			mov ch, 2
			mul ch
			add bx, ax	; bx保存第dh行 dl列的首地址
			
			mov dl, cl  ; 在dl中暂存颜色，因为cl后续会被覆盖
	change:	mov ah, dl	; ah保存当前字符需要显示的颜色
			mov cl, ds:[si]
			mov ch, 0
			jcxz ok		; 判断字符串是否为0
			mov al, cl	; al保存当前字符的ASCII码
			mov es:[bx], ax
			add bx, 2
			inc si
			jmp short change

		ok:	pop si
			pop ax
			pop cx
			pop dx
			ret			; 返回call指令的下一条指令处继续执行

code ends
end start