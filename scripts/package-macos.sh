#!/bin/sh
set -e

root_dir=$(pwd)
build_dir=${root_dir}/build
cache_dir=${build_dir}/cache
build_file=${build_dir}/synthein-${SYNTHEIN_VERSION}-macos.zip
love_file=${build_dir}/synthein-${SYNTHEIN_VERSION}.love

. "${root_dir}/scripts/util.sh"

if [ ! -f "$love_file" ]; then
	echo "Need to build the .love file first."
	exit 1
fi
if [ ! -d "${cache_dir}" ]; then
	mkdir "${cache_dir}"
fi

echo "Getting MacOS LÖVE binary."
cd "${cache_dir}"

love_zip=love-${LOVE_VERSION}-macos.zip
dlcache "https://github.com/love2d/love/releases/download/${LOVE_VERSION}/${love_zip}"
unzip "${love_zip}"

echo "Building MacOS package."
app_dir="${build_dir}/synthein.app"

cp -aR "${cache_dir}/love.app/" "$app_dir"
cp "$love_file" "${app_dir}/Contents/Resources/"
cp "${root_dir}/package/Info.plist" "${app_dir}/Contents/"

cd "$build_dir"
zip -ry "$build_file" synthein.app

# Clean up.
rm -r "${cache_dir}/love.app"
rm -r "$app_dir"

echo "Built ${build_file}."
