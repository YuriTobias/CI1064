.section .data
    topoInicialHeap:        .quad 0
    topoFinalHeap:          .quad 0
    formatString:           .string "Brk value: %p\n"
    formatFirstString:      .string "Basic Software academic work... Izalorran Bonaldi & Yuri Tobias\n"
    formatAddress:          .string "Block address: %p\n"
    formatStatus:           .string "      status: %d\n"
    formatSize:             .string "      size: %d\n"
    formatChar:             .string "%c"

.section .text
    .global iniciaAlocador
    .global finalizaAlocador
    .global alocaMem
    .global liberaMem
    .global topoInicialHeap
    .global imprimeMapa

// Gets the current value of brk
getBrk:
    pushq %rbp
    movq %rsp, %rbp

    // Gets the current value of brk according to table 14 of the book
    movq $12, %rax
    movq $0, %rdi
    syscall

    popq %rbp
    ret

// Runs syscall brk to get the address of the current top of the heap and stores it in a global variable, topStartHeap.
iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    // Calls printf to display a message and allocate space in brk
    // (%rip) is useful because of relative addressing
    leaq formatFirstString(%rip), %rdi
    call printf

    // Gets the initial value of brk after calling printf
    call getBrk

    // Stores the value obtained in the global variable topoInicialHeap
    movq %rax, topoInicialHeap(%rip)

    // Increases the value of brk by 1040, that is,
    // 16 bytes of metadata: 8 to know whether the block is free or not; and 8 to know the block size
    // 1024 bytes of free block
    movq %rax, %rdi
    addq $1040, %rdi
    movq $12, %rax
    syscall

    // Initializing the metadata of the first block
    movq topoInicialHeap(%rip), %rax
    movq $0, 0(%rax)
    movq $1024, 8(%rax)

    popq %rbp
    ret

// Executes syscall brk to restore the heap's original value contained in topInicialHeap
finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    // Resets the brk value to its initial value
    movq topoInicialHeap(%rip), %rdi
    movq $12, %rax
    syscall

    // Stores the new value of brk in the global variable topoFinalHeap
    movq %rax, topoFinalHeap(%rip)

    popq %rbp
    ret

// Memory allocation function with brk redimensioning
alocaMem:
    pushq %rbp
    movq %rsp, %rbp
    subq $48, %rsp
    /*
        Local variables:
        -8(%rbp) = bytes to be allocated
        -16(%rbp) = current block address
        -24(%rbp) = current block status (0 = free, 1 = occupied)
        -32(%rbp) = current block size
        -40(%rbp) = biggest block address
        -48(%rbp) = biggest block size
    */
    // Get the bytes to be allocated
    movq %rdi, -8(%rbp)    
    // Get the initial heap address
    movq topoInicialHeap(%rip), %r10
    // Set the current block address as the initial heap address
    movq %r10, -16(%rbp)
    movq %r10, -40(%rbp)
    // Set the current block status as the initial heap status
    movq 0(%r10), %rbx
    movq %rbx, -24(%rbp)
    // Set the current block size as the initial heap size
    movq 8(%r10), %rbx
    movq %rbx, -32(%rbp)
    movq %rbx, -48(%rbp)
searchFreeBlock:
    // Check if current block is free
    cmpq $0, -24(%rbp)
    jne findNextBlock
    // Check if the current block is the biggest one found so far
    movq -48(%rbp), %r10
    cmpq %r10, -32(%rbp)
    jle findNextBlock
    movq -16(%rbp), %r10
    movq %r10, -40(%rbp)
    movq -32(%rbp), %r10
    movq %r10, -48(%rbp)
findNextBlock:
    // Find the next block
    movq -16(%rbp), %r10
    addq $16, %r10
    addq -32(%rbp), %r10
    // Check if the next block exists
    call getBrk
    cmpq %rax, %r10
    // If it exists, update the current block address to the next one and repeat the search
    jl notResizeHeap
    // If the next block doesn't exists, check if the biggest block found so far has enough space
    movq -8(%rbp), %r10
    cmpq -48(%rbp), %r10
    jle reserveBlock
    // If it doesn't, resize the heap adding 1024 bytes to the brk
    jmp resizeHeap
notResizeHeap:
    // Update current block to the next one and repeat the search
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
    // Check if the last block is free
    cmpq $0, -24(%rbp)
    // If it is, merge the last block with the new one, resizing it
    je mergeBlocks
    // Create a new block in the resized heap right after the current one (not resizing the last block)
    movq %r10, -16(%rbp)
    movq $0, -24(%rbp)
    movq $1024, -32(%rbp)
    // Repeat the search to check if the new block has enough space
    jmp searchFreeBlock
