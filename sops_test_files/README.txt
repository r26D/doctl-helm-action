These files can be used to verify that the sops installation works correctly with gpg

The following commands should allow you to see into the example.yaml file

gpg --import pgp/sops_functional_tests_key.asc
sops example.yaml



echo "vanu43g9VDSVD@#%DVmvdsi2-dvk%" | gpg --batch --import jobward.private.key

echo "vanu43g9VDSVD@#%DVmvdsi2-dvk%" | gpg --batch --import jobward.private.key
echo "vanu43g9VDSVD@#%DVmvdsi2-dvk%" > key.txt
touch dummy.txt
gpg --batch --yes --passphrase-file key.txt --pinentry-mode=loopback -s dummy.txt
rm -f dummy.txt
sops secrets.local.yaml