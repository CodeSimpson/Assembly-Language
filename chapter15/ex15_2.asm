; 在屏幕中间依次显示"a"~"z"，并可以让人看清，在显示的过程中，按下Esc键后，改变显示的颜色
assume cs:code

stack segment
    db 128 dup (0)
stack ends

data segment
    dw 0 , 0            ; 保存BIOS的int 9中断例程入口地址
data ends

code segment
 start:
    mov ax, stack
    mov ss, ax
    mov sp, 128             ; ss:[sp]指向栈顶

    mov ax, data            ; 段寄存器指向data数据段
    mov ds, ax

    mov ax, 0               ; es段寄存器指向中断向量表段地址
    mov es, ax

    mov ax, es:[9*4]
    mov ds:[0], ax          ; ds:[0]存放int 9中断例程的偏移地址
    mov ax, es:[9*4+2]
    mov ds:[2], ax          ; ds:[2]存放int 9中断例程的段地址

    ; push es:[9*4]         ; 另一种写法
    ; pop ds:[0]
    ; push es:[9*4+2]
    ; pop ds:[2]

    cli                     ; 设置IF = 0，不响应可屏蔽中断
    mov word ptr es:[9*4], offset int9
    mov word ptr es:[9*4+2], cs     ; 代码段寄存器cs直接复制内存单元
    sti                     ; 设置IF = 1，响应可屏蔽中断

    mov ax, 0b800h
    mov es, ax
    mov ah, 'a'
 s:
    mov es:[160*12+40*2], ah
    call delay              ; CPU空循环延时
    inc ah
    cmp ah, 'z'             ; 比较al是否加到字符‘z’
    jne s                   ; 不等于则转移

    mov ax, 0
    mov es, ax

    mov ax, ds:[0]          ; 还原BIOS int 9中断例程的入口地址
    mov es:[9*4], ax
    mov ax, ds:[2]
    mov es:[9*4+2], ax

    ; push ds:[0]
    ; pop es:[9*4]
    ; push ds:[2]
    ; pop es:[9*4+2]

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

; 名称：int9
; 功能：实现在显示的过程中，按下Esc键后，改变显示的颜色，内部调用BIOS的int 9中断例程
; 参数：ds:[0]保存BIOS int 9中断例程的偏移地址
;       ds:[2]保存BIOS int 9中断例程的段地址
; 返回：无
 int9:
    push ax
    push bx
    push es

    in al, 60h          ; 读出60h端口的扫描码
    ; 调用bios中的int 9中断
    pushf               ; 标志寄存器入栈

    pushf               ; IF = 0, TF = 0，进入BIOS的int 9中断例程后会自动设置，这段可以省略
    pop bx
    and bh, 11111100b
    push bx
    popf                

    call dword ptr ds:[0]   ; 对int指令进行模拟，调用原来的int 9中断例程

    cmp al, 1           ; esc键的扫描码
    jne int9ret         ; 不等于则转移

    mov ax, 0b800h
    mov es, ax
    inc byte ptr es:[160*12+40*2+1]     ; 将颜色属性+1

 int9ret:
    pop es
    pop bx
    pop ax
    iret

code ends
end start