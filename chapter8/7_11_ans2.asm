; 将data段中的数据按如下格式写入table段中，并计算21年中人均收入，也存入table段中
assume cs:codesg

data segment
	db '1975','1976','1977','1978','1979','1980','1981','1982','1983'			; 单项四个字节
	db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
	db '1993','1994','1995'

	dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514			; 单项四个字节
	dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000

	dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226		; 单项两个字节
	dw 11542,14430,15257,17800
data ends

table segment
	db 21 dup ('year summ ne ?? ')
table ends

stack segment
	dw 10 dup (0)
stack ends

codesg segment
 start:
	mov ax, data
	mov ds, ax
	mov di, 0
	mov ax, table
	mov es, ax
	mov si, 0
	mov ax, stack
	mov ss, ax
	mov sp, 20

	mov bx, 0
; 先复制年份和收入，两者都占4个字节
	mov cx, 2
 s0:
	mov si, 0
	push cx
	mov cx, 21
 s1:
	push cx
	mov cx, 4
 s2:
	mov al, ds:[di]	; ds:[di]指向data内存单元
	mov es:[si+bx], al
	inc di
	inc si
	loop s2
	
	add si, 12		; 更新si，使之指向table的下一行
	pop cx
	loop s1

	mov bx, 5		; 更新bx，使之指向table的收入内存单元
	pop cx
	loop s0

; 复制雇员数，单项占两个字节，此时di指向第一个雇员数据单元
	mov cx, 21
	mov si, 0		; 指向table的每一行
	mov bx, 10		; 控制指向table的雇员数列
 s3:
	push cx
	
	mov cx, 2
 s4:
	mov al, ds:[di]
	mov es:[si+bx], al
	inc di
	inc si
	loop s4
	
	add si, 14		; 更新si，使之指向table下一行的首地址内存单元
	pop cx
	loop s3

; 计算雇员的平均工资
	mov di, 0
	mov si, 0
	mov bx, 0
	
	mov cx, 21
 s5:
	mov ax, es:[si+5]		; 取被除数的低16位
	mov dx, es:[si+7]		; 取被除数的高16位
	div word ptr es:[si+10]
	mov es:[si+13], ax			; 取商
	add si, 16
	loop s5
	
	mov ax, 4c00h
	int 21h
codesg ends
end start