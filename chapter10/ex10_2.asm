assume cs:code
stack segment
 db 10 dup (0)
stack ends

data segment
 dw 10 dup (0)
data ends

code segment
start:
	mov ax, 1731H
	mov dx, 00aaH
	mov cx, 0AH
	call divdw
		
	mov ax, 4c00h
	int 21h
		
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
	mov dx, di	; 将int(H/N)作为高位商结果保存

	pop di
	pop bx
	ret
	
code ends
end start