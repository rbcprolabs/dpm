<img src="https://raw.githubusercontent.com/rbcprolabs/dpm/master/media/hero.png" alt="Logo" width="100%" />

<h2>
  <p align="center">
    Run commands upon installing & upgrades packages, powerfull package management with CLI. <b>Flutter</b> cappatible!
  </p>
</h2>

<p align="center">
  <a href="https://pub.dartlang.org/packages/dpm">
    <img src="https://img.shields.io/pub/v/dpm.svg"
         alt="Pub">
  </a>
</p>

<p align="center">
  <a href="#how-to-use">Features</a> •
  <a href="#how-to-use">How to use</a> •
  <a href="#available-commands">Available Commands</a>
</p>

# Features

- Small weight
- Productive development
- Fast works

# How to use
```bash
$ pub global activate dpm
```

To use packages that integrate with `dpm`, you should run
`dpm get` instead of `pub get`. This will run `pub get`, and
then install package executables into a `.dpm_bin` directory.
Then, all installed packages will have their `get` dpm run.

Also replace `pub upgrade` with `dpm upgrade`. This will run `get`
dpm as well.

You can run `dpm link` to link executables into `.dpm_bin`.

# Running your own scripts
It is very likely that you want to run your own scripts during
development, or upon package installation. Do as follows in your
`pubspec.yaml`:

```yaml
name: foo
# ...
scripts:
  build: gcc -o foo src/foo.cc
  post_get:
    - dart_gyp configure
    - dart_gyp build
  post_upgrade: echo ":)"
```

Installed dependencies with executables will automatically be
filled in to the `PATH` during script execution.

Then, in your project root, you can run:
```bash
$ dpm build
```

# Available Commands
* [add](#add)
* [remove](#remove)
* [get](#get)
* [init](#init)
* [upgrade](#upgrade)
* [link](#link)
* [clean](#clean)
* [reset](#reset)

## Add
Can be used to install dependencies without having to search
the Pub directory for the current version.

```bash
# Install the newest version, and apply caret syntax
$ dpm add my-package

# Install a specific version
$ dpm add my-package@^1.0.0
$ dpm add my-package@0.0.4+25
$ dpm add "my-package@>=2.0.0 <3.0.0"

# Install a Git dependency
$ dpm add my-package@git://path/to/repo.git

# Specify a commit or ref
$ dpm add my-package@git://path/to/repo.git#bleeding-edge

# Install a local package
$ dpm add my-package@path:/Users/john/Source/Dart/pkg

# Install multiple packages
$ dpm add my-package my-other-package yet-another-package

# Install to dev_dependencies
$ dpm add --dev http test my-package@git://repo#dev

# Preview `pubspec.yaml`, without actually installing dependencies,
# or modifying the file.
$ dpm add --dry-run my-experimental-package
```

## Remove
Can be used to remove dependencies without need go to file.

```bash
# Remove specific package 
$ dpm remove my-package 

# Remove multiple packages
$ dpm remove my-package my-other-package
```
## Get
This script simply runs `pub get`, and then calls [`link`](#link).

## init
Essentially an `npm init` for Dart. This command will
run you through a series of prompts, after which a `pubspec.yaml`
will be generated for you.

## Upgrade
This script simply runs `pub upgrade`, and then calls [`link`](#link).

## Link
Creates symlinks to each dependency (in future versions, I
will eliminate symlink use), and also creates executable files
linked to any dependencies that export executables.

## Clean
Removes the `.dpm_bin` directory, if present.

## Reset
Runs `clean`, followed by `get`.
