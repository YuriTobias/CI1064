.section .data
    topoInicialHeap:        .quad 0
    resetaHeap:             .quad 0
    formatString:           .string "Valor da brk: %p\n"
    formatStringInit:       .string "Iniciando printf...\n"
    formatStringUltimo:     .string "Foi buscar o ultimo...\n"
    formatStringCont:       .string "Continua pra comparar o tamanho...\n"
    formatMallocError:      .string "Erro de alocacao de memoria (malloc)\n"
    formatNumber:           .string "Number: %d\n"

.section .text
    .global iniciaAlocador
    .global finalizaAlocador
    .global allocMem
    .global topoInicialHeap
    .global resetaHeap

# Obtem o valor atual da brk
getBrk:
    pushq %rbp
    movq %rsp, %rbp

    # Pega o valor atual do brk vide tabela presente no livro
    movq $12, %rax
    movq $0, %rdi
    syscall

    popq %rbp
    ret

iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    # Chama printf para exibir uma mensagem
    # O (%rip) eh util por conta do enderecamento relativo
    leaq formatStringInit(%rip), %rdi
    call printf

    # Obtem o valor inicial da brk apos a chamada do printf
    call getBrk

    # Armazena o valor obtido na variavel global topoIniciaHeap
    movq %rax, topoInicialHeap(%rip)

    # Incrementa o valor da brk em 1040, ou seja,
    # 8 bytes que dizem se o bloco ta livre ou nao
    # 8 bytes que salvam o tamanho do bloco
    # 1024 bytes do tamanho do bloco
    movq %rax, %rdi
    addq $1040, %rdi
    movq $12, %rax
    syscall

    # Iniciando os valores
    movq topoInicialHeap(%rip), %rax
    movq $0, 0(%rax)
    movq $1024, 8(%rax)

    popq %rbp
    ret

finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    # Reseta o valor da brk pro seu valor inicial
    movq $12, %rax
    movq topoInicialHeap(%rip), %rdi
    syscall

    # Armazena o novo valor da brk na variavel global resetaHeap
    movq %rax, resetaHeap(%rip)

    popq %rbp
    ret

    // Memory allocation function with brk redimensioning and 

allocMem:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rbp
    /*
        Local variables:
        -8(%rbp) = bytes to be allocated
        -16(%rbp) = current block address
        -24(%rbp) = current block status (0 = free, 1 = occupied)
        -32(%rbp) = current block size
    */
    movq %rdi, -8(%rbp)    
    movq topoInicialHeap(%rip), %rax
    movq %rax, -16(%rbp)
    movq 0(%rax), %rbx
    movq %rbx, -24(%rbp)
    movq 8(%rax), %rbx
    movq %rbx, -32(%rbp)
searchFreeBlock:
    // Check if current block is free
    cmpq $0, -24(%rbp)
    jne findNextBlock
    // Check if current block has enough space
    movq -8(%rbp), %rax
    addq $16, %rax
    cmpq %rax, -32(%rbp)
    jge reserveBlock
findNextBlock:
    // Find the next block
    movq -16(%rbp), %rbx
    addq $16, %rbx
    addq -32(%rbp), %rbx
    // Check if the next block exists
    call getBrk
    cmpq %rax, %rbx
    jge resizeHeap
    // Update current block to the next one
    movq %rbx, -16(%rbp)
    movq 0(%rbx), %rax
    movq %rax, -24(%rbp)
    movq 8(%rbx), %rax
    movq %rax, -32(%rbp)
    jmp searchFreeBlock
resizeHeap:
    // Resize the heap adding 1024 bytes to the brk
    call getBrk
    addq $1024, %rax
    movq %rax, %rdi
    movq $12, %rax
    syscall
    cmpq $0, -24(%rbp)
    je mergeBlocks
    // Create a new block in the resized heap right after the current one
    movq -16(%rbp), %rax
    addq $16, %rax
    addq -32(%rbp), %rax
    movq %rax, -16(%rbp)
    movq $0, -24(%rbp)
    movq $1024, -32(%rbp)
    jmp reserveBlock
mergeBlocks:
    // Update the current block size the resized heap 1024 bytes
    movq -16(%rbp), %rax
    addq $1024, 8(%rax)
    movq %rax, -32(%rbp)
reserveBlock:
    movq -8(%rbp), %rax
    movq -16(%rbp), %rbx
    movq -32(%rbp), %rcx
    // Reserve space on the current block
    movq $1, 0(%rbx)
    movq %rax, 8(%rbx)
    // Calculate the space occupied by the reserved block
    movq %rax, %rdx
    addq $16, %rdx
    // Calculate the size of the remaining block
    subq %rdx, %rcx
    // Find and create the remaining block
    addq %rbx, %rdx
    movq $0, 0(%rdx)
    movq %rcx, 8(%rdx)
    // Return the address of data of the reserved block
    addq $16, %rbx
    movq %rbx, %rax
    addq $32, %rbp
    popq %rbp
    ret

fim_:
    # Preparando a pilha para a chamada do printf
    subq $8, %rbp

    leaq formatStringUltimo(%rip), %rdi
    call printf

    # Restaurando a pilha
    addq $8, %rbp

    popq %rbp
    ret
