#include <stdio.h>
#include <stdlib.h>

extern int sum(int, int);

extern int sum_2(int);

extern void iniciaAlocador();

extern void finalizaAlocador();

extern void * alocaMem(int);

extern void * topoInicialHeap;

extern void * aposAlteracao;

extern void * resetaHeap;

int main() {
    int c;
    
    // printf("%d\n", sum(15, 15));
    // printf("%d\n", sum_2(8));
    // printf("%p\n", iniciaAlocador());
    // topoInicialHeap = iniciaAlocador();
    iniciaAlocador();
    printf("%p\n", topoInicialHeap);
    finalizaAlocador();
    // printf("%p\n", aposAlteracao);
    printf("%p\n", resetaHeap);
    alocaMem(30);
    alocaMem(30);
    alocaMem(30);
    alocaMem(30);
    alocaMem(30);

    return 0;
}