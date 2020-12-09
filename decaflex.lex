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

// Apologies for poor code formatting; .lex makes it difficult to autoformat.

struct Token {
    Token(const char* s) : str(s) {}
    Token(std::string s) : str(std::move(s)) {}
    std::string str; 
};

struct OutputTokenState {
    OutputTokenState(int id, std::string lexeme) : 
        id(id),
        lexeme_str(std::move(lexeme)) {}
    OutputTokenState() : set(false) {}
    OutputTokenState(int id, 
                     std::string lexeme, 
                     std::string curr_line, 
                     long current_line_pos,
                     long prev_line_pos) :
                        id(id), lexeme_str(std::move(lexeme)),
                        cl(curr_line), clp(current_line_pos),
                        plp(prev_line_pos)
                        {}
    int id{-1};
    bool set{true};
    std::string lexeme_str;

    std::string cl;
    long clp{};
    long plp{};
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

int outputToken(OutputTokenState t, const bool suppress_generic, 
                const bool canonical, const std::string curr_line,
                const long current_line_pos, const long prev_line_pos) {
    // Destructure arguments (as this is a quick refactor post-majority-of-project)
    const auto& lexeme = t.lexeme_str;
    const int token = t.id;

    // Grab our constant information
    std::vector<Token> tokens {
        "T_AND", "T_ASSIGN", "T_BOOLTYPE", "T_BREAK", "T_CHARCONSTANT", 
        "T_COMMA", "T_COMMENT", "T_CONTINUE", "T_DIV", "T_DOT", "T_ELSE", "T_EQ", "T_EXTERN", 
        "T_FALSE", "T_FOR", "T_FUNC", "T_GEQ", "T_GT", "T_ID", "T_IF", "T_INTCONSTANT", 
        "T_INTTYPE", "T_LCB", "T_LEFTSHIFT", "T_LEQ", "T_LPAREN", "T_LSB", "T_LT", "T_MINUS", 
        "T_MOD", "T_MULT", "T_NEQ", "T_NOT", "T_NULL", "T_OR", "T_PACKAGE", "T_PLUS", "T_RCB", 
        "T_RETURN", "T_RIGHTSHIFT", "T_RPAREN", "T_RSB", "T_SEMICOLON", "T_STRINGCONSTANT", 
        "T_STRINGTYPE", "T_TRUE", "T_VAR", "T_VOID", "T_WHILE", "T_WHITESPACE"
    };
    constexpr auto error_offset = 300;
    const std::vector<Token> errors { // This could be static for better performance.
        "unknown escape sequence in string constant",
        "newline in string constant",
        "string constant is missing closing delimiter",
        "char constant length is greater than one",
        "unterminated char constant",
        "char constant has zero width",
        "unexpected character in input." 
    };

    // Run the actual code for printing tokens.

    // Lexeme size is 0 if we just found tabs, currently. No other reason.
    if (lexeme.size() == 0) return EXIT_SUCCESS;

    // This occurs if the lexeme directly corresponded to a token.
    if ((token - 1) < tokens.size()) {
        // In this case, we can translate it automatically
        if (!suppress_generic)
            std::cout << tokens[token - 1].str << " " << lexeme << std::endl;
        return EXIT_SUCCESS;
    }
    else if (token == 51) {
        if (!suppress_generic) std::cout << "T_WHITESPACE \\n" << std::endl;
    }
    else if (token >= error_offset && 
             (token - error_offset) < errors.size()) {
        // Properly format error message.
        if (canonical) {
            std::cerr << "Error: " << errors[token - error_offset].str << "\n";
            std::cerr << "Lexical error: line " << current_line_pos;
            std::cerr << ", position " << prev_line_pos << "\n";
        }
        else {
            std::cerr << "Scanning failure: '" << rstrip(lexeme, '\n') << "':\n";
            std::cerr << "(Position " << current_line_pos << ":" << prev_line_pos << ") ";
            std::cerr << "Error #" << token << ": ";
            std::cerr << errors[token - error_offset].str << "\n";
            std::cerr << curr_line << std::endl;
            for (int i = 0; i < prev_line_pos - 1; i++) std::cerr << '~';
            std::cerr << "^\n";
        }
        return EXIT_FAILURE;
    }
    else {
        std::cerr << "Unexpected token ID: " << token << std::endl; 
        return EXIT_FAILURE;
    }
}

int main (int argc, char* argv[]) {
    // Configuration / command-line arguments.
    std::vector<std::string> args(argv + 1, argv + argc);
    auto escape_trailing_newlines = contains(args, "--literal-newlines");
    auto exit_error = contains(args, "--exit-error");
    auto keep_tabs = contains(args, "--keep-tabs");
    auto canonical = contains(args, "--canonical");
    auto group_whitespace = contains(args, "--group-whitespace");
    escape_trailing_newlines = escape_trailing_newlines || canonical;
    keep_tabs = keep_tabs || canonical;
    group_whitespace = group_whitespace || canonical;
    auto suppress_generic = contains(args, "--quiet");
    auto verbose = contains(args, "--verbose");

    std::unordered_set<int> escape_newlines_ids = { 7 };

    std::unordered_set<int> second_line_errors = { 302, 301 };

    Lexer lexer;
    long line_pos = 1;
    long prev_line_pos = 1;
    long current_line_pos = 0;
    auto ret = EXIT_SUCCESS;
    std::string curr_line;
    OutputTokenState whitespace;
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
            else if (actual_line != current_line_pos) {
                current_line_pos = actual_line;
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
            else if (current_line_pos == actual_line) {
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

        if ((lexer.token == 50 || lexer.token == 51) && group_whitespace) {
            if (verbose) std::cout << "Found whitespace.\n";
            if (!whitespace.set) {
                if (verbose) std::cout << "Wasn't set. Creating.\n";
                whitespace = OutputTokenState(50, lexeme, curr_line, 
                                              current_line_pos, prev_line_pos);
                if (lexer.token == 51) whitespace.lexeme_str = "\\n";
            }
            else {
                if (verbose) std::cout << "Adding the lexeme (" << lexeme << ")";
                whitespace.cl = curr_line;
                whitespace.clp = current_line_pos;
                if (lexer.token == 50) whitespace.lexeme_str += lexeme;
                else whitespace.lexeme_str += "\\n";
                if (verbose) std::cout << ", New: " << whitespace.lexeme_str << std::endl;
            }
            continue;
        }
        else if (whitespace.set) {
            if (outputToken(whitespace, suppress_generic, canonical, 
                        whitespace.cl, whitespace.clp, whitespace.plp)
                == EXIT_FAILURE)
            {
                if (exit_error) return EXIT_FAILURE;
                else ret = EXIT_FAILURE;
            }
            whitespace = OutputTokenState{};
        }

        if (outputToken({lexer.token, lexeme}, suppress_generic, canonical, curr_line, current_line_pos, prev_line_pos) 
            == EXIT_FAILURE) {
            if (exit_error) return EXIT_FAILURE;
            else ret = EXIT_FAILURE;
        }
    }
    if (whitespace.set) {
        if (outputToken(whitespace, suppress_generic, canonical,
                    whitespace.cl, whitespace.clp, whitespace.plp) == EXIT_FAILURE) {
            ret = EXIT_FAILURE;
        }
        whitespace = OutputTokenState{};
    }

    return ret;
}
