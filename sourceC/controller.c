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
    node_t *prevScn = NULL;
    node_t *nextScn = NULL;
    if(heap->size > 0)
        nextScn = heap->head->next;

    for(int i = 0; i < heap->size; i++) {
        if(scn->block == block) {
            scn->free = 1;
            if(prevScn != NULL && prevScn->free == 1) {
                free(prevScn->block);
                free(scn->block);
                prevScn->blockSize = prevScn->blockSize + scn->blockSize;
                prevScn->block = malloc(sizeof(char)*(prevScn->blockSize));
                prevScn->next = scn->next;
                scn = prevScn;
                heap->size--;
            }
            if(nextScn != NULL && nextScn->free == 1) {
                free(nextScn->block);
                free(scn->block);
                scn->blockSize = scn->blockSize + nextScn->blockSize;
                scn->block = malloc(sizeof(char)*(scn->blockSize));
                scn->next = nextScn->next;
                heap->size--;
            }
            return 1;
        }
        prevScn = scn;
        scn = scn->next;
        nextScn = scn->next;
    }

    return 0;
}

void printMap(heap_t *heap) {
    node_t *scn = heap->head;

    for(int i = 0; i < heap->size; i++) {
        printf("#");
        for(int j = 0; j < scn->blockSize; j++) {
            printf("#");
        }
        for(int j = 0; j < scn->blockSize; j++) {
            if(scn->free == 0)
                printf("+");
            if(scn->free == 1)
                printf("-");
        }
        scn = scn->next;
    }
    printf("\n");
}

int main(int argc, char **argv) {
    heap_t *heap;
    char *scanner, *test;

    heap = initAllocator();
    if(heap == NULL) {
        perror("Heap wasn't initialized\n");
        return 1;
    }   
    
    scanner = alocBlock(heap, 50);
    printMap(heap);
    freeBlock(heap, scanner);
    printMap(heap);
    scanner = alocBlock(heap, 60);
    test = scanner;
    printMap(heap);
    scanner = alocBlock(heap, 30);
    printMap(heap);
    freeBlock(heap, scanner);
    printMap(heap);
    freeBlock(heap, test);
    printMap(heap);

    heap = endAllocator(heap);

    return 0;
}