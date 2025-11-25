# Custom Functions

# Create directory and cd into it
function mkcd --description 'Create directory and cd into it'
    if test (count $argv) -eq 0
        echo "Usage: mkcd <directory>"
        return 1
    end
    mkdir -p $argv[1] && cd $argv[1]
end

# Extract archives
function extract --description 'Extract various archive formats'
    if test (count $argv) -eq 0
        echo "Usage: extract <archive_file>"
        echo "Supported: tar.bz2, tar.gz, tar.xz, tar.zst, bz2, rar, gz, tar, tbz2, tgz, zip, Z, 7z, xz, zst"
        return 1
    end

    if not test -f $argv[1]
        echo "Error: '$argv[1]' is not a valid file"
        return 1
    end

    switch $argv[1]
        case '*.tar.bz2'
            tar xjf $argv[1]
        case '*.tar.gz'
            tar xzf $argv[1]
        case '*.tar.xz'
            tar xJf $argv[1]
        case '*.tar.zst'
            tar --zstd -xf $argv[1]
        case '*.bz2'
            bunzip2 $argv[1]
        case '*.rar'
            if not command -q unrar
                echo "Error: 'unrar' required. Install: brew install unrar"
                return 1
            end
            unrar e $argv[1]
        case '*.gz'
            gunzip $argv[1]
        case '*.tar'
            tar xf $argv[1]
        case '*.tbz2'
            tar xjf $argv[1]
        case '*.tgz'
            tar xzf $argv[1]
        case '*.zip'
            unzip $argv[1]
        case '*.Z'
            uncompress $argv[1]
        case '*.7z'
            if not command -q 7z
                echo "Error: '7z' required. Install: brew install p7zip"
                return 1
            end
            7z x $argv[1]
        case '*.xz'
            xz -d $argv[1]
        case '*.zst'
            zstd -d $argv[1]
        case '*'
            echo "Error: '$argv[1]' - unknown archive format"
            return 1
    end
end

# Search in history (using native fish)
function hist --description 'Search command history'
    if test (count $argv) -eq 0
        echo "Usage: hist <search_term>"
        return 1
    end
    history search --contains $argv[1]
end

# Port usage
function port --description 'Show processes using a port'
    if test (count $argv) -eq 0
        echo "Usage: port <port_number>"
        return 1
    end
    lsof -i :$argv[1]
end

# Kill process on port
function killport --description 'Kill process using specified port'
    if test (count $argv) -eq 0
        echo "Usage: killport <port_number>"
        return 1
    end

    set -l pids (lsof -ti :$argv[1] 2>/dev/null)
    if test -z "$pids"
        echo "No process found on port $argv[1]"
        return 0
    end

    for pid in $pids
        kill -9 $pid 2>/dev/null
    end
    echo "Killed processes on port $argv[1]"
end
