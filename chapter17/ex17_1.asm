; 接受用户的键盘输入，输入“r”，将屏幕上的字符设置为红色，输入“g”，
; 将屏幕上的字符设置为绿色，输入“b”，将屏幕上的字符设置为蓝色
assume cs:codesg

codesg segment
 start:
    mov ah, 0       ; 选择int 16h中断的功能0
    int 16h         ; 输入扫描码保存于ah，ASCII码保存于al

    mov ah, 1       ; R G B 设置颜色码为B
    cmp al, 'r'
    je red
    cmp al, 'g'
    je green
    cmp al, 'b'
    je blue

    jmp short sret

 red:
    shl ah, 1
 green:
    shl ah, 1
 blue:
    mov bx, 0b800h      ; 这里不能再用ax
    mov es, bx

    mov bx, 1
    mov cx, 2000
 lp:
    and byte ptr es:[bx], 11111000b
    or es:[bx], ah
    add bx, 2
    loop lp
 sret:
    mov ax, 4c00h
    int 21h

codesg ends
end start