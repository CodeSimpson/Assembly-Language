; 在屏幕的第2、4、6、8行显示4句英文诗句
assume cs:code
code segment
 s1:    db 'Good,better,best', '$'
 s2:    db 'Never let it reset', '$'
 s3:    db 'Till good is better', '$'
 s4:    db 'And better, best.', '$'
 s:     dw offset s1, offset s2, offset s3, offset s4
 row:   db 2, 4, 6, 8

 start:
    mov ax, cs
    mov ds, ax
    mov bx, offset s        ; ds:[bx]为英文诗句内存单元的偏移地址
    mov si, offset row      ; ds:[si]对应的内存单元保存行数
    mov cx, 4
 ok:                        ; 设置光标位置
    mov bh, 0               ; 第0页
    mov dh, ds:[si]         ; 第dh行    
    mov dl, 0               ; 第0列
    mov ah, 2               ; 设置10h中断例程的2号子程序：置光标
    int 10h

    mov dx, ds:[bx]         ; ds:[dx]指向字符串
    mov ah, 9               ; 调用21h号中断例程的9号子程序
    int 21h
    inc si
    add bx, 2
    loop ok

    mov ax, 4c00h
    int 21h
code ends
end start