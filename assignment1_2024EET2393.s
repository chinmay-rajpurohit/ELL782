# Name: Chinmay Rajpurohit
# Programme: Computer Technology
# Entry No: 2024EET2393 
# Course : Computer Architecture ( ELL782 )

  #REQUIRED DATA DECLARATION  

.data
    n: .word 2                                                                                     # matrix size
    M: .float 2,2,2
    M1: .space 200
    I: .space 200                                                                                  # space for identity matrix 
    V: .space 200                                                                                  # space for verification matrix 
    zero: .float 0.0                                                                               # zero label
    one: .float 1.0                                                                                # one label
    ten_thousand: .float 10000.0                                                                   # ten thousand label
    ten: .float 10.0                                                                               # ten label
    addv: .float 0.00005                                                                           # addv label
    msg1: .string "\n"                                                                             # new line character label
    msg2: .string "Inverse of the matrix does not exist.\n"                                        # text label
    msg3: .string "."                                                                              # dot label
    msg4: .string "  "                                                                             # space label
    msg5: .string "-"                                                                              # minus sign label
    msg6: .string "Find the respective Inverse below:"                                             # text label
    msg7: .string "Verification matrix after multiplication of the Matrix and its Inverse:"                                      # text label
    msg8: .string ".0000"                                                                          # text label
    esp: .float 1e-5                                                                               # esp label for very small value


.text
.globl main

main:
    lw a6, n                    # matrix size 
    la a7, M                    # load address of matrix M into a7
    la a3, I                    # load the address of identity matrix I into a3
    li a4, 4                    # offset a4=4
    li t1, 1                    # put 1 in t1 
    la s6, V                    # load address of verification matrix into s6 
    la s5 , M1                  # load address of copied matrix for verification purpose     

    la s0,esp                   # load address of 1e-5 stored into esp label
    flw f31,0(s0)               # load 1e-5 into f31

    la s0,ten_thousand          # load address of label ten_thousand
    flw f29,0(s0)               # load the value stored at that address

    la s0,ten                   # load address of label ten
    flw f26,0(s0)               # load the value stored at that address

    la s0,addv                  # load address of label addv 
    flw f24,0(s0)               # load the value stored at that address

    la s0, one                  # load address of label one 
    flw f28,0(s0)               # load the value stored at that address

    fmv.s.x f30, zero           # store zero into f30 register



   #######################IDENTITY MATRIX INITIALIZATION and PARALLELY COPY THE M MATRIX VALUES INTO M1 MATRIX#########################
   ######################################################################################################################################

    li a5,0                     # i=0 

identity_loop1: 
    bge a5,a6,end_iloop1        # if i>=n end the loop 

    li s11,0                    # j=0 

inside_loop: 
    bge s11,a6,end_insideloop   # end the loop if j>=n 

    mv s9,a5                    # i into s2               
    mul s9,s9,a6                # i*n
    add s9,s9,s11               # ( i*n + j )
    mul s9,s9,a4                # 4*( i*n + j )

    add s10,s5,s9               # calculate address of M1[i][j]
    add s3,a7,s9                # calculate address of M[i][j] 
    flw f1,0(s3)                # load value of M[i][j] into float reg 
    fsw f1,0(s10)               # store into M1[i][j]

    add s9,s9,a3                # I address + 4*( i*n + j )

    beq a5, s11, equal 

    fsw f30,0(s9)               # put 0 int0 I when i!=j 
    j here 

equal: 

    fsw f28,0(s9)               # put 1 if i==j 
here:
    addi s11,s11,1 
    j inside_loop 

end_insideloop: 

    addi a5,a5,1 
    j identity_loop1 

end_iloop1:


    ##################################GUSSIAN ELIMINATION STARTS FROM HERE WITH THE HELP OF PARTIAL PIVOTING###########################
    ###################################################################################################################################
    
    li a5, 0                    # i=0
loop1:
    bge a5, a6, end_loop1       # If i >= n, exit the loop1

    #Pivot assign

    mv t0,a5                    # pivot = i

    add t2,a5,t1                # k=i+1
