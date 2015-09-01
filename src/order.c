#include <stdlib.h>
#include <stdio.h>

#include "order.h"

int
cmpInt(const void *v1, const void *v2) {
  const int v1_ = **((const int **)v1);
  const int v2_ = **((const int **)v2);
  return v1_ < v2_ ? -1 : v1_ > v2_;
}

int
cmpDouble(const void *v1, const void *v2) {
  const double v1_ = **((const double **)v1);
  const double v2_ = **((const double **)v2);
  return v1_ < v2_ ? -1 : v1_ > v2_;
}

int
cmpFloat(const void *v1, const void *v2) {
  const float v1_ = **((const float **)v1);
  const float v2_ = **((const float **)v2);
  return v1_ < v2_ ? -1 : v1_ > v2_;
}

/**
 * Order an array and return the index sequence of odered values.
 */
void
order(void *array, size_t nitems, size_t size,
  int (*cmp)(const void *p1, const void *p2), size_t *result) {
  char *aa = array;
  void *pindex[nitems];
  int i;
    
  for ( i = 0; i < nitems; i++) {
    pindex[i] = aa + size * i;
  }
    
  qsort(pindex, nitems, sizeof(*pindex), cmp);
  
  for ( i = 0; i < nitems; i++ ) {
    result[i] = ((char *)pindex[i] - aa ) / size;
  }
}
