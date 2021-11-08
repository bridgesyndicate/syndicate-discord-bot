#!/usr/bin/env bash

PATCH_DIR=$PWD
cd $(bundle info discordrb --path)
patch -p1 < $PATCH_DIR/interaction.rb.patch
