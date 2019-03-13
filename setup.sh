#!/bin/bash
groupadd -g "$GID" "$GROUP" && \
useradd -u "$UID" -s /bin/bash -g "$GROUP" "$USERNAME"
gosu $USERNAME $@
