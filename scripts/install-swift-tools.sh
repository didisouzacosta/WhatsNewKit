#!/usr/bin/env bash
# Downloads the SwiftLint and SwiftFormat releases pinned in scripts/lint-swift.sh into
# .build/quality-tools/bin, which scripts/lint-swift.sh adds to PATH. Use it in CI
# (GitHub Actions, Xcode Cloud ci_post_clone.sh) or locally instead of Homebrew when
# the exact versions are required.
set -euo pipefail

readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly GATE="$ROOT/scripts/lint-swift.sh"
readonly TOOLS="$ROOT/.build/quality-tools"

swiftlint_version="$(sed -n 's/^readonly SWIFTLINT_VERSION="\(.*\)"$/\1/p' "$GATE")"
swiftformat_version="$(sed -n 's/^readonly SWIFTFORMAT_VERSION="\(.*\)"$/\1/p' "$GATE")"
[[ -n "$swiftlint_version" && -n "$swiftformat_version" ]] || {
  echo "Could not read the pinned tool versions from $GATE." >&2
  exit 1
}

downloads="$(mktemp -d "${TMPDIR:-/tmp}/swift-tools.XXXXXX")"
trap 'rm -rf "$downloads"' EXIT INT TERM

download() {
  local url="$1" binary="$2" name="$3"
  curl --fail --location --silent --show-error "$url" --output "$downloads/$name.zip"
  unzip -q "$downloads/$name.zip" -d "$downloads/$name"
  cp "$downloads/$name/$binary" "$downloads/bin-$name"
  chmod +x "$downloads/bin-$name"
}

download "https://github.com/realm/SwiftLint/releases/download/$swiftlint_version/portable_swiftlint.zip" \
  swiftlint swiftlint
download "https://github.com/nicklockwood/SwiftFormat/releases/download/$swiftformat_version/swiftformat.zip" \
  swiftformat swiftformat

[[ "$("$downloads/bin-swiftlint" version)" == "$swiftlint_version" ]] || {
  echo "Downloaded SwiftLint does not report $swiftlint_version." >&2
  exit 1
}
[[ "$("$downloads/bin-swiftformat" --version)" == "$swiftformat_version" ]] || {
  echo "Downloaded SwiftFormat does not report $swiftformat_version." >&2
  exit 1
}

mkdir -p "$TOOLS/bin"
# Keep the downloaded binaries out of Git even when the consumer does not ignore .build.
printf '*\n' > "$TOOLS/.gitignore"
mv -f "$downloads/bin-swiftlint" "$TOOLS/bin/swiftlint"
mv -f "$downloads/bin-swiftformat" "$TOOLS/bin/swiftformat"

echo "Installed SwiftLint $swiftlint_version and SwiftFormat $swiftformat_version in $TOOLS/bin"
