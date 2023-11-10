#include <stdio.h>
#include <stdlib.h>

extern int sum(int, int);

extern int sum_2(int);

extern void iniciaAlocador();

extern void finalizaAlocador();

extern void* allocMem(int);

extern int liberaMem(void* block);

extern void* topoInicialHeap;

extern void* aposAlteracao;

extern void* resetaHeap;

extern void printMem();

extern void printMemChars();

int main() {
    void *a, *b;
    int c, valor, *i, *p, *ptr;

    iniciaAlocador();
    printMemChars();  // vazio
    printf("\n");
    a = (void*)allocMem(10);
    printMemChars();  // ################**********
    printf("\n");
    b = (void*)allocMem(4);
    printMemChars();  // ################**********##############****
    printf("\n");
    liberaMem(a);
    printMemChars();  // ################----------##############****
    printf("\n");
    liberaMem(b);
    printMemChars();  // vazio
    printf("\n");

    return 0;
}