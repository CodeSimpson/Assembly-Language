; 在屏幕中间依次显示"a"~"z"，并可以让人看清
assume cs:code

stack segment
    db 128 dup (0)
stack ends

code segment
 start:
    mov ax, stack
    mov ss, ax
    mov sp, 128         ; ss:[sp]指向栈顶

    mov ax, 0b800h
    mov es, ax
    mov al, 'a'
    mov ah, 2           ; 颜色
 s:
    mov es:[160*12+40*2], ax
    call delay          ; CPU空循环延时
    inc al
    cmp al, 'z'         ; 比较al是否加到字符‘z’
    jne s               ; 不等于则转移

    mov ax, 4c00h
    int 21h

; 名称：delay
; 功能：CPU执行一段空循环达到延时一段时间的作用
; 参数：(ax) = dword型数据的低16位
;       (dx) = dword型数据的高16位
; 返回：无
 delay:
    push ax
    push dx

    mov dx, 10h
    mov ax, 0
 lp:
    sub ax, 1
    sbb dx, 0
    cmp ax, 0
    jne lp
    cmp dx, 0
    jne lp

    pop dx
    pop ax
    ret

code ends

end start