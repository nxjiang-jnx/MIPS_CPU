    .data
newline: .asciiz "\n"            # ���з�

    .text
    # ��ȡ���
    li $v0, 5                    # syscall 5 ��ȡ����
    syscall
    move $t0, $v0                # ���������ݴ��� $t0

    # �ж��Ƿ�Ϊ����
    li $t1, 400                  # $t1 = 400
    div $t0, $t1                 # ��������Ƿ��ܱ� 400 ����
    mfhi $t2                     # $t2 = ����
    beq $t2, $zero, leap_year    # �������Ϊ0���������꣬��ת�� leap_year

    li $t1, 100                  # $t1 = 100
    div $t0, $t1                 # ��������Ƿ��ܱ� 100 ����
    mfhi $t2                     # $t2 = ����
    bne $t2, $zero, check_by_4   # ���������Ϊ0����������Ƿ��ܱ�4����

    # ����ܱ�100���������0���������꣩
    j not_leap_year

check_by_4:
    li $t1, 4                    # $t1 = 4
    div $t0, $t1                 # ��������Ƿ��ܱ� 4 ����
    mfhi $t2                     # $t2 = ����
    bne $t2, $zero, not_leap_year  # ���������Ϊ0����������

    # �ܱ�4���������ܱ�100������������
leap_year:
    li $v0, 1                    # syscall 1 ��ӡ����
    li $a0, 1                    # ��� 1
    syscall
    j end_program

not_leap_year:
    li $v0, 1                    # syscall 1 ��ӡ����
    li $a0, 0                    # ��� 0
    syscall

end_program:
    li $v0, 10                   # syscall 10 ��������
    syscall
