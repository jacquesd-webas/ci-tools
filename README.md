# ci-tools installer

This repo provides an `install.sh` script that copies the `ci/`, `env/`, and `github-workflows/` templates (plus a `make/Makefile`) into a target project while replacing `{{__VARNAME__}}` placeholders.

## Usage

Run from the repo root:

```sh
./install.sh
```

You will be prompted for:

- `APP_NAME` first.
- The project directory if it cannot be located automatically.
- Any remaining placeholder variables found in `ci/`, `env/`, and `github-workflows/`.

## Project directory lookup

The script looks for a directory named after `APP_NAME` in these locations:

- the current directory
- `../`
- `../*`
- `../*/*`

If no match is found, it will ask for the path to the project.

## What gets copied

- `ci/` -> `../<project_dir>/ci`
- `env/` -> `../<project_dir>/env`
- `github-workflows/` -> `../<project_dir>/.github/workflows`
- `make/Makefile` -> `../<project_dir>/make/Makefile` (only if missing)

All `{{__VARNAME__}}` placeholders are replaced with your provided values.

### Non-overwrite behavior

Existing `env/*.env` and `env/*.txt` files in the target project are preserved and will not be overwritten. The `make/Makefile` is only copied if it does not already exist.

Existing `env/*.env` and `env/*.txt` files in the target project are preserved and will not be overwritten.

## How to use in your repo

### Making your environment

Make sure to create any .env files where you want them:
```
$ touch api/.env
$ touch web/.env
$ make env
./env/make-env.sh  
No environment specified. Assuming 'local'
Wrote /Users/jacquesd/dev/myapp/env/../web/.env for local
Wrote /Users/jacquesd/dev/myapp/env/../api/.env for local
```
### Running scripts manually

Most of the scripts in ci/ should be able to be executed manually if you want to just run them eg.

```
$ ./ci/01_build_docker.sh api
```

### Creating tagged builds in the pipeline

For development deployment tag as -alpha eg.

```
$ git tag v0.5.0-alpha.1
$ git push --tags
```

For testing deployment tag as -beta eg.

```
$ git tag v0.5.0-beta.1
$ git push --tags
```

For production deployment just tag with the version eg.

```
$ git tag v1.0.0
$ git push --tags
```

Any other builds will be tagged with :latest.

### Deployment to the swarm

Deploment is run via manual trigger where you have to select the environment and the tag.

Remember that you can only run it on a tag, not a branch!

