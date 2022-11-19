; 安装一个新的int 9中断例程，在DOS下，按下‘A’键后，除非不在松开，如果松开，就显示满屏的‘A’，其他键照常处理
assume cs:code

stack segment
    db 128 dup (0)
stack ends

code segment
 start:
    mov ax, stack   ; ss:[sp]指向栈顶
    mov ss, ax
    mov sp, 128

    push cs                 ; ds:[si]指向新的中断例程所在内存单元
    pop ds
    mov si, offset int9

    mov ax, 0
    mov es, ax
    mov di, 204h            ; es:[di]指向目的地址0:204h

    mov cx, offset int9end - offset int9
    cld                     ; 每次操作后si和di递增
    rep movsb               ; 开始串传送

    ; 保存原来int 9中断例程的入口地址
    push es:[9*4]
    pop es:[200h]
    push es:[9*4+2]
    pop es:[202h]

    ; 给中断向量表中的int 9赋值新的中断入口地址
    cli
    mov word ptr es:[9*4], 204h
    mov word ptr es:[9*4+2], 0
    sti

    mov ax, 4c00h
    int 21h

 int9:
    push ax
    push bx
    push cx
    push es

    in al, 60h

    pushf
    call dword ptr cs:[200h]

    cmp al, 9Eh     ; A断码：1Eh + 80h
    jne int9ret

    mov ax, 0b800h
    mov es, ax
    mov bx, 0
    mov ah, 'A'
    mov cx, 2000
 s:
    mov es:[bx], ah
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