loop2:
    bge t2,a6, end_loop2        # if k>=n, exit the loop2

    # Now to access M[k][i] = address of M + ( k*n + i )*4

    mv t3,t2                    # put k into temp   
    mul t3,t3,a6                # k*n
    add t3,t3,a5                # (k*n + i)
    mul t3,t3,a4                # (k*n + i)*4
    add t3,t3,a7                # matrix M address + ( k*n + i )*4
    flw f5,0(t3)                # load value of M[k][i] 

    # access A[pivot][i]

    mv t3,t0                    # put pivot into temp   
    mul t3,t3,a6                # pivot*n
    add t3,t3,a5                # (pivot*n + i)
    mul t3,t3,a4                # (pivot*n + i)*4
    add t3,t3,a7                # matrix M address + ( pivot*n + i )*4
    flw f1,0(t3)                # load value of M[pivot][i] 

    #take absolute value of both

    fabs.s f2,f5                # f2 = M[k][i] 
    fabs.s f3,f1                # f3 = M[pivot][i]

    flt.s t5, f3,f2             #compare both values if M[k][i]>M[pivot][i]

    beqz t5, ignore             #if M[pivot][i]>=M[k][i] , do not update pivot

update_pivot:
    mv t0,t2                    # updating the pivot with k

ignore:    

    addi t2,t2,1                # Increment k
    j loop2                     

end_loop2:

    # Check if Pivot != i

    beq t0, a5, skip_swap       #if pivot==i skip the swapping else

    # Row swapping

    li t2,0                     # j=0

loop3:
    bge t2,a6,end_loop3         # if j>=n, exit the loop3

    # Swap the rows in M matrix

    # Now to access M[i][j] = address of M + ( i*n + j )*4

    mv t3,a5                    # put i into t3   
    mul t3,t3,a6                # i*n
    add t3,t3,t2                # (i*n + j)
    mul t3,t3,a4                # (i*n + j)*4
    add t3,t3,a7                # matrix M address + ( i*n + j )*4
    flw f5,0(t3)                # load value of M[i][j]

    # Now to access M[pivot][j] = address of M + ( pivot*n + j )*4

    mv t4,t0                    # put pivot into t4  
    mul t4,t4,a6                # pivot*n
    add t4,t4,t2                # (pivot*n + j)
    mul t4,t4,a4                # (pivot*n + j)*4
    add t4,t4,a7                # matrix M address + ( pivot*n + j )*4
    flw f1,0(t4)                # load value of M[pivot][j]

    fsw f5,0(t4)                # M[pivot][j]=f0
    fsw f1,0(t3)                # M[i][j]=f1


    # Swap the rows in I matrix

    # Now to access I[i][j] = address of I + ( i*n + j )*4

    mv t3,a5                    # put i into t3   
    mul t3,t3,a6                # i*n
    add t3,t3,t2                # (i*n + j)
    mul t3,t3,a4                # (i*n + j)*4
    add t3,t3,a3                # matrix I address + ( i*n + j )*4
    flw f5,0(t3)                # load value of I[i][j]

    # Now to access I[pivot][j] = address of I + ( pivot*n + j )*4

    mv t4,t0                    # put pivot into t4  
    mul t4,t4,a6                # pivot*n
    add t4,t4,t2                # (pivot*n + j)
    mul t4,t4,a4                # (pivot*n + j)*4
    add t4,t4,a3                # matrix I address + ( pivot*n + j )*4
    flw f1,0(t4)                # load value of I[pivot][j]

    fsw f5,0(t4)                # I[pivot][j]=f0
    fsw f1,0(t3)                # I[i][j]=f1

    addi t2,t2,1                # j++
    j loop3

