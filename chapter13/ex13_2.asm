; 编写int 7ch中断例程和安装程序，功能为完成loop指令的功能
assume cs:code

code segment
 start:
    mov ax, 0
    mov es, ax
    mov di, 200h

    mov ax, cs
    mov ds, ax
    mov si, offset lp

    mov cx, offset lpend - offset lp
    cld
    rep movsb

    ; 设置中断向量表
    mov word ptr es:[7ch*4], 200h
    mov word ptr es:[7ch*4+2], 0

    mov ax, 4c00h
    int 21h

; 中断例程
; 名称：循环
; 功能：通过位移和次数指令循环指令loop的功能
; 参数：(cx) = 循环次数
; 	    (bx) = 位移
; 返回：无
 lp:
    push bp             ; 保存当前bp寄存器的值到栈中，此前栈中保存了标志寄存器，
                        ; 触发中断的原程序段地址以及触发中断指令的下一条指令的偏移地址
    mov bp, sp          ; 将栈顶指针地址复制到bp中，此时bp指向栈顶【栈顶首元素为原bp的值】
    dec cx              ; cx减1
    jcxz lpret          ; cx == 0，直接返回
    add ss:[bp+2], bx   ; 栈中的偏移地址加上转移位移
 lpret:
    pop bp              ; 还原bp中的值
    iret                ; 分别弹出IP，CS和标志寄存器的值
 lpend:
    nop
code ends
end start

