#!/bin/bash

echo "Checking for Flutter..."
if [ -d "flutter" ]; then
    cd flutter && git pull && cd ..
else
    git clone https://github.com/flutter/flutter.git -b stable
fi

echo "Flutter version:"
./flutter/bin/flutter --version

echo "Building web app..."
./flutter/bin/flutter config --enable-web
./flutter/bin/flutter build web --release

echo "Build complete!"
