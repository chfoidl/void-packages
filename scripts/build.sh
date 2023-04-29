#!/bin/bash

BINPKGS_DIR="/root/hostdir/binpkgs"

operation=$1

# Preemptive check.
if [ -z "$operation" ]; then
	echo "Please specify an operation as first argument. Supported operations: build"
	exit 1
fi

# Build command.
build() {
	help() {
		echo "./build.sh build <packages> --out <output-dir>"
	}

	pkgs=()

	while [[ $# -gt 0 ]]; do
		case $1 in
			-o|--out)
				outdir="$2"
				shift # past argument
				shift # past value
				;;
			-*|--*)
				help
				exit 1
				;;
			*)
				pkgs+=("$1") # save positional arg
				shift # past argument
				;;
		esac
	done

	if [ -z "$outdir" ]; then
		echo "Please specify an output directory with --out"
		exit 1
	fi

	if [ ${#pkgs[@]} -eq 0 ]; then
		echo "Please specify at least one package"
		exit 1
	fi

	sorted_pkgs=$(/hostrepo/xbps-src sort-dependencies "${pkgs[@]}")

	echo "Building packages: ${sorted_pkgs[@]}"

	for pkg in ${sorted_pkgs}; do
		/hostrepo/xbps-src -j$(nproc) -s -H "$HOME"/hostdir $arch $test pkg "$pkg"
		[ $? -eq 1 ] && exit 1
	done

	echo "Copying packages to $outdir"
	cp -R $BINPKGS_DIR/*.xbps "$outdir"
}

# Parse command.
case $operation in
	build)
		shift
		build $@
		;;
	*)
		echo "Unknown operation $operation"
		exit 1
		;;
esac