end_loop3:

    skip_swap:


    mv t3,a5                    # t3=i
    mul t3,t3,a6                # i*n
    add t3,t3,a5                # ( i*n + i )
    mul t3,t3,a4                # ( i*n + i)*4
    add t3,t3,a7                # M address + ( i*n + i )*4
    flw f0,0(t3)                # load M[i][i] into f0(temp)

    fabs.s f8,f0                #load absolute value of temp into temporary float register
    

    flt.s s7,f8,f31             # compare M[i][i]< 1e-5 
    beqz s7, not_singular_matrix    #if s7=0 then jump 

    li a0,4
    la a1,msg2 
    ecall 
    li a0,0
    ret

    not_singular_matrix:

    li t3,0                     # l=0

loop4:

    bge t3,a6,end_loop4         # if l>=n, exit the loop4

    mv t2,a5                    # put i into t3   
    mul t2,t2,a6                # i*n
    add t2,t2,t3                # (i*n + j)
    mul t2,t2,a4                # (i*n + j)*4
    add t2,t2,a7                # matrix M address + ( i*n + j )*4
    flw f1,0(t2)                # load value of M[i][j]

    fdiv.s f1,f1,f0             # M[i][j] = M[i][j]/temp(f0)

    fsw f1,0(t2)                # store back the value

    mv t2,a5                    # put i into t3   
    mul t2,t2,a6                # i*n
    add t2,t2,t3                # (i*n + j)
    mul t2,t2,a4                # (i*n + j)*4
    add t2,t2,a3                # matrix I address + ( i*n + j )*4
    flw f2,0(t2)                # load value of I[i][j]

    fdiv.s f2,f2,f0             # I[i][j]=I[i][j]/temp(f0)
    fsw f2,0(t2)                # store back the value

    addi t3,t3,1 
    j loop4 

end_loop4:

    li t2,0                     # l=0

loop5:

    bge t2,a6,end_loop5         # if l>=n, exit the loop5

    beq t2, a5, skip_this_i     # skip if l==i 

    mv t6,t2                    # put l into temp   
    mul t6,t6,a6                # l*n
    add t6,t6,a5                # (l*n + i)
    mul t6,t6,a4                # (l*n + i)*4
    add t6,t6,a7                # matrix M address + ( l*n + i )*4
    flw f5,0(t6)                # load value of M[l][i] into f0(temp) 

    li s1,0                     # k=0 

loop6:

    bge s1,a6,end_loop6 

    # Normalize rowa in M

    mv s2,a5                    # i into s2               
    mul s2,s2,a6                # i*n
    add s2,s2,s1                # ( i*n + k )
    mul s2,s2,a4                # 4*( i*n + k )
    add s2,s2,a7                # M address + 4*( i*n + k )
    flw f2,0(s2)                # M[i][k]

    mv s2,t2                    # l into s2               
    mul s2,s2,a6                # l*n
    add s2,s2,s1                # ( l*n + k )
    mul s2,s2,a4                # 4*( l*n + k )
    add s2,s2,a7                # M address + 4*( l*n + k )
    flw f1,0(s2)                # M[l][k]

    fmul.s f2,f2,f5             # M[i][k] = M[i][k]*f0(temp) 
    fsub.s f1, f1,f2            # M[l][k] = M[l][k] - M[i][k]
    fsw  f1, 0(s2)              # store back the value 

    # Normalize rows in I 

    mv s2,a5                    # i into s2               
    mul s2,s2,a6                # i*n
    add s2,s2,s1                # ( i*n + k )
    mul s2,s2,a4                # 4*( i*n + k )
    add s2,s2,a3                # I address + 4*( i*n + k )
    flw f2,0(s2)                # I[i][k]

    mv s2,t2                    # l into s2               
    mul s2,s2,a6                # l*n
    add s2,s2,s1                # ( l*n + k )
    mul s2,s2,a4                # 4*( l*n + k )
    add s2,s2,a3                # I address + 4*( l*n + k )
    flw f1,0(s2)                # I[l][k]

    fmul.s f2,f2,f5             # I[i][k] = I[i][k]*f0(temp) 
    fsub.s f1, f1,f2            # I[l][k] = I[l][k] - I[i][k]
    fsw  f1, 0(s2)              # store back the value

    addi s1,s1,1                # k++ 
    j loop6 

end_loop6: 
 
