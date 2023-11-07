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
    .global alocaMem
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

alocaMem:
    pushq %rbp
    movq %rsp, %rbp

    # Salva o rdi, ou seja, a quantidade de bytes a ser alocada
    movq %rdi, -8(%rbp)

    # Move o endereço do topo inicial da heap pro rax
    movq topoInicialHeap(%rip), %rax

    # Compara 0 com o valor do primeiro elemento da heap
buscaEspaco:
    # Check if the element pointed by rax is free (=0)
    cmpq $0, 0(%rax)
    je achouEspaco
    # If it is not free, go to the next element
    movq 8(%rax), %rbx
    addq %rbx, %rax
    jmp buscaEspaco
achouEspaco:
    leaq formatStringCont(%rip), %rdi
    call printf
    
    movq -8(%rbp), %rdi
    movq topoInicialHeap(%rip), %rax
    cmpq 8(%rax), %rdi
    je fim_

    movq topoInicialHeap(%rip), %rdi
    addq $1024, %rdi
    movq $12, %rax
    syscall

    movq -8(%rbp), %rdi

    movq topoInicialHeap(%rip), %rax
    movq %rdi, 0(%rax)
    movq $1, 8(%rax)

    # Preparando a pilha para a chamada do printf
    subq $8, %rbp

    # Chama printf para exibir uma mensagem
    # O (%rip) eh util por conta do enderecamento relativo
    leaq formatString(%rip), %rdi
    movq %rax, %rsi
    call printf

    # Restaurando a pilha
    addq $8, %rbp

    movq topoInicialHeap(%rip), %rax

    # Preparando a pilha para a chamada do printf
    subq $8, %rbp

    # Chama printf para exibir uma mensagem
    # O (%rip) eh util por conta do enderecamento relativo
    leaq formatNumber(%rip), %rdi
    movq (%rax), %rsi
    call printf

    # Restaurando a pilha
    addq $8, %rbp

    movq topoInicialHeap(%rip), %rax

    # Preparando a pilha para a chamada do printf
    subq $8, %rbp

    # Chama printf para exibir uma mensagem
    # O (%rip) eh util por conta do enderecamento relativo
    leaq formatNumber(%rip), %rdi
    movq 8(%rax), %rsi
    call printf

    # Restaurando a pilha
    addq $8, %rbp

    movq topoInicialHeap(%rip), %rax
    addq $16, %rax

    popq %rbp
    ret

fim_:
    # Preparando a pilha para a chamada do printf
    subq $8, %rbp

    movq %rdi, %rax

    # Chama printf para exibir uma mensagem
    # O (%rip) eh util por conta do enderecamento relativo
    leaq formatNumber(%rip), %rdi
    movq (%rax), %rsi
    call printf

    # Restaurando a pilha
    addq $8, %rbp

    popq %rbp
    ret
