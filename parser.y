%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"    //  AST header
#include "symbol.h" // Symbol Table header
 


int yy_scan_string(const char *str);
extern int yylex(); // Lexical analyzer function
void yyerror(const char *s); // Error function

ASTNode *createIfElseNode(ASTNode *condition, ASTNode *thenBranch, ASTNode *elseBranch) {
    ASTNode *node = createBinaryNode("if_else", condition, thenBranch);
    node->right = elseBranch; // Link the else branch
    return node;
}

ASTNode *root; // Global variabe AST root
%}

%union {
    int num;
    char *id;
    struct ASTNode *ast;
}

%token <num> NUMBER
%token <id> IDENTIFIER
%token IF ELSE
%type <ast> expression term factor assignment statement conditional

%% // Grammar Rules

program:
    statement ';' {
        root = $1; 
    }
;

statement:
    expression {
        $$ = $1; 
    }
    | assignment {
        $$ = $1; 
    }
    | conditional {
        $$ = $1; 
    }
;

assignment:
    IDENTIFIER '=' expression {
	insertSymbol($1, "int", 0);
        $$ = createBinaryNode("assign", createIdentifierNode($1), $3);
    }
;

conditional:

  // Create an if-else statement and corresponding instructions
   

expression:
    expression '+' term {
        $$ = createBinaryNode("add", $1, $3);
    }


//add subtraction rule


    | term {
        $$ = $1;
    }
;



term:
    
//Create all the term rules and respective semantic instructions Term * factor ,  Term/facror , factor


factor:
    NUMBER {
        $$ = createTerminalNode("number", $1);
    }
    | IDENTIFIER {
        $$ = createIdentifierNode($1);
    }
    | '(' expression ')' {
        $$ = $2; // Return the expression within parentheses
    }
;

%% // Error Handling

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    printf("Enter your expressions (end with ; and type 'exit' to quit):\n");
    while (1) {
        char input[256];
        printf(">> ");
        if (fgets(input, sizeof(input), stdin) == NULL) {
            break; // Handle end of input
        }
        if (strcmp(input, "exit\n") == 0) {
            break; // Exit condition
        }
        yy_scan_string(input); // Pass the input to the lexer
        if (yyparse() == 0) {  // Call the parser
	 printSymbolTable();
            if (root != NULL) {
                printAST(root, 0); // Print the AST
            } else {
                printf("Error: syntax error\n");
            }
        }
    }
    return 0;
}

