#ifndef COMPILER_HW_COMMON_H
#define COMPILER_HW_COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

/* Add what you need */

typedef struct Symbol
{
	int index;
	char *name;
	char *type;
	int addr;
	int lineNum;
	char *funcSign;
	char *owner;
	struct Symbol *next;
}Symbol;

typedef struct symbolTable
{
	int scopeLevel;
	int length;
	char *name;
	struct Symbol *symbols;
	struct symbolTable *next;
}symbolTable;

typedef struct tableStack
{
	struct symbolTable *top;
}stack;

typedef struct Scope
{
	int scopeLevel;
	int currentAddr;
	struct symbolTable *tables;
	struct Scope *next;
}Scope;


#endif /* COMPILER_HW_COMMON_H */
