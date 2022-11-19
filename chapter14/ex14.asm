; 以“年/月/日 时:分:秒的格式，显示当前的日期、时间”
assume cs:code
timeStr segment
    db 'XX/XX/XX XX:XX:XX', '0'
timeStr ends

locs segment
    db 9, 8, 7, 4, 2, 0
locs ends

code segment
 start:
    mov ax, timeStr
    mov ds, ax
    mov si, 0           ; ds:[si]指向要显示的字符串内存单元

    mov ax, locs
    mov es, ax
    mov di, 0

    mov cx, 6
 s:
    push cx

    mov al, es:[di]     ; 读取coms ram中的信息所在的单元
    out 70h, al
    in al, 71h          ; 从9号单元读取信息的BCD码

    mov ah, al
    mov cl, 4
    shr ah, cl
    and al, 00001111b   ; ah保存十位，al保存个位

    add ah, 30h         ; 将BCD码转为ASCII码
    add al, 30h

    mov ds:[si], ah     ; 复制到对应的字符串内存单元
    mov ds:[si+1], al

    add si, 3
    inc di

    pop cx
    loop s

    mov dh, 12
    mov dl, 30
    mov cl, 2
    mov si, 0           ; ds:[si]指向字符串首地址
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
show_str:
	push dx
	push cx
	push ax
	push si
	push es
	push bx
	
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
 change:	
	mov ah, dl	; ah保存当前字符需要显示的颜色
	mov cl, ds:[si]
	mov ch, 0
	jcxz ok		; 判断字符串是否为0
	mov al, cl	; al保存当前字符的ASCII码
	mov es:[bx], ax
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
	ret			; 返回call指令的下一条指令处继续执行

code ends
end start