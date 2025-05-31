.macro print(%dst)
	move $a0, %dst
	li $v0, 1
	syscall
.end_macro

.macro scanf(%dst)
	li $v0, 5
	syscall
	move %dst, $v0
.end_macro

.data 
result: .word 0 : 2000

.text
	.eqv n, $s0
	.eqv addr, $s1
	.eqv result_size, $s2
	.eqv x, $s3
	.eqv i, $s4
	
	.eqv tmp, $t0
	.eqv carry, $t1
	.eqv prod, $t2
	
	#读取n
	scanf(n)
	
	#result[0] = 1;
	li tmp, 1
	li addr, 0
	sw tmp, result(addr)
	
	#int result_size = 1;
	li result_size, 1
	
	#初始化循环变量
	li x, 2
for_begin:
	bgt x, n, for_end
	
	#调用函数
	jal multiply
	 
	addi x, x, 1
	j for_begin
for_end: 
	
	#初始化循环变量
	addi i, result_size, -1
for_output_begin:
	bltz i, for_output_end
	
	sll addr, i, 2
	lw tmp, result(addr)
	print(tmp)
	
	addi i, i, -1
	j for_output_begin
for_output_end:

	li $v0, 10
	syscall
	
multiply:
	li carry, 0
	
	#初始化循环变量
	li i, 0
for_in_begin:
	bge i, result_size, for_in_end
	
	#int prod = result[i] * x + carry;
	sll addr, i, 2
	lw tmp, result(addr)
	
	mult tmp, x
	mflo tmp
	
	add prod, tmp, carry
	
	#result[i] = prod % 10;
	li tmp, 10
	divu prod, tmp
	mfhi tmp
	
	sll addr, i, 2
	sw tmp, result(addr)
	
	#carry = prod / 10;
	li tmp, 10
	divu prod, tmp
	mflo carry
	
	addi i, i, 1
	j for_in_begin
for_in_end:
	
while_begin:
	blez carry, while_end
	
	#result[result_size] = carry % 10
	li tmp, 10
	divu carry, tmp
	mfhi tmp
	sll addr, result_size, 2
	sw tmp, result(addr)
	
	#carry = carry / 10;
	li tmp, 10
	divu carry, tmp
	mflo carry
	
	#result_size++;
	addi result_size, result_size, 1
	
	j while_begin
while_end:

	jr $ra