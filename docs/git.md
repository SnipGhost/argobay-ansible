# Git troubles & tricks

## GitHub auth/credentials
Not recommended password auth:
```
# File: ~/.netrc
machine github.com
login GIHUB_LOGIN
password GIHUB_PASSOWORD
```

## Import ssh-keys
Import ssh-key to ssh-agent (see `ssh-add -L`) and set ssh-origin
```bash
git remote set-url origin git@github.com:SnipGhost/assol-ansible.git 
```

## Make multiple remote upstreams
```bash
GROUP=infrastructure
PROJECT=assol-ansible

git remote add bmstu git@bmstu.codes:iu5/${GROUP}/${PROJECT}.git
git config --global alias.pushall '!git remote | xargs -L1 git push --all'

git pushall
```
