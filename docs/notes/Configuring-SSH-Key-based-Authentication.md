# Configuring SSH Key-based Authentication

## Create an SSH Key-pair

`ssh-keygen [-t dsa | ecdsa | ecdsa-sk | ed25519 | ed25519-sk | rsa] [-f output_keyfile] [-C comment] ` generates an ssh key-pair with a specified type [-t] with a file name [-f]. A file name such as "id_ed25519_rhel9_server" could be used for an optional file name extension. 

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519<OPTIONAL_NAME> -C "<USER>@$<HOST>"
```
---

## Add Private Key Identity to the OpenSSH Authentication Agent

`ssh-add` adds private key identities to the OpenSSH authentication agent.
Skip this process of addin the identity to the agent when a passphrase was not set during the key creation stage using the `ssh-keygen`. 


Ensure the ssh-agent is activated

```bash
eval "$(ssh-agent -s)"
```

Add an ssh private key identity to the agent

```bash
ssh-add ~/.ssh/id_ed25519<OPTIONAL_NAME>
```
---

## Copy the Public Key to Host

`ssh-copy-id -i [identity_file]` copies public key to the targeted HOST as USER.

```bash
ssh-copy-id -i ~/.ssh/id_ed25519<OPTIONAL_NAME>.pub <USER>@<HOST>
```

For hosts not accepting `ssh-copy-id` such as GitHub.com, copy the public key manually. For GitHub,as an example, use `cat` and paste the public key manually on GitHub → Settings → SSH and GPG keys → New SSH key.

```bash
cat ~/.ssh/id_ed25519<OPTIONAL_NAME>.pub
```
---

## Set Permissions

- `chmod 700` # for .ssh directory
- `chmod 600` # for config, private key files
- `chmod 644` # for public key files

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config ~/.ssh/id_ed25519_*
chmod 644 ~/.ssh/*.pub
```
---

## Test Connections

```bash
ssh -T git@github.com    # Expect GitHub greeting "Hi <USER_NAME>..."
ssh <HOST>                # Should log into your host
```

---
