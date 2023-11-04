.section .data
    topoInicialHeap:   .quad 0
    aposAlteracao:     .quad 0
    resetaHeap:        .quad 0 
    formatString:      .string "Valor da brk: %p\n"
    formatStringInit:  .string "Iniciando printf...\n"
    formatNumber:       .string "Number: %d\n"
.section .text
    .global sum
    .global sum_2
    .global iniciaAlocador
    .global finalizaAlocador
    .global alocaMem
    .global topoInicialHeap
    .global aposAlteracao
    .global resetaHeap

iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    # Preparando a pilha para a chamada do printf
    subq $8, %rbp

    # Chama printf para exibir uma mensagem
    leaq formatStringInit(%rip), %rdi
    call printf

    # Restaurando a pilha
    addq $8, %rbp

    # Pega o valor inicial do brk vide tabela presente no livro
    movq $12, %rax
    movq $0, %rdi
    syscall

    # Armazena o valor obtido na variavel global topoIniciaHeap
    # O (%rip) eh util por conta do enderecamento relativo
    movq %rax, topoInicialHeap(%rip)

    popq %rbp
    ret

finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    # Pega o valor atual
    # movq $12, %rax
    # movq $0, %rdi
    # syscall

    # Soma 2048 ao valor atual e chama o syscall pra atualizar a brk
    # movq %rax, %rdi
    # movq $12, %rax
    # addq $2048, %rdi
    # syscall

    # Armazena o novo valor da brk na variavel global aposAlteracao
    # movq %rax, aposAlteracao(%rip)

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

    # Aloca 20bytes e retorna o endereco inicial no rax
    # movq $20, %rdi
    call malloc

    # Preparando a pilha para a chamada do printf
    subq $8, %rbp

    # Chama printf para exibir uma mensagem
    leaq formatString(%rip), %rdi
    movq %rax, %rsi
    call printf

    # Restaurando a pilha
    addq $8, %rbp

    popq %rbp
    ret

sum:
    pushq %rbp
    movq %rsp, %rbp
    movq %rdi, %rax
    movq %rsi, %rbx
    addq %rbx, %rax
    popq %rbp
    ret

sum_2:
    pushq %rbp
    movq %rsp, %rbp
    movq %rdi, %rax
    addq $2, %rax
    popq %rbp
    ret
