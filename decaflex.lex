%option C++ noyywrap

%{
#include "tools.hpp" // Custom tools

#include <iostream>
#include <string>
#include <vector>
#include <array>
#include <algorithm>
#include <unordered_set>
%}

all_chars (.\n)
chars [^\n\\1\"]
char_lit_chars [^'\\]
char_no_nl .
str (\\[abtvfrn\\\"]|[^\"\\\n])

escaped_char (\\[abtnvfr\\'\"])

letter [A-Za-z_]
decimal_digit [0-9]
hex_digit [0-9A-Fa-f]
digit [0-9]

%%
  /*
    Pattern definitions for all tokens
  */

"//"{char_no_nl}*\n                 { return 7; }
&&				                    { return 1; }
=					                { return 2; }
bool					            { return 3; }
break					            { return 4; }
'({char_lit_chars}|{escaped_char})' { return 5; }
'.[^']+'                            { return 303; }
'[^']                               { return 304; }
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
\"{str}*\n{str}*\"                  { return 301; /* Newline in string constant */ }
\"{str}*\"		                    { return 44; /* String matcher */ }
\"{str}*\\[^abtvfrn\\\"][^\"]*\"    { return 300; }
\"(\\[abtnvfrn\\\"]|[^\"\\\n])*\n   { return 302; /* String constant is missing closing delimiter */ }
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

struct Token {
    Token(const char* s) : str(s) {}
    Token(std::string s) : str(std::move(s)) {}
    std::string str; 
    bool escape_trailing_newlines = false;
};

// A small wrapper class for the yyFlexLexer.
class Lexer {
public:
    int next() {
        token = lexer.yylex();
        if (token) text = lexer.YYText();
        return token;
    }

    const std::string& get_text() {
        return text;
    }

    int token{0};
    std::string text;

private:
    yyFlexLexer lexer;
};

int main (int argc, char* argv[]) {
    // Configuration / command-line arguments.
    std::vector<std::string> args(argv + 1, argv + argc);
    auto escape_trailing_newlines = contains(args, "--literal-newlines");
    auto exit_error = contains(args, "--exiting-errors");
    auto keep_tabs = contains(args, "--keep-tabs");

    std::vector<Token> tokens {
        "T_AND", "T_ASSIGN", "T_BOOLTYPE", "T_BREAK", "T_CHARCONSTANT", 
        "T_COMMA", "T_COMMENT", "T_CONTINUE", "T_DIV", "T_DOT", "T_ELSE", "T_EQ", "T_EXTERN", 
        "T_FALSE", "T_FOR", "T_FUNC", "T_GEQ", "T_GT", "T_ID", "T_IF", "T_INTCONSTANT", 
        "T_INTTYPE", "T_LCB", "T_LEFTSHIFT", "T_LEQ", "T_LPAREN", "T_LSB", "T_LT", "T_MINUS", 
        "T_MOD", "T_MULT", "T_NEQ", "T_NOT", "T_NULL", "T_OR", "T_PACKAGE", "T_PLUS", "T_RCB", 
        "T_RETURN", "T_RIGHTSHIFT", "T_RPAREN", "T_RSB", "T_SEMICOLON", "T_STRINGCONSTANT", 
        "T_STRINGTYPE", "T_TRUE", "T_VAR", "T_VOID", "T_WHILE"
    };
    std::unordered_set<int> escape_newlines_ids = { 7 };

    Lexer lexer;
    while (lexer.next()) {
        if (lexer.token < 0) {
            return EXIT_FAILURE;
        }
        const auto& lexeme = [&] {
            const auto& l = lexer.get_text();
            if (escape_newlines_ids.find(lexer.token) != escape_newlines_ids.end())
            {
                return newline_lexeme(l, escape_trailing_newlines);
            }
            if (lexer.token == 50 && !keep_tabs) {
                std::string temp = l;
                temp.erase(std::remove(temp.begin(), temp.end(), '\t'), temp.end());
                return temp;
            }
            return l;
        }();
        if (lexeme.size() == 0) continue;
        if ((lexer.token - 1) < tokens.size()) {
            // In this case, we can translate it automatically
            std::cout << tokens[lexer.token - 1].str << " " << lexeme << std::endl;
            continue;
        }
        switch (lexer.token) {
            case 50: std::cout << "T_WHITESPACE " << lexeme << std::endl; break;
            case 51: std::cout << "T_WHITESPACE \\n" << std::endl; break;
            case 300: std::cerr << "Error: unknown escape sequence in string constant" << std::endl; break;
            case 301: std::cerr << "Error: newline in string constant" << std::endl; break;
            case 302: std::cerr << "Error: string constant is missing closing delimiter" << std::endl; break;
            case 303: std::cerr << "Error: char constant length is greater than one" << std::endl; break;
            case 304: std::cerr << "Error: unterminated char constant" << std::endl; break;
            case 305: std::cerr << "Error: char constant has zero width" << std::endl; break;
            default: return EXIT_FAILURE;
        }
    }
    return EXIT_SUCCESS;
}
