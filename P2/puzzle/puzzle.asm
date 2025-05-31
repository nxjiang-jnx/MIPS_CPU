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
	#��ʼ��cnt
	li cnt, 0
	
	#��ʼ��dir
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
	
	#��ȡ�Թ�������������
	scanf(n)
	scanf(m)
	
	#��ȡ�Թ�����
	li i1, 0		#��ʼ��ѭ������
for_out_begin:
	bge i1, n, for_out_end
	
	li j1, 0		#��ʼ��ѭ������
for_in_begin:
	bge j1, m, for_in_end
	
	#����ƫ����
	cal_addr(addr, i1, j1, m)
	
	#��ȡ����Ԫ��
	scanf(tmp)
	
	#�������
	sw tmp, maze(addr)
	
	addi j1, j1, 1
	j for_in_begin
for_in_end:
	
	addi i1, i1, 1
	j for_out_begin
for_out_end:
	
	#��ȡ�����յ������
	scanf(start_x)
	scanf(start_y)
	scanf(end_x)
	scanf(end_y)
	
	#���������յ�����꣨���������1��ʼ���������±��0��ʼ��
	addi start_x, start_x, -1
	addi start_y, start_y, -1
	addi end_x, end_x, -1
	addi end_y, end_y, -1
	
	#���뺯������
	move x, start_x
	move y, start_y
	
	#��ʼ�����������
	jal dfs
	
	#������
	print(cnt)	

	li $v0,10
	syscall

dfs:
	#��ջ
	push($ra)
	
	#��������յ㣬����·�߼���
if_begin:
	bne x, end_x, if_end
	bne y, end_y, if_end
	
	#route_count++
	addi cnt, cnt,1
if_end:	
	
	#��ʱ����ǰ����Ϊ�߹�
	cal_addr(addr, x, y, m)
	li tmp, 1
	sw tmp, maze(addr)
	
	#�����ĸ�����
	li i1, 0		#��ʼ��ѭ������
	li $t3, 4		#dir������
	li $t4, 2		#dir������
loop_begin:
	bge i1, $t3, loop_end
	
	#��ջ
	push(i1)
	push(x)
	push(y)
	
	#����x
	li tmp, 0
	cal_addr(addr, i1, tmp, $t4)
	lw tmp, dir(addr)
	add x, x, tmp
	
	#����y
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
	
	#�ݹ����
	jal dfs
	
if1_end:
	
	#��ջ���ָ���ǰ״̬
	pop(y)
	pop(x)
	pop(i1)
	
	addi i1, i1, 1
	j loop_begin
loop_end:

	#����ʱ����ǰ��ָ�Ϊδ�߹�
	cal_addr(addr, x, y, m)
	li tmp, 0
	sw tmp, maze(addr)
	
	#��ջ
	pop($ra)
	
	#return 
	jr $ra

