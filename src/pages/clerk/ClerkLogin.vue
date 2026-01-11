<template>
  <div class="clerk-login">
    <div class="login-container">
      <div class="login-card">
        <div class="login-header">
          <div class="logo">
            <svg class="logo-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z" />
            </svg>
          </div>
          <h1>取票管理</h1>
          <p class="subtitle">春晚票务取票系统</p>
        </div>

        <form @submit.prevent="handleLogin" class="login-form">
          <div class="form-group">
            <label for="email">取票员邮箱</label>
            <input
              id="email"
              v-model="email"
              type="email"
              placeholder="clerk@chunwan.com"
              :disabled="loading"
              required
            />
          </div>

          <div class="form-group">
            <label for="password">密码</label>
            <input
              id="password"
              v-model="password"
              type="password"
              placeholder="请输入密码"
              :disabled="loading"
              required
            />
          </div>

          <p v-if="error" class="error-message">{{ error }}</p>

          <button type="submit" class="login-btn" :disabled="loading">
            <span v-if="loading" class="loading-spinner"></span>
            <span v-else>登录</span>
          </button>
        </form>

        <div class="login-footer">
          <a href="/" class="back-link">← 返回首页</a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { clerkLogin, isClerkLoggedIn } from '@/supabase'

export default {
  name: 'ClerkLogin',
  data() {
    return {
      email: '',
      password: '',
      loading: false,
      error: ''
    }
  },
  mounted() {
    // If already logged in, redirect to dashboard
    if (isClerkLoggedIn()) {
      this.$router.push('/clerk/orders')
    }
  },
  methods: {
    async handleLogin() {
      this.error = ''
      this.loading = true

      try {
        const result = await clerkLogin(this.email, this.password)

        if (result.success) {
          this.$router.push('/clerk/orders')
        } else {
          this.error = result.error || '登录失败'
        }
      } catch (err) {
        console.error('Login error:', err)
        this.error = '登录失败，请稍后重试'
      } finally {
        this.loading = false
      }
    }
  }
}
</script>

<style scoped>
.clerk-login {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
  padding: 20px;
}

.login-container {
  width: 100%;
  max-width: 400px;
}

.login-card {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  padding: 40px;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.login-header {
  text-align: center;
  margin-bottom: 32px;
}

.logo {
  width: 64px;
  height: 64px;
  margin: 0 auto 16px;
  background: linear-gradient(135deg, #4CAF50 0%, #8BC34A 100%);
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.logo-icon {
  width: 36px;
  height: 36px;
  color: white;
}

.login-header h1 {
  color: #fff;
  font-size: 24px;
  font-weight: 600;
  margin: 0 0 8px;
}

.subtitle {
  color: rgba(255, 255, 255, 0.6);
  font-size: 14px;
  margin: 0;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  color: rgba(255, 255, 255, 0.8);
  font-size: 14px;
  font-weight: 500;
}

.form-group input {
  padding: 14px 16px;
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
  font-size: 16px;
  transition: all 0.3s ease;
}

.form-group input::placeholder {
  color: rgba(255, 255, 255, 0.3);
}

.form-group input:focus {
  outline: none;
  border-color: #4CAF50;
  background: rgba(255, 255, 255, 0.08);
  box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.2);
}

.form-group input:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error-message {
  color: #ff6b6b;
  font-size: 14px;
  text-align: center;
  margin: 0;
  padding: 12px;
  background: rgba(255, 107, 107, 0.1);
  border-radius: 8px;
}

.login-btn {
  padding: 14px 24px;
  border-radius: 12px;
  border: none;
  background: linear-gradient(135deg, #4CAF50 0%, #8BC34A 100%);
  color: white;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.login-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(76, 175, 80, 0.3);
}

.login-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.login-footer {
  margin-top: 24px;
  text-align: center;
}

.back-link {
  color: rgba(255, 255, 255, 0.6);
  text-decoration: none;
  font-size: 14px;
  transition: color 0.3s ease;
}

.back-link:hover {
  color: #fff;
}
</style>
