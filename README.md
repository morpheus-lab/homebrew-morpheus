# Morpheus-lab Morpheus

## How do I install these formulae?

`brew install morpheus-lab/morpheus/<formula>`

Or `brew tap morpheus-lab/morpheus` and then `brew install <formula>`.

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).

## Maintainer Guidelines

## Create Tap

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

The latest available GitHub workflows created with brew tap-new can be found under [`Homebrew/brew/Library/Homebrew/dev-cmd/tap-new.rb`](https://github.com/Homebrew/brew/blob/1a1aa3eed4ebda138f1f05806e957850c027eb4f/docs/Homebrew-homebrew-core-Maintainer-Guide.md).

### Add Locally Built Bottles

#### Generate Bottle

Prepare the formula for eventual bottling during installation, skipping any post-install steps:

    brew install morpheus --build-bottle

Generate a bottle (binary package) from a formula that was installed with
`--build-bottle` and write bottle information to a JSON file:

    brew bottle morpheus --no-rebuild --json

Now, add the new bottle block line to the formula, e.g.:

    sha256 arm64_monterey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"

Additional values such as `cellar: :any` can usually be omitted.

Alternatively, merge the new bottle block line with the existing formula using the `brew bottle` command:

    brew bottle --merge morpheus--x.x.x.arm64_monterey.bottle.json

Replace x.x.x with the correct version number.

#### Upload Bottle to GitHub

Set GitHub credentials:

    export HOMEBREW_GITHUB_PACKAGES_USER=morpheus-lab
    export HOMEBREW_GITHUB_PACKAGES_TOKEN=<personal access token>

Add bottle to release tag:

    brew pr-upload --upload-only --root-url="https://github.com/morpheus-lab/homebrew-morpheus/releases/download/morpheus-x.x.x"

Or upload bottle to GitHub Packages (Docker):

    brew pr-upload --upload-only --root-url="https://ghcr.io/v2/morpheus-lab/homebrew"

#### Commit 

Commit and push the updated bottle block for the formula. Provide a commit message in the style of:

    git commit -m "morpheus: add x.x.x bottle"

#### Alternative: Combine `brew bottle` + `brew pr-upload` steps

Run `brew bottle`, do not generate a new commit and upload to GitHub:

    brew pr-upload --no-commit --root-url="https://github.com/morpheus-lab/homebrew-morpheus/releases/download/morpheus-x.x.x"
