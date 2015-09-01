#ifndef __MOVR_ORDER_H__
#define __MOVR_ORDER_H__

int cmpInt(const void *v1, const void *v2);
int cmpDouble(const void *v1, const void *v2);
int cmpFloat(const void *v1, const void *v2);
void order(void *, size_t, size_t, int (*cmp)(const void *, const void *), size_t *);

#endif /* __MOVR_ORDER_H__ */
