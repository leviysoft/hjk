# hjk

**hjk** is a simple yet flexible build tool for Scala and virtually any other language.

hjk is designed with the following principles in mind:

* **Nothing is hardcoded** - everything in hjk is configuration, built-in tasks are just statically served templates (we call them blueprints)
* **Nothing is special** - every single bit of configuration can be overridden by the user, hjk is not opinionated about anything
* **Extensibility gives the power** - hjk is designed to be extensible, you can add support for any reasonable tool with a few lines

Technically hjk is not a build tool, it's a, let's say, configurable launcher. For example, it leverages [Coursier](https://get-coursier.io/docs/cli-installation)
for resolving dependencies and running Scala compiler, but has no hardcoded knowledge about Scala or any other language.

hjk uses [Dhall](https://dhall-lang.org/) for configuration, which is a powerful typed configuration language.

## Installation

### Prerequisites

For building Scala (or other JVM languages) you need to install [Coursier](https://get-coursier.io/docs/cli-installation).
Only the `cs` command is required, `scala`, `scalac`, etc. are not required for installation.

### Getting hjk

You can download a precompiled hjk binary from the [releases page](https://github.com/leviysoft/hjk/releases).

If you want to build hjk from sources, you need to install [Stack](https://docs.haskellstack.org/en/stable/README/).
When you have stack installed, you can install hjk with `stack install`.

## Usage

You can find an example project using hjk [here](https://github.com/leviysoft/hjk-sample-project).
