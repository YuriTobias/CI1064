
#ifndef MEUALOCADOR_H
#define MEUALOCADOR_H

extern void iniciaAlocador();
extern void finalizaAlocador();
extern void *alocaMem(int);
extern int liberaMem(void *block);
extern void imprimeMapa();

#endif