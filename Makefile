all: malloc.s main.c
	as malloc.s -o malloc.o
	gcc main.c malloc.o -o malloc.out

run: malloc.out
	./malloc.out

clean:
	rm -f malloc.out malloc.o