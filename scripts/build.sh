#!/bin/bash
set -e

function startCmd {
    echo ""
    echo -e "\x1b[96m\x1b[1m$1\x1b[0m"
    echo -en "\x1b[2m"
}
function endCmd {
    echo -en "\x1b[0m\x1b[92mDone!\x1b[0m\n"
}

startCmd "Removing lib/*"
mkdir -p lib
rm -rf lib/*
endCmd

startCmd "Generating theme files"
./scripts/generate-scss.sh | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g"
node scripts/generate-theme-vars.js
endCmd

startCmd "Building library"
echo -en "\x1b[2m"
yarn vite build | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g"
endCmd

startCmd "Copy in raw files"
echo -en "\x1b[2m"
cp \
    src/lib/tailwind.preset.js \
    src/lib/styles/variables-theme.scss \
    package.json \
    lib/
endCmd

startCmd "Compile Tailwind entrypoint"
yarn -s sass src/lib/styles/index.scss lib/tailwind.css
# Remove source mappings from compiled SCSS
sed -i '/\/\*\# sourceMappingURL=tailwind.css.map \*\//d' lib/style.css
cat lib/style.css >> lib/tailwind.css
endCmd

startCmd "Remove unneccessary files"
rm -f lib/favicon.ico lib/style.css
endCmd

echo ""
