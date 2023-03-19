; 字符串输入
assume cs:code, ds:stacksg

stacksg segment
    dw 16 dup (0)
stacksg ends

code segment
 start:
    mov ax, stacksg
    mov ds, ax
    mov si, 0           ; ds:[si]指向栈空间

    mov dh, 10
    mov dl, 40

 getstrs:
    mov ah, 0
    int 16h
    cmp al, 20h
    jb nochar           ; ASCII码小于20h，说明不是字符
    mov ah, 0
    call charstack      ; 字符入栈
    mov ah, 2
    call charstack      ; 显示栈中的字符
    jmp getstrs

 nochar:
    cmp ah, 0eh         ; 退格键扫描码
    je backspace
    cmp ah, 1ch         ; Enter键扫描码
    je enter
    jmp getstrs

 backspace:
    mov ah, 1
    call charstack      ; 字符出栈
    mov ah, 2
    call charstack      ; 显示字符
    jmp getstrs

 enter:
    mov al, 0
    mov ah, 0
    call charstack      ; 0入栈
    mov ah, 2
    call charstack

    mov ax, 4c00h
    int 21h

; 子程序：字符串入栈，出栈和显示
; 参数说明：(ah)=功能号，0表示入栈，1表示出栈，2表示显示
;          ds:[si]指向字符栈空间
;          对于0号功能：(al) = 入栈字符
;          对于1号功能：(al) = 出栈字符
;          对于2号功能：(dh)、(dl) = 字符串在屏幕上显示的行、列位置
charstack:
    jmp short charstart

    table   dw charpush, charpop, charshow
    top     dw 0                            ; 栈顶，保存栈中的元素个数

 charstart:
    push bx
    push dx
    push di
    push es

    cmp ah, 2
    ja sret                                 ; 功能号高于2则转移
    mov bl, ah                              ; ah中保存功能号
    mov bh, 0
    add bx, bx
    jmp word ptr table[bx]                  ; 转移地址在内存中

 charpush:
    mov bx, top
    mov ds:[si][bx], al                     ; ds:[si][bx]等价于ds:[si+bx], 入栈
    inc top                                 ; top为所在的字内存单元
    jmp sret

 charpop:
    cmp top, 0
    je sret                                 ; 判栈空
    dec top
    mov bx, top
    mov al, ds:[si][bx]                     ; 出栈
    jmp sret

; 显示栈中的字符串
 charshow:
    mov bx, 0b800h
    mov es, bx
    mov al, 160
    mov ah, 0
    mul dh                                  ; dh中为要显示的行数
    mov di, ax                              ; 将乘法结果保存于di中
    add dl, dl                              ; dl中为要显示的列数，一个字符在显存中占两个字节
    mov dh, 0
    add di, dx                              ; di中为要显示的显示地址

    mov bx, 0
 charshows:
    cmp bx, top
    jne noempty                             ; 判断栈是否为空或栈是否显示结束
    mov byte ptr es:[di], ' '               ; 字符串最后显示空格
    jmp sret
 noempty:
    mov al, ds:[si][bx]
    mov es:[di], al
    mov byte ptr es:[di+2], ' '             ; 清除上一次的显存
    inc bx
    add di, 2
    jmp charshows

 sret:
    pop es
    pop di
    pop dx
    pop bx
    ret

code ends
end start