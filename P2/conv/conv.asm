.macro scanf(%dst)
	.eqv input, $t0
	li $v0, 5
	syscall
	move %dst, $v0
.end_macro

.macro print(%dst)
	move $a0, %dst
	li $v0, 1
	syscall
.end_macro

.macro print_space
    li $v0, 4
    la $a0, space       # 输出空格
    syscall
.end_macro

.macro print_newline
	li $v0, 4
	la $a0, newline
	syscall				#输出换行
.end_macro

.macro cal_addr(%dst, %sumcal, %row, %cal)
	# dst: 最终返回地址
	# sumcal: 这个矩阵一共多少列
	# row: 当前函数
	# cal: 当前列数
	
	multu %row, %sumcal
	mflo %dst
	add %dst, %dst, %cal
	sll %dst, %dst, 2
.end_macro

.macro cal_conv(%sumcal, %row, %cal, %m2, %n2)
	.eqv temp, $t4
	.eqv tempsub, $t5
	.eqv x, $t6
	.eqv y, $t7
	.eqv i2, $t8
	.eqv j2, $t9
	
	#初始化
	li digit, 0
	add maxi, %row, %m2
	add maxj, %cal, %n2
	
	#初始化循环变量
	move i2, %row
	
for_out_begin:
	bge i2, maxi, for_out_end
	
	#初始化循环变量
	move j2, %cal
	
for_in_begin:
	bge j2, maxj, for_in_end
	
	#加载f的定位地址到addr
	cal_addr(addr, %sumcal, i2, j2)
	
	#取出f[i][j]
	lw temp, f(addr)
	
	#加载g的定位地址到addr
	sub x, i2, %row
	sub y, j2, %cal 
	cal_addr(addr, %n2, x, y)
	
	#取出g[i - row][j - cal]
	lw tempsub, g(addr)
	
	#temp = f[i][j] * g[i - row][j - cal]
	multu temp, tempsub
	mflo temp
	
	#digit += temp
	add digit, digit, temp
	
	addi j2, j2, 1
	j for_in_begin
for_in_end:
	
	addi i2, i2, 1
	j for_out_begin
for_out_end:	
.end_macro

.data
f: .word 0 : 400
g: .word 0 : 400
newline: .asciiz "\n"
space: .asciiz " "

.text
	#定义程序员变量
	.eqv i1, $s0
	.eqv j1, $s1
	.eqv digit, $s2
	.eqv m1, $s3
	.eqv n1, $s4
	.eqv m2, $s5
	.eqv n2, $s6
	.eqv addr $t1
	.eqv maxi $t2
	.eqv maxj $t3
	
	#input
	scanf(m1)
	scanf(n1)
	scanf(m2)
	scanf(n2)
	
	#输入矩阵f	
	li i1, 0		#初始化循环变量
input_f_out_begin:
	bge i1, m1, input_f_out_end
	
	li j1, 0		#初始化循环变量
input_f_in_begin:
	bge j1, n1, input_f_in_end
	
	#读取digit
	scanf(digit)
	
	#计算存储地址
	cal_addr(addr, n1, i1, j1)
	
	#存入矩阵
	sw digit, f(addr)
	
	addi j1, j1, 1	#j1++
	j input_f_in_begin	
input_f_in_end:
	
	addi i1, i1, 1	#i1++
	j input_f_out_begin
input_f_out_end:
	
	#输入矩阵g
	li i1, 0		#初始化循环变量
input_g_out_begin:
	bge i1, m2, input_g_out_end
	
	li j1, 0		#初始化循环变量
input_g_in_begin:
	bge j1, n2, input_g_in_end
	
	#读取digit
	scanf(digit)
	
	#计算存储地址
	cal_addr(addr, n2, i1, j1)
	
	#存入矩阵
	sw digit, g(addr)
	
	addi j1, j1, 1	#j1++
	j input_g_in_begin	
input_g_in_end:
	
	addi i1, i1, 1	#i1++
	j input_g_out_begin
input_g_out_end:
	
	#output
	#maxi = m1 - m2 + 1
	sub maxi, m1, m2
	addi maxi, maxi, 1
	
	#maxj = n1 - n2 + 1
	sub maxj, n1, n2
	addi maxj, maxj, 1
	
	li i1, 0		#初始化循环变量
output_loop_out_begin:
	bge i1, maxi, output_loop_out_end
	
	li j1, 0		#初始化循环变量
output_loop_in_begin:
	bge j1, maxj, output_loop_in_end
	
	#把addr, maxi, maxj压入栈
	addi $sp, $sp, -12
	sw addr, 8($sp)
	sw maxi, 4($sp)
	sw maxj, 0($sp)
	
	cal_conv(n1, i1, j1, m2, n2)
	print(digit)
	print_space
	
	#恢复参数，恢复栈顶指针
	lw addr, 8($sp)
	lw maxi, 4($sp)
	lw maxj, 0($sp)
	addi $sp, $sp, 12
	
	addi j1, j1, 1	#j1++
	j output_loop_in_begin
output_loop_in_end:
	
	#printf("\n");
	print_newline
	
	addi i1, i1, 1	#i1++
	j output_loop_out_begin
output_loop_out_end:
	
	li $v0, 10
	syscall
	