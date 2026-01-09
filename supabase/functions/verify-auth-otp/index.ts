// Supabase Edge Function: Verify Auth OTP and Create/Update User
// Trigger: When user submits OTP code
// Creates or updates Supabase Auth user with language preference
// Returns a magic link token for frontend to create session

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
}

serve(async (req) => {
  // Handle CORS preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Parse request
    const { email, otpCode, language = 'en-US' } = await req.json()

    if (!email || !otpCode) {
      return new Response(JSON.stringify({ error: 'Missing email or otpCode' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 2. Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // 3. Verify OTP code
    const { data: otpRecord, error: otpError } = await supabase
      .from('auth_otps')
      .select('*')
      .eq('email', email.toLowerCase().trim())
      .eq('otp_code', otpCode)
      .gt('expires_at', new Date().toISOString())
      .maybeSingle()

    if (otpError || !otpRecord) {
      return new Response(JSON.stringify({ error: 'Invalid or expired OTP code' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 4. Delete the used OTP
    await supabase
      .from('auth_otps')
      .delete()
      .eq('id', otpRecord.id)

    // 5. Check if user exists using getUserByEmail
    const normalizedEmail = email.toLowerCase().trim()
    let foundUser = null
    let page = 1
    const perPage = 1000

    // Paginate through users to find matching email
    while (!foundUser) {
      const { data: usersData, error: listError } = await supabase.auth.admin.listUsers({
        page,
        perPage
      })

      if (listError) {
        console.error('Error listing users:', listError)
        break
      }

      foundUser = usersData.users.find(u => u.email.toLowerCase() === normalizedEmail)

      // If no user found and there are more pages, continue; otherwise stop
      if (!foundUser && usersData.users.length === perPage) {
        page++
      } else {
        break
      }
    }

    // 6. Generate a temporary password for login
    const tempPassword = crypto.randomUUID().substring(0, 32)
    let userId: string

    if (foundUser) {
      // Update existing user's language preference and reset password
      await supabase.auth.admin.updateUserById(foundUser.id, {
        password: tempPassword,
        user_metadata: {
          ...foundUser.user_metadata,
          preferred_language: language
        }
      })
      userId = foundUser.id
    } else {
      // Create new user
      const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
        email: normalizedEmail,
        email_confirm: true,
        password: tempPassword,
        user_metadata: {
          preferred_language: language
        }
      })

      if (createError) {
        console.error('Failed to create user:', createError)
        throw new Error('Failed to create user account')
      }
      userId = newUser.user.id
    }

    // 8. Return success with email and temp password for frontend to login
    return new Response(JSON.stringify({
      message: 'OTP verified successfully',
      email: email.toLowerCase().trim(),
      tempPassword,
      language,
      userCreated: !foundUser
    }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Error in verify-auth-otp:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})
