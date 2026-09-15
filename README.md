# Offline POS

Offline-first Android Point of Sale application built with Flutter.

## Architecture

- Clean MVVM
- Provider
- SQLite / sqflite
- Repository pattern
- Offline-first local database
- Retail POS
- F&B POS
- Restaurant tables
- Shift / Kas Harian
- Bluetooth thermal printer
- ESC/POS 58mm / 80mm
- Mobile barcode / QR scanner
- USB HID scanner listener
- GitHub Actions CI/CD

## Database

SQLite database:

- users
- categories
- products
- product_variants
- orders
- order_items
- restaurant_tables
- shifts

## Default User

Username:

admin

Password:

admin

This is a local demo account and should be replaced with a secure authentication implementation before production deployment.

## Build

The source tree is intentionally generated without running any Flutter command from the setup script.

Cloud CI/CD performs dependency installation and APK compilation through GitHub Actions.
