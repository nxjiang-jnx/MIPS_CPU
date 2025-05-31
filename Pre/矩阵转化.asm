    .data
newline:  .asciiz "\n"

    .text

    # 输入 n

    li $v0, 5              # syscall 5: read integer
    syscall
    move $t0, $v0          # $t0 保存 n

    # 输入 m

    li $v0, 5              # syscall 5: read integer
    syscall
    move $t1, $v0          # $t1 保存 m

    # 读取矩阵元素并输出非零元素
    li $t2, 0              # i = 0 (行数)
matrix_loop:
    bge $t2, $t0, end_program # 如果 i >= n，跳出循环

    li $t3, 0              # j = 0 (列数)
col_loop:
    bge $t3, $t1, next_row  # 如果 j >= m，跳到下一行

    # 读取矩阵元素
    li $v0, 5              # syscall 5: read integer
    syscall
    move $t4, $v0          # $t4 保存矩阵元素 A[i][j]

    # 如果 A[i][j] 不为 0，则输出 (i+1, j+1, A[i][j])
    beq $t4, $zero, skip   # 如果 A[i][j] == 0，跳过输出

    addi $a0, $t2, 1       # 输出行号 i+1
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline        # 输出空格
    syscall

    addi $a0, $t3, 1       # 输出列号 j+1
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline        # 输出空格
    syscall

    move $a0, $t4          # 输出矩阵元素 A[i][j]
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline        # 换行
    syscall

skip:
    addi $t3, $t3, 1       # j++
    j col_loop             # 继续处理下一列

next_row:
    addi $t2, $t2, 1       # i++
    j matrix_loop          # 继续处理下一行

end_program:
    li $v0, 10             # syscall 10: 结束程序
    syscall
