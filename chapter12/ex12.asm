assume cs:code

code segment
start:
    ; do0按照程序
    mov ax, 0
    mov es, ax
    mov di, 200h            ; es:[di]设置为传送的目的地址0:200h

    mov ax, cs              ; cs为当前程序开始执行时的段地址
    mov ds, ax
    mov si, offset do0

    mov cx, offset do0end - offset do0
    cld
    rep movsb

    ; 设置中断向量表
    mov ax, 0
    mov ds, ax
    mov word ptr ds:[0*4], 200h
    mov word ptr ds:[0*4+2], 0h 

    ; 尝试触发0号中断
    mov ax, 1000h
    mov bh, 1
    div bh

    mov ax, 4c00h
    int 21h

 do0:
    jmp short do0start  ; 占两个字节
    db "divide error!"
 do0start:
    mov ax, 0b800h          ; 显存段地址
    mov es, ax
    mov si, 12*160 + 36*2   ; 显存偏移地址，在屏幕中间打印

    mov ax, 0               ; 中断处理程序被加载到0:200h后的段地址
    mov ds, ax
    mov di, 202h            ; 中断处理程序被加载到0:200h后字符串所在内存单元的偏移地址

    mov cx, 13
 s:
    mov al, ds:[di]
    mov ah, 2h
    mov es:[si], ax
    inc di
    add si, 2
    loop s

    mov ax, 4c00h           ; 直接返回dos系统
    int 21h
 do0end:                    ; 安装程序有用
    nop

code ends
end start