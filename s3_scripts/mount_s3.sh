#!/bin/bash
# Mount/Unmount S3 bucket: centralai-mlplatform-dev-use2
# Prefix: users/songwang/
# Mount point: /share5/users/song.wang/s3_mount
#
# Prerequisites:
#   conda install -c conda-forge s3fs-fuse
#
# Usage:
#   ./mount_s3.sh mount    # mount the bucket
#   ./mount_s3.sh unmount  # unmount the bucket
#   ./mount_s3.sh status   # check if mounted
#
# Before mounting, export your AWS credentials:
#   export AWS_ACCESS_KEY_ID="..."
#   export AWS_SECRET_ACCESS_KEY="..."
#   export AWS_SESSION_TOKEN="..."

BUCKET="centralai-mlplatform-dev-use2"
PREFIX="users/songwang"
MOUNT_POINT="/share5/users/song.wang/s3_mount"
REGION="us-east-2"

mount_s3() {
    if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
        echo "Already mounted at $MOUNT_POINT"
        return 0
    fi

    # Verify credentials are set
    if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
        echo "Error: AWS credentials not set. Export AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_SESSION_TOKEN first."
        return 1
    fi

    mkdir -p "$MOUNT_POINT"

    s3fs "${BUCKET}:/${PREFIX}" "$MOUNT_POINT" \
        -o url="https://s3.${REGION}.amazonaws.com" \
        -o use_session_token

    if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
        echo "Mounted s3://${BUCKET}/${PREFIX} at $MOUNT_POINT"
    else
        echo "Mount failed. Check your credentials and try again."
        return 1
    fi
}

unmount_s3() {
    if ! mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
        echo "Not currently mounted at $MOUNT_POINT"
        return 0
    fi

    fusermount -u "$MOUNT_POINT"
    echo "Unmounted $MOUNT_POINT"
}

status_s3() {
    if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
        echo "Mounted at $MOUNT_POINT"
        echo "Contents:"
        ls "$MOUNT_POINT"
    else
        echo "Not mounted"
    fi
}

case "${1:-}" in
    mount)   mount_s3 ;;
    unmount) unmount_s3 ;;
    status)  status_s3 ;;
    *)
        echo "Usage: $0 {mount|unmount|status}"
        echo ""
        echo "Remember to export AWS credentials before mounting."
        ;;
esac
