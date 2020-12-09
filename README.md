# COMP 382: Final Project (Scanner Generation using Flex)

Created by Christian Trelenberg (300110670) and Michael Bennett (300142749).

### Notes

#### Error Handling

Error handling conforms as closely to the specified behaviour as possible, while taking some liberties and cleaning up some error conflicts. With `--canonical`, errors will be printed in a format identical to the one given as reference (through `std::cerr`/`stderr`, so errors can be redirected to a file on the commandline if so desired). If desirable behaviour is to *only* output errors, `--quiet` can achieve this (with `--canonical` if the reference formatting is desired). If it is desirable to quit immediately on encountering an error, the additional argument `--exit-error` is available.
