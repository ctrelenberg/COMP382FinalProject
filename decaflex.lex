%option C++ 

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

&{2}					{ return 1; }
=					{ return 2; }
bool					{ return 3; }
break					{ return 4; }
"'"(char_lit_chars|escaped_char)"'"	{ return 5; }
,					{ return 6; }
"//" (char_no_nl)* '\n'			{ return 7; }
continue				{ return 8; }
\/					{ return 9; }
\.					{ return 10; }
else					{ return 11; }
={2}					{ return 12; }
extern					{ return 13; }
false					{ return 14; }
for					{ return 15; }
func					{ return 16; }
>=					{ return 17; }
>					{ return 18; }
letter {letter | digit}			{ return 19; }
if					{ return 20; }
"{decimal_digit}+ | "0"("x"|"X"){hex_digit}+"	{ return 21; }
int					{ return 22; }
\{					{ return 23; }
\<{2}					{ return 24; }
\<=					{ return 25; }
\(					{ return 26; }
\[					{ return 27; }
\<					{ return 28; }
\-					{ return 29; }
\%					{ return 30; }
\*					{ return 31; }
"!="					{ return 32; }
\!					{ return 33; }
null					{ return 34; }
\|{2}					{ return 35; }
package					{ return 36; }
\+					{ return 37; }
\}					{ return 38; }
return					{ return 39; }
>{2}					{ return 40; }
\)					{ return 41; }
\]					{ return 42; }
\;					{ return 43; }
`"`{char | escaped_char}`"`		{ return 44; }
string					{ return 45; }
true					{ return 46; }
var					{ return 47; }
void					{ return 48; }
while					{ return 49; }
[\t\r\a\v\b ]+				{ return 50; }
\n					{ return 51; }
. 			{ cerr << "Error: unexpected character in input" << endl; return -1; }


%%

int main () {
  int token;
  string lexeme;
  while ((token = yylex())) {
    if (token > 0) {
      lexeme.assign(yytext);
      switch(token) {
	case 1: cout << "T_AND " << lexeme << endl; break;
	case 2: cout << "T_ASSIGN " << lexeme << endl; break;
	case 3: cout << "T_BOOLTYPE " << lexeme << endl; break;
	case 4: cout << "T_BREAK " << lexeme << endl; break;
	case 5: cout << "T_CHARCONSTANT " << lexeme << endl; break;
	case 6: cout << "T_COMMA " << lexeme << endl; break;
	case 7: cout << "T_COMMENT " << lexeme << endl; break;
        case 8: cout << "T_CONTINUE " << lexeme << endl; break;
        case 9: cout << "T_DIV " << lexeme << endl; break;
	case 10: cout << "T_DOT " << lexeme << endl; break;
	case 11: cout << "T_ELSE " << lexeme << endl; break;
        case 12: cout << "T_EQ " << lexeme << endl; break;
	case 13: cout << "T_EXTERN " << lexeme << endl; break;
	case 14: cout << "T_FALSE " << lexeme << endl; break;
	case 15: cout << "T_FOR " << lexeme << endl; break;
	case 16: cout << "T_FUNC " << lexeme << endl; break;
	case 17: cout << "T_GEQ " << lexeme << endl; break;
	case 18: cout << "T_GT " << lexeme << endl; break;
	case 19: cout << "T_ID " << lexeme << endl; break;
	case 20: cout << "T_IF " << lexeme << endl; break;
	case 21: cout << "T_INTCONSTANT " << lexeme << endl; break;
	case 22: cout << "T_INTTYPE " << lexeme << endl; break;
	case 23: cout << "T_LCB " << lexeme << endl; break;
	case 24: cout << "T_LEFTSHIFT " << lexeme << endl; break;
	case 25: cout << "T_LEQ " << lexeme << endl; break;
        case 26: cout << "T_LPAREN " << lexeme << endl; break;
        case 27: cout << "T_LSB " << lexeme << endl; break;
	case 28: cout << "T_LT " << lexeme << endl; break;
	case 29: cout << "T_MINUS " << lexeme << endl; break;
        case 30: cout << "T_MOD " << lexeme << endl; break;
	case 31: cout << "T_MULT " << lexeme << endl; break;
	case 32: cout << "T_NEQ " << lexeme << endl; break;
	case 33: cout << "T_NOT " << lexeme << endl; break;
	case 34: cout << "T_NULL " << lexeme << endl; break;
	case 35: cout << "T_OR " << lexeme << endl; break;
	case 36: cout << "T_PACKAGE " << lexeme << endl; break;
	case 37: cout << "T_PLUS " << lexeme << endl; break;
	case 38: cout << "T_RCB " << lexeme << endl; break;
	case 39: cout << "T_RETURN " << lexeme << endl; break;
	case 40: cout << "T_RIGHTSHIFT " << lexeme << endl; break;
	case 41: cout << "T_RPAREN " << lexeme << endl; break;
	case 42: cout << "T_RSB " << lexeme << endl; break;
	case 43: cout << "T_SEMICOLON " << lexeme << endl; break;
        case 44: cout << "T_STRINGCONSTANT " << lexeme << endl; break;
        case 45: cout << "T_STRINGTYPE " << lexeme << endl; break;
	case 46: cout << "T_TRUE " << lexeme << endl; break;
	case 47: cout << "T_VAR " << lexeme << endl; break;
        case 48: cout << "T_VOID " << lexeme << endl; break;
	case 49: cout << "T_WHILE " << lexeme << endl; break;
        case 50: cout << "T_WHITESPACE " << lexeme << endl; break;
        case 51: cout << "T_WHITESPACE \\n" << endl; break;
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
