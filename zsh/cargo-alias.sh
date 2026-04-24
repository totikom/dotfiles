#set -exo pipefail
export RUST_BUILD_BASE="$HOME/.cache/builds/rust-builds"
WORKSPACE_ROOT=$(cargo metadata --no-deps --offline 2>/dev/null | jq -r ".workspace_root")
PACKAGE_BASENAME=$(basename $WORKSPACE_ROOT)
TARGET_DIRECTORY=$(cargo metadata --no-deps --offline 2>/dev/null | jq -r ".target_directory")

if [ $TARGET_DIRECTORY == "$WORKSPACE_ROOT/target" ]; then
	#echo "Changed target to $RUST_BUILD_BASE/$PACKAGE_BASENAME"
	CARGO_TARGET_DIR="$RUST_BUILD_BASE/$PACKAGE_BASENAME" cargo $@
else 
	#echo "Non-default target location, no change applied"
	cargo $@
fi

