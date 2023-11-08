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

int main() {
    int c, *i, *p;

    // printf("%d\n", sum(15, 15));
    // printf("%d\n", sum_2(8));
    // printf("%p\n", iniciaAlocador());
    // topoInicialHeap = iniciaAlocador();
    iniciaAlocador();
    i = topoInicialHeap;
    printf("%p\n", i);
    p = allocMem(984);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    p = allocMem(8);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    p = allocMem(8);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    p = allocMem(8);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    p = allocMem(8);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    p = allocMem(8);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    p = allocMem(8);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    liberaMem(topoInicialHeap + 16);
    // liberaMem(topoInicialHeap+34);
    int* ptr = (int*)((char*)topoInicialHeap + 8);  // Convertemos para int* e somamos 8 bytes.
    int valor = *ptr;                               // Acessamos o valor inteiro.
    printf("--- %d\n", valor);
    // finalizaAlocador();
    // printf("%p\n", resetaHeap);

    return 0;
}