#!/usr/bin/env bash
set -euo pipefail

readonly SWIFTLINT_VERSION="0.63.2"
readonly SWIFTFORMAT_VERSION="0.63.0"
readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Xcode build phases and CI do not inherit the interactive PATH: search the pinned
# download (scripts/install-swift-tools.sh) and Homebrew explicitly.
export PATH="$ROOT/.build/quality-tools/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

mode=lint
case "${1:-}" in
  "") ;;
  --fix) mode=fix ;;
  --format-only) mode=format-only ;;
  --add-marks) mode=add-marks ;;
  *) echo "Usage: scripts/lint-swift.sh [--fix | --format-only | --add-marks]" >&2; exit 2 ;;
esac

swift_paths=()
swift_path_count=0
submodule_paths=()
submodule_count=0

if [[ -f .gitmodules ]]; then
  while IFS= read -r line; do
    submodule_paths+=("${line#* }")
    submodule_count=$((submodule_count + 1))
  done < <(git config -f .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null || true)
fi

add_file() {
  local path="$1" existing submodule normalized="${1#./}"
  [[ -f "$path" && ! -L "$path" ]] || return 0
  if [[ "$submodule_count" -gt 0 ]]; then
    for submodule in "${submodule_paths[@]}"; do
      [[ "$normalized" != "$submodule" && "$normalized" != "$submodule/"* ]] || return 0
    done
  fi
  swift_path_count=$((swift_path_count + 1))
  if [[ "$swift_path_count" -gt 1 ]]; then
    for existing in "${swift_paths[@]}"; do
      if [[ "$existing" == "$path" ]]; then
        swift_path_count=$((swift_path_count - 1))
        return 0
      fi
    done
  fi
  swift_paths+=("$path")
}

add_swift_tree() {
  local tree="$1" path absolute_tree submodule normalized_tree="${1#./}"
  [[ -d "$tree" && ! -L "$tree" ]] || return 0
  absolute_tree="$ROOT/${tree#./}"
  if [[ "$submodule_count" -gt 0 ]]; then
    for submodule in "${submodule_paths[@]}"; do
      [[ "$normalized_tree" != "$submodule" && "$normalized_tree" != "$submodule/"* ]] || return 0
    done
  fi
  local -a find_args=("$absolute_tree")
  if [[ "$submodule_count" -gt 0 ]]; then
    for submodule in "${submodule_paths[@]}"; do
      find_args+=( -path "$ROOT/$submodule" -prune -o )
    done
  fi
  while IFS= read -r -d '' path; do
    add_file "${path#"$ROOT/"}"
  done < <(
    find "${find_args[@]}" \
      \( -type d \( -name .git -o -name .ai -o -name .build -o -name .swiftpm \
        -o -name .cache -o -name DerivedData \) -prune \) -o \
      \( -type f -name '*.swift' -print0 \)
  )
}

# SwiftPM and conventional project-root layouts.
add_swift_tree Sources
add_swift_tree Tests
add_file Package.swift

# Xcode projects commonly keep synchronized Sources/Tests roots inside the app.
while IFS= read -r -d '' app_root; do
  add_swift_tree "$app_root/Sources"
  add_swift_tree "$app_root/Tests"
done < <(
  find . -mindepth 1 -maxdepth 1 -type d \
    ! -name '.*' ! -name Packages -print0
)

if [[ -d Packages && ! -L Packages ]]; then
  while IFS= read -r -d '' package; do
    case "$(basename "$package")" in
      .ai|.build|.swiftpm|.cache|DerivedData|.git) continue ;;
    esac
    add_swift_tree "$package/Sources"
    add_swift_tree "$package/Tests"
    add_file "$package/Package.swift"
  done < <(find Packages -mindepth 1 -maxdepth 1 -type d -print0)
fi

if [[ "$swift_path_count" -eq 0 ]]; then
  echo "No Swift sources, tests, or Package.swift files found in supported project paths." >&2
  exit 1
fi

readonly INSTALL_HINT="run scripts/install-swift-tools.sh or brew install swiftlint swiftformat"

command -v swiftformat >/dev/null 2>&1 || {
  echo "SwiftFormat $SWIFTFORMAT_VERSION is required; $INSTALL_HINT." >&2
  exit 1
}
actual_swiftformat="$(swiftformat --version)"
[[ "$actual_swiftformat" == "$SWIFTFORMAT_VERSION" ]] || {
  echo "Expected SwiftFormat $SWIFTFORMAT_VERSION; found $actual_swiftformat ($INSTALL_HINT)." >&2
  exit 1
}

if [[ "$mode" == format-only ]]; then
  # Non-mutating layout check for Xcode build phases; SwiftLint runs as the build plugin.
  swiftformat --lint --quiet --config .swiftformat "${swift_paths[@]}"
  exit 0
fi

command -v swiftlint >/dev/null 2>&1 || {
  echo "SwiftLint $SWIFTLINT_VERSION is required; $INSTALL_HINT." >&2
  exit 1
}
command -v perl >/dev/null 2>&1 || {
  echo "perl is required by scripts/fix-swift-spacing.pl." >&2
  exit 1
}
actual_swiftlint="$(swiftlint version)"
[[ "$actual_swiftlint" == "$SWIFTLINT_VERSION" ]] || {
  echo "Expected SwiftLint $SWIFTLINT_VERSION; found $actual_swiftlint ($INSTALL_HINT)." >&2
  exit 1
}

if [[ "$mode" == add-marks ]]; then
  # Drafts the required type MARK sections; review the generated names before committing.
  command -v python3 >/dev/null 2>&1 || { echo "python3 is required by scripts/add-type-marks.py." >&2; exit 1; }
  python3 scripts/add-type-marks.py "${swift_paths[@]}"
  exit 0
fi

if [[ "$mode" == fix ]]; then
  # SwiftFormat owns layout; the spacing fixer inserts the blank lines SwiftFormat cannot
  # express; SwiftLint applies its correctable rules; a final SwiftFormat pass stabilizes.
  echo "Formatting Swift files at paths ${swift_paths[*]}"
  swiftformat --quiet --config .swiftformat "${swift_paths[@]}"
  perl scripts/fix-swift-spacing.pl "${swift_paths[@]}"
  swiftlint lint --fix --quiet --no-cache --config .swiftlint.yml "${swift_paths[@]}"
  swiftformat --quiet --config .swiftformat "${swift_paths[@]}"
  perl scripts/fix-swift-spacing.pl "${swift_paths[@]}"
  echo "Missing type MARK sections are not fixed here; scripts/lint-swift.sh --add-marks drafts them for review."
fi

echo "Linting Swift files at paths ${swift_paths[*]}"
swiftformat --lint --config .swiftformat "${swift_paths[@]}"
swiftlint lint --strict --no-cache --config .swiftlint.yml "${swift_paths[@]}"
