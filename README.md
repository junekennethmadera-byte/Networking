# Database Setup

This version can save data to MySQL through `api.php`.

## 1. Create the database

Open phpMyAdmin or MySQL, then import/run:

```sql
schema.sql
```

This creates the `liquidation_tracker` database and the `app_state` table.

## 2. Check database credentials

Edit `db.php` if your MySQL username or password is different:

```php
const DB_USER = 'root';
const DB_PASS = '';
```

The default values match a common local XAMPP setup.

## 3. Run through a PHP server

Place this folder inside your web server folder, for example:

```text
C:\xampp\htdocs\liquidation
```

Then open:

```text
http://localhost/liquidation/index.html
```

When the PHP/MySQL backend is available, records are saved in MySQL. If the backend is not available, the app still falls back to browser `localStorage`.

## Reset registered accounts

To clear registered accounts from MySQL, run/import:

```sql
reset_accounts.sql
```

Or open this through your PHP server:

```text
http://localhost/liquidation/reset_accounts.php
```

To clear accounts saved only in the browser, open DevTools Console on the app page and run:

```js
localStorage.removeItem("cashAdvanceAccounts");
localStorage.removeItem("cashAdvanceSession");
location.reload();
```