mergeBlocks:
    // Update the current block size the resized heap 1024 bytes
    movq -16(%rbp), %r10
    addq $1024, 8(%r10)
    movq 8(%r10), %r11
    movq %r11, -32(%rbp)
    // Repeat the search to check if the new block has enough space
    jmp searchFreeBlock
reserveBlock:
    // Get the bytes to be allocated
    movq -8(%rbp), %r10
    // Get the current block size
    movq -48(%rbp), %r11
    // Check if the current block has enough space to be split
    subq %r10, %r11
    cmpq $16, %r11
    // If it has, split the block creating a new block with the second part
    jge allocNext
checkNext:
    // If it doesn't, check if the next block exists to avoid subscribing it
    movq -40(%rbp), %r10
    addq $16, %r10
    addq -48(%rbp), %r10
    call getBrk
    cmpq %rax, %r10
    // If it doesn't, resize the heap adding 1024 bytes to the brk to allow the creation of a new block
    jge resizeHeap
    // If it does, do not create a new block. Instead, alloc the remaining space on the current block
    movq -48(%rbp), %r11
    movq %r11, -8(%rbp)
    jmp allocCurrentBlock
allocNext:
    // Create a new block with the remaining space of the current block if it has enough space to be split
    // Get the current block address
    movq -40(%rbp), %r10
    // Get the bytes to be allocated
    movq -8(%rbp), %rbx
    // Get the current block size
    movq -48(%rbp), %r11
    // Get the remainder block address and create a new empty block
    addq $16, %r10
    addq %rbx, %r10
    movq $0, 0(%r10)
    // Get the remainder block size and sets it
    subq $16, %r11
    subq -8(%rbp), %r11
    movq %r11, 8(%r10)
allocCurrentBlock:
    // Reserve space on the current block
    movq -8(%rbp), %rbx
    movq -40(%rbp), %r10
    movq $1, 0(%r10)
    movq %rbx, 8(%r10)
    // Return the address of data of the reserved block
    addq $16, %r10
    movq %r10, %rax
    addq $48, %rsp
    popq %rbp
    ret

// Indicates that the block passed as a parameter is free
liberaMem:
    pushq %rbp
    movq %rsp, %rbp
    
    // Reserves space for two variables
    subq $16, %rsp

    // Store the parameter value in -8(%rbp)
    movq %rdi, -8(%rbp)

    // rax points to the first block
    movq topoInicialHeap(%rip), %rax
    addq $16, %rax

findBlock:
    // Stacks rax at -16(%rbp)
    movq %rax, -16(%rbp)
    // Compares the parameter value with the rax value
    cmpq -8(%rbp), %rax 
    // If it is the same, go to the procedure that free the block
    je freeBlock

    // Otherwise...
    // Unstacks the last rax value
    movq -16(%rbp), %rax

    // Decrease the rax value to get the size of the current block
    subq $16, %rax
    // Increases the rax value to fall into the next block and compare again
    addq 8(%rax), %rax
    // 32: two-block metadata
    addq $32, %rax

    // Start over
    jmp findBlock

freeBlock:
    // Decreases rax value to the start address of the block metadata
    subq $16, %rax
    // Changes the value of the block's first metadata to 0, that is, free
    movq $0, (%rax)

    // Calls the procedure that merges free nodes
    call mergeNodes

    // Frees up space reserved for variables
    addq $16, %rsp
    
    popq %rbp
    ret

mergeNodes:
    pushq %rbp
    movq %rsp, %rbp

    // Reserves space for two variables
    subq $16, %rsp

    // rax & rbx = start of heap
    movq topoInicialHeap(%rip), %rax
    movq %rax, %rbx

    // Makes rax point to the second block of the heap
    addq 8(%rax), %rax
    addq $16, %rax
    
    // Stacks rax & rbx
    movq %rax, -8(%rbp)
    movq %rbx, -16(%rbp)

    // Series of instructions to ensure that rax, as it is next, does not overflow the heap...
    call getBrk
    // -8(%rbp) is the value of the rax we are interested in &
    // The current rax contains the value that was returned by the getBrk procedure
    cmpq -8(%rbp), %rax
    // If it bursts, that is, brk <= rax, thermal fusion
    jle finishMerge
    
    // Unstack rax & rbx
    movq -8(%rbp), %rax
    movq -16(%rbp), %rbx

startMerge:
    // Checks if the next element (rax) is free
    cmpq $0, (%rax)
    // If so, also checks if the previous one is 
    je isLastFree

    // Otherwise, update the pointers
    movq %rax, %rbx
    addq 8(%rax), %rax
    addq $16, %rax

    // Stacks rax & rbx
    movq %rax, -8(%rbp)
    movq %rbx, -16(%rbp)

    // Series of instructions explained in the "mergeNodes" label
    call getBrk
    cmpq -8(%rbp), %rax
    jle finishMerge

    // Unstack rax & rbx
    movq -8(%rbp), %rax
    movq -16(%rbp), %rbx

    jmp startMerge

isLastFree:
    // Checks if the current/previous element is free
    cmpq $0, (%rbx)
    // If so, merge with the next one
    je merge

    // Otherwise, update the pointers
    movq %rax, %rbx
    addq 8(%rax), %rax
    addq $16, %rax

    // Stacks rax & rbx
    movq %rax, -8(%rbp)
    movq %rbx, -16(%rbp)

    // Series of instructions explained in the "mergeNodes" label
    call getBrk
    cmpq -8(%rbp), %rax
    jle finishMerge

    // Unstack rax & rbx
    movq -8(%rbp), %rax
    movq -16(%rbp), %rbx

    jmp startMerge

merge:
    // Move block size from current block to rdx
    movq 8(%rbx), %rdx
    // Sum 16
    addq $16, %rdx
    // Sum the size of the next block
    addq 8(%rax), %rdx
    // Updates the current block size value
    movq %rdx, 8(%rbx)

    // rax = rbx
    movq %rbx, %rax
    // rax points to the next node
    addq $16, %rax
    addq 8(%rbx), %rax

    // Stacks rax & rbx
    movq %rax, -8(%rbp)
    movq %rbx, -16(%rbp)

    // Series of instructions explained in the "mergeNodes" label
    call getBrk
    cmpq -8(%rbp), %rax
    jle finishMerge

    // Unstack rax & rbx
    movq -8(%rbp), %rax
    movq -16(%rbp), %rbx

    jmp startMerge

finishMerge:
    // Frees up space reserved for variables
    addq $16, %rsp

    // Ends the procedure
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

imprimeMapa:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp
    /*
    Local variables:
    -8(%rbp) = current block address
    -16(%rbp) = counter
    -24(%rbp) = char to print
    */
    // Get the initial heap address
    movq topoInicialHeap(%rip), %r10
    // Set the current block address as the initial heap address
    movq %r10, -8(%rbp)
// Iterate over all blocks in the heap printing their status
iterateBlocksWhile:
    // Get the current block address
    movq -8(%rbp), %r10 
    // Get the current brk
    call getBrk 
    // Check if the current block address is greater than the current brk
    cmpq %rax, %r10 
    // If it is, finish the function
    jge iterateBlocksWhileEnd
    // Get the current block address
    movq -8(%rbp), %r10
    // Set the counter to 0
    movq $0, -16(%rbp) 
    // Set the char to print as #
    movq $35, -24(%rbp) 
// Print the current block metadata (16 # characters)
printMetaDoWhile: 
    movq -24(%rbp), %rsi
    leaq formatChar(%rip), %rdi
    // Print #
    call printf 
    // Increment the counter
    addq $1, -16(%rbp) 
    // Check if the counter is equal to 16
    cmpq $16, -16(%rbp)
    // If it is, continue printing the current block metadata
    jl printMetaDoWhile 
    // Get the current block address
    movq -8(%rbp), %r10 
    // Get the current block status
    movq 0(%r10), %r11 
    // Get the current block size
    movq 8(%r10), %r10 
    // Set the counter as the current block size
    movq %r10, -16(%rbp) 
    // Check if the current block is free
    cmpq $0, %r11 
    // If it is, set the char to print as -
    je freeBlockChar 
// Set the char to print as +
reservedBlockChar: 
    movq $43, -24(%rbp)
    jmp printDataCharWhile
// Set the char to print as -
freeBlockChar: 
    movq $45, -24(%rbp)
// Print the current block data status (block size + or - characters)
printDataCharWhile:
    // Check if the counter is equal to 0
    cmpq $0, -16(%rbp)
    movq -24(%rbp), %rsi
    // If it is, finish printing the current block data status
    jle printDataCharWhileEnd 
    leaq formatChar(%rip), %rdi
    // Print + or -
    call printf
    // Decrement the counter
    subq $1, -16(%rbp) 
    jmp printDataCharWhile
printDataCharWhileEnd:
    // Get the current block address
    movq -8(%rbp), %r10
    // Add the current block size to the current block address
    addq 8(%r10), %r10
    // Add 16 to the current block address
    addq $16, %r10
    // Set the current block address as the updated address
    movq %r10, -8(%rbp) 
    jmp iterateBlocksWhile
iterateBlocksWhileEnd:
    movq $10, %rsi
    leaq formatChar(%rip), %rdi
    call printf
    // Finish function
    addq $32, %rsp
    popq %rbp
    ret
