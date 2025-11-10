# Docker Functions
# Docker cleanup and utility functions

function dockerclean --description 'Clean up Docker containers, images, and volumes'
    # Remove stopped containers
    set -l containers (docker ps -a -q)
    if test -n "$containers"
        docker rm $containers
    end

    # Remove unused images
    set -l images (docker images -q)
    if test -n "$images"
        docker rmi $images
    end

    # Remove dangling volumes
    set -l volumes (docker volume ls -f dangling=true -q)
    if test -n "$volumes"
        docker volume rm $volumes
    end
end