#!/bin/sh

# fail fast
set -e -u

# Locking code retrieved from http://stackoverflow.com/a/1985512 on 2017-03-17
LOCK_FILE=/tmp/$( md5sum "$0" | awk '{print $1}' ).lock
LOCK_FD=99
_lock() {
    flock -$1 $LOCK_FD;
}
_no_more_locking() {
    _lock u;
    _lock xn && rm -f $LOCK_FILE;
}
lock() {
    eval "exec $LOCK_FD>\"$LOCK_FILE\"";
    trap _no_more_locking EXIT;

    # Obtain an exclusive lock immediately or fail
    _lock xn;
}

# Only run one copy of the script at a time
echo "$( date +'%Y/%m/%d %H:%M:%S' ) Checking process lock"
lock || exit 1

# Clean up empty directories in order to speed up rclone
echo "$( date +'%Y/%m/%d %H:%M:%S' ) Tidying empty directories in $SOURCE"
find "$SOURCE" -mindepth 2 -depth -not -path '*/\.*' -type d -exec rmdir -p --ignore-fail-on-non-empty {} \;

if [[ ! -z "$RCLONE_RC_URL" ]]; then
    echo "$( date +'%Y/%m/%d %H:%M:%S' ) Storing cached directories"
    cd "$SOURCE"
    find . -type f -exec dirname {} \; | grep -v "\.unionfs" | sort | uniq > /tmp/rclone-cached-dirs.txt
fi

echo -e "$( date +'%Y/%m/%d %H:%M:%S' ) rclone $CONFIG_OPTS $COMMAND $COMMAND_OPTS $SOURCE $DESTINATION"
rclone $CONFIG_OPTS $COMMAND $COMMAND_OPTS "$SOURCE" "$DESTINATION"

if [[ ! -z "$RCLONE_RC_URL" ]]; then
    echo "$( date +'%Y/%m/%d %H:%M:%S' ) Expiring Rclone cache for recently uploaded files"
    while read dir; do
        curl --silent --request POST --data-urlencode "dir=$dir" "$RCLONE_RC_URL/vfs/forget"
    done </tmp/rclone-cached-dirs.txt
fi
rm -f /tmp/rclone-cached-dirs.txt

if [[ ! -z "$HEALTH_URL" ]]; then
  echo "$( date +'%Y/%m/%d %H:%M:%S' ) Pinging $HEALTH_URL"
  curl --silent $HEALTH_URL
fi

