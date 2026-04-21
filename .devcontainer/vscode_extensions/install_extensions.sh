#!/bin/bash
echo "Installing VS Code extensions from extensions.txt..."
while read extension; do
    code --install-extension "$extension"
done < extensions.txt
echo "Done."
