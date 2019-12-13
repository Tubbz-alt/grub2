#include <grub/err.h>
#include <grub/misc.h>

extern unsigned char _binary_cert_pem_start;
extern unsigned char _binary_cert_pem_end;
extern unsigned char _binary_cert_pem_size;

extern void init_openssl();

grub_err_t
verify_pe (char* buf)
{
  init_openssl();
  grub_dprintf("sbverify", "%s\n", buf);

  return GRUB_ERR_NONE;
}
