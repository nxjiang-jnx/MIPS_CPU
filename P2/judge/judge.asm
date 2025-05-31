
.data
array: .word 0 : 20		#�洢 �ַ���������

.text
	.eqv n, $s0			# s0 : n
	.eqv i, $s1			# s1 : i ѭ������
	.eqv flag, $s2		# s2 : flag ������� 
	.eqv char, $s3		# s3 : ����Ͷ�������
	.eqv offset, $s4	# s4 : �洢��ַƫ����
	.eqv op1, $s5		# op1: a[i]
	.eqv op2, $s6		# op2: a[n - i -1]
	
	#��ʼ��flag
	li flag, 1
	
	#��ȡn
	li $v0, 5
	syscall
	move n, $v0
	
	#����ѭ������ȡ�ַ���
	#��ʼ��i
	li i, 0
	
input_loop_begin:
	bge i, n , input_loop_end
	
	#����һ���ַ�
	li $v0, 12
	syscall
	move char, $v0
	
	#���ַ���������
	move offset, i
	sll offset, offset, 2
	sw char, array(offset)
	
	addi i, i, 1		#i++
	j input_loop_begin	#����
input_loop_end:

	#����ѭ�����жϻ�����
	#��ʼ��i, ����$t1Ϊn/2, $t0 Ϊ2
	li i, 0
	li $t0, 2
	divu n, $t0
	mflo $t1
	
output_loop_begin:
	bge i, $t1,  output_loop_end
	
	#��ȡa[i]
	move offset, i
	sll offset, offset, 2
	lw op1, array(offset)
	
	#��ȡa[n-i-1]
	move offset, n
	sub offset, offset, i
	subi offset, offset, 1
	sll offset, offset, 2
	lw op2, array(offset)	
	
	#����������ת
	beq op1, op2, equal_case
	
	#����flag = 0
	li flag, 0
	
	#break����ѭ��
	j output_loop_end
	
equal_case:

	addi i, i, 1		#i++
	j output_loop_begin	#����
output_loop_end:

	#��ӡ��flag
	move $a0, flag
	li $v0, 1
	syscall
	
	li $v0,10
	syscall
