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
    int c, valor, *i, *p, *ptr;

    iniciaAlocador();
    i = topoInicialHeap;
    printf("%p\n", i);
    p = allocMem(2);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    p = allocMem(2);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    p = allocMem(2);
    printf("-- %p (%li)\n", p, (p - i) * 4);
    // p = allocMem(2);
    // printf("-- %p (%li)\n", p, (p - i) * 4);
    // printMemChars();
    // printf("\n");
    ptr = (int*)((char*)topoInicialHeap + 8);  // Convertemos para int* e somamos 8 bytes.
    valor = *ptr;                               // Acessamos o valor inteiro.
    printf("--- %d\n", valor);
    ptr = (int*)((char*)topoInicialHeap + 26);  // Convertemos para int* e somamos 8 bytes.
    valor = *ptr;                               // Acessamos o valor inteiro.
    printf("--- %d\n", valor);
    ptr = (int*)((char*)topoInicialHeap + 44);  // Convertemos para int* e somamos 8 bytes.
    valor = *ptr;                               // Acessamos o valor inteiro.
    printf("--- %d\n", valor);
    ptr = (int*)((char*)topoInicialHeap + 62);  // Convertemos para int* e somamos 8 bytes.
    valor = *ptr;                               // Acessamos o valor inteiro.
    printf("--- %d\n", valor);
    liberaMem(topoInicialHeap + 16);
    liberaMem(topoInicialHeap + 52);
    // liberaMem(topoInicialHeap + 34);
    ptr = (int*)((char*)topoInicialHeap + 8);  // Convertemos para int* e somamos 8 bytes.
    valor = *ptr;                               // Acessamos o valor inteiro.
    printf("--- %d\n", valor);
    ptr = (int*)((char*)topoInicialHeap + 26);  // Convertemos para int* e somamos 8 bytes.
    valor = *ptr;                               // Acessamos o valor inteiro.
    printf("--- %d\n", valor);
    ptr = (int*)((char*)topoInicialHeap + 44);  // Convertemos para int* e somamos 8 bytes.
    valor = *ptr;                               // Acessamos o valor inteiro.
    printf("--- %d\n", valor);
    ptr = (int*)((char*)topoInicialHeap + 62);  // Convertemos para int* e somamos 8 bytes.
    valor = *ptr;  
    printf("--- %d\n", valor);
    finalizaAlocador();
    printf("%p\n", resetaHeap);

    return 0;
}