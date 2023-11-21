all: meuAlocador.s avalia.c
	as meuAlocador.s -o meuAlocador.o
	gcc avalia.c meuAlocador.o -o avalia

run: meuAlocador
	./avalia

clean:
	rm -f avalia meuAlocador.o