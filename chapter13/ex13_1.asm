; 编写int 7ch中断例程和安装程序，功能为显示一个用0结束的字符串，中断例程安装在0:200处
assume cs:code

code segment
 start:
    mov ax, 0
    mov es, ax
    mov di, 200h        ; es:di指向中断例程的目的地址0:200h

    mov ax, cs
    mov ds, ax
    mov si, offset showStr     ; ds:si指向中断例程所在的内存单元

    mov cx, offset showEnd - offset showStr ; cx记录安装程序的传输长度

    cld                 ; 设置传输方向为正
    rep movsb           ; 开始串传送

    ; 设置中断向量表
    mov word ptr es:[7ch*4], 200h   ; 低地址存放偏移地址
    mov word ptr es:[7ch*4+2], 0    ; 高地址存放段地址

    mov ax, 4c00h
    int 21h

; 中断例程
; 名称：显示以0结尾的字符串
; 功能：在指定位置，用指定的颜色，显示一个用0结束的字符串
; 参数：(dh) = 行号 (0 ~ 24)
; 	    (dl) = 列号 (0 ~ 79)
; 	    (cl) = 颜色
;	    ds:si指向字符串的首地址
; 返回：无
 showStr:
	push dx
	push cx
	push ax
	push si
	push es
	push bx

    ; 设置显示缓冲区
    mov ax, 0B800h
    mov es, ax

    ;通过dh，dl计算显示首地址
    mov al, dh      ; mul 8位乘法被乘数一个默认在al中，另一个为8位reg或内存单元
    mov ch, 160
    mul ch
    mov bx, ax      ; 保存乘法结果

    mov al, dl
    mov ch, 2
    mul ch
    add bx, ax      ; bx保存要显示的字符串在显存对应位置的首地址

    mov dl, cl      ; dl暂存颜色
change:
    mov ah, dl      ; ah保存当前字符需要显示的颜色
    mov cl, ds:[si]
    mov ch, 0
    jcxz ok         ; 判断当前字符是否为0
    mov al, cl      ; al保存当前字符的ASCII码
    mov es:[bx], ax ; 复制当前字符及其颜色信息到显存
    add bx, 2
    inc si
    jmp short change

 ok:
	pop bx
	pop es
	pop si
	pop ax
	pop cx
	pop dx
    iret            ; 程序返回断点继续执行
 showEnd:
    nop
code ends
end start