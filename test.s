.section .data
    topoInicialHeap:        .quad 0
    resetaHeap:             .quad 0
    formatString:           .string "Valor da brk: %p\n"
    formatStringInit:       .string "Iniciando printf...\n"
    formatMallocError:      .string "Erro de alocacao de memoria (malloc)\n"
    formatNumber:           .string "Number: %d\n"

.section .text
    .global iniciaAlocador
    .global finalizaAlocador
    .global alocaMem
    .global topoInicialHeap
    .global resetaHeap

iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    # Preparando a pilha para a chamada do printf
    subq $8, %rbp

    # Chama printf para exibir uma mensagem
    # O (%rip) eh util por conta do enderecamento relativo
    leaq formatStringInit(%rip), %rdi
    call printf

    # Restaurando a pilha
    addq $8, %rbp

    # Pega o valor inicial do brk vide tabela presente no livro
    movq $12, %rax
    movq $0, %rdi
    syscall

    # Armazena o valor obtido na variavel global topoIniciaHeap
    movq %rax, topoInicialHeap(%rip)

    movq %rax, %rdi
    addq $1040, %rdi
    movq $12, %rax
    syscall

    movq topoInicialHeap(%rip), %rax
    movq $1024, 0(%rax)
    movq $0, 8(%rax)

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

    # Move o endereço do topo da heap pro rdi
    movq topoInicialHeap(%rip), %rdi
    jmp buscaUltimo_
    
    # cmpq $1024, (%rax)
    # je fim_

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

buscaUltimo_:
    cmpq $1024, 0(%rdi)
    je fim_

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
