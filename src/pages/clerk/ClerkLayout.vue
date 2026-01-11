<template>
  <div class="clerk-layout">
    <!-- Sidebar -->
    <aside class="sidebar">
      <div class="sidebar-header">
        <div class="logo">
          <svg class="logo-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z" />
          </svg>
        </div>
        <h2>取票管理</h2>
      </div>

      <nav class="sidebar-nav">
        <router-link to="/clerk/orders" class="nav-item" :class="{ active: $route.path === '/clerk/orders' }">
          <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" />
          </svg>
          <span>订单管理</span>
        </router-link>
      </nav>

      <div class="sidebar-footer">
        <div class="clerk-info">
          <div class="clerk-avatar">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
            </svg>
          </div>
          <div class="clerk-details">
            <span class="clerk-name">{{ clerkName }}</span>
            <span class="clerk-email">{{ clerkEmail }}</span>
          </div>
        </div>
        <button @click="handleLogout" class="logout-btn">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
          <span>退出登录</span>
        </button>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
      <router-view />
    </main>
  </div>
</template>

<script>
import { getClerkSession, clerkLogout } from '@/supabase'

export default {
  name: 'ClerkLayout',
  computed: {
    clerkName() {
      const session = getClerkSession()
      return session?.name || '取票员'
    },
    clerkEmail() {
      const session = getClerkSession()
      return session?.email || ''
    }
  },
  methods: {
    handleLogout() {
      clerkLogout()
      this.$router.push('/clerk/login')
    }
  }
}
</script>

<style scoped>
.clerk-layout {
  display: flex;
  min-height: 100vh;
  background: #0f0f23;
}

/* Sidebar */
.sidebar {
  width: 260px;
  background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%);
  border-right: 1px solid rgba(255, 255, 255, 0.05);
  display: flex;
  flex-direction: column;
  position: fixed;
  height: 100vh;
  z-index: 100;
}

.sidebar-header {
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 12px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.logo {
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #4CAF50 0%, #8BC34A 100%);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.logo-icon {
  width: 24px;
  height: 24px;
  color: white;
}

.sidebar-header h2 {
  color: #fff;
  font-size: 18px;
  font-weight: 600;
  margin: 0;
}

.sidebar-nav {
  flex: 1;
  padding: 16px 12px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  border-radius: 10px;
  color: rgba(255, 255, 255, 0.6);
  text-decoration: none;
  transition: all 0.3s ease;
}

.nav-item:hover {
  color: #fff;
  background: rgba(255, 255, 255, 0.05);
}

.nav-item.active {
  color: #fff;
  background: linear-gradient(135deg, rgba(76, 175, 80, 0.2) 0%, rgba(139, 195, 74, 0.1) 100%);
  border: 1px solid rgba(76, 175, 80, 0.3);
}

.nav-icon {
  width: 20px;
  height: 20px;
}

.sidebar-footer {
  padding: 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
}

.clerk-info {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 10px;
  margin-bottom: 12px;
}

.clerk-avatar {
  width: 36px;
  height: 36px;
  background: rgba(76, 175, 80, 0.2);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.clerk-avatar svg {
  width: 20px;
  height: 20px;
  color: #4CAF50;
}

.clerk-details {
  display: flex;
  flex-direction: column;
  gap: 2px;
  flex: 1;
  overflow: hidden;
}

.clerk-name {
  color: #fff;
  font-size: 14px;
  font-weight: 500;
}

.clerk-email {
  color: rgba(255, 255, 255, 0.5);
  font-size: 12px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.logout-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  width: 100%;
  padding: 10px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  background: transparent;
  color: rgba(255, 255, 255, 0.6);
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.logout-btn:hover {
  color: #ff6b6b;
  border-color: rgba(255, 107, 107, 0.3);
  background: rgba(255, 107, 107, 0.1);
}

.logout-btn svg {
  width: 18px;
  height: 18px;
}

/* Main Content */
.main-content {
  flex: 1;
  margin-left: 260px;
  padding: 24px;
  background: #0f0f23;
  min-height: 100vh;
}
</style>
