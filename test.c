#include <stdio.h>
#include <stdlib.h>

extern int sum(int, int);

extern int sum_2(int);

extern void iniciaAlocador();

extern void finalizaAlocador();

extern void* alocaMem(int);

extern void* topoInicialHeap;

extern void* aposAlteracao;

extern void* resetaHeap;

int main() {
    int c, *i, *p;

    // printf("%d\n", sum(15, 15));
    // printf("%d\n", sum_2(8));
    // printf("%p\n", iniciaAlocador());
    // topoInicialHeap = iniciaAlocador();
    iniciaAlocador();
    i = topoInicialHeap;
    printf("%p\n", i);
    p = alocaMem(984);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    p = alocaMem(8);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    p = alocaMem(8);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    p = alocaMem(8);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    p = alocaMem(8);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    p = alocaMem(8);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    p = alocaMem(8);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    // finalizaAlocador();
    // printf("%p\n", resetaHeap);

    return 0;
}