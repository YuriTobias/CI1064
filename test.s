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

    // Memory allocation function with brk redimensioning and 

alocaMem:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rbp

    # Variáveis locais:
    # -8(%rbp) = %rdi = quantidade de bytes a ser alocada
    # -16(%rbp) = %rax = endereço do bloco atual (inicialmente topoInicialHeap)
    # -24(%rbp) = 0(%rax) = situação do bloco atual (0 = livre, 1 = ocupado)
    # -32(%rbp) = 8(%rax) = tamanho do bloco atual
    movq %rdi, -8(%rbp)    
    movq topoInicialHeap(%rip), %rax
    movq %rax, -16(%rbp)
    movq 0(%rax), %rbx
    movq %rbx, -24(%rbp)
    movq 8(%rax), %rbx
    movq %rbx, -32(%rbp)
buscaEspaco:
    cmpq $0, -24(%rbp)
    jne buscaProximo # Caso bloco ocupado
    movq -8(%rbp), %rax
    addq $16, %rax
    cmpq %rax, -32(%rbp)
    jge achouEspaco # Caso bloco livre com tamanho suficiente
buscaProximo:
    movq -16(%rbp), %rbx
    addq $16, %rbx
    addq -32(%rbp), %rbx
    call getBrk
    cmpq %rax, %rbx
    jge extendeHeap # Caso próximo bloco inexistente
    movq %rbx, -16(%rbp)
    movq 0(%rbx), %rax
    movq %rax, -24(%rbp)
    movq 8(%rbx), %rax
    movq %rax, -32(%rbp)
    jmp buscaEspaco # Caso próximo bloco existente
extendeHeap:
    call getBrk
    addq $1024, %rax
    movq %rax, %rdi
    movq $12, %rax
    syscall
    cmpq $0, -24(%rbp)
    je funde # Caso último bloco ocupado
    movq -16(%rbp), %rax
    addq $16, %rax
    addq -32(%rbp), %rax
    movq %rax, -16(%rbp)
    movq $0, -24(%rbp)
    movq $1024, -32(%rbp)
    jmp achouEspaco
funde:
    movq -16(%rbp), %rax
    addq $1024, 8(%rax)
    movq %rax, -32(%rbp)
achouEspaco:
    # Recupera o valor do parametro
    movq -8(%rbp), %rax # tamanho
    movq -16(%rbp), %rbx # bloco atual
    movq -32(%rbp), %rcx # tamanho do bloco atual
    # Atualiza metadados
    movq $1, 0(%rbx)
    movq %rax, 8(%rbx)
    # Calcula espaco livre do proximo bloco
    movq %rax, %rdx
    addq $16, %rdx
    subq %rdx, %rcx
    # Get do endereco inicial do proximo bloco
    addq %rbx, %rdx
    # Atualiza os metadados do proximo bloco
    movq $0, 0(%rdx)
    movq %rcx, 8(%rdx)
    # Retorna o endereco bloco alocado
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
