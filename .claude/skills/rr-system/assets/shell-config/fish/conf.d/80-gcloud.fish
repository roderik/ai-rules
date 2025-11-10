#!/usr/bin/env fish
# Google Cloud SDK shell integration

# Detect Google Cloud SDK installation path
if test -d "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
    # Apple Silicon Mac
    set -x GCLOUD_SDK_PATH "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
else if test -d "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
    # Intel Mac
    set -x GCLOUD_SDK_PATH "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
end

# Source Google Cloud SDK if available
if test -n "$GCLOUD_SDK_PATH"
    # Add gcloud to PATH
    if test -f "$GCLOUD_SDK_PATH/path.fish.inc"
        source "$GCLOUD_SDK_PATH/path.fish.inc"
    end
end