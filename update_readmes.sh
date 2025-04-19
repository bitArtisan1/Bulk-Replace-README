#!/usr/bin/env bash
#

# User-configurable parameters
REPO_NAME="CapScript"  # Name of the repository to update
USER="bitArtisan1"     # GitHub username
KOFI_URL="https://ko-fi.com/D1D11CZNM1"  # Your Ko-fi URL

# Optional Git configuration
GIT_NAME=""  # Optional git user.name for commit
GIT_EMAIL="" # Optional git user.email for commit

echo "=== Processing $USER/$REPO_NAME ==="

# Create a clean temporary directory
WORK_DIR=$(pwd)/temp_repo_work
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR" || exit 1

# Clone the repository
echo "Cloning repository..."
git clone "https://github.com/$USER/$REPO_NAME.git" 2>/dev/null

# Check if clone was successful
if [ ! -d "$REPO_NAME" ]; then
    echo "Error: Failed to clone repository. Please check the repository name and your permissions."
    cd .. && rm -rf "$WORK_DIR"
    exit 1
fi

# Change to the repository directory
cd "$REPO_NAME" || exit 1

# Configure Git user identity if provided
[ -n "$GIT_NAME" ] && git config user.name "$GIT_NAME"
[ -n "$GIT_EMAIL" ] && git config user.email "$GIT_EMAIL"

# Check if README.md exists
if [ ! -f "README.md" ]; then
    echo "README.md not found in this repository. Exiting."
    cd ../.. && rm -rf "$WORK_DIR"
    exit 1
fi

echo "Updating README.md..."

# Create backup of README
cp README.md README.md.backup

# Define the new Ko-fi badge blocks
KOFI_BLOCK1="<p align=\"center\">
  <a href=\"${KOFI_URL}\">
    <img src=\"https://ko-fi.com/img/githubbutton_sm.svg\" alt=\"Support me on Ko-fi\" />
  </a>
</p>"

KOFI_BLOCK2="<a href=\"${KOFI_URL}\">
  <img src=\"https://github.com/user-attachments/assets/ba118768-9054-416f-b7b2-adaa69a53434\" alt=\"Support me on Ko-fi\" width=\"200\" />
</a>"

# Look for the patterns and report if found
echo "Checking for badge patterns..."
PATTERN1_FOUND=false
PATTERN2_FOUND=false

# Initialize variables to prevent errors
DIV_START_LINE=""
DIV_END_LINE=""
BUYME_LINES=()

# Use grep with context to identify the exact div block
if grep -q '<div align="right">' README.md; then
    echo "- Found 'div align=right' pattern"
    PATTERN1_FOUND=true
    
    # Find the start line of the div
    DIV_START_LINE=$(grep -n '<div align="right">' README.md | cut -d':' -f1)
    
    # Create a temporary file with numbered lines to help find the end
    nl -ba README.md > README.nl
    
    # Extract the div section by balancing tags (simpler approach)
    DIV_END_LINE=""
    OPEN_TAGS=1
    CURRENT_LINE=$DIV_START_LINE
    
    while [ $OPEN_TAGS -gt 0 ] && [ $CURRENT_LINE -le $(wc -l < README.md) ]; do
        CURRENT_LINE=$((CURRENT_LINE + 1))
        LINE_CONTENT=$(sed -n "${CURRENT_LINE}p" README.md)
        
        # Count opening and closing div tags
        OPEN_DIVS=$(echo "$LINE_CONTENT" | grep -o '<div' | wc -l)
        CLOSE_DIVS=$(echo "$LINE_CONTENT" | grep -o '</div>' | wc -l)
        
        OPEN_TAGS=$((OPEN_TAGS + OPEN_DIVS - CLOSE_DIVS))
        
        if [ $OPEN_TAGS -eq 0 ]; then
            DIV_END_LINE=$CURRENT_LINE
            break
        fi
    done
    
    # If we found a balanced div
    if [ -n "$DIV_END_LINE" ]; then
        echo "- Found balanced div from line $DIV_START_LINE to $DIV_END_LINE"
        
        # Print the div content for debug
        sed -n "${DIV_START_LINE},${DIV_END_LINE}p" README.md > div_content.txt
        echo "- Original div content (first 5 lines):"
        head -n 5 div_content.txt
        
        # Count lines to ensure we don't replace too much
        DIV_LINES=$(wc -l < div_content.txt)
        if [ $DIV_LINES -gt 20 ]; then
            echo "⚠️ Warning: The div block is $DIV_LINES lines long! This seems excessive for a badge."
            echo "  Only the first 10 lines:"
            head -n 10 div_content.txt
            echo "  Are you sure this is just a badge? (y/n)"
            read -r CONFIRM
            if [ "$CONFIRM" != "y" ]; then
                echo "Aborting replacement for safety."
                DIV_START_LINE=""
                DIV_END_LINE=""
                PATTERN1_FOUND=false
            fi
        fi
    else
        echo "⚠️ Could not find a balanced div tag. Will skip this replacement."
        PATTERN1_FOUND=false
    fi
fi

