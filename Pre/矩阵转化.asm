    .data
newline:  .asciiz "\n"

    .text

    # ���� n

    li $v0, 5              # syscall 5: read integer
    syscall
    move $t0, $v0          # $t0 ���� n

    # ���� m

    li $v0, 5              # syscall 5: read integer
    syscall
    move $t1, $v0          # $t1 ���� m

    # ��ȡ����Ԫ�ز��������Ԫ��
    li $t2, 0              # i = 0 (����)
matrix_loop:
    bge $t2, $t0, end_program # ��� i >= n������ѭ��

    li $t3, 0              # j = 0 (����)
col_loop:
    bge $t3, $t1, next_row  # ��� j >= m��������һ��

    # ��ȡ����Ԫ��
    li $v0, 5              # syscall 5: read integer
    syscall
    move $t4, $v0          # $t4 �������Ԫ�� A[i][j]

    # ��� A[i][j] ��Ϊ 0������� (i+1, j+1, A[i][j])
    beq $t4, $zero, skip   # ��� A[i][j] == 0���������

    addi $a0, $t2, 1       # ����к� i+1
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline        # ����ո�
    syscall

    addi $a0, $t3, 1       # ����к� j+1
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline        # ����ո�
    syscall

    move $a0, $t4          # �������Ԫ�� A[i][j]
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline        # ����
    syscall

skip:
    addi $t3, $t3, 1       # j++
    j col_loop             # ����������һ��

next_row:
    addi $t2, $t2, 1       # i++
    j matrix_loop          # ����������һ��

end_program:
    li $v0, 10             # syscall 10: ��������
    syscall
