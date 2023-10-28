.global _start

.data 
    test1:    .dword 0x1122334455007700
    test2:    .dword 0x0123456789abcdef
    test3:    .dword 0x1100220033445566
    str_cycle:     .string "cycle count: "
    endl:     .string "\n"
    buffer:     .byte 0, 0, 0, 0

.set STDOUT, 1
.set SYSEXIT,  93
.set SYSWRITE, 64

str: .ascii "The Leftmost 0-byte is "
     .set str_size, .-str

.text
_start:

    jal get_cycles      # get cycles before execution
    addi sp, sp, -4
    sw a0, 0(sp)
    la   t2, test1          # t2 points to the first test case
    li   t3, 3              # number of test cases

loop:
    lw   a0, 0(t2)          # a0:test_half_right
    lw   a1, 4(t2)          # a1:test_half_left
    jal  zbytel
    mv   t4, a0             # save the result to t4

    #print
    li a7, SYSWRITE	# "write" syscall
    li a0, 1            # 1 = standard output (stdout)
    la a1, str          # load address of string
    li a2, str_size     # length of string
    ecall

    addi sp, sp, -4
    addi t4, t4, 48
    sw t4, 0(sp)
    li a7, SYSWRITE
    li a0, 1
    mv a1, sp
    li a2, 1
    ecall
    addi sp, sp, 4

    li a7, SYSWRITE
    li a0, 1
    la a1, endl
    li a2, 2
    ecall

    addi t2, t2, 8	# move to the next test case
    addi t3, t3, -1	# test case counter--
    bne  t3, x0, loop	# counter=0,break

    #--------------get cycle start------------------

    li a7, SYSWRITE	
    li a0, 1            
    la a1, str_cycle
    li a2, 13
    ecall
    
    # cycle count
    jal get_cycles
    lw t0, 0(sp)    # t0 = pre cycle
    sub a0, a0, t0    # a0 = new cycle
    addi sp, sp, 4
    li a1, 4
    jal print_ascii
    mv t0, a0
    li a0, 1
    la a1, buffer
    li a2, 4
    li a7, SYSWRITE
    ecall
    
    li a7, SYSWRITE
    li a0, 1
    la a1, endl
    li a2, 2
    ecall

    #--------------get cycle end------------------


    li a7, SYSEXIT    # "exit" syscall
    add a0, x0, 0       # Use 0 return code
    ecall               # invoke syscall to terminate the program
            

zbytel:
    addi  sp,sp,-4             #push
    sw    ra,0(sp)              
    mv    s0,a0                #s0:test_half_right  
    mv    s1,a1                #s1:test_half_left

    #y = (x & 0x7F7F7F7F7F7F7F7F)+ 0x7F7F7F7F7F7F7F7F
    li    t0,0x7f7f7f7f
    and   s2,s0,t0          
    add   s2,s2,t0

    #y = ~(y | x |0x7F7F7F7F7F7F7F7F)
    or    s2,s2,s0
    or    s2,s2,t0
    xori  s2,s2,-1          #s2:y_half_right

    and  s3,s1,t0       
    add  s3,s3,t0        
    or   s3,s3,s0
    or    s3,s3,t0
    xori  s3,s3,-1          #s3:y_half_left
    
    mv    a0,s2          
    mv    a1,s3                
    jal   clz
    lw    ra,0(sp)
    addi  sp,sp,4           #pop 
    srli  a0,a0,3           #clz(y)>>3
    jr   ra

 

