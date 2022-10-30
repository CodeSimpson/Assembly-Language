; 将data段中的数据按如下格式写入table段中，并计算21年中人均收入，也存入table段中
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
	db 21 dup ('year summ ne ?? ')
table ends

codesg segment
 start:
	mov ax, data
	mov ds, ax
	mov ax, table
	mov es, ax
	
	; 复制年信息
	mov si, 0
	mov di, 0
	mov cx, 21
 s0:
	mov ax, ds:[si]
	mov es:[di], ax
	add si, 2
	add di, 2
	mov ax, ds:[si]
	mov es:[di], ax
	add si, 2
	add di, 14
	loop s0
	
	; 复制收入信息
	mov si, 0
	mov di, 0
	mov cx, 21
 s1: 
	mov ax, ds:[si+54H]
	mov es:[di+5], ax
	add si, 2
	add di, 2
	mov ax, ds:[si+60H]
	mov es:[di+5], ax
	add si, 2
	add di, 14
	loop s1
	
	; 复制雇员信息
	mov si, 0
	mov di, 0
	mov cx, 21
 s2:
	mov ax, ds:[si+0A8H]
	mov es:[di+0AH], ax
	add si, 2
	add di, 16	
	loop s2
	
	; 计算平均收入
	mov si, 0
	mov di, 0
	mov cx, 21
 s3:
	mov ax, es:[di+5]
	mov dx, es:[di+7]
	div word ptr es:[di+0AH]
	mov es:[di+0DH], ax
	add di, 10H
	loop s3
	
	mov ax, 4c00h
	int 21h
codesg ends

end start