.section .data
    topoInicialHeap:        .quad 0
    resetaHeap:             .quad 0
    formatString:           .string "Valor da brk: %p\n"
    formatStringInit:       .string "Iniciando printf...\n"
    formatStringUltimo:     .string "Foi buscar o ultimo...\n"
    formatStringCont:       .string "Continua pra comparar o tamanho...\n"
    formatMallocError:      .string "Erro de alocacao de memoria (malloc)\n"
    formatNumber:           .string "Number: %d\n"
    formatAddress:          .string "Block address: %p\n"
    formatStatus:           .string "      status: %d\n"
    formatSize:             .string "      size: %d\n"
    formatChar:             .string "%c"

.section .text
    .global iniciaAlocador
    .global finalizaAlocador
    .global allocMem
    .global liberaMem
    .global topoInicialHeap
    .global resetaHeap
    .global printMem
    .global printMemChars

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
    subq $32, %rsp
    /*
        Local variables:
        -8(%rbp) = bytes to be allocated
        -16(%rbp) = current block address
        -24(%rbp) = current block status (0 = free, 1 = occupied)
        -32(%rbp) = current block size
    */
    movq %rdi, -8(%rbp)    
    movq topoInicialHeap(%rip), %r10
    movq %r10, -16(%rbp)
    movq 0(%r10), %rbx
    movq %rbx, -24(%rbp)
    movq 8(%r10), %rbx
    movq %rbx, -32(%rbp)
searchFreeBlock:
    // Check if current block is free
    cmpq $0, -24(%rbp)
    jne findNextBlock
    // Check if current block has enough space
    movq -8(%rbp), %r10
    addq $16, %r10
    cmpq %r10, -32(%rbp)
    jge reserveBlock
findNextBlock:
    // Find the next block
    movq -16(%rbp), %r10
    addq $16, %r10
    addq -32(%rbp), %r10
    // Check if the next block exists
    call getBrk
    cmpq %rax, %r10
    jge resizeHeap
    // Update current block to the next one
    movq %r10, -16(%rbp)
    movq 0(%r10), %r11
    movq %r11, -24(%rbp)
    movq 8(%r10), %r11
    movq %r11, -32(%rbp)
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
    movq %r10, -16(%rbp)
    movq $0, -24(%rbp)
    movq $1024, -32(%rbp)
    jmp reserveBlock
mergeBlocks:
    // Update the current block size the resized heap 1024 bytes
    movq -16(%rbp), %r10
    addq $1024, 8(%r10)
    movq 8(%r10), %r11
    movq %r11, -32(%rbp)
reserveBlock:
    movq -8(%rbp), %rbx
    movq -16(%rbp), %r10
    movq -32(%rbp), %r11
    // Reserve space on the current block
    movq $1, 0(%r10)
    movq %rbx, 8(%r10)
    // Calculate the space occupied by the reserved block
    movq %rbx, %rdx
    addq $16, %rdx
    // Calculate the size of the remaining block
    subq %rdx, %r11
    // Find and create the remaining block
    addq %r10, %rdx
    movq $0, 0(%rdx)
    movq %r11, 8(%rdx)
    // Return the address of data of the reserved block
    addq $16, %r10
    movq %r10, %rax
    addq $32, %rsp
    popq %rbp
    ret

liberaMem:
    pushq %rbp
    movq %rsp, %rbp
    
    # Reserva espaço para duas variáveis
    subq $16, %rsp

    # Guarda o valor do parâmetro em -8(%rbp)
    movq %rdi, -8(%rbp)

    # rax aponta pro bloco atual/inicial
    movq topoInicialHeap(%rip), %rax
    addq $16, %rax

buscaElem:
    movq %rax, -16(%rbp)
    cmpq -8(%rbp), %rax 
    je liberaBloco
    movq -16(%rbp), %rax

    # Volta o valor do rax pra pegar o tamanho do bloco atual
    subq $16, %rax
    # Incrementa o valor do rax pra cair no próximo endereço e comparar novamente
    addq 8(%rax), %rax
    addq $32, %rax

    jmp buscaElem

liberaBloco:
    # Volta o rax pro endereço de início dos metadados do bloco pra zerar a variável que diz se está livre ou não
    subq $16, %rax
    movq $0, (%rax)

    call chamaFusao

    # Libera o espaço reservado para as variáveis
    addq $16, %rsp
    
    popq %rbp
    ret

chamaFusao:
    pushq %rbp
    movq %rsp, %rbp

    # Reserva espaço para duas variáveis
    subq $16, %rsp

    # rax = início da heap
    # rbx = início da heap
    movq topoInicialHeap(%rip), %rax
    movq %rax, %rbx
    # rax = rax + 16 + tamanho do bloco (aponta pro segundo bloco)
    addq 8(%rax), %rax
    addq $16, %rax
    # Empilha rax e rbx
    movq %rax, -8(%rbp)
    movq %rbx, -16(%rbp)

    # Garante que o rax, por ser o próximo, não estourou a heap
    call getBrk
    cmpq -8(%rbp), %rax
    # Se estourou, ou seja, brk < rax, finaliza fusão
    jl finalizaLibera
    
    # Desempilha rax e rbx
    movq -8(%rbp), %rax
    movq -16(%rbp), %rbx

buscaFusao:
    # Compara se rax, ou seja, "próximo" elemento está livre
    # Se estiver, verifica se o anterior também está
    cmpq $0, (%rax)
    je verificaAnterior

    # Se não, rbx = rax
    # rax = rax + 16 + tamanho do bloco (aponta pro segundo bloco)
    movq %rax, %rbx
    addq 8(%rax), %rax
    addq $16, %rax

    # Empilha rax e rbx e verifica a brk novamente
    movq %rax, -8(%rbp)
    movq %rbx, -16(%rbp)
    call getBrk
    cmpq -8(%rbp), %rax
    jle finalizaLibera

    # Desempilha rax, rbx e continua a execução
    movq -8(%rbp), %rax
    movq -16(%rbp), %rbx

    jmp buscaFusao

verificaAnterior:
    # Compara se rbx, ou seja, elemento atual está livre
    # Se estiver faz a fusão com o próximo
    cmpq $0, (%rbx)
    je fusao

    # Se não, rbx = rax
    # rax = rax + 16 + tamanho do bloco (aponta pro segundo bloco)
    movq %rax, %rbx
    addq 8(%rax), %rax
    addq $16, %rax

    # Empilha rax e rbx e verifica a brk novamente
    movq %rax, -8(%rbp)
    movq %rbx, -16(%rbp)
    call getBrk
    cmpq -8(%rbp), %rax
    jle finalizaLibera

    # Desempilha rax, rbx e continua a execução
    movq -8(%rbp), %rax
    movq -16(%rbp), %rbx

    jmp buscaFusao

fusao:
    # Move o tamanho do bloco de rax pro rdx e soma no tamanho do rbx
    movq 8(%rbx), %rdx
    addq $16, %rdx
    addq 8(%rax), %rdx
    movq %rdx, 8(%rbx)

    # Muda o rax pro próximo
    movq %rbx, %rax
    addq $16, %rax
    addq 8(%rbx), %rax

    # Empilha rax e rbx e verifica a brk novamente
    movq %rax, -8(%rbp)
    movq %rbx, -16(%rbp)
    call getBrk
    cmpq -8(%rbp), %rax
    jle finalizaLibera

    # Desempilha rax, rbx e continua a execução
    movq -8(%rbp), %rax
    movq -16(%rbp), %rbx

    jmp buscaFusao

finalizaLibera:
    # Libera o espaço reservado para as variáveis
    addq $16, %rsp

    popq %rbp
    ret

fim_:
    # Preparando a pilha para a chamada do printf
    pushq %rbp
    movq %rsp, %rbp
    subq $8, %rsp

    leaq formatStringUltimo(%rip), %rdi
    call printf

    # Restaurando a pilha
    addq $8, %rsp

    popq %rbp
    ret

printMem:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp
    /*
    Local variables:
    -8(%rbp) = current block address
    */
    movq topoInicialHeap(%rip), %r10
    movq %r10, -8(%rbp)
printLoop:
    // Print the current block address
    movq -8(%rbp), %r10
    addq $16, %r10
    movq %r10, %rsi
    leaq formatAddress(%rip), %rdi
    call printf
    // Print the current block status
    movq -8(%rbp), %r10
    movq 0(%r10), %r11
    movq %r11, %rsi
    leaq formatStatus(%rip), %rdi
    call printf
    // Print the current block size
    movq -8(%rbp), %r10
    movq 8(%r10), %r11
    movq %r11, %rsi
    leaq formatSize(%rip), %rdi
    call printf
    // Update the current block address
    movq -8(%rbp), %r10
    addq 8(%r10), %r10
    addq $16, %r10
    movq %r10, -8(%rbp)
    // Check if the next block exists
    call getBrk
    cmpq %rax, %r10
    jl printLoop
    addq $16, %rsp
    popq %rbp
    ret

printMemChars:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp
    /*
    Local variables:
    -8(%rbp) = current block address
    -16(%rbp) = counter
    -24(%rbp) = char to print
    */
    movq topoInicialHeap(%rip), %r10
    movq %r10, -8(%rbp)
iterateBlocks:
    movq $0, -16(%rbp)
    movq $35, -24(%rbp)
printMetaSection:
    movq -24(%rbp), %rsi
    leaq formatChar(%rip), %rdi
    call printf
    addq $1, -16(%rbp)
    cmpq $16, -16(%rbp)
    jl printMetaSection
    // Print the current block status
    movq -8(%rbp), %r10
    movq 0(%r10), %r11
    movq 8(%r10), %r10
    movq %r10, -16(%rbp)
    cmpq $0, %r11
    je freeBlockChar
reservedBlockChar:
    movq $43, -24(%rbp)
    jmp printDataChar
freeBlockChar:
    movq $45, -24(%rbp)
printDataChar:
    cmpq $0, -16(%rbp)
    jle fimPrintDataChar
    movq -24(%rbp), %rsi
    leaq formatChar(%rip), %rdi
    call printf
    subq $1, -16(%rbp)
    jmp printDataChar
fimPrintDataChar:
    // Update the current block address
    movq -8(%rbp), %r10
    addq 8(%r10), %r10
    addq $16, %r10
    movq %r10, -8(%rbp)
    // Check if the next block exists
    call getBrk
    cmpq %rax, %r10
    jl iterateBlocks
    // Finish function
    addq $32, %rsp
    popq %rbp
    ret
