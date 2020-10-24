# Init -- a quick start for Laravel development in a new environment

Pnit is a simple tool for setting up an ideal Laravel development environment on any machine.

It can be run multiple times on the same machine safely.

## Getting Started

### Prerequisites

- macOS, Linux, or Windows with WSL2
- `curl` or `wget` installed
- `git` installed

### Basic Installation

Init is activated by running one of the following commands in your terminal.

| Method    | Command                                                                                           |
|:----------|:--------------------------------------------------------------------------------------------------|
| **curl**  | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/tighten/init/main/install.sh)"` |
| **wget**  | `sh -c "$(wget -O- https://raw.githubusercontent.com/tighten/init/main/install.sh)"`   |
| **fetch** | `sh -c "$(fetch -o - https://raw.githubusercontent.com/tighten/init/main/install.sh)"` |

#### Manual inspection

It's a good idea to inspect the install script from projects you don't yet know. You can do
that by downloading the install script first, looking through it so everything looks normal,
then running it:

```shell
curl --remote-name https://raw.githubusercontent.com/tighten/init/main/install.sh
less install.sh
sh install.sh
```

## What Init does for you

Init isn't a locally installed tool; you run it once and then you're done. 

It'll install:

- PHP
- Composer (for PHP dependencies)
- The Laravel Installer
- Takeout (for other dependencies like databases)

## Thanks

The oomph to finally build this from a conversation with the incredible Taylor Otwell.

This README was inspired by the Oh-My-Zsh readme.
