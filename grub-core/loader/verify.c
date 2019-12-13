extern unsigned char _binary_cert_pem_start;
extern unsigned char _binary_cert_pem_end;
extern unsigned char _binary_cert_pem_size;

static grub_err_t
verify_pe (char* buf)
{
  init_openssl();
}
