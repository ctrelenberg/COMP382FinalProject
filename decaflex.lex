%option C++ noyywrap yylineno

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
. 			                        { return 306; }
%%

struct Token {
    Token(const char* s) : str(s) {}
    Token(std::string s) : str(std::move(s)) {}
    std::string str; 
};

// A small wrapper class for the yyFlexLexer.
class Lexer {
public:
    int next() {
        token = lexer.yylex();
        if (token) text = lexer.YYText();
        return token;
    }

    const std::string& get_text() const {
        return text;
    }

    int token{0};
    std::string text;
    int lineno() const { return lexer.lineno(); }

private:
    yyFlexLexer lexer;
};

int main (int argc, char* argv[]) {
    // Configuration / command-line arguments.
    std::vector<std::string> args(argv + 1, argv + argc);
    auto escape_trailing_newlines = contains(args, "--literal-newlines");
    auto exit_error = contains(args, "--exiting-errors");
    auto keep_tabs = contains(args, "--keep-tabs");
    auto canonical = contains(args, "--canonical");
    escape_trailing_newlines = canonical;
    auto suppress_generic = contains(args, "--quiet");
    auto verbose = contains(args, "--verbose");

    std::vector<Token> tokens {
        "T_AND", "T_ASSIGN", "T_BOOLTYPE", "T_BREAK", "T_CHARCONSTANT", 
        "T_COMMA", "T_COMMENT", "T_CONTINUE", "T_DIV", "T_DOT", "T_ELSE", "T_EQ", "T_EXTERN", 
        "T_FALSE", "T_FOR", "T_FUNC", "T_GEQ", "T_GT", "T_ID", "T_IF", "T_INTCONSTANT", 
        "T_INTTYPE", "T_LCB", "T_LEFTSHIFT", "T_LEQ", "T_LPAREN", "T_LSB", "T_LT", "T_MINUS", 
        "T_MOD", "T_MULT", "T_NEQ", "T_NOT", "T_NULL", "T_OR", "T_PACKAGE", "T_PLUS", "T_RCB", 
        "T_RETURN", "T_RIGHTSHIFT", "T_RPAREN", "T_RSB", "T_SEMICOLON", "T_STRINGCONSTANT", 
        "T_STRINGTYPE", "T_TRUE", "T_VAR", "T_VOID", "T_WHILE", "T_WHITESPACE "
    };
    std::unordered_set<int> escape_newlines_ids = { 7 };

    constexpr auto error_offset = 300;
    std::vector<Token> errors {
        "unknown escape sequence in string constant",
        "newline in string constant",
        "string constant is missing closing delimiter",
        "char constant length is greater than one",
        "unterminated char constant",
        "char constant has zero width",
        "unexpected character in input." 
    };
    std::unordered_set<int> second_line_errors = { 302, 301 };

    Lexer lexer;
    long line_pos = 1;
    long prev_line_pos = 1;
    long current_line = 0;
    auto ret = EXIT_SUCCESS;
    std::string curr_line;
    while (lexer.next()) {
        /**
         * Get the lexeme that's been parsed using Flex.
         * Increase and/or reset subline positioning.
         * Update line number.
         * Removes tabs when necessary & also escapes newlines.
         */
        const auto& lexeme = [&] {
            const auto& l = lexer.get_text();
            const auto actual_line = lexer.lineno();
            
            prev_line_pos = line_pos;
            // Save the previous position (start position) for error reporting.
            if (std::find(second_line_errors.begin(), second_line_errors.end(), lexer.token) 
                     != second_line_errors.end()) {
                // Another hack.
                // This error was encountered on line X, but line X - 1 actually has the erroring
                // code. So, we should retain that code.
                curr_line += rstrip(l, std::vector<char>{'\n', ' ', '\t'});
            }
            else if (actual_line != current_line) {
                current_line = actual_line;
                line_pos = 1;
                curr_line = "";
            }

            if (!l.empty() && l[l.size() - 1] == '\n') {
                // This is a weird bugfix for a weird bug where the \n at the end
                // of a comment scan seems to drag it into the next line's scanning.
                // Could not find a reference fix for this, so went with a simple fix.
                if (lexer.token == 7) {
                    line_pos = 1;
                    curr_line = "";
                }
            }
            else if (current_line == actual_line) {
                line_pos += l.size();
                curr_line += l;
            }

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

        // Lexeme size is 0 if we just found tabs, currently. No other reason.
        if (lexeme.size() == 0) continue;

        // This occurs if the lexeme directly corresponded to a token.
        if ((lexer.token - 1) < tokens.size()) {
            // In this case, we can translate it automatically
            if (!suppress_generic)
                std::cout << tokens[lexer.token - 1].str << " " << lexeme << std::endl;
            continue;
        }
        else if (lexer.token == 51) {
            if (!suppress_generic) std::cout << "T_WHITESPACE \\n" << std::endl;
        }
        else if (lexer.token >= error_offset && 
                 (lexer.token - error_offset) < errors.size()) {
            // Properly format error message.
            if (canonical) {
                std::cerr << "Error: " << errors[lexer.token - error_offset].str << "\n";
                std::cerr << "Lexical error: line " << current_line;
                std::cerr << ", position " << prev_line_pos << "\n";
            }
            else {
                std::cerr << "Scanning failure: '" << rstrip(lexeme, '\n') << "':\n";
                std::cerr << "(Position " << current_line << ":" << prev_line_pos << ") ";
                std::cerr << "Error #" << lexer.token << ": ";
                std::cerr << errors[lexer.token - error_offset].str << "\n";
                std::cerr << curr_line << std::endl;
                for (int i = 0; i < prev_line_pos - 1; i++) std::cerr << '~';
                std::cerr << "^\n";
            }
           
            if (exit_error) {
                return EXIT_FAILURE;
            }
            else {
                ret = EXIT_FAILURE;
            }
        }
        else {
            std::cerr << "Unexpected token ID: " << lexer.token << std::endl; 
            return EXIT_FAILURE;
        }
    }
    return ret;
}
