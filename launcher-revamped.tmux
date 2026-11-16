#!/bin/sh

launcher_revamped_dir=$(cd "$(dirname "$0")" && pwd)
"${launcher_revamped_dir}/bin/launcher-revamped" apply
