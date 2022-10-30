assume cs:code

data segment
 db 10 dup (0)
 ;db '12666', 0
data ends

stack segment
 db 20 dup (0)
stack ends

code segment
 start:	
	mov ax, 1266600
	mov bx, data	; 指向保存字符串的data内存
	mov ds, bx
	mov si, 0

	mov bx, stack	; ss:sp指向栈空间
	mov ss, bx
	mov sp, 20
	call dtoc

	mov dh, 8
	mov dl, 3
	mov cl, 2
	call show_str

	mov ax, 4c00h
	int 21h

; 名称：dtoc
; 功能：将word型数据转变为十进制数字符串，字符串以0为结尾符
; 参数: (ax) = word型数据
;       ds:si指向字符串的首地址
; 返回：无
 dtoc:	
	push si
	push bx
	push dx
	push cx
	push ax

	mov bx, 10
 lp:
	mov dx, 0	; 将16为除法高16位dx置零
	div bx		; 16位除法

	mov cx, ax	; 将商ax复制到cx中，判断商是否为0，最后一位被除数需要单独处理
	jcxz finish

	add dx, 30H	; 余数dx转为字符串
	push dx		; 先存入栈，后取出，保证
	add si, 1	; 记录栈的长度
	
	jmp short lp

 finish:	
	add dx, 30H
	push dx
	add si, 1

	; 将栈中的字符串正序保存于data中
	mov cx, si
	mov si, 0	
 s:
	pop ds:[si]
	inc si
	loop s

	pop ax
	pop cx
	pop dx
	pop bx
	pop si
	ret

; 名称：显示字符串
; 功能：在指定位置，用指定的颜色，显示一个用0结束的字符串
; 参数：(dh) = 行号 (0 ~ 24)
; 	    (dl) = 列号 (0 ~ 79)
; 	    (cl) = 颜色
;	    ds:si指向字符串的首地址
; 返回：无
 show_str:	
	push dx
	push cx
	push ax
	push si
	
	; 设置显示缓冲区
	mov ax, 0B800h
	mov es, ax
	
	; 通过dh，dl计算显示首地址
	mov al, dh
	mov ch, 160
	mul ch
	mov bx, ax	; 保存乘法结果
	
	mov al, dl
	mov ch, 2
	mul ch
	add bx, ax	; bx保存第dh行 dl列的首地址
	
	mov dl, cl
 change:	
	mov ah, dl	; 颜色
	mov cl, ds:[si]
	mov ch, 0
	jcxz ok		; 判断字符串是否为0
	mov al, cl
	mov es:[bx], ax
	add bx, 2
	inc si
	jmp short change

 ok:	
	pop si
	pop ax
	pop cx
	pop dx
	ret
code ends
end start