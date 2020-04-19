package main

// Generate keys for signing jwt keys

import (
	"flag"
	"fmt"
	"github.com/getcouragenow/getcourage-packages/mod-account/authz/pkg/keyutil"
	"os"
)

var (
	alg = flag.String("a", "RSA", "Choose between RSA / ECC (EdDSA)")
	pth = flag.String("p", "./", "Output dir for the generated key")
)

func main() {
	flag.Parse()
	var algo keyutil.KeyType
	switch *alg {
	case "RSA":
		algo = keyutil.RSA
	case "ECC":
		algo = keyutil.ECC
	default:
		algo = keyutil.RSA
	}
	if err := algo.GenSigningKeys(*pth); err != nil {
		fmt.Fprintf(os.Stdout, "Error generating signing keys: %s", err.Error())
	}
	fmt.Fprintf(os.Stdout, "Keys successfully generated in dir: %s", *pth)
}
