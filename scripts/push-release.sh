#!/bin/bash
git push gitlab && \
    git push origin && \
    git push --tags origin
