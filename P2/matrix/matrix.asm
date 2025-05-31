.macro read_matrix(%n, %dst)
	# %dst: 矩阵的基地址
	# %n :矩阵的阶数
	# $t1 : i，now row
	# $t2 : j, now cal
	# $t3 : offset
	# $t0 : 存放地址
	# $t4 : 存放的数字
	
	#初始化索引
	li $t1, 0	
	
	#for(i = 0; i < n ; i++)
input_out_loop:
	bge $t1, %n, input_out_loop_end
	li $t2, 0
input_in_loop:	
	bge $t2, %n, input_in_loop_end
		#读取数据，保存在$t4中
		li $v0, 5
		syscall
		move $t4, $v0
		
		#计算偏移量，保存在$t3中
		multu $t1, %n
		mflo $t3
		addu $t3, $t3, $t2
		sll $t3, $t3, 2
		
		#计算存放地址$t0，基地址%dst加上偏移量$t3
		addu $t0, %dst, $t3
		
		#将数据存放在矩阵对应地址中
		sw $t4, 0($t0)
	addi $t2, $t2, 1
	j input_in_loop
input_in_loop_end:		
	addi $t1, $t1, 1
	j input_out_loop	
input_out_loop_end:				
.end_macro

.macro print(%out)
	move $a0, %out
	li $v0, 1
	syscall
.end_macro

.macro cal_addr(%base, %n, %row, %cal, %dst)
	#用于计算地址
	# base:基地址
	# n：矩阵的阶数
	# row：定位行号
	# cal: 定位列号
	# dst: 保存的返回地址
	
	multu %row, %n
	mflo $t5
	addu $t5, $t5, %cal
	sll $t5, $t5, 2
	addu $t5, $t5, %base
	move %dst, $t5
.end_macro

.macro print_space()
	li $v0, 4
    la $a0, space        # 输出空格
    syscall
.end_macro

.macro print_newline()
	li $v0, 4
    la $a0, newline        # 输出\n
    syscall
.end_macro

.data
newline: .asciiz "\n"
space: .asciiz " "
matrix1: .word 0 : 64
matrix2: .word 0 : 64

.text
	# $s0 = n
	# $s1 = a矩阵的基地址
	# $s2 = b矩阵的基地址
	# $s3 = 循环变量—a的行
	# $s4 = 循环变量—b的列
	# $s5 = 循环变量—a的列 == b的行
	# $s6 = cnt
	# $t6 = a的地址
	# $t7 = b的地址
	# $t8 = a[i][k]
	# $t9 = b[k][j]
	
	#加载基地址
	la $s1 matrix1
	la $s2 matrix2
	
	# 输入n
	li $v0, 5
	syscall
	move $s0, $v0
	
	# 输入矩阵
	read_matrix($s0, $s1)
	read_matrix($s0, $s2)
	
	#初始化循环变量
	li $s3, 0 		# i = 0
	
output_loop_out_begin:
	bge $s3, $s0, output_loop_out_end
	li $s4, 0		# j = 0
output_loop_mid_begin:
	bge $s4, $s0, output_loop_mid_end
	li $s6, 0		# cnt = 0
	li $s5, 0		# k = 0
output_loop_in_begin:	
	bge $s5, $s0, output_loop_in_end
	#计算所需地址
	cal_addr($s1, $s0, $s3, $s5, $t6)
	cal_addr($s2, $s0, $s5, $s4, $t7)
	
	#获取矩阵对应的值
	lw $t8, 0($t6)
	lw $t9, 0($t7)
	
	#计算$t4 =  a[i][k] * b[k][j]
	multu $t8, $t9
	mflo $t8
	
	#cnt = cnt + a[i][k] * b[k][j]
	add $s6, $s6, $t8
	
	addi $s5, $s5, 1
	j output_loop_in_begin
output_loop_in_end:	
	# printf("%d ", cnt)
	print($s6)
	print_space()
		
	addi $s4, $s4, 1
	j output_loop_mid_begin
output_loop_mid_end:
	# printf("\n")
	print_newline()
			 
	addi $s3, $s3, 1
	j output_loop_out_begin
output_loop_out_end:

	li $v0,10
	syscall