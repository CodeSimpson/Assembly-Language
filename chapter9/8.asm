assume cs:codesg
codesg segment

		mov ax, 4c00h
		int 21h
	
start: 	mov ax, 0
	s:	nop
		nop
		
		mov di, offset s	; s标号的偏移地址为8
		mov si, offset s2	; s2标号的偏移地址为20H
		mov ax, cs:[si]		; ax保存s2处的指令：jmp short s1，刚好2个字节
		mov cs:[di], ax		; 将jmp shot s1复制到s处，一个nop占一个字节
		
	s0:	jmp short s			; jmp的偏移位移在程序编译时计算，s2处的jmp short s1经过计算偏移为EBF8，F8对应-8的补码，将jmp short s1后，
							; 指令仍为EBF8，而由于s刚好处于cs:0008处，运行jmp后，转跳到cs:0程序段，正常退出，非常巧妙
	
	s1: mov ax, 0
		int 21h
		mov ax, 0
	
	s2: jmp short s1
	nop

codesg ends
end start