    .data
newline: .asciiz "\n"            # 换行符

    .text
    # 读取年份
    li $v0, 5                    # syscall 5 读取整数
    syscall
    move $t0, $v0                # 将输入的年份存入 $t0

    # 判断是否为闰年
    li $t1, 400                  # $t1 = 400
    div $t0, $t1                 # 计算年份是否能被 400 整除
    mfhi $t2                     # $t2 = 余数
    beq $t2, $zero, leap_year    # 如果余数为0，则是闰年，跳转到 leap_year

    li $t1, 100                  # $t1 = 100
    div $t0, $t1                 # 计算年份是否能被 100 整除
    mfhi $t2                     # $t2 = 余数
    bne $t2, $zero, check_by_4   # 如果余数不为0，继续检查是否能被4整除

    # 如果能被100整除，输出0（不是闰年）
    j not_leap_year

check_by_4:
    li $t1, 4                    # $t1 = 4
    div $t0, $t1                 # 计算年份是否能被 4 整除
    mfhi $t2                     # $t2 = 余数
    bne $t2, $zero, not_leap_year  # 如果余数不为0，则不是闰年

    # 能被4整除但不能被100整除，是闰年
leap_year:
    li $v0, 1                    # syscall 1 打印整数
    li $a0, 1                    # 输出 1
    syscall
    j end_program

not_leap_year:
    li $v0, 1                    # syscall 1 打印整数
    li $a0, 0                    # 输出 0
    syscall

end_program:
    li $v0, 10                   # syscall 10 结束程序
    syscall
