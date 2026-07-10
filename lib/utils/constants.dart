/// App-wide constants: storage keys, URLs, dropdown options.
///
/// BASE URL NOTE:
///   - Android Emulator  → 10.0.2.2 maps to host machine's localhost
///   - Physical Device   → Replace with your machine's LAN IP, e.g. 192.168.1.100
const String kBaseUrl = 'https://orderly-backend-qmgi.onrender.com/api';

// ── Secure Storage Keys ─────────────────────────────────────────────────────
const String kTokenKey    = 'jwt_token';
const String kRoleKey     = 'user_role';
const String kUserIdKey   = 'user_id';
const String kUserNameKey = 'user_name';

// ── Static Dropdown Options ──────────────────────────────────────────────────
const List<String> kPaymentModes = [
  'Cash',
  'Cheque',
  'Next Visit',
  'UPI',
  'Bank Transfer',
];

const List<String> kRoles = [
  'Admin',
  'Employee',
  'Salesman',
];

const List<String> kShopNameOptions = [
  'AAGAM ET', 
  'VARDHMAN MT',
];
