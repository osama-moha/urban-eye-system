#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
./bin/rails assets:precompile
./bin/rails assets:clean
./bin/rails db:migrate
./bin/rails runner "SystemAdmin.where(email: 'admin@urbaneye.co.ke').first_or_initialize.update!(password: 'Reset123!', password_confirmation: 'Reset123!')"