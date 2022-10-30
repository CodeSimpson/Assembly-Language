; 将dword型数转变为十进制数的字符串
assume cs:codesg, ds:datasg

datasg segment
 dd 593700
datasg ends

strtable segment
 db 20 dup (0)
strtable ends

stack segment
 db 20 dup (0)
stack ends

codesg segment
 start:
   mov ax, datasg
   mov ds, ax
   mov di, 0

   mov ax, stack
   mov ss, ax
   mov sp, 20

   mov ax, strtable
   mov es, ax
   mov si, 0

   mov ax, ds:[di]   ; 低位内存地址存放数据低位
   mov dx, ds:[di+2]
   call dwtoc

	mov dh, 8
	mov dl, 3
	mov cl, 2
   mov ax, strtable
   mov ds, ax
   mov si, 0
	call show_str

   mov ax, 4c00h
   int 21h

; 名称：dwtoc
; 功能：将dword型数转变为表示十进制数的字符串，字符串以0为结尾符
; 参数：(ax) = dword型数据的低16位
;       (dx) = dword型数据的高16位
;       es:[0]指向字符串的首地址
; 返回：无
dwtoc:
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
   pop es:[si]     ; 记得是以字为单位操作的？？？？
   inc si
   loop ps
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
show_str:	push dx
			push cx
			push ax
			push si
			
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
	change:	mov ah, dl	; ah保存当前字符需要显示的颜色
			mov cl, ds:[si]
			mov ch, 0
			jcxz ok		; 判断字符串是否为0
			mov al, cl	; al保存当前字符的ASCII码
			mov es:[bx], ax
			add bx, 2
			inc si
			jmp short change

		ok:	pop si
			pop ax
			pop cx
			pop dx
			ret			; 返回call指令的下一条指令处继续执行

codesg ends
end start