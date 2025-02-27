	.file	"simple_cnn.c"
	.text
	.globl	relu
	.type	relu, @function
relu:
.LFB0:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -4(%rbp)
	movl	-4(%rbp), %eax
	movl	$0, %edx
	testl	%eax, %eax
	cmovs	%edx, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	relu, .-relu
	.section	.rodata
.LC0:
	.string	"%u, "
	.text
	.globl	convolution_max_pool
	.type	convolution_max_pool, @function
convolution_max_pool:
.LFB1:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$2384, %rsp
	movq	%rdi, -2360(%rbp)
	movq	%rsi, -2368(%rbp)
	movq	%rdx, -2376(%rbp)
	movq	%rcx, -2384(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$0, -2344(%rbp)
	jmp	.L4
.L13:
	leaq	-2320(%rbp), %rdx
	movl	$0, %eax
	movl	$288, %ecx
	movq	%rdx, %rdi
	rep stosq
	movl	$0, -2340(%rbp)
	jmp	.L5
.L12:
	movl	$0, -2336(%rbp)
	jmp	.L6
.L11:
	movl	$0, -2332(%rbp)
	movl	$0, -2328(%rbp)
	jmp	.L7
.L10:
	movl	$0, -2324(%rbp)
	jmp	.L8
.L9:
	movl	-2340(%rbp), %edx
	movl	-2328(%rbp), %eax
	addl	%edx, %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$3, %rax
	subq	%rdx, %rax
	salq	$2, %rax
	movq	%rax, %rdx
	movq	-2360(%rbp), %rax
	addq	%rax, %rdx
	movl	-2336(%rbp), %ecx
	movl	-2324(%rbp), %eax
	addl	%ecx, %eax
	cltq
	movzbl	(%rdx,%rax), %eax
	movzbl	%al, %ecx
	movl	-2344(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	leaq	0(,%rax,4), %rdx
	addq	%rax, %rdx
	movq	-2368(%rbp), %rax
	leaq	(%rdx,%rax), %rdi
	movl	-2324(%rbp), %eax
	movslq	%eax, %rsi
	movl	-2328(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$2, %rax
	addq	%rdx, %rax
	addq	%rdi, %rax
	addq	%rsi, %rax
	movzbl	(%rax), %eax
	movsbl	%al, %eax
	imull	%ecx, %eax
	addl	%eax, -2332(%rbp)
	movl	-2340(%rbp), %edx
	movl	-2328(%rbp), %eax
	addl	%edx, %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$3, %rax
	subq	%rdx, %rax
	salq	$2, %rax
	movq	%rax, %rdx
	movq	-2360(%rbp), %rax
	addq	%rax, %rdx
	movl	-2336(%rbp), %ecx
	movl	-2324(%rbp), %eax
	addl	%ecx, %eax
	cltq
	movzbl	(%rdx,%rax), %eax
	movzbl	%al, %eax
	movl	%eax, %esi
	leaq	.LC0(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	addl	$1, -2324(%rbp)
.L8:
	cmpl	$4, -2324(%rbp)
	jle	.L9
	addl	$1, -2328(%rbp)
.L7:
	cmpl	$4, -2328(%rbp)
	jle	.L10
	movl	-2344(%rbp), %eax
	movslq	%eax, %rdx
	movq	-2376(%rbp), %rax
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	movsbl	%al, %edx
	movl	-2332(%rbp), %eax
	addl	%edx, %eax
	movl	%eax, %edi
	call	relu
	movl	%eax, %edx
	movl	-2336(%rbp), %eax
	movslq	%eax, %rsi
	movl	-2340(%rbp), %eax
	movslq	%eax, %rcx
	movq	%rcx, %rax
	addq	%rax, %rax
	addq	%rcx, %rax
	salq	$3, %rax
	addq	%rsi, %rax
	movl	%edx, -2320(%rbp,%rax,4)
	addl	$1, -2336(%rbp)
.L6:
	cmpl	$23, -2336(%rbp)
	jle	.L11
	addl	$1, -2340(%rbp)
.L5:
	cmpl	$23, -2340(%rbp)
	jle	.L12
	movq	-2384(%rbp), %rdx
	leaq	-2320(%rbp), %rcx
	movl	-2344(%rbp), %eax
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	max_pool
	addl	$1, -2344(%rbp)
.L4:
	cmpl	$5, -2344(%rbp)
	jle	.L13
	nop
	movq	-8(%rbp), %rax
	subq	%fs:40, %rax
	je	.L14
	call	__stack_chk_fail@PLT
.L14:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	convolution_max_pool, .-convolution_max_pool
	.globl	max_pool
	.type	max_pool, @function
max_pool:
.LFB2:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -36(%rbp)
	movq	%rsi, -48(%rbp)
	movq	%rdx, -56(%rbp)
	movl	$0, -28(%rbp)
	jmp	.L16
.L23:
	movl	$0, -24(%rbp)
	jmp	.L17
.L22:
	movl	$0, -20(%rbp)
	movl	$0, -16(%rbp)
	jmp	.L18
.L21:
	movl	$0, -12(%rbp)
	jmp	.L19
.L20:
	movl	-28(%rbp), %eax
	leal	(%rax,%rax), %edx
	movl	-16(%rbp), %eax
	addl	%edx, %eax
	movl	%eax, -8(%rbp)
	movl	-24(%rbp), %eax
	leal	(%rax,%rax), %edx
	movl	-12(%rbp), %eax
	addl	%edx, %eax
	movl	%eax, -4(%rbp)
	movl	-8(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$5, %rax
	movq	%rax, %rdx
	movq	-48(%rbp), %rax
	addq	%rax, %rdx
	movl	-4(%rbp), %eax
	cltq
	movl	(%rdx,%rax,4), %eax
	movl	-20(%rbp), %edx
	cmpl	%eax, %edx
	cmovge	%edx, %eax
	movl	%eax, -20(%rbp)
	addl	$1, -12(%rbp)
.L19:
	cmpl	$1, -12(%rbp)
	jle	.L20
	addl	$1, -16(%rbp)
.L18:
	cmpl	$1, -16(%rbp)
	jle	.L21
	movl	-36(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	salq	$3, %rax
	addq	%rdx, %rax
	salq	$6, %rax
	movq	%rax, %rdx
	movq	-56(%rbp), %rax
	leaq	(%rdx,%rax), %rcx
	movl	-24(%rbp), %eax
	movslq	%eax, %rsi
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$2, %rax
	leaq	(%rax,%rsi), %rdx
	movl	-20(%rbp), %eax
	movl	%eax, (%rcx,%rdx,4)
	addl	$1, -24(%rbp)
.L17:
	cmpl	$11, -24(%rbp)
	jle	.L22
	addl	$1, -28(%rbp)
.L16:
	cmpl	$11, -28(%rbp)
	jle	.L23
	nop
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	max_pool, .-max_pool
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
