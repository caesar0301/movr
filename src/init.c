#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

// Forward declarations of all .Call routines
extern SEXP _compress_mov(SEXP, SEXP, SEXP);
extern SEXP _flow_stat(SEXP, SEXP, SEXP, SEXP);
extern SEXP _radius_of_gyration(SEXP, SEXP, SEXP);

// Single registration table
static const R_CallMethodDef callEntries[] = {
  {"_compress_mov",               (DL_FUNC)&_compress_mov,              3},
  {"_flow_stat",                  (DL_FUNC)&_flow_stat,                 4},
  {"_radius_of_gyration",  (DL_FUNC)&_radius_of_gyration, 3},
  {NULL, NULL, 0}
};

void R_init_movr(DllInfo *dll) {
  R_registerRoutines(dll, NULL, callEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
