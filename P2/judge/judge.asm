
.data
array: .word 0 : 20		#存储 字符串的数组

.text
	.eqv n, $s0			# s0 : n
	.eqv i, $s1			# s1 : i 循环变量
	.eqv flag, $s2		# s2 : flag 最终输出 
	.eqv char, $s3		# s3 : 读入和读出变量
	.eqv offset, $s4	# s4 : 存储地址偏移量
	.eqv op1, $s5		# op1: a[i]
	.eqv op2, $s6		# op2: a[n - i -1]
	
	#初始化flag
	li flag, 1
	
	#读取n
	li $v0, 5
	syscall
	move n, $v0
	
	#构造循环，读取字符串
	#初始化i
	li i, 0
	
input_loop_begin:
	bge i, n , input_loop_end
	
	#读入一个字符
	li $v0, 12
	syscall
	move char, $v0
	
	#将字符存入数组
	move offset, i
	sll offset, offset, 2
	sw char, array(offset)
	
	addi i, i, 1		#i++
	j input_loop_begin	#返回
input_loop_end:

	#构造循环，判断回文数
	#初始化i, 定义$t1为n/2, $t0 为2
	li i, 0
	li $t0, 2
	divu n, $t0
	mflo $t1
	
output_loop_begin:
	bge i, $t1,  output_loop_end
	
	#读取a[i]
	move offset, i
	sll offset, offset, 2
	lw op1, array(offset)
	
	#读取a[n-i-1]
	move offset, n
	sub offset, offset, i
	subi offset, offset, 1
	sll offset, offset, 2
	lw op2, array(offset)	
	
	#如果相等则跳转
	beq op1, op2, equal_case
	
	#否则，flag = 0
	li flag, 0
	
	#break跳出循环
	j output_loop_end
	
equal_case:

	addi i, i, 1		#i++
	j output_loop_begin	#返回
output_loop_end:

	#打印出flag
	move $a0, flag
	li $v0, 1
	syscall
	
	li $v0,10
	syscall
