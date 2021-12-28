include:
  - ..letsencrypt

letsencrypt-activate-cert:
  file.symlink:
    - name: /etc/pki/current
    - target: /etc/letsencrypt/live/fqdn
    - onlyif:
        fun: x509.read_certificate
        certificate: /etc/letsencrypt/live/fqdn/cert.pem
