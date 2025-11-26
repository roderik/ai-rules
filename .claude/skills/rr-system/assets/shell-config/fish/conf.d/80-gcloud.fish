# Google Cloud SDK shell integration
# Static path setup - avoids expensive path.fish.inc script

# Detect and set up Google Cloud SDK (static paths, no subprocess)
if test -d "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
    # Apple Silicon Mac
    set -gx GCLOUD_SDK_PATH "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
    fish_add_path -gP "$GCLOUD_SDK_PATH/bin"
else if test -d "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
    # Intel Mac
    set -gx GCLOUD_SDK_PATH "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
    fish_add_path -gP "$GCLOUD_SDK_PATH/bin"
end