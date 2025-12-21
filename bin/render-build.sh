#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
./bin/rails assets:precompile
./bin/rails assets:clean
./bin/rails db:migrate
./bin/rails runner "SystemAdmin.find_by(email: 'admin@urbaneye.co.ke')&.update(password: 'Reset123!', password_confirmation: 'Reset123!')"