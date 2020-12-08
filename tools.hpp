#ifndef DECAFLEX_TOOLS_HPP
#define DECAFLEX_TOOLS_HPP

/**
 * This file contains a variety of useful C++ tools.
 */

#include <vector>
#include <algorithm>
#include <string>

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

auto rstrip(const std::string& container, const std::vector<char>& value) -> std::string {
    const auto begin = container.cbegin();
    const auto end = std::find_if(container.crbegin(), container.crend(), [value](char v) { return !contains(value, v); }).base();
    return std::string(begin, end);
}

std::string newline_lexeme(const std::string& lexeme, bool print_newlines) {
    if (!print_newlines) return lexeme;
    return rstrip(lexeme, '\n') + "\\n";
}

#endif // DECAFLEX_TOOLS_HPP