# For the BuyMeACoffee link, find all instances
if grep -q 'buymeacoffee\.com/bitArtisan' README.md; then
    echo "- Found BuyMeACoffee link pattern"
    PATTERN2_FOUND=true
    
    # Get all lines containing buymeacoffee links
    readarray -t BUYME_LINES < <(grep -n 'buymeacoffee\.com/bitArtisan' README.md | cut -d':' -f1)
    echo "- Found ${#BUYME_LINES[@]} BuyMeACoffee links at lines: ${BUYME_LINES[*]}"
    
    # Process each link
    for i in "${!BUYME_LINES[@]}"; do
        BUYME_LINE="${BUYME_LINES[$i]}"
        echo "- Processing BuyMeACoffee link at line $BUYME_LINE"
        
        # Show context around the link
        echo "- Link context:"
        sed -n "$((BUYME_LINE-2)),$((BUYME_LINE+2))p" README.md
        
        # Extract the entire <a> tag content
        # For simplicity, we'll just use a basic approach: find the nearest <a> before and </a> after
        START_LINE=$BUYME_LINE
        END_LINE=$BUYME_LINE
        
        # Look for the opening <a tag
        while [ "$START_LINE" -ge 1 ]; do
            if grep -q '<a ' <(sed -n "${START_LINE}p" README.md); then
                break
            fi
            START_LINE=$((START_LINE - 1))
            # Safety check to avoid infinite loops
            if [ "$((BUYME_LINE - START_LINE))" -gt 10 ]; then
                echo "⚠️ Could not find opening <a> tag within 10 lines. Using line $BUYME_LINE as fallback."
                START_LINE=$BUYME_LINE
                break
            fi
        done
        
        # Look for the closing </a> tag
        while [ "$END_LINE" -le "$(wc -l < README.md)" ]; do
            if grep -q '</a>' <(sed -n "${END_LINE}p" README.md); then
                break
            fi
            END_LINE=$((END_LINE + 1))
            # Safety check
            if [ "$((END_LINE - BUYME_LINE))" -gt 10 ]; then
                echo "⚠️ Could not find closing </a> tag within 10 lines. Using line $BUYME_LINE as fallback."
                END_LINE=$BUYME_LINE
                break
            fi
        done
        
        echo "- Link found from line $START_LINE to $END_LINE"
        
        # Store the line ranges for later replacement
        BUYME_START_LINES[$i]=$START_LINE
        BUYME_END_LINES[$i]=$END_LINE
    done
fi

# Apply replacements if patterns were found
if [ "$PATTERN1_FOUND" = true ] || [ "$PATTERN2_FOUND" = true ]; then
    echo "Applying replacements..."
    
    # Make a working copy
    cp README.md README.new
    
    # Replace the first pattern (div)
    if [ "$PATTERN1_FOUND" = true ] && [ -n "$DIV_START_LINE" ] && [ -n "$DIV_END_LINE" ]; then
        echo "Replacing div block (lines $DIV_START_LINE-$DIV_END_LINE)..."
        
        # Extract parts before and after the div
        head -n $((DIV_START_LINE-1)) README.md > part1.txt
        tail -n +$((DIV_END_LINE+1)) README.md > part2.txt
        
        # Create the new file
        cat part1.txt > README.new
        echo "$KOFI_BLOCK1" >> README.new
        cat part2.txt >> README.new
    fi
    
    # Replace BuyMeACoffee links
    if [ "$PATTERN2_FOUND" = true ] && [ "${#BUYME_LINES[@]}" -gt 0 ]; then
        # We need to handle replacements differently if we've already made changes
        # Rebuild README, starting with the first replacement we already did
        CURRENT_FILE="README.new"
        
        # For each BuyMeACoffee link
        for i in "${!BUYME_LINES[@]}"; do
            START_LINE="${BUYME_START_LINES[$i]}"
            END_LINE="${BUYME_END_LINES[$i]}"
            
            # Skip if we couldn't find proper tag boundaries
            if [ -z "$START_LINE" ] || [ -z "$END_LINE" ]; then
                echo "⚠️ Skipping replacement for link $i - incomplete tag boundaries"
                continue
            fi
            
            echo "Replacing BuyMeACoffee link $i (lines $START_LINE-$END_LINE)..."
            
            # Adjust line numbers if we've already replaced content
            if [ "$CURRENT_FILE" = "README.new" ] && [ "$PATTERN1_FOUND" = true ]; then
                # Calculate line shift from the div replacement
                ORIGINAL_DIV_LINES=$((DIV_END_LINE - DIV_START_LINE + 1))
                NEW_DIV_LINES=$(echo "$KOFI_BLOCK1" | wc -l)
                LINE_SHIFT=$((NEW_DIV_LINES - ORIGINAL_DIV_LINES))
                
                # Only adjust if the BuyMeACoffee link comes after the div
                if [ "$START_LINE" -gt "$DIV_END_LINE" ]; then
                    START_LINE=$((START_LINE + LINE_SHIFT))
                    END_LINE=$((END_LINE + LINE_SHIFT))
                    echo "- Adjusted lines to $START_LINE-$END_LINE after previous replacement"
                fi
            fi
            
            # Extract parts before and after the link
            head -n $((START_LINE-1)) "$CURRENT_FILE" > part1.txt
            tail -n +$((END_LINE+1)) "$CURRENT_FILE" > part2.txt
            
            # Create the new file
            cat part1.txt > README.updated
            echo "$KOFI_BLOCK2" >> README.updated
            cat part2.txt >> README.updated
            mv README.updated "$CURRENT_FILE"
        done
    fi
    
    # Move the new file back to README.md
    mv "$CURRENT_FILE" README.md
    
    # Check if the file changed
    if ! diff -q README.md README.md.backup > /dev/null; then
        echo "Changes applied successfully. Committing..."
        git add README.md
        git commit -m "chore: replace BuyMeACoffee badges with Ko‑fi badges"
        
        echo "Pushing changes..."
        git push origin main
        
        echo "Repository updated successfully!"
    else
        echo "No changes were made to the file."
    fi
else
    echo "No matching badge patterns found in README.md."
fi

# Clean up temporary files
rm -f README.nl part1.txt part2.txt div_content.txt link_tag.txt buymeacoffee_context.txt

# Clean up work directory
cd ../..
rm -rf "$WORK_DIR"

echo "Script completed."
