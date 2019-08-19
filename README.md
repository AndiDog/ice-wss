# ZeroC Ice – WS/WSS transport example

See `Makefile`.

Needs an /etc/hosts entry `the-server` pointing to 127.0.0.1 so that peer verification on macOS
(SecureTransport backend) works. For a proxy `-h localhost`, you'd get
`IceSSL: certificate verification failure: Trust denied`. On FreeBSD/OpenSSL, the peer name
isn't checked as expected (`IceSSL.CheckCertName=0` is the default). Therefore, the separation
feature for `IceSSL.VerifyPeer.{Client,Server}` was developed ([available
here](https://github.com/AndiDog/ice/tree/server-name-indication-and-verify-peer-separation),
but not submitted as PR to upstream.
