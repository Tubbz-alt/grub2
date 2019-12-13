#include <openssl/err.h>
#include <openssl/bn.h>
#include <openssl/dh.h>
#include <openssl/ocsp.h>
#include <openssl/pkcs12.h>
#include <openssl/rand.h>
#include <openssl/crypto.h>
#include <openssl/ssl.h>
#include <openssl/x509.h>
#include <openssl/x509v3.h>
#include <openssl/rsa.h>
#include <Library/BaseCryptLib.h>


void
init_openssl(void)
{
  CRYPTO_set_mem_functions(ossl_malloc, NULL, ossl_free);
  OPENSSL_init();
  CRYPTO_set_mem_functions(ossl_malloc, NULL, ossl_free);
  ERR_load_ERR_strings();
  ERR_load_BN_strings();
  ERR_load_RSA_strings();
  ERR_load_DH_strings();
  ERR_load_EVP_strings();
  ERR_load_BUF_strings();
  ERR_load_OBJ_strings();
  ERR_load_PEM_strings();
  ERR_load_X509_strings();
  ERR_load_ASN1_strings();
  ERR_load_CONF_strings();
  ERR_load_CRYPTO_strings();
  ERR_load_COMP_strings();
  ERR_load_BIO_strings();
  ERR_load_PKCS7_strings();
  ERR_load_X509V3_strings();
  ERR_load_PKCS12_strings();
  ERR_load_RAND_strings();
  ERR_load_DSO_strings();
  ERR_load_OCSP_strings();
}
