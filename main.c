#include <stdio.h>
#include <stdlib.h>

extern void iniciaAlocador();
extern void finalizaAlocador();
extern void *alocaMem(int);
extern int liberaMem(void *block);
extern void imprimeMapa();

int main() {
    void *a, *b;

    iniciaAlocador();  // Impressão esperada
    imprimeMapa();     // <vazio>

    a = (void *)alocaMem(10);
    imprimeMapa();  // ################++++++++++
    b = (void *)alocaMem(4);
    imprimeMapa();  // ################++++++++++##############++++
    liberaMem(a);
    imprimeMapa();  // ################----------##############++++
    liberaMem(b);   // ################----------------------------
                    // ou
                    // <vazio>
    imprimeMapa();
    finalizaAlocador();
}