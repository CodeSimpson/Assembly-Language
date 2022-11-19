; 安装一个新的int 7ch中断例程，为显示输出提供如下功能子程序：
; (1) 清屏
; (2) 设置前景色
; (3) 设置背景色
; (4) 向上滚动一行
; 入口参数： ah传递功能号，0表示清屏，1表示设置前景色，2表示设置背景色，3表示向上滚动一行
;           对于1、2号功能，用al传递颜色值，(al) = {0,1,2,3,4,5,6,7}
assume cs:code

code segment
 start:
    mov ax, 0
    mov es, ax
    mov di, 200h        ; 设置传传送指令的目的地址0:[200h]

    mov ax, cs
    mov ds, ax
    mov si, offset int7 ; 设置串传送指令的源地址

    cld                 ; 正向传送
    mov cx, offset int7end - offset int7

    rep movsb

    mov word ptr es:[7ch*4], 200H       ;
    mov word ptr es:[7ch*4+2], cx      ; 设置中断向量表的入口地址

    mov ah, 0
    int 7ch              ; 触发中断

    mov ax, 4c00h
    int 21h


; ==================中断例程===================
 int7:
    jmp short set                           ; 占2个字节
    ; 注意这里需要手动计算子程序偏移地址！！！！！！！！
    stable dw 200h + offset sub1 - offset int7
           dw 200h + offset sub2 - offset int7
           dw 200h + offset sub3 - offset int7
           dw 200h + offset sub4 - offset int7      ; 通过直接定址表表示中断子程序的入口偏移地址，每个数据项占2个字节
 set:
    push ax
    push bx

    cmp ah, 3                              ; ah功能号是否大于3
    jnb int7ret
    mov bl, ah
    mov bh, 0
    add bx, bx
    call word ptr cs:[bx+202h]             ; 转跳子程序，这里不能用stable[bx]的形式代表偏移地址，
                                           ; 因为stable数据标号在编译的时候会被编译为一个固定值，在中断例程中不再适用
 int7ret:
    pop bx
    pop ax
    iret

 sub1:
    push ax
    push es

    mov ax, 0b800h
    mov es, ax
    mov al, '1'
    mov ah, 2
    mov es:[160*12+40*2], ax
    
    pop es
    pop ax
    ret                                     ; 这里不能简单通过jmp short int7ret返回中断例程，因为call指令调用后，执行了push ip操作，
                                            ; 而int指令之前也执行了push CS和IP操作，此时直接调用iret，此时占顶存在两个不同的IP值，执行iret后得到的CS和IP是错误的

 sub2:
    push ax
    push es

    mov ax, 0b800h
    mov es, ax
    mov al, '2'
    mov ah, 2
    mov es:[160*12+40*2], ax
    
    pop es
    pop ax
    ret

 sub3:
    push ax
    push es

    mov ax, 0b800h
    mov es, ax
    mov al, '3'
    mov ah, 2
    mov es:[160*12+40*2], ax
    
    pop es
    pop ax
    ret

 sub4:
    push ax
    push es

    mov ax, 0b800h
    mov es, ax
    mov al, '4'
    mov ah, 2
    mov es:[160*12+40*2], ax
    
    pop es
    pop ax
    ret

 int7end:
    nop
code ends
end start