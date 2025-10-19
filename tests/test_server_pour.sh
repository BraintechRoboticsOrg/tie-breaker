#!/usr/bin/env bash
echo 'Server pour test executing ...'
bash src/loader/pour_loader.sh || echo 'Server test failed'
