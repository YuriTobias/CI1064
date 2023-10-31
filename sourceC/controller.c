#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct node_t {
    int free;               // 0 - occupied ; 1 - free
    int blockSize;          // Block size
    char *block;            // Pointer to the first address of the block
    struct node_t *next;    // Pointer to next node
} node_t;

typedef struct heap_t {
    node_t *head;
    int size;
} heap_t;

heap_t *initAllocator() {
    heap_t *aux = malloc(sizeof(heap_t));
    if(aux == NULL) {
        return NULL;
    }

    aux->head = NULL;
    aux->size = 0;

    return aux;
}

heap_t *endAllocator(heap_t *heap) {
    node_t *scn;

    while(heap->size > 0) {
        scn = heap->head;
        for(int i = 1; i < heap->size - 1; i++) {
            scn = scn->next;
        }

        if(heap->size != 1) {
            free(scn->next->block);
            free(scn->next);
            scn->next = NULL;
        } else {
            free(scn->block);
            free(scn);
            heap->head = NULL;
        }

        heap->size--;
    }

    free(heap);
    return NULL;
}

char *alocBlock(heap_t *heap, int numBytes) {
    int trashSize;
    node_t *scn = heap->head;    
    node_t *nextAux, *newBlock;

    for(int i = 0; i < heap->size; i++) {
        if((scn->free == 1) && (numBytes <= scn->blockSize)) {
            scn->free = 0;
            if(numBytes != scn->blockSize) {
                trashSize = scn->blockSize - numBytes;
                free(scn->block);
                scn->blockSize = numBytes;
                scn->block = malloc(sizeof(char)*numBytes);

                nextAux = scn->next;
                newBlock = malloc(sizeof(node_t));
                newBlock->free = 1;
                newBlock->blockSize = trashSize;
                newBlock->block = malloc(sizeof(char)*trashSize);
                newBlock->next = nextAux;
                scn->next = newBlock;

                heap->size++;
            }

            return scn->block;
        }
        scn = scn->next;
    }

    scn = heap->head;
    for(int i = 0; i < heap->size - 1; i++)
        scn = scn->next;

    newBlock = malloc(sizeof(node_t));
    newBlock->free = 0;
    newBlock->blockSize = numBytes;
    newBlock->block = malloc(sizeof(char)*numBytes);
    newBlock->next = NULL;
    if(heap->size == 0) {
        heap->head = newBlock;
    } else {
        scn->next = newBlock;
    }

    heap->size++;

    return newBlock->block;
}

int freeBlock(heap_t *heap, char *block) {
    node_t *scn = heap->head;

    for(int i = 0; i < heap->size; i++) {
        if(scn->block == block) {
            scn->free = 1;
            return 1;
        }
    }

    return 0;
}

int main(int argc, char **argv) {
    heap_t *heap;
    char *scanner;

    heap = initAllocator();
    if(heap == NULL) {
        perror("Heap wasn't initialized\n");
        return 1;
    }   
    
    scanner = alocBlock(heap, 50);

    printf("%p %d - %d %d %p %p %p %p\n", heap->head, heap->size, heap->head->free, heap->head->blockSize, &(heap->head->block), heap->head->block, &(heap->head->next), heap->head->next);
    printf("%p\n", scanner);

    freeBlock(heap, scanner);
    printf("%d\n", heap->head->free);

    heap = endAllocator(heap);

    return 0;
}