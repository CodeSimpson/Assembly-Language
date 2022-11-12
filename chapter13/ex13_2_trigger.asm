; 在屏幕中打印80个'!'
assume cs:code

code segment
 start:
    mov ax, 0B800h
    mov es, ax
    mov di, 160*12                      ; 显示显示地址
    mov bx, offset s - offset se        ; 位移，预期为负数
    mov cx, 80                          ; 循环次数
 s:
    mov byte ptr es:[di], '!'           ; 将字符复制到显存所对应的内存单元中，字符颜色为默认值
    add di, 2
    int 7ch
 se:
    nop

    mov ax, 4c00h
    int 21h

code ends
end start