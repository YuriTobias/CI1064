#include <stdio.h>

#include "meuAlocador.h"

int main(long int argc, char **argv) {
    void *a, *b, *c, *d, *e, *f, *g, *h, *j;
    int i = 0;

    iniciaAlocador();
    printf("%d\n", ++i);
    imprimeMapa();
    // 0) estado inicial

    a = (void *)alocaMem(240);
    printf("%d\n", ++i);
    imprimeMapa();
    b = (void *)alocaMem(240);
    printf("%d\n", ++i);
    imprimeMapa();
    c = (void *)alocaMem(240);
    printf("%d\n", ++i);
    imprimeMapa();
    d = (void *)alocaMem(240);
    printf("%d\n", ++i);
    imprimeMapa();
    liberaMem(a);
    printf("%d\n", ++i);
    imprimeMapa();
    liberaMem(c);
    printf("%d\n", ++i);
    imprimeMapa();
    e = (void *)alocaMem(32);
    printf("%d\n", ++i);
    imprimeMapa();
    f = (void *)alocaMem(64);
    printf("%d\n", ++i);
    imprimeMapa();
    g = (void *)alocaMem(32);
    printf("%d\n", ++i);
    imprimeMapa();
    g = (void *)alocaMem(240);
    printf("%d\n", ++i);
    imprimeMapa();
    g = (void *)alocaMem(240);
    printf("%d\n", ++i);
    imprimeMapa();
    g = (void *)alocaMem(10);
    printf("%d\n", ++i);
    imprimeMapa();

    finalizaAlocador();
}
