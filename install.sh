#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH= cd "$(dirname "$0")" && pwd)"

TEMPLATE_DIRS="ci env github-workflows"

cat <<'EOF'
==============================================================================
WARNING: This script will overwrite some files.
Please ensure your project files are committed before installing the ci-tools.
==============================================================================
EOF

collect_vars() {
  for dir in $TEMPLATE_DIRS; do
    if [ -d "$SCRIPT_DIR/$dir" ]; then
      find "$SCRIPT_DIR/$dir" -type f 2>/dev/null
    fi
  done | while IFS= read -r file; do
    awk '
      {
        line = $0
        while (match(line, /{{__[A-Z0-9_]+__}}/)) {
          var = substr(line, RSTART + 4, RLENGTH - 8)
          print var
          line = substr(line, RSTART + RLENGTH)
        }
      }
    ' "$file"
  done
}

find_project_dir() {
  app="$1"
  base="$2"

  if [ "$(basename "$base")" = "$app" ]; then
    printf '%s\n' "$base"
    return 0
  fi

  if [ -d "$base/$app" ]; then
    (cd "$base/$app" && pwd)
    return 0
  fi

  if [ -d "$base/../$app" ]; then
    (cd "$base/../$app" && pwd)
    return 0
  fi

  for candidate in "$base"/../*/"$app" "$base"/../*/*/"$app"; do
    if [ -d "$candidate" ]; then
      (cd "$candidate" && pwd)
      return 0
    fi
  done

  return 1
}

escape_sed_repl() {
  printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

prompt_value() {
  var="$1"
  printf '%s: ' "$var"
  IFS= read -r value
  eval "$var=\$value"
}

ensure_dir() {
  dir="$1"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
  fi
}

copy_dir() {
  src_dir="$1"
  dest_dir="$2"

  if [ ! -d "$src_dir" ]; then
    return 0
  fi

  find "$src_dir" -type f | while IFS= read -r src; do
    rel="${src#"$src_dir"/}"
    dest="$dest_dir/$rel"
    if [ "$dest_dir" = "$PROJECT_DIR/env" ]; then
      case "$dest" in
        *.env|*.txt)
          if [ -f "$dest" ]; then
            echo "Skipping existing file: $dest"
            continue
          fi
          ;;
      esac
    fi
    ensure_dir "$(dirname "$dest")"
    sed -f "$SED_SCRIPT" "$src" > "$dest"
    if [ -x "$src" ]; then
      chmod +x "$dest"
    fi
  done
}

VARS="$(collect_vars | sort -u | tr '\n' ' ')"

prompt_value "APP_NAME"

PROJECT_DIR="$(find_project_dir "$APP_NAME" "$PWD" || true)"
if [ -z "$PROJECT_DIR" ]; then
  while [ -z "$PROJECT_DIR" ]; do
    printf 'Project path: '
    IFS= read -r input_path
    if [ -z "$input_path" ]; then
      continue
    fi
    if [ -d "$input_path" ]; then
      PROJECT_DIR="$(cd "$input_path" && pwd)"
    elif [ -d "$PWD/$input_path" ]; then
      PROJECT_DIR="$(cd "$PWD/$input_path" && pwd)"
    else
      echo "Path not found: $input_path" >&2
    fi
  done
else
  echo "Found project directory: $PROJECT_DIR"
fi

case " $VARS " in
  *" APP_NAME "*) ;;
  *) VARS="APP_NAME $VARS" ;;
esac

for VAR in $VARS; do
  if [ "$VAR" = "APP_NAME" ]; then
    continue
  fi
  prompt_value "$VAR"
done

SED_SCRIPT="$(mktemp)"
trap 'rm -f "$SED_SCRIPT"' EXIT

for VAR in $VARS; do
  VALUE="$(eval "printf '%s' \"\${$VAR}\"")"
  ESCAPED="$(escape_sed_repl "$VALUE")"
  printf 's|{{__%s__}}|%s|g\n' "$VAR" "$ESCAPED" >> "$SED_SCRIPT"
done

ensure_dir "$PROJECT_DIR/ci"
ensure_dir "$PROJECT_DIR/env"
ensure_dir "$PROJECT_DIR/.github/workflows"

copy_dir "$SCRIPT_DIR/ci" "$PROJECT_DIR/ci"
copy_dir "$SCRIPT_DIR/env" "$PROJECT_DIR/env"
copy_dir "$SCRIPT_DIR/github-workflows" "$PROJECT_DIR/.github/workflows"

echo "Installed ci/, env/, and .github/workflows into $PROJECT_DIR"
