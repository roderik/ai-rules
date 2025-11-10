#!/usr/bin/env zsh
# Google Cloud SDK shell integration

# Detect Google Cloud SDK installation path
if [[ -d "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk" ]]; then
  # Apple Silicon Mac
  GCLOUD_SDK_PATH="/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
elif [[ -d "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk" ]]; then
  # Intel Mac
  GCLOUD_SDK_PATH="/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
fi

# Source Google Cloud SDK if available
if [[ -n "$GCLOUD_SDK_PATH" ]]; then
  # The path.zsh.inc file adds gcloud to PATH
  if [[ -f "$GCLOUD_SDK_PATH/path.zsh.inc" ]]; then
    source "$GCLOUD_SDK_PATH/path.zsh.inc"
  fi
  
  # The completion.zsh.inc file adds shell command completion for gcloud
  if [[ -f "$GCLOUD_SDK_PATH/completion.zsh.inc" ]]; then
    source "$GCLOUD_SDK_PATH/completion.zsh.inc"
  fi
fi