skip_this_i:

    addi t2,t2,1                # l++ 
    j loop5 

end_loop5: 


    addi a5, a5, 1              # i++ 
    j loop1                     # Jump back to the start of the loop1 

end_loop1:




    li a0,4
    la a1,msg6 
    ecall

    li a0,4
    la a1,msg1 
    ecall 

    li a0,4
    la a1,msg1 
    ecall

############################################ Printing the respective Inverse stored in I #############################################
######################################################################################################################################

    li s7,0                     # i=0

loop7:

    bge s7,a6,end_loop7         

    li s8,0                     # j=0
loop8:

    bge s8,a6,end_loop8

    mv t3,s7                    # put i into t3   
    mul t3,t3,a6                # i*n
    add t3,t3,s8                # (i*n + j)
    mul t3,t3,a4                # (i*n + j)*8
    add t3,t3,a3                # matrix M address + ( i*n + j )*8
    flw f5,0(t3)                # load value of M[i][j]

    flt.s s0,f5,f30             # check if M[i][j] is neagtive 
 
    beqz s0,skip_minusprint     # skip check task 

    li a0,4
    la a1,msg5                  # printing minus sign if number is negative 
    ecall 

    skip_minusprint:

    fabs.s f2,f5                # move value of M[i][j] in one more temp register
    fmv.s f4,f2                 # move value of M[i][j] in temp register
    fmul.s f4,f4,f29            # multiply the m[i][j] by 10000

    fcvt.w.s t2,f4              # put integer value of f4 into int reg
    fcvt.s.w f4,t2              # put rounded off value into the f4 again 

    fdiv.s f4,f4,f29            # divide the M[i][j] by 10000 
    fmv.s f2,f4                 # move that value into the f2 register too 

    fcvt.w.s t2,f4              # put integer value of f4 into int reg
    fcvt.s.w f1,t2              # put t2 value into f1 reg 

    fsub.s f4,f4,f1             # subtract value of reg which we stored in int reg so that we can put some check for round offs 

    flt.s s0,f4,f30             # check if subtracted value less than 0.0 

    beqz s0, skip_adjust        # check if s0 is zero 

    addi t2,t2,-1               #add -1 to t2 so that actual value comes into t2 before round off 

    skip_adjust:
    # print the part before the decimal point 

    li a0,1                     # system call for int print    
    mv a1,t2                    # move value of integer for printing
    ecall                       # call for print 

    # print the decimal point 

    li a0,4
    la a1,msg3 
    ecall 

    fcvt.s.w f1,t2             # put integer value of t2 into a float register 
    fsub.s f2,f2,f1            # subtract the part before decimal from the whole value

    # loop for printing digits after decimal

    li s1,0                    # k=0

loop9: 

    bge s1,a4,end_loop9         

    fadd.s f2,f2,f24           # add some value at 5th place after decimal dot to maintain precision for 4th digit after decimal point
    fmul.s f2,f2,f26            # multiply by 10 to shift the decimal point

    fmv.s f4,f2                 # move value of f2 in temp register
    fcvt.w.s t2,f4              # put integer value of f4 into int reg
    fcvt.s.w f1,t2              # put t2 value into f1 reg 

    fmul.s f1,f1,f29            # multiply value by 10000
    fmul.s f4,f4,f29            # multiply value by 10000

    fsub.s f4,f4,f1             # subtract f1 from f4
    fdiv.s f4,f4,f29            # divide by 10000

    flt.s s0,f4,f30             # check if subtracted value less than 0.0 , it means value has been changed after storing in int 

    beqz s0, skip_sub           # check if s0 is zero 

    addi t2,t2,-1               #add -1 to t2 so that actual value comes into t2 

    skip_sub: 

    li a0,1                     # system call for int print    
    mv a1,t2                    # move value of integer for printing
    ecall                       # call for print 

    fcvt.s.w f1,t2              # put integer value of t2 into a float register

    fmul.s f1,f1,f29            # multiply f1 by 10000   
    fmul.s f2,f2,f29            # multiply f2 by 10000

    fsub.s f2,f2,f1             # subtract f1 from f2 so that left result can go under printing processing 
    fdiv.s f2,f2,f29            # divide by 10000 to bring back into original form 

    addi s1,s1,1                # k++ 
    j loop9 

end_loop9:

    li a0,4
    la a1,msg4                  # print space 
    ecall

    addi s8,s8,1                # j++ 
    j loop8

end_loop8:


    li a0,4
    la a1,msg1                  # print new line 
    ecall 

    li a0,4
    la a1,msg1                  # print new line 
    ecall 

    addi s7,s7,1                # i++ 
    j loop7 

end_loop7:

    


    ####################################################### Verification matrix task###################################################
    ################################################################################################################################### 

    li a5,0                    # i=0 

loopv1:
    bge a5,a6,end_loopv1

    li a2,0                    # j=0

loopv2: 
    bge a2,a6,end_loopv2 

    li s11,0                   # k=0 

loopv3: 
    bge s11,a6,end_loopv3

    mv t3,a5                    # put i into t3   
    mul t3,t3,a6                # i*n
    add t3,t3,s11               # (i*n + k)
    mul t3,t3,a4                # (i*n + k)*4
    add t3,t3,s5                # matrix M1 address + ( i*n + k )*4
    flw f5,0(t3)                # load value of M1[i][k]


    mv t3,s11                   # put k into t3   
    mul t3,t3,a6                # k*n
    add t3,t3,a2                # (k*n + j)
    mul t3,t3,a4                # (i*n + j)*4
    add t3,t3,a3                # matrix M1 address + ( k*n + j )*4
    flw f6,0(t3)                # load value of I[k][j]


    mv t3,a5                    # put i into t3   
    mul t3,t3,a6                # i*n
    add t3,t3,a2                # (i*n + j)
    mul t3,t3,a4                # (i*n + j)*4
    add t3,t3,s6                # matrix V address + ( i*n + j )*4
    flw f4,0(t3)                # load value of V[i][j]


    fmul.s f5,f5,f6             # multiply both values 
    fadd.s f4,f4,f5             # add f4 and f5 

    fsw  f4,0(t3)               # store the result into the verification matrix 


    addi s11,s11,1              # k++
    j loopv3

end_loopv3:

    addi a2,a2,1                # j++ 
    j loopv2 

end_loopv2: 

    addi a5,a5,1                # i++ 
    j loopv1 

end_loopv1: 

    li a0,4
    la a1,msg7 
    ecall

    li a0,4
    la a1,msg1 
    ecall

    li a0,4
    la a1,msg1 
    ecall

    

    ############################################ Print the verification matrix V ###################################################
    ################################################################################################################################# 

    li s7,0                     # i=0

loop10:

    bge s7,a6,end_loop10

    li s8,0                     # j=0 
loop11:

    bge s8,a6,end_loop11

    mv t3,s7                    # put i into t3   
    mul t3,t3,a6                # i*n
    add t3,t3,s8                # (i*n + j)
    mul t3,t3,a4                # (i*n + j)*4
    add t3,t3,s6                # matrix V address + ( i*n + j )*4
    flw f6,0(t3)                # load value of V[i][j]

    fcvt.w.s t2,f6 

    beq t2,t1,print_one 

    flt.s s4,f6,f31               # compare M[i][i]< 1e-5 
    beq s4,t1, print_zero         #if s7=0 then jump 

print_one:

    li a0,1
    mv a1,t2
    ecall 

    li a0,4
    la a1,msg8 
    ecall

    li a0,4
    la a1,msg4 
    ecall 

    j increase 

print_zero:

    li a0,1
    mv a1,t2
    ecall 

    li a0,4
    la a1,msg8 
    ecall

    li a0,4
    la a1,msg4 
    ecall 

    j increase


increase:

    addi s8,s8,1
    j loop11

end_loop11:


    li a0,4
    la a1,msg1 
    ecall 

    li a0,4
    la a1,msg1 
    ecall 

    addi s7,s7,1
    j loop10  

end_loop10:

     li a0,0




















 