# Morpheus Homebrew Tap

## User Guide
### Install Homebrew

[Homebrew](https://brew.sh/) is a free and open-source package manager for macOS that lets you easily install Morpheus and keep it up-to-date.

If not already done, install Homebrew first.

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

### Install Morpheus

#### 1. Tap

If you have never used Homebrew to install Morpheus before, add this Morpheus tap first:

    brew tap morpheus-lab/tap

#### 2. Install

Simply install the latest version of Morpheus with:

    brew install morpheus

And follow possibly emerging instructions from Homebrew.

#### 3. Launch

Start morpheus from the command line by typing:

    morpheus-gui

### Update Morpheus

First, update the formulae and Homebrew itself:

    brew update

Find out what is outdated with:

    brew outdated

Upgrade everything with:

    brew upgrade

Or upgrade only Morpheus with:

    brew upgrade morpheus

More information about updating and, if desired, how to prevent Morpheus from being automatically updated by Homebrew, etc. can be found in the [Homebrew FAQ](https://docs.brew.sh/FAQ).

### Install Specific Version of Morpheus

To install a specific version of Morpheus, you can append the desired version number with ```@<VERSION>```:

    brew install morpheus@<VERSION>

An example would be: ```brew install morpheus@2.2.0b3```.

To list all versions available online, you can simply do a ```brew search```:

    brew search morpheus

### Uninstall Morpheus

Delete Morpheus with:

    brew uninstall morpheus

Forcibly remove Morpheus along with deleting all it's versions:

    brew uninstall --force morpheus

## Maintainer Guidelines

### Create Tap

    brew tap-new morpheus-lab/morpheus

### To add a new formula for `foo` version `2.3.4` from `$URL`

* read [the Formula Cookbook](https://docs.brew.sh/Formula-Cookbook) or: `brew create $URL` and make edits
* `brew install --build-from-source foo`
* `brew audit --new-formula foo`
* `git commit` with message formatted `foo 2.3.4 (new formula)`
* [open a pull request](https://brew.sh/2020/11/18/homebrew-tap-with-bottles-uploaded-to-github-releases/) and fix any failing tests

### Publish Automatically Built Bottles

When a pull request making changes to a formula (or formulae) becomes green (all checks passed), then you can publish the built bottles. To do so, label your PR as `pr-pull` and the workflow will be triggered.

### Get GitHub Workflows

The latest available GitHub workflows created with brew tap-new can be found under [`Homebrew/brew/Library/Homebrew/dev-cmd/tap-new.rb`](https://github.com/Homebrew/brew/blob/master/Library/Homebrew/dev-cmd/tap-new.rb).

See also the [Homebrew-Core Maintainer Guide](https://github.com/Homebrew/brew/blob/master/docs/Homebrew-homebrew-core-Maintainer-Guide.md).

### Add Locally Built Bottles

#### Generate Bottle

Prepare the formula for eventual bottling during installation, skipping any post-install steps:

    brew install --build-bottle morpheus

Generate a bottle (binary package) from a formula that was installed with
`--build-bottle` and write bottle information to a JSON file:

    brew bottle --no-rebuild --json morpheus

Now, add the new bottle block line to the formula, e.g.:

    sha256 arm64_monterey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"

Additional values such as `cellar: :any` can [usually be omitted](https://docs.brew.sh/Bottles#cellar-cellar).

Alternatively, merge the new bottle block line with the existing formula using the `brew bottle` command:

    brew bottle --merge morpheus--<VERSION>.<OS>.bottle.json

Replace `<VERSION>` with the correct version number.

#### Upload Bottle to GitHub

Set GitHub credentials:

    export HOMEBREW_GITHUB_PACKAGES_USER=morpheus-lab
    export HOMEBREW_GITHUB_PACKAGES_TOKEN=<YOUR_PERSONAL_ACCESS_TOKEN>

Add bottle to release tag:

    brew pr-upload --upload-only --root-url="https://github.com/morpheus-lab/homebrew-morpheus/releases/download/morpheus-VERSION"

Or upload bottle to GitHub Packages (Docker):

    brew pr-upload --upload-only --root-url="https://ghcr.io/v2/morpheus-lab/homebrew"

#### Check & Commit

Check formula for Homebrew coding style violations:

    brew audit morpheus

Or check the whole tap:

    brew audit --tap morpheus-lab/morpheus

If necessary, let `brew` fix them automatically:

    brew audit --fix morpheus

Check formulae for conformance to Homebrew style guidelines:

    brew style morpheus-lab/morpheus

Fix style violations automatically using:

    brew style --fix morpheus-lab/morpheus

Commit and push the updated bottle block for the formula. Provide a commit message in the style of:

    git commit -m "morpheus: add <VERSION> bottle (<OS/ARCHITECTURE>)"

Replace `<VERSION>` and `<OS/ARCHITECTURE>` with the corresponding values.

#### Alternative: Combine `brew bottle` + `brew pr-upload` steps

Run `brew bottle`, do not generate a new commit and upload to GitHub:

    brew pr-upload --no-commit --root-url="https://github.com/morpheus-lab/homebrew-morpheus/releases/download/morpheus-VERSION"
