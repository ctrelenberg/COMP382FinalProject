# COMP 382: Final Project (Scanner Generation using Flex)

Created by Christian Trelenberg (300110670) and Michael Bennett (300142749).

## YouTube Link

https://www.youtube.com/watch?v=4O-T4KaTBRg

### Notes

Code is contained within `decaflex.lex` and `tools.hpp` (helper utilities). `check.sh` can be used to check the current scanner against reference implementation output.

#### Error Handling

Error handling conforms as closely to the specified behaviour as possible, while taking some liberties and cleaning up some error conflicts. With `--canonical`, errors will be printed in a format identical to the one given as reference (through `std::cerr`/`stderr`, so errors can be redirected to a file on the commandline if so desired). If desirable behaviour is to *only* output errors, `--quiet` can achieve this (with `--canonical` if the reference formatting is desired). If it is desirable to quit immediately on encountering an error, the additional argument `--exit-error` is available.

The default error handling behaviour (i.e. without `--canonical`) uses custom error formatting that displays the information normally available (e.g. line number, position in line) but also displays the erroring lexeme & visually points to where the error occurred.
