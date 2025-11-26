# Google Cloud SDK shell integration
# Static path setup - avoids expensive path.bash.inc script

# Detect and set up Google Cloud SDK (static paths, no subprocess)
if [[ -d "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk" ]]; then
  # Apple Silicon Mac
  export GCLOUD_SDK_PATH="/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
  export PATH="$GCLOUD_SDK_PATH/bin:$PATH"
elif [[ -d "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk" ]]; then
  # Intel Mac
  export GCLOUD_SDK_PATH="/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
  export PATH="$GCLOUD_SDK_PATH/bin:$PATH"
fi

# Load completions if SDK is available (completion file is lightweight)
if [[ -n "$GCLOUD_SDK_PATH" && -f "$GCLOUD_SDK_PATH/completion.bash.inc" ]]; then
  source "$GCLOUD_SDK_PATH/completion.bash.inc"
fi