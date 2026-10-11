#!/bin/bash
# Runs in webroot on every start, after Composer and before the web server starts.
# A failing command is reported in the console and the web server still starts.
#
# Laravel example:
# php artisan migrate --force
# php artisan optimize
