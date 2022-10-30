assume cs:codesg

data segment
	db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
	db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
	db '1993','1994','1995'

	dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
	dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000

	dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
	dw 11542,14430,15257,17800
data ends

table segment
	db 21 dup ('year', 0, 'summ ne ??', 0)
table ends

str segment
	db 8 dup (0)
str ends

stack segment
	db 40 dup (0)
stack ends

codesg segment
 start:	
	; 指向栈
	mov ax, stack
	mov ss, ax
	mov sp, 20

	; 指向data数据
	mov ax, data
	mov ds, ax

	; 指向table表格
	mov ax, table
	mov es, ax

	; 复制年和收入信息，都是4个字节，si指向data，di指向table每行的首地址
	mov si, 0		
	mov di, 0
	mov bx, 0
	mov cx, 2
 s0:
	mov di, 0
	push cx
	mov cx, 21
 s1:
	push cx
	mov cx, 4
 s2:
	mov al, ds:[si]
	mov es:[di+bx], al
	inc si
	inc di		; 注意这里修改的di，不能修改bx，因为bx指向每一行的固定项处，在此di被加1四次
	loop s2

	add di, 12	; di加12即可指向下一行
	pop cx
	loop s1

	mov bx, 5
	pop cx
	loop s0


	; 复制雇员信息，单项占2个字节
	mov di, 0
	mov bx, 10
	mov cx, 21
 s3: 
	mov ax, ds:[si]			; 此时si指向雇员人数信息
	mov es:[di+bx], ax
	add si, 2
	add di, 16
	loop s3

	; 计算平均收入
	mov si, 0
	mov di, 0
	mov cx, 21
 s4:	
	mov ax, es:[di+5]		; 复制收入信息
	mov dx, es:[di+7]
	div word ptr es:[di+0AH]
	mov es:[di+0DH], ax
	add di, 10H
	loop s4

	; 循环打印21行table内容
	mov cx, 21
	; 先打印输出year，已是字符串，无需转换
	mov dh, 3		; 第3行
	mov dl, 2		; 第2列

	mov ax, table	; ds:[si]指向要显示字符串的首地址
	mov ds, ax
	mov si, 0
 s5:
	push cx
	mov cl, 2		; cx寄存器被修改，故每次循环需要重新写入颜色
	call show_str

	add si, 16
	inc dh
	pop cx
	loop s5

	; 再循环打印summ，考虑到summ和人数、平均收入所占字节数不同，所以分开写成两个循环打印
	mov ax, table	; es:[bx+di]指向table中的summ项
	mov es, ax
	mov bx, 0		; 指向table每行起始内存地址
	mov di, 5		; 

	mov dh, 3		; 第3行
	mov dl, 12		; 第12列

	mov ax, str		; ds:[si]指向字符串转换后所保存的首地址
	mov ds, ax
	mov si, 0

	mov cx, 21
 s6:
	push cx
	; 先转换
	push dx			; 转换前保存dx！！！！，否则会影响后续show_str
	mov ax, es:[bx+di]
	mov dx, es:[bx+di+2]
	call dwtoc
	pop dx			; 转换后恢复dx，确定行数和列数

	; 再打印
	mov cl, 2
	mov si, 0
	call show_str

	add bx, 16
	inc dh			; 下一行
	pop cx
	loop s6

	; 继续循环打印雇员人数和平均工资	
	mov di, 10		; 指向雇员人数项

	mov dl, 24		; 第24列

	mov cx, 2
 s7:
	push cx

	mov dh, 3		; 循环开始，从第3行开始打印
	mov bx, 0		; 循环开始，bx指向table第一行的首地址
	mov si, 0
	mov cx, 21
 s8:
	push cx
	push dx
	mov ax, es:[bx+di]
	mov dx, 0
	call dwtoc
	pop dx
	
	mov cl, 2
	mov si, 0
	call show_str

	add bx, 16		; 指向table下一行
	inc dh
	pop cx
	loop s8

	add di, 3		 ; 指向平均工资项
	add dl, 10
	pop cx
	loop s7

	mov ax, 4c00h
	int 21h

; 名称：dwtoc
; 功能：将dword型数转变为表示十进制数的字符串，字符串以0为结尾符
; 参数：(ax) = dword型数据的低16位
;       (dx) = dword型数据的高16位
;       ds:[0]指向字符串的首地址
; 返回：无
dwtoc:
	push cx
	push bx

   	mov si, 0
 s:
	mov cx, 10      ; 将除数设为10
	mov bx, 0
	call divdw
	push cx         ; 保存余数结果

	add bx, dx
	add bx, ax
	mov cx, bx
	jcxz finish     ; 判断当前商是否为0

	pop cx
	add cx, 30H     ; 将数字转为ascii码
	push cx         ; 保存于栈中
	inc si          ; 统计栈长度
	jmp short s

 finish:
	pop cx
	add cx, 30H
	push cx
	inc si

	mov cx, si
	mov si, 0
 ps:
	pop ds:[si]     ; 记得是以字为单位操作的？？？？
	inc si
	loop ps

	pop bx
	pop cx
	ret             ; 返回主程序中


; 参数: (ax) = dword型整数的低16位
;		(dx) = dword型整数的高16位
;		(cx) = 除数
; 返回：(dx) = 结果的高16位， (ax) = 结果的低16位
;		(cx) = 余数
; 作用：将div运算的商由8位改为16位，防止溢出产生
; 提示：div: 除数16位，ax:商，dx:余数
;			 除数8位，al:商，ah:余数
divdw:	
	push bx
	push di

	mov bx, ax	; 将dword类型的被除数的低16位保存于bx中
	mov ax, dx	; 将dword类型的被除数的高16位转移到16位div运算保存低16位被除数的ax中
	mov dx, 0	; 注意将高位清零
	div cx		; int(H/N)，ax中保存着商int(H/N)，dx中保存着余数rem(H/N)
				   ; int(H/N)*65536，取ax中的商，乘65536相当于左移16位
	mov di, ax	; 将商int(H/N)先保存于di中

				   ; 此时dx保存上一次div运算的余数，作为当前16位除法div的高16位被除数
	mov ax, bx	; [rem(H/N) * 65536 + L]/N = [(dx)*65536 + (ax)] / (cx)
	div cx		; 此时ax中为商，dx为余数

	mov cx, dx	; cx中放余数
	mov dx, di	; 将int(H/N)作为高位商结果保存到dx中

	pop di
	pop bx
	ret

; 名称：显示字符串
; 功能：在指定位置，用指定的颜色，显示一个用0结束的字符串
; 参数：(dh) = 行号 (0 ~ 24)
; 	    (dl) = 列号 (0 ~ 79)
; 	    (cl) = 颜色
;	    ds:si指向字符串的首地址
; 返回：无
show_str:
	push dx
	push cx
	push ax
	push si
	push es
	push bx
	
	; 设置显示缓冲区
	mov ax, 0B800h
	mov es, ax
	
	; 通过dh，dl计算显示首地址
	mov al, dh
	mov ch, 160	; 每行80个字符，一个字符占两个字节
	mul ch		; 8位乘法，结果保存于ax中
	mov bx, ax	; 保存乘法结果
	
	mov al, dl
	mov ch, 2
	mul ch
	add bx, ax	; bx保存第dh行 dl列的首地址
	
	mov dl, cl  ; 在dl中暂存颜色，因为cl后续会被覆盖
 change:	
	mov ah, dl	; ah保存当前字符需要显示的颜色
	mov cl, ds:[si]
	mov ch, 0
	jcxz ok		; 判断字符串是否为0
	mov al, cl	; al保存当前字符的ASCII码
	mov es:[bx], ax
	add bx, 2
	inc si
	jmp short change

 ok:
	pop bx
	pop es
	pop si
	pop ax
	pop cx
	pop dx
	ret			; 返回call指令的下一条指令处继续执行

codesg ends
end start