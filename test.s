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

    subq $16, %rbp

    # Salva o rdi, ou seja, a quantidade de bytes a ser alocada
    movq %rdi, -8(%rbp)

    # Move o endereço do topo inicial da heap pro rax
    movq topoInicialHeap(%rip), %rax
    movq %rax, -16(%rbp)

buscaEspaco:
    # Check if the element pointed by rax is free (=0)
    movq -16(%rbp), %rax
    cmpq $0, 0(%rax)
    jne buscaProximo
    movq %rdi, %rbx
    addq $16, %rbx
    cmpq %rbx, 8(%rax)
    jge achouEspaco

buscaProximo:
    # Encontra próximo bloco (atual+tamanho+16)
    movq 8(%rax), %rbx
    addq $16, %rbx
    addq %rbx, -16(%rbp)
    # Checa se estourou a brk
    call getBrk
    cmpq -16(%rbp), %rax
    # Se não estourou, segue a busca
    jge buscaEspaco
    # Se estourou, aloca mais e já presume que encontrou
    addq $1024, %rax
    movq %rax, %rdi
    movq $12, %rax
    syscall
    movq -16(%rbp), %rax
achouEspaco: 
    # Recupera o valor do parametro
    movq -8(%rbp), %rdi
    
    # Salva tamanho atual
    movq 8(%rax), %rbx

    # Atualiza metadados
    movq $1, (%rax)
    movq %rdi, 8(%rax)

    # Calcula espaco livre do proximo bloco
    subq %rdi, %rbx
    subq $16, %rbx

    # Get do endereco inicial do proximo bloco
    movq %rax, %rdx
    addq $16, %rdx
    addq 8(%rax), %rdx

    # Atualiza os metadados do proximo bloco
    movq $0, (%rdx)
    movq %rbx, 8(%rdx)

    # Retorna o endereco bloco alocado
    addq $16, %rax

    addq $16, %rbp

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
