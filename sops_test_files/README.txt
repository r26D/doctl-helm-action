These files can be used to verify that the sops installation works correctly with gpg

The following commands should allow you to see into the example.yaml file

gpg --import pgp/sops_functional_tests_key.asc
sops example.yaml
