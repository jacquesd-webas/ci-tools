# ci-tools installer

This repo provides an `install.sh` script that copies the `ci/`, `env/`, and `github-workflows/` templates into a target project while replacing `{{__VARNAME__}}` placeholders.

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

All `{{__VARNAME__}}` placeholders are replaced with your provided values.

### Non-overwrite behavior

Existing `env/*.env` and `env/*.txt` files in the target project are preserved and will not be overwritten.
