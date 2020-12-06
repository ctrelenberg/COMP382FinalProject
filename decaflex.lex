
%{

#include <iostream>
#include <cstdlib>

using namespace std;

all_char = "\a"|"\b"|"\t"|"\n"|"\v"|"\f"|"\r"|" "|"!"|`"`|"#"|"$"|"%"|"&"|"'"|"("|\
		")"|"*"|"+"|","|"-"|"."|"/"|"0"..."9"|":"|";"|"<"|"="|">"|"?"|\
		"@"|"A"..."Z"|"["|"\"|"]"|"^"|"_"|"`"|"a"..."z"|"{"|"|"|"}"|"~".

char = "\a"|"\b"|"\t""\v"|"\f"|"\r"|" "|"!"|"#"|"$"|"%"|"&"|"'"|"("|\
	    ")"|"*"|"+"|","|"-"|"."|"/"|"0"..."9"|":"|";"|"<"|"="|">"|"?"|\
	    "@"|"A"..."Z"|"["|"]"|"^"|"_"|"`"|"a"..."z"|"{"|"|"|"}"|"~".

char_lit_chars = "\a"|"\b"|"\t"|"\n"|"\v"|"\f"|"\r"|" "|"!"|`"`|"#"|"$"|"%"|"&"|"("|\
		      ")"|"*"|"+"|","|"-"|"."|"/"|"0"..."9"|":"|";"|"<"|"="|">"|"?"|\
		      "@"|"A"..."Z"|"["|"]"|"^"|"_"|"`"|"a"..."z"|"{"|"|"|"}"|"~".

char_no_nl = "\a"|"\b"|"\t"|"\v"|"\f"|"\r"|" "|"!"|`"`|"#"|"$"|"%"|"&"|"'"|"("|\
		  ")"|"*"|"+"|","|"-"|"."|"/"|"0"..."9"|":"|";"|"<"|"="|">"|"?"|\
		  "@"|"A"..."Z"|"["|"\"|"]"|"^"|"_"|"`"|"a"..."z"|"{"|"|"|"}"|"~".

escaped_char = "\"("a"|"b"|"t"|"n"|"v"|"f"|"r"|`\`|"'"|`"`).

letter = "A"..."Z"|"a"..."z"|"_".
decimal_digit = "0"..."9".
hex_digit = "0"..."9"|"A"..."F"|"a"..."f".
digit = "0"..."9".

%}

%%
  /*
    Pattern definitions for all tokens
  */
\{                         { return 4; }
\}                         { return 5; }
\(                         { return 6; }
\)                         { return 7; }
[a-zA-Z\_][a-zA-Z\_0-9]*   { return 8; }
[\t\r\a\v\b ]+             { return 9; }
\n                         { return 10; }
.                          { cerr << "Error: unexpected character in input" << endl; return -1; }


bool			{ return 1; }		T_BOOLTYPE
break			{ return 2; }		T_BREAK
continue		{ return 3; }		T_CONTINUE
else			{ return 4; }		T_ELSE
extern			{ return 5; }		T_EXTERN
false			{ return 6; }		T_FALSE
for			{ return 7; }		T_FOR
func			{ return 8; }		T_FUNC
if			{ return 9; }		T_IF
int			{ return 10; }		T_INTTYPE
null			{ return 11; }		T_NULL
package			{ return 12; }		T_PACKAGE
return			{ return 13; }		T_RETURN
string			{ return 14; }		T_STRINGTYPE
true			{ return 15; }		T_TRUE
var			{ return 16; }		T_VAR
void			{ return 17; }		T_VOID
while			{ return 18; }		T_WHILE

"'"(char_lit_chars|escaped_char)"'"		T_CHARCONSTANT
// (char_no_nl)* \n				T_COMMENT
letter {letter | digit}				T_ID
{decimal_digit}+ | "0"("x"|"X"){hex_digit}+	T_INTCONSTANT
`"`{char | escaped_char}`"`			T_STRINGCONSTANT
[\t\r\a\v\b ]+					T_WHITESPACE
\n						T_WHITESPACE

&&						T_AND
=						T_ASSIGN
,						T_COMMA
/						T_DIV
.						T_DOT
==						T_EQ
>=						T_GEQ
>						T_GT
{						T_LCB
<<						T_LEFTSHIFT
<=						T_LEQ
(						T_LPAREN
[						T_LSB
<						T_LT
-						T_MINUS
%						T_MOD
*						T_MULT
!=						T_NEQ
!						T_NOT
||						T_OR
+						T_PLUS
}						T_RCB
>>						T_RIGHTSHIFT
)						T_RPAREN
]						T_RSB
;						T_SEMICOLON





%%

int main () {
  int token;
  string lexeme;
  while ((token = yylex())) {
    if (token > 0) {
      lexeme.assign(yytext);
      switch(token) {
	case 1: cout << "T_BOOLTYPE " << lexeme << endl; break;
	case 2: cout << "T_BREAK " << lexeme << endl; break;
	case 3: cout << "T_CONTINUE " << lexeme << endl; break;
	case 4: cout << "T_ELSE " << lexeme << endl; break;
	case 5: cout << "T_EXTERN " << lexeme << endl; break;
	case 6: cout << "T_FALSE " << lexeme << endl; break;
	case 7: cout << "T_FOR " << lexeme << endl; break;
        case 8: cout << "T_FUNC " << lexeme << endl; break;
        case 9: cout << "T_IF " << lexeme << endl; break;
	case 10: cout << "T_INTTYPE " << lexeme << endl; break;
	case 11: cout << "T_NULL " << lexeme << endl; break;
        case 12: cout << "T_PACKAGE " << lexeme << endl; break;
	case 13: cout << "T_RETURN " << lexeme << endl; break;
	case 14: cout << "T_STRINGTYPE " << lexeme << endl; break;
	case 15: cout << "T_TRUE " << lexeme << endl; break;
	case 16: cout << "T_VAR " << lexeme << endl; break;
	case 17: cout << "T_VOID " << lexeme << endl; break;
	case 18: cout << "T_WHILE " << lexeme << endl; break;

        case 4: cout << "T_LCB " << lexeme << endl; break;
        case 5: cout << "T_RCB " << lexeme << endl; break;
        case 6: cout << "T_LPAREN " << lexeme << endl; break;
        case 7: cout << "T_RPAREN " << lexeme << endl; break;
        case 8: cout << "T_ID " << lexeme << endl; break;
        case 9: cout << "T_WHITESPACE " << lexeme << endl; break;
        case 10: cout << "T_WHITESPACE \\n" << endl; break;
        default: exit(EXIT_FAILURE);
      }
    } else {
      if (token < 0) {
        exit(EXIT_FAILURE);
      }
    }
  }
  exit(EXIT_SUCCESS);
}
