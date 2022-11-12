; 通过子程序将包含任意字符，以0结尾的字符串中的小写字母转变为大写字母
assume cs:codesg

datasg segment
    db "Beginner's All-purpose Symbolic Instruction Code.", 0
datasg ends

codesg segment
 begin:
    mov ax, datasg
    mov ds, ax
    mov si, 0
    call letterc

    mov ax, 4c00h
    int 21h

; 名称： letterc
; 功能：将以0结尾的字符串中的小写字母转变为大写字母
; 参数：ds:si指向字符串首地址
 letterc:
    push cx
    push ax
 s:
    mov cl, ds:[si]
    mov ch, 0
    jcxz ok                      ; 判断当前字符是否为0

    cmp byte ptr ds:[si], 97     ; 小写字母的acsii码范围：a~z: 97~122
    jb  next                     ; 低于97则判断下一个字符
    cmp byte ptr ds:[si], 122
    ja next                      ; 大于122则判断下一个字符

    mov al, ds:[si]              ; 将小写字母转换为大写字母
    sub al, 32	                ; 将小写字母的acsii码减32即可转为大写字母，还有一种与操作，将字符转化为大写，自动过滤大写字母
    mov ds:[si], al
 next:
    inc si
    jmp short s

 ok:
    pop ax
    pop cx
    ret
codesg ends
end begin