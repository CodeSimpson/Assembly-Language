; 安装一个新的int 9中断例程，在DOS下，按F1键后改变当前屏幕的颜色，其他的键照常处理
assume cs:code

stack segment
    db 128 dup (0)
stack ends

code segment
 start:
    mov ax, stack
    mov ss, ax
    mov sp, 128

    ; 采用串传送指令
    push cs
    pop ds
    mov si, offset int9

    mov ax, 0
    mov es, ax
    mov di, 204h    ; 200h~203h四个字节保存原BIOS int 9的段地址和偏移地址

    mov cx, offset int9end - offset int9
    cld
    rep movsb

    ; 保存原BIOS int9的段地址和偏移地址
    push es:[9*4]
    pop es:[200h]
    push es:[9*4+2]
    pop es:[202h]

   ; 更新中断向量表
    cli
    mov word ptr es:[9*4], 204h
    mov word ptr es:[9*4+2], 0
    sti

    mov ax, 4c00h
    int 21h

;------------------以下为新的int 9中断例程--------------------

 int9:
    push ax
    push bx
    push cx
    push es

    ; 读取60h端口的键盘扫描码
    in al, 60h

    pushf
    call dword ptr cs:[200h]     ; 执行此中断时，(cs) = 0

    cmp al, 3bh                 ; F1扫描码为3bh
    jne int9ret                 ; 不等于则跳转

    mov ax, 0b800h
    mov es, ax
    mov bx, 1
    mov cx, 2000
 s:
    inc byte ptr es:[bx]
    add bx, 2
    loop s
 int9ret:
    pop es
    pop cx
    pop bx
    pop ax
    iret    

 int9end:
    nop
code ends
end start