.macro scanf(%dst)
	li $v0, 5
	syscall
	move %dst, $v0
.end_macro

.macro print(%dst)
	move $a0, %dst
	li $v0, 1
	syscall
.end_macro

.macro cal_addr(%dst, %i, %j, %rank)
	mult %i, %rank
	mflo %dst
	add %dst, %dst, %j
	sll %dst, %dst, 2
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
maze: .word 0 : 196
dir: .word 0 : 32

.text
	.eqv n, $s0
	.eqv m, $s1
	.eqv start_x, $s2
	.eqv start_y, $s3
	.eqv end_x, $s4
	.eqv end_y, $s5	
	.eqv i1, $s6
	.eqv j1, $s7
	
	.eqv cnt, $t0
	.eqv addr, $t1
	.eqv tmp, $t2
	
	.eqv x, $a0
	.eqv y, $a1
	
main:
	#初始化cnt
	li cnt, 0
	
	#初始化dir
	li tmp, -1
	li addr, 0
	sw tmp, dir(addr)
	
	li tmp, 0
	li addr, 4
	sw tmp, dir(addr)
	
	li tmp, 1
	li addr, 8
	sw tmp, dir(addr)
	
	li tmp, 0
	li addr, 12
	sw tmp, dir(addr)
	
	li tmp, 0
	li addr, 16
	sw tmp, dir(addr)
	
	li tmp, -1
	li addr, 20
	sw tmp, dir(addr)
	
	li tmp, 0
	li addr, 24
	sw tmp, dir(addr)
	
	li tmp, 1
	li addr, 28
	sw tmp, dir(addr)	
	
	#读取迷宫的行数和列数
	scanf(n)
	scanf(m)
	
	#读取迷宫矩阵
	li i1, 0		#初始化循环变量
for_out_begin:
	bge i1, n, for_out_end
	
	li j1, 0		#初始化循环变量
for_in_begin:
	bge j1, m, for_in_end
	
	#计算偏移量
	cal_addr(addr, i1, j1, m)
	
	#读取矩阵元素
	scanf(tmp)
	
	#存入矩阵
	sw tmp, maze(addr)
	
	addi j1, j1, 1
	j for_in_begin
for_in_end:
	
	addi i1, i1, 1
	j for_out_begin
for_out_end:
	
	#读取起点和终点的坐标
	scanf(start_x)
	scanf(start_y)
	scanf(end_x)
	scanf(end_y)
	
	#调整起点和终点的坐标（由于输入从1开始，而数组下标从0开始）
	addi start_x, start_x, -1
	addi start_y, start_y, -1
	addi end_x, end_x, -1
	addi end_y, end_y, -1
	
	#传入函数参数
	move x, start_x
	move y, start_y
	
	#开始深度优先搜索
	jal dfs
	
	#输出结果
	print(cnt)	

	li $v0,10
	syscall

dfs:
	#入栈
	push($ra)
	
	#如果到达终点，增加路线计数
if_begin:
	bne x, end_x, if_end
	bne y, end_y, if_end
	
	#route_count++
	addi cnt, cnt,1
if_end:	
	
	#临时将当前点标记为走过
	cal_addr(addr, x, y, m)
	li tmp, 1
	sw tmp, maze(addr)
	
	#遍历四个方向
	li i1, 0		#初始化循环变量
	li $t3, 4		#dir的行数
	li $t4, 2		#dir的列数
loop_begin:
	bge i1, $t3, loop_end
	
	#入栈
	push(i1)
	push(x)
	push(y)
	
	#更新x
	li tmp, 0
	cal_addr(addr, i1, tmp, $t4)
	lw tmp, dir(addr)
	add x, x, tmp
	
	#更新y
	li tmp, 1
	cal_addr(addr, i1, tmp, $t4)
	lw tmp, dir(addr)
	add y, y, tmp
	
	#if (new_x >= 0 && new_x < n && new_y >= 0 && new_y < m && maze[new_x][new_y] == 0)
if1_begin:
	bltz x, if1_end
	bge x, n, if1_end
	bltz y, if1_end
	bge y, m, if1_end
	cal_addr(addr, x, y, m)
	lw tmp, maze(addr)
	bnez tmp, if1_end
	
	#递归调用
	jal dfs
	
if1_end:
	
	#出栈，恢复当前状态
	pop(y)
	pop(x)
	pop(i1)
	
	addi i1, i1, 1
	j loop_begin
loop_end:

	#回溯时将当前点恢复为未走过
	cal_addr(addr, x, y, m)
	li tmp, 0
	sw tmp, maze(addr)
	
	#出栈
	pop($ra)
	
	#return 
	jr $ra

