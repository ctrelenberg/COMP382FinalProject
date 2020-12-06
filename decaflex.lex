%option C++ noyywrap

%{
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
%}

all_chars (.\n)
chars [^\n\\1\"]
char_lit_chars [^'\\]
char_no_nl .

escaped_char \\(a|b|t|n|v|f|r|\\|'|\")

letter [A-Za-z_]
decimal_digit [0-9]
hex_digit [0-9A-Fa-f]
digit [0-9]

%%
  /*
    Pattern definitions for all tokens
  */

"//"{char_no_nl}*\n                   { return 7; }
&&				                    { return 1; }
=					                { return 2; }
bool					            { return 3; }
break					            { return 4; }
'({char_lit_chars}|{escaped_char})' { return 5; }
'..+'                               { return 303; }
'.                                  { return 304; }
''                                  { return 305; }
,					                { return 6; }
continue				            { return 8; }
\/					                { return 9; }
\.					                { return 10; }
else					            { return 11; }
={2}					            { return 12; }
extern					            { return 13; }
false					            { return 14; }
for					                { return 15; }
func					            { return 16; }
>=					                { return 17; }
>					                { return 18; }
if					                { return 20; }
{decimal_digit}+|0(x|X){hex_digit}+	{ return 21; }
int					                { return 22; }
\{					                { return 23; }
\<{2}					            { return 24; }
\<=					                { return 25; }
\(					                { return 26; }
\[					                { return 27; }
\<					                { return 28; }
\-					                { return 29; }
\%					                { return 30; }
\*					                { return 31; }
"!="					            { return 32; }
\!					                { return 33; }
null					            { return 34; }
\|{2}					            { return 35; }
package					            { return 36; }
\+					                { return 37; }
\}					                { return 38; }
return					            { return 39; }
>{2}					            { return 40; }
\)					                { return 41; }
\]					                { return 42; }
\;					                { return 43; }
\"({char}|{escaped_char})\"		    { return 44; }
\"[^\\\n]*\\[^abtvfr\\'\"].*\"      { return 300; }
\".*\n.*\"                         { return 301; }
\".*\n                             { return 302; }
string					            { return 45; }
true					            { return 46; }
var					                { return 47; }
void					            { return 48; }
while					            { return 49; }
[\t\r\a\v\b ]+				        { return 50; }
\n					                { return 51; }
{letter}({letter}|{digit})*			{ return 19; }
. 			                        { std::cerr << "Error: unexpected character in input.\n"; return -1; }
%%

template<typename Iterable, typename V>
bool contains(const Iterable& container, const V value) {
    return (std::find(container.begin(), container.end(), value) != container.end());
}

// Few helper functions that make string processing nicer in C++.
auto rstrip(const std::string& container, const char value) -> std::string {
    const auto begin = container.cbegin();
    const auto end = std::find_if(container.crbegin(), container.crend(), [value](char v) { return v != value; }).base();
    return std::string(begin, end);
}

std::string newline_lexeme(const std::string& lexeme, bool print_newlines) {
    if (!print_newlines) return lexeme;
    return rstrip(lexeme, '\n') + "\\n";
}

int main (int argc, char* argv[]) {
    std::vector<std::string> args(argv + 1, argv + argc);
    auto print_newlines = contains(args, "--literal-newlines");
    int token{};
    std::string lexeme;
    yyFlexLexer lexer{};
    while ((token = lexer.yylex())) {
        if (token > 0) {
            lexeme = lexer.YYText();
            switch (token) {
                case 1: std::cout << "T_AND " << lexeme << std::endl; break;
                case 2: std::cout << "T_ASSIGN " << lexeme << std::endl; break;
                case 3: std::cout << "T_BOOLTYPE " << lexeme << std::endl; break;
                case 4: std::cout << "T_BREAK " << lexeme << std::endl; break;
                case 5: std::cout << "T_CHARCONSTANT " << lexeme << std::endl; break;
                case 6: std::cout << "T_COMMA " << lexeme << std::endl; break;
                case 7: std::cout << "T_COMMENT " << newline_lexeme(lexeme, print_newlines) << std::endl; break;
                case 8: std::cout << "T_CONTINUE " << lexeme << std::endl; break;
                case 9: std::cout << "T_DIV " << lexeme << std::endl; break;
                case 10: std::cout << "T_DOT " << lexeme << std::endl; break;
                case 11: std::cout << "T_ELSE " << lexeme << std::endl; break;
                case 12: std::cout << "T_EQ " << lexeme << std::endl; break;
                case 13: std::cout << "T_EXTERN " << lexeme << std::endl; break;
                case 14: std::cout << "T_FALSE " << lexeme << std::endl; break;
                case 15: std::cout << "T_FOR " << lexeme << std::endl; break;
                case 16: std::cout << "T_FUNC " << lexeme << std::endl; break;
                case 17: std::cout << "T_GEQ " << lexeme << std::endl; break;
                case 18: std::cout << "T_GT " << lexeme << std::endl; break;
                case 19: std::cout << "T_ID " << lexeme << std::endl; break;
                case 20: std::cout << "T_IF " << lexeme << std::endl; break;
                case 21: std::cout << "T_INTCONSTANT " << lexeme << std::endl; break;
                case 22: std::cout << "T_INTTYPE " << lexeme << std::endl; break;
                case 23: std::cout << "T_LCB " << lexeme << std::endl; break;
                case 24: std::cout << "T_LEFTSHIFT " << lexeme << std::endl; break;
                case 25: std::cout << "T_LEQ " << lexeme << std::endl; break;
                case 26: std::cout << "T_LPAREN " << lexeme << std::endl; break;
                case 27: std::cout << "T_LSB " << lexeme << std::endl; break;
                case 28: std::cout << "T_LT " << lexeme << std::endl; break;
                case 29: std::cout << "T_MINUS " << lexeme << std::endl; break;
                case 30: std::cout << "T_MOD " << lexeme << std::endl; break;
                case 31: std::cout << "T_MULT " << lexeme << std::endl; break;
                case 32: std::cout << "T_NEQ " << lexeme << std::endl; break;
                case 33: std::cout << "T_NOT " << lexeme << std::endl; break;
                case 34: std::cout << "T_NULL " << lexeme << std::endl; break;
                case 35: std::cout << "T_OR " << lexeme << std::endl; break;
                case 36: std::cout << "T_PACKAGE " << lexeme << std::endl; break;
                case 37: std::cout << "T_PLUS " << lexeme << std::endl; break;
                case 38: std::cout << "T_RCB " << lexeme << std::endl; break;
                case 39: std::cout << "T_RETURN " << lexeme << std::endl; break;
                case 40: std::cout << "T_RIGHTSHIFT " << lexeme << std::endl; break;
                case 41: std::cout << "T_RPAREN " << lexeme << std::endl; break;
                case 42: std::cout << "T_RSB " << lexeme << std::endl; break;
                case 43: std::cout << "T_SEMICOLON " << lexeme << std::endl; break;
                case 44: std::cout << "T_STRINGCONSTANT " << lexeme << std::endl; break;
                case 45: std::cout << "T_STRINGTYPE " << lexeme << std::endl; break;
                case 46: std::cout << "T_TRUE " << lexeme << std::endl; break;
                case 47: std::cout << "T_VAR " << lexeme << std::endl; break;
                case 48: std::cout << "T_VOID " << lexeme << std::endl; break;
                case 49: std::cout << "T_WHILE " << lexeme << std::endl; break;
                case 50: std::cout << "T_WHITESPACE " << lexeme << std::endl; break;
                case 51: std::cout << "T_WHITESPACE \\n" << std::endl; break;
                case 300: std::cerr << "Error: unknown escape sequence in string constant\n"; break;
                case 301: std::cerr << "Error: newline in string constant\n"; break;
                case 302: std::cerr << "Error: string constant is missing closing delimiter\n"; break;
                case 303: std::cerr << "Error: char constant length is greater than one\n"; break;
                case 304: std::cerr << "Error: unterminated char constant\n"; break;
                case 305: std::cerr << "Error: char constant has zero width\n"; break;
                default: return EXIT_FAILURE;
            }
        } else {
            if (token < 0) {
                return EXIT_FAILURE;
            }
        }
    }
    return EXIT_SUCCESS;
}
