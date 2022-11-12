; 触发实验1的7ch中断例程
assume cs:code

data segment
    db "Welcome to masm! ", 0
data ends

code segment
 start:
    mov dh, 10      ; 设置行号
    mov dl, 10      ; 设置列号
    mov cl, 2       ; 设置颜色

    mov ax, data
    mov ds, ax
    mov si, 0

    int 7ch         ; 触发中断

    mov ax, 4c00h
    int 21h
code ends
end start