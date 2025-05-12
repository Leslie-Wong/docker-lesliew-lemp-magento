#!/bin/sh
nginx -g 'daemon off;'
supervisord  -n -j /supervisord.pid
