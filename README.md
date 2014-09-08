# Groom your Android NDK environment with ndkenv.

Use ndkenv to pick a NDK version for your environment and guarantee
that your development environment matches production.

**Powerful in development.** Specify your app's NDK version once,
  in a single file. Keep all your teammates on the same page. No
  headaches running apps on different versions of NDK.
  Override the NDK version anytime: just set an environment variable.

**Rock-solid in production.** With ndkenv, 
  you'll never again need to `cd` in a cron job or Chef recipe to
  ensure you've selected the right runtime. The NDK version
  dependency lives in one place. So upgrades and rollbacks are
  atomic, even when you switch versions.

**One thing well.** ndkenv is concerned solely with switching NDK
  versions. It's simple and predictable.

## Table of Contents

* [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the NDK Version](#choosing-the-NDK-version)
  * [Locating the NDK Installation](#locating-the-NDK-installation)
* [Installation](#installation)
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
  * [How ndkenv hooks into your shell](#how-ndkenv-hooks-into-your-shell)
  * [Installing NDK Versions](#installing-NDK-versions)
  * [Uninstalling NDK Versions](#uninstalling-NDK-versions)
* [Command Reference](#command-reference)
  * [ndkenv local](#ndkenv-local)
  * [ndkenv global](#ndkenv-global)
  * [ndkenv shell](#ndkenv-shell)
  * [ndkenv versions](#ndkenv-versions)
  * [ndkenv version](#ndkenv-version)
  * [ndkenv rehash](#ndkenv-rehash)
  * [ndkenv which](#ndkenv-which)
  * [ndkenv whence](#ndkenv-whence)
* [Development](#development)
  * [Version History](#version-history)
  * [License](#license)

## How It Works

At a high level, ndkenv intercepts NDK commands using shim
executables injected into your `PATH`, determines which NDK version
has been specified by your application, and passes your commands along
to the correct NDK installation.

### Understanding PATH

When you run a command like `NDK` or `rake`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.

### Understanding Shims

ndkenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    ~/.ndkenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, ndkenv maintains shims in that
directory to match every NDK command across every installed version
of NDK—`ndk-build`, `ndk-gdb`, and so on.

Shims are lightweight executables that simply pass your command along
to ndkenv. So with ndkenv installed, when you run, say, `ndk-build`, your
operating system will do the following:

* Search your `PATH` for an executable file named `ndk-build`
* Find the ndkenv shim named `ndk-build` at the beginning of your `PATH`
* Run the shim named `ndk-build`, which in turn passes the command along to
  ndkenv

### Choosing the NDK Version

When you execute a shim, ndkenv determines which NDK version to use by
reading it from the following sources, in this order:

1. The `NDKENV_VERSION` environment variable, if specified. You can use
   the [`ndkenv shell`](#ndkenv-shell) command to set this environment
   variable in your current shell session.

2. The first `.ndk-version` file found by searching the directory of the
   script you are executing and each of its parent directories until reaching
   the root of your filesystem.

3. The first `.ndk-version` file found by searching the current working
   directory and each of its parent directories until reaching the root of your
   filesystem. You can modify the `.NDK-version` file in the current working
   directory with the [`ndkenv local`](#ndkenv-local) command.

4. The global `~/.ndkenv/version` file. You can modify this file using
   the [`ndkenv global`](#ndkenv-global) command. If the global version
   file is not present, ndkenv assumes you want to use the "system"
   NDK—i.e. whatever version would be run if ndkenv weren't in your
   path.

### Locating the NDK Installation

Once ndkenv has determined which version of NDK your application has
specified, it passes the command along to the corresponding NDK
installation.

Each NDK version is installed into its own directory under
`~/.ndkenv/versions`. For example, you might have these versions
installed:

* `~/.ndkenv/versions/r9d/`
* `~/.ndkenv/versions/r10-32/`
* `~/.ndkenv/versions/r10-64/`

Version names to ndkenv are simply the names of the directories in
`~/.ndkenv/versions`.

## Installation

### Basic GitHub Checkout

This will get you going with the latest version of ndkenv and make it
easy to fork and contribute any changes back upstream.

1. Check out ndkenv into `~/.ndkenv`.

    ~~~ sh
    $ git clone https://github.com/rinrinne/ndkenv.git ~/.ndkenv
    ~~~

2. Add `~/.ndkenv/bin` to your `$PATH` for access to the `ndkenv`
   command-line utility.

    ~~~ sh
    $ echo 'export PATH="$HOME/.ndkenv/bin:$PATH"' >> ~/.bash_profile
    ~~~

    **Ubuntu Desktop note**: Modify your `~/.bashrc` instead of `~/.bash_profile`.

    **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.

3. Add `ndkenv init` to your shell to enable shims and autocompletion.

    ~~~ sh
    $ echo 'eval "$(ndkenv init -)"' >> ~/.bash_profile
    ~~~

    _Same as in previous step, use `~/.bashrc` on Ubuntu, or `~/.zshrc` for Zsh._

4. Restart your shell so that PATH changes take effect. (Opening a new
   terminal tab will usually do it.) Now check if ndkenv was set up:

    ~~~ sh
    $ type ndkenv
    #=> "ndkenv is a function"
    ~~~

#### Upgrading

If you've installed ndkenv manually using git, you can upgrade your
installation to the cutting-edge version at any time.

~~~ sh
$ cd ~/.ndkenv
$ git pull
~~~

To use a specific release of ndkenv, check out the corresponding tag:

~~~ sh
$ cd ~/.ndkenv
$ git fetch
$ git checkout v0.1.0
~~~

### Installing NDK Versions

You can download NDK package that is suitable for your platform
from [Distribution page](http://developer.android.com/tools/sdk/ndk/index.html)
and extract it manually as a subdirectory of `~/.ndkenv/versions/`.
(You would need to rename `android-ndk` to version name.)
An entry in that directory can also be a symlink to a NDK version 
installed elsewhere on the filesystem. 
ndkenv doesn't care; it will simply treat any entry in the `versions/`
directory as a separate NDK version.

### Uninstalling NDK Versions

As time goes on, NDK versions you install will accumulate in your
`~/.ndkenv/versions` directory.

To remove old NDK versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
NDK version with the `ndkenv prefix` command, e.g. `ndkenv prefix
r9d`.

## Command Reference

Like `git`, the `ndkenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### ndkenv local

Sets a local application-specific NDK version by writing the version
name to a `.ndk-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `NDKENV_VERSION` environment variable or with the `ndkenv shell`
command.

    $ ndkenv local r9d

When run without a version number, `ndkenv local` reports the currently
configured local version. You can also unset the local version:

    $ ndkenv local --unset

Previous versions of ndkenv stored local version specifications in a
file named `.ndkenv-version`. For backwards compatibility, ndkenv will
read a local version specified in an `.ndkenv-version` file, but a
`.NDK-version` file in the same directory will take precedence.

### ndkenv global

Sets the global version of NDK to be used in all shells by writing
the version name to the `~/.ndkenv/version` file. This version can be
overridden by an project-specific `.ndk-version` file, or by
setting the `NDKENV_VERSION` environment variable.

    $ ndkenv global r9d

The special version name `system` tells ndkenv to use the system NDK
(detected by searching your `$PATH`).

When run without a version number, `ndkenv global` reports the
currently configured global version.

### ndkenv shell

Sets a shell-specific NDK version by setting the `NDKENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ ndkenv shell r9d

When run without a version number, `ndkenv shell` reports the current
value of `NDKENV_VERSION`. You can also unset the shell version:

    $ ndkenv shell --unset

Note that you'll need ndkenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`NDKENV_VERSION` variable yourself:

    $ export NDKENV_VERSION=r9d

### ndkenv versions

Lists all NDK versions known to ndkenv, and shows an asterisk next to
the currently active version.

    $ ndkenv versions
    * r9d (set by /Users/sam/.ndkenv/version)
      r10-32
      r10-64

### ndkenv version

Displays the currently active NDK version, along with information on
how it was set.

    $ ndkenv version
    r9d (set by /Volumes/37signals/basecamp/.ndk-version)

### ndkenv rehash

Installs shims for all NDK executables known to ndkenv (i.e.,
`~/.ndkenv/versions/*/*`). Run this command after you install a new
version of NDK.

    $ ndkenv rehash

### ndkenv which

Displays the full path to the executable that ndkenv will invoke when
you run the given command.

    $ ndkenv which ndk-build
    /Users/sam/.ndkenv/versions/r9d/ndk-build

### ndkenv whence

Lists all NDK versions with the given command installed.

    $ ndkenv whence ndk-build
    r9d
    r10-32
    r10-64

## Development

The ndkenv source code is [hosted on
GitHub](https://github.com/rinrinne/ndkenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are still not supported.

### Version History

**0.1.0** (September 8, 2013)

* Fork from rbenv HEAD(latest version is 0.4.0).
* Rename rbenv and Ruby related to ndkenv and NDK.
* Adjust executable directory.
* Remove plugin and hook feature.

### License

(The MIT license)

Copyright (c) 2014 rinrinne a.k.a. rin_ne

ndkenv users rbenv code.

> Copyright (c) 2013 Sam Stephenson
> 
> Permission is hereby granted, free of charge, to any person obtaining
> a copy of this software and associated documentation files (the
> "Software"), to deal in the Software without restriction, including
> without limitation the rights to use, copy, modify, merge, publish,
> distribute, sublicense, and/or sell copies of the Software, and to
> permit persons to whom the Software is furnished to do so, subject to
> the following conditions:
> 
> The above copyright notice and this permission notice shall be
> included in all copies or substantial portions of the Software.
> 
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
> LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
> OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
> WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

