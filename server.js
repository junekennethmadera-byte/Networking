const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const { URL } = require('node:url');
const { DatabaseSync } = require('node:sqlite');

const PORT = Number(process.env.PORT || 3000);
const ROOT = __dirname;
const PUBLIC_ROOT = path.join(ROOT, 'public');
const DATABASE_ROOT = path.join(ROOT, 'database');
const db = new DatabaseSync(path.join(DATABASE_ROOT, 'liquidation.db'));

db.exec(`
  PRAGMA foreign_keys = ON;
  CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE COLLATE NOCASE,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('Requester','FinSec','Treasurer')),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
  );
  CREATE UNIQUE INDEX IF NOT EXISTS one_finsec ON users(role) WHERE role = 'FinSec';
  CREATE UNIQUE INDEX IF NOT EXISTS one_treasurer ON users(role) WHERE role = 'Treasurer';
  CREATE TABLE IF NOT EXISTS cash_advance_requests (
    id TEXT PRIMARY KEY,
    reference_no TEXT NOT NULL UNIQUE,
    requester_id TEXT NOT NULL REFERENCES users(id),
    requester_name TEXT NOT NULL,
    requester_email TEXT NOT NULL,
    position TEXT,
    account_title TEXT NOT NULL,
    account_title_other TEXT,
    particulars TEXT NOT NULL,
    particulars_other TEXT,
    amount REAL NOT NULL CHECK (amount > 0),
    needed_by TEXT,
    notes TEXT,
    status TEXT NOT NULL DEFAULT 'pending_finsec_approval',
    submitted_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
  );
`);

const json = (res, status, data) => {
  res.writeHead(status, {'Content-Type': 'application/json; charset=utf-8', 'Access-Control-Allow-Origin': '*'});
  res.end(JSON.stringify(data));
};
const body = req => new Promise((resolve, reject) => {
  let raw = ''; req.on('data', chunk => { raw += chunk; });
  req.on('end', () => { try { resolve(raw ? JSON.parse(raw) : {}); } catch { reject(new Error('Invalid JSON')); } });
});
const hash = password => crypto.scryptSync(password, process.env.PASSWORD_SALT || 'liquidation-flow-local-salt', 32).toString('hex');
const id = () => crypto.randomUUID();
const safeUser = row => ({id: row.id, name: row.name, email: row.email, role: row.role, created_at: row.created_at});
const nextReference = () => {
  const row = db.prepare("SELECT COUNT(*) AS total FROM cash_advance_requests").get();
  return `CA-${String(Number(row.total) + 1).padStart(5, '0')}`;
};

async function api(req, res, url) {
  if (req.method === 'OPTIONS') { res.writeHead(204); return res.end(); }
  if (req.method === 'GET' && url.pathname === '/api/health') return json(res, 200, {ok: true, database: 'sqlite'});

  if (req.method === 'POST' && url.pathname === '/api/auth/register') {
    try {
      const data = await body(req);
      const role = data.role || 'Requester';
      if (!data.name || !data.email || !data.password) return json(res, 400, {error: 'Name, email, and password are required.'});
      if (data.password.length < 6) return json(res, 400, {error: 'Password must be at least 6 characters.'});
      const existing = db.prepare('SELECT id FROM users WHERE email = ?').get(data.email.trim().toLowerCase());
      if (existing) return json(res, 409, {error: 'Registration failed: email is already registered.'});
      if (!['Requester', 'FinSec', 'Treasurer'].includes(role)) return json(res, 400, {error: 'Invalid role.'});
      if (role !== 'Requester' && db.prepare('SELECT id FROM users WHERE role = ?').get(role)) return json(res, 409, {error: `Registration failed: ${role} account already exists.`});
      const user = {id: id(), name: data.name.trim(), email: data.email.trim().toLowerCase(), password_hash: hash(data.password), role};
      db.prepare('INSERT INTO users (id,name,email,password_hash,role) VALUES (?,?,?,?,?)').run(user.id, user.name, user.email, user.password_hash, user.role);
      return json(res, 201, {message: 'Registration successful.', user: safeUser(user)});
    } catch (error) { return json(res, 500, {error: error.message}); }
  }

  if (req.method === 'POST' && url.pathname === '/api/auth/login') {
    try {
      const data = await body(req); const user = db.prepare('SELECT * FROM users WHERE email = ?').get(String(data.email || '').trim().toLowerCase());
      if (!user || user.password_hash !== hash(String(data.password || ''))) return json(res, 401, {error: 'Login failed: invalid email or password.'});
      return json(res, 200, {message: 'Login successful.', user: safeUser(user)});
    } catch (error) { return json(res, 500, {error: error.message}); }
  }

  if (req.method === 'GET' && url.pathname === '/api/requests') {
    const rows = db.prepare('SELECT * FROM cash_advance_requests ORDER BY submitted_at DESC').all();
    return json(res, 200, rows);
  }

  if (req.method === 'POST' && url.pathname === '/api/requests') {
    try {
      const data = await body(req);
      if (!data.requester_id || !data.requester_name || !data.requester_email || !data.account_title || !data.amount) return json(res, 400, {error: 'Required request fields are missing.'});
      const request = {id: id(), reference_no: nextReference(), ...data, particulars: Array.isArray(data.particulars) ? JSON.stringify(data.particulars) : String(data.particulars), status: 'pending_finsec_approval'};
      db.prepare(`INSERT INTO cash_advance_requests (id,reference_no,requester_id,requester_name,requester_email,position,account_title,account_title_other,particulars,particulars_other,amount,needed_by,notes,status) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`).run(request.id, request.reference_no, request.requester_id, request.requester_name, request.requester_email, request.position || '', request.account_title, request.account_title_other || '', request.particulars, request.particulars_other || '', Number(request.amount), request.needed_by || '', request.notes || '', request.status);
      return json(res, 201, {message: 'Cash advance submitted successfully.', reference_no: request.reference_no});
    } catch (error) { return json(res, 500, {error: error.message}); }
  }

  return json(res, 404, {error: 'API route not found.'});
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  if (url.pathname.startsWith('/api/')) return api(req, res, url);
  if (req.method !== 'GET' && req.method !== 'HEAD') return json(res, 405, {error: 'Method not allowed.'});
  const requested = url.pathname === '/' ? '/cash_advance_supabase.html' : url.pathname;
  const file = path.resolve(PUBLIC_ROOT, `.${requested}`);
  if (!file.startsWith(PUBLIC_ROOT + path.sep) || !fs.existsSync(file)) return json(res, 404, {error: 'File not found.'});
  const types = {'.html':'text/html; charset=utf-8','.css':'text/css; charset=utf-8','.js':'text/javascript; charset=utf-8','.json':'application/json'};
  res.writeHead(200, {'Content-Type': types[path.extname(file)] || 'application/octet-stream'});
  if (req.method === 'GET') fs.createReadStream(file).pipe(res); else res.end();
});

server.listen(PORT, () => console.log(`Liquidation Flow running at http://localhost:${PORT}`));
