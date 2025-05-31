#»Ù10 < 20 ‘ÚÃ¯◊™
.data
prompt .asciiz

.text
li $v0, 5
syscall
move $t0, $v0

li $t0, 10
li $t1, 20

for_begin:
beq	$t0, $t1, end_for
nop
#do sth

addi $t0, $t0, 1
j for_begin
nop

li $v0 
end_for:   
li $v0, 10
syscall
