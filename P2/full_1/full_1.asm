.macro scanf(%dst)
	li $v0, 5
	syscall
	move %dst, $v0
.end_macro

.macro print(%dst)
	move $a0, %dst
	li $v0, 1
	syscall			#��ӡ����
	
	la $a0, space
	li $v0, 4
	syscall			#��ӡ�ո�
.end_macro

.macro print_newline
	la $a0, newline
	li $v0, 4
	syscall
.end_macro

.macro push(%dst)
	addi $sp, $sp, -4
	sw %dst, 0($sp)
.end_macro
	
.macro pop(%dst)
	lw %dst, 0($sp)
	addi $sp, $sp, 4
.end_macro

.data
symbol: .word 0 : 28
array: .word 0 : 28
newline: .asciiz "\n"
space: .asciiz " "

.text
main:
	.eqv n, $s0
	.eqv i, $s1
	.eqv index, $a0
	.eqv addr, $t0
	.eqv digit, $t1
	
	#��ȡn
	scanf(n)
	
	#��������������
	li index, 0
	
	#���ú���
	jal FullArray
	
end:
	#��������
	li $v0,10
	syscall
	
FullArray:
	#�����ص�ַ��ջ
	push($ra)
	
	#if(index >= n)
	blt index, n, if_end
	
	#��ʼ��ѭ������
	li, i, 0
	
for_in_begin:
	bge i, n, for_in_end
	
	#printf array[i]
	sll addr, i, 2
	lw digit, array(addr)
	print(digit)
	
	addi i, i, 1
	j for_in_begin
	
for_in_end:	
	#print \n
	print_newline
	
if_end:
	#��ʼ��ѭ������
	li i, 0

for_out_begin:
	bge i, n, for_out_end
	
	#if symbol[i] == 0
	sll addr, i, 2
	lw digit, symbol(addr)
if_symbol:
	bne digit, 0, if_symbol_end
	
	#array[index] = i + 1
	sll addr, index, 2
	addi digit, i, 1
	sw digit, array(addr)
	
	#symbol[i] = 1
	sll addr, i, 2
	li digit, 1
	sw digit, symbol(addr)
	
	#��ջ
	push(i)
	push(index)
	
	#���²���
	addi index, index, 1
	
	#�ݹ����
	jal FullArray
	
	#��ջ
	pop(index)
	pop(i)	
	
	#symbol[i] = 0
	sll addr, i, 2
	li digit, 0
	sw digit, symbol(addr)
	
if_symbol_end:	
	addi i, i, 1
	j for_out_begin
for_out_end:	
	#��ջ������
	pop($ra)
	jr $ra
	