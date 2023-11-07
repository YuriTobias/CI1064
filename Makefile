all: test.s test.c
	as test.s -o test.o
	gcc test.c test.o

run: a.out
	./a.out