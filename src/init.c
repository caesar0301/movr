#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

extern SEXP turbo_radius_of_gyration_c(SEXP, SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
    {"turbo_radius_of_gyration_c", (DL_FUNC)&turbo_radius_of_gyration_c, 3},
    {NULL, NULL, 0}
};

void R_init_movr(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
