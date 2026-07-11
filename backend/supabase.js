import { createClient } from '@supabase/supabase-js';

const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_KEY;

if (!url || !key) {
  console.error('SUPABASE_URL oder SUPABASE_SERVICE_KEY fehlt in .env');
}

export const supabase = createClient(url, key, {
  auth: { persistSession: false }
});