clz:
    #x |= (x >> 1)
    andi  t1,a1,0x1
    srli  s4,a1,1
    srli  s5,a0,1
    slli  t1,t1,31
    or    s5,s5,t1
    or    a1,s4,a1
    or    a0,s5,a0

    #x |= (x >> 2)
    andi  t1,a1,0x3
    srli  s4,a1,2
    srli  s5,a0,2
    slli  t1,t1,30
    or    s5,s5,t1
    or    a1,s4,a1
    or    a0,s5,a0

    #x |= (x >> 4)
    andi  t1,a1,0xf
    srli  s4,a1,4
    srli  s5,a0,4
    slli  t1,t1,28
    or    s5,s5,t1
    or    a1,s4,a1
    or    a0,s5,a0  

    #x |= (x >> 8)
    andi  t1,a1,0xff
    srli  s4,a1,8
    srli  s5,a0,8
    slli  t1,t1,24
    or    s5,s5,t1
    or    a1,s4,a1
    or    a0,s5,a0
   
    #x |= (x >> 16)
    li    t1,0xffff
    and   t1,a1,t1
    srli  s4,a1,16
    srli  s5,a0,16
    slli  t1,t1,16
    or    s5,s5,t1
    or    a1,s4,a1
    or    a0,s5,a0
    
    #x |= (x >> 32)
    mv    s5,a1
    and   s4,a1,x0
    or    a1,s4,a1
    or    a0,s5,a0

    # x -= ((x >> 1) & 0x5555555555555555)
    andi  t1,a1,0x1
    srli  s4,a1,1
    srli  s5,a0,1
    slli  t1,t1,31
    or    s5,s5,t1
    li    t1,0x55555555
    and   s4,s4,t1
    and   s5,s5,t1
    sub   a1,a1,s4
    sub   a0,a0,s5
    
    #x = ((x >> 2) & 0x3333333333333333) + (x & 0x3333333333333333)
    andi  t1,a1,0x3
    srli  s4,a1,2
    srli  s5,a0,2
    slli  t1,t1,30
    or    s5,s5,t1
    li    t1,0x33333333
    and   s4,s4,t1        
    and   s5,s5,t1        
    and   a1,a1,t1
    and   a0,a0,t1
    add   a1,a1,s4
    add   a0,a0,s5

    #x = ((x >> 4) + x) & 0x0f0f0f0f0f0f0f0f;
    andi  t1,a1,0xf
    srli  s4,a1,4
    srli  s5,a0,4
    slli  t1,t1,28
    or    s5,s5,t1
    add   s4,s4,a1
    add   s5,s5,a0
    li    t1,0x0f0f0f0f
    and   a1,s4,t1
    and   a0,s5,t1

    #x += (x >> 8)
    andi  t1,a1,0xff
    srli  s4,a1,8
    srli  s5,a0,8
    slli  t1,t1,24
    or    s5,s5,t1
    add   a1,a1,s4
    add   a0,a0,s5
    
    #x += (x >> 16)
    li    t1,0xffff
    and   t1,t1,a1
    srli  s4,a1,16
    srli  s5,a0,16
    slli  t1,t1,16
    or    s5,s5,t1
    add   a1,a1,s4
    add   a0,a0,s5
    
    #x += (x >> 32)
    mv    s5,a1
    and   s4,a1,x0
    add   a1,a1,s4
    add   a0,a0,s5
    
    #64 - (x & 0x7f)
    andi  a0,a0,0x7f
    li    t1,64
    sub   a0,t1,a0
    jr    ra

    

get_cycles:
    csrr a1, cycleh
    csrr a0, cycle
    csrr a2, cycleh
    bne a1, a2, get_cycles
    ret
    

# a0: integer of cycle
# a1: number of bytes in buffer
print_ascii:
    mv t0, a0     # load integer
    li t1, 0      # t1 = quotient
    li t2, 0      # t2 = reminder
    li t3, 10     # t3 = divisor
    mv t4, a1     # t4 = count round

check_less_then_ten:
    bge t0, t3, divide
    mv t2, t0
    mv t0, t1    # t0 = quotient
    j to_ascii

divide:
    sub t0, t0, t3
    addi t1, t1, 1
    j check_less_then_ten

to_ascii:
    addi t2, t2, 48	# reminder to ascii
    la t5, buffer  # t5 = buffer addr
    addi t4, t4, -1
    add t5, t5, t4
    sb t2, 0(t5)
    
    # counter = 0 exit
    beqz t4, convert_loop_done
    li t1, 0 # refresh quotient
    j check_less_then_ten

convert_loop_done:
    ret