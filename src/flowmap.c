#include <R.h>
#include <Rdefines.h>
#include <glib.h>

/**
 * Calculate the flow statistic for each link (of a location pair)
 * 
 * @param loc character vector
 * @param stime real vector
 * @param etime real vector
 * @param gap length one vector of real number
 */
SEXP _flow_stat(SEXP loc, SEXP stime, SEXP etime, SEXP gap) {
  double *stime_ = REAL(stime);
  double *etime_ = REAL(etime);
  double gap_ = asReal(gap);
  char *last_loc, *cur_loc;
  double last_et;
  int i;
  
  GHashTable * stat = g_hash_table_new(g_str_hash, g_int_equal);
  last_loc = CHAR(STRING_ELT(loc, 0));
  last_et = etime_[0];
  
  for ( i = 1; i < length(loc); i++ ){
    if ( stime_[i] - last_et <= gap_ ) {
      // assemble new link name   
      char *link;
      link = malloc(sizeof(char) * (strlen(last_loc) + strlen(cur_loc) + 3));
      cur_loc = CHAR(STRING_ELT(loc, i));
      sprintf(link, "%s->%s", last_loc, cur_loc);
      
      // update flow stat
      if ( ! g_hash_table_contains(stat, link) ) {
        g_hash_table_insert(stat, link, 0);
      }
      g_hash_table_insert(stat, link,
        GPOINTER_TO_INT(g_hash_table_lookup(stat, link)) + 1 );
    }
    
    last_loc = CHAR(STRING_ELT(loc, i));
    last_et = etime_[i];
  }
  
  // convert flow stat in hash table to R data frame
  SEXP out, edges, flows;
  const int PAIR_NUM = g_hash_table_size(stat);
  GHashTableIter iter;
  gpointer key, value;
  i = 0;
  
  PROTECT(out = NEW_LIST(2));
  PROTECT(edges = NEW_CHARACTER(PAIR_NUM));
  PROTECT(flows = NEW_INTEGER(PAIR_NUM));
  
  g_hash_table_iter_init(&iter, stat);
  while (g_hash_table_iter_next (&iter, &key, &value)) {
    SET_STRING_ELT(edges, i, mkChar((char*)key));
    INTEGER(flows)[i] = GPOINTER_TO_INT(value);
    i++;
  }
  
  SET_VECTOR_ELT(out, 0, edges);
  SET_VECTOR_ELT(out, 1, flows);
  
  UNPROTECT(3);
  
  g_hash_table_destroy(stat);
  
  return out;
}