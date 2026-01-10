<template>
  <div class="orders-management">
    <div class="page-header">
      <h1>订单管理</h1>
      <p class="subtitle">查看和管理所有票务订单</p>
    </div>

    <!-- Filters -->
    <div class="filters-bar">
      <div class="search-box">
        <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
            d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
        <input 
          v-model="searchQuery" 
          type="text" 
          placeholder="搜索订单（姓名、邮箱、电话）..."
          @input="debouncedSearch"
        />
      </div>

      <div class="filter-tabs">
        <button 
          v-for="tab in statusTabs" 
          :key="tab.value"
          :class="['filter-tab', { active: currentStatus === tab.value }]"
          @click="filterByStatus(tab.value)"
        >
          {{ tab.label }}
          <span v-if="tab.count !== undefined" class="tab-count">{{ tab.count }}</span>
        </button>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="stats-grid">
      <div class="stat-card pending">
        <div class="stat-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
              d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.pending }}</span>
          <span class="stat-label">待支付</span>
        </div>
      </div>
      <div class="stat-card paid">
        <div class="stat-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
              d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.paid }}</span>
          <span class="stat-label">已支付</span>
        </div>
      </div>
      <div class="stat-card expired">
        <div class="stat-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
              d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.expired }}</span>
          <span class="stat-label">已过期</span>
        </div>
      </div>
      <div class="stat-card total">
        <div class="stat-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
              d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.pickedUp }}</span>
          <span class="stat-label">已取票</span>
        </div>
      </div>
      <div class="stat-card revenue">
        <div class="stat-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
              d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <div class="stat-info">
          <span class="stat-value">${{ stats.totalRevenue }}</span>
          <span class="stat-label">总收入</span>
        </div>
      </div>
    </div>

    <!-- Orders Table -->
    <div class="orders-table-container">
      <div v-if="loading" class="loading-state">
        <div class="spinner"></div>
        <span>加载中...</span>
      </div>

      <table v-else class="orders-table">
        <thead>
          <tr>
            <th>订单编号</th>
            <th>客户信息</th>
            <th>座位</th>
            <th>金额</th>
            <th>状态</th>
            <th>时间</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="order in orders" :key="order.id">
            <td class="order-id">
              <span class="id-text">#{{ order.id.substring(0, 8).toUpperCase() }}</span>
            </td>
            <td class="customer-info">
              <div class="customer-name">{{ order.customer_name }}</div>
              <div class="customer-contact">{{ order.customer_email }}</div>
              <div class="customer-contact">{{ order.customer_phone }}</div>
            </td>
            <td class="seats-info">
              <div class="seats-list">
                <span 
                  v-for="rs in order.reservation_seats.slice(0, 3)" 
                  :key="rs.seat_id"
                  class="seat-tag"
                >
                  {{ formatSeat(rs.seats) }}
                </span>
                <span v-if="order.reservation_seats.length > 3" class="seat-more">
                  +{{ order.reservation_seats.length - 3 }}
                </span>
              </div>
            </td>
            <td class="amount">${{ order.total_amount }}</td>
            <td>
              <span :class="['status-badge', order.status]">
                {{ getStatusText(order.status) }}
              </span>
            </td>
            <td class="time-info">
              <div class="created-time">{{ formatDate(order.created_at) }}</div>
              <div v-if="order.status === 'pending'" class="expires-time">
                过期：{{ formatDate(order.expires_at) }}
              </div>
            </td>
            <td class="actions">
              <div class="action-buttons">
                <button 
                  v-if="order.status === 'pending'"
                  class="action-btn confirm"
                  @click="confirmPayment(order)"
                  :disabled="actionLoading === order.id"
                >
                  确认支付
                </button>
                <button 
                  v-if="order.status === 'pending'"
                  class="action-btn cancel"
                  @click="cancelOrder(order)"
                  :disabled="actionLoading === order.id"
                >
                  取消
                </button>
                <button 
                  v-if="order.status === 'paid'"
                  class="action-btn pickup"
                  @click="pickUpTicket(order)"
                  :disabled="actionLoading === order.id"
                >
                  取票
                </button>
                <button 
                  class="action-btn view"
                  @click="viewOrder(order)"
                >
                  详情
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="!loading && orders.length === 0" class="empty-state">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
            d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
        </svg>
        <p>暂无订单记录</p>
      </div>
    </div>

    <!-- Pagination -->
    <div v-if="totalPages > 1" class="pagination">
      <button 
        class="page-btn" 
        :disabled="currentPage === 1"
        @click="goToPage(currentPage - 1)"
      >
        上一页
      </button>
      <span class="page-info">第 {{ currentPage }} / {{ totalPages }} 页</span>
      <button 
        class="page-btn" 
        :disabled="currentPage === totalPages"
        @click="goToPage(currentPage + 1)"
      >
        下一页
      </button>
    </div>

    <!-- Order Detail Modal -->
    <div v-if="selectedOrder" class="modal-overlay" @click.self="closeModal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>订单详情</h2>
          <button class="close-btn" @click="closeModal">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <div class="modal-body">
          <div class="detail-section">
            <h3>客户信息</h3>
            <div class="detail-grid">
              <div class="detail-item">
                <span class="label">姓名</span>
                <span class="value">{{ selectedOrder.customer_name }}</span>
              </div>
              <div class="detail-item">
                <span class="label">邮箱</span>
                <span class="value">{{ selectedOrder.customer_email }}</span>
              </div>
              <div class="detail-item">
                <span class="label">电话</span>
                <span class="value">{{ selectedOrder.customer_phone }}</span>
              </div>
            </div>
          </div>
          <div class="detail-section">
            <h3>座位信息</h3>
            <div class="seats-detail">
              <span 
                v-for="rs in selectedOrder.reservation_seats" 
                :key="rs.seat_id"
                class="seat-tag-lg"
              >
                {{ formatSeat(rs.seats) }}
              </span>
            </div>
          </div>
          <div class="detail-section">
            <h3>订单信息</h3>
            <div class="detail-grid">
              <div class="detail-item">
                <span class="label">订单编号</span>
                <span class="value">{{ selectedOrder.id }}</span>
              </div>
              <div class="detail-item">
                <span class="label">总金额</span>
                <span class="value amount">${{ selectedOrder.total_amount }}</span>
              </div>
              <div class="detail-item">
                <span class="label">状态</span>
                <span :class="['status-badge', selectedOrder.status]">{{ getStatusText(selectedOrder.status) }}</span>
              </div>
              <div class="detail-item">
                <span class="label">创建时间</span>
                <span class="value">{{ formatDateTime(selectedOrder.created_at) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { getAllReservations, updateReservationStatus, sendPaymentConfirmationBackend, getTotalRevenueByStatuses } from '@/supabase'
import { formatSeat } from '@/composables/useSeatFormat'

export default {
  name: 'OrdersManagement',
  data() {
    return {
      orders: [],
      loading: true,
      currentPage: 1,
      pageSize: 20,
      totalCount: 0,
      currentStatus: null,
      searchQuery: '',
      searchTimeout: null,
      actionLoading: null,
      selectedOrder: null,
      stats: {
        pending: 0,
        paid: 0,
        expired: 0,
        cancelled: 0,
        pickedUp: 0,
        totalRevenue: 0
      }
    }
  },
  computed: {
    totalPages() {
      return Math.ceil(this.totalCount / this.pageSize)
    },
    statusTabs() {
      return [
        { label: '全部', value: null },
        { label: '待支付', value: 'pending', count: this.stats.pending },
        { label: '已支付', value: 'paid', count: this.stats.paid },
        { label: '已取票', value: 'picked_up', count: this.stats.pickedUp },
        { label: '已过期', value: 'expired', count: this.stats.expired },
        { label: '已取消', value: 'cancelled', count: this.stats.cancelled }
      ]
    }
  },
  mounted() {
    this.loadOrders()
    this.loadStats()
  },
  methods: {
    formatSeat,
    async loadOrders() {
      this.loading = true
      try {
        const result = await getAllReservations({
          page: this.currentPage,
          pageSize: this.pageSize,
          status: this.currentStatus,
          search: this.searchQuery
        })
        this.orders = result.data || []
        this.totalCount = result.count || 0
      } catch (err) {
        console.error('Failed to load orders:', err)
      } finally {
        this.loading = false
      }
    },
    async loadStats() {
      try {
        // Load stats for each status
        const [pending, paid, pickedUp, expired, cancelled] = await Promise.all([
          getAllReservations({ status: 'pending', pageSize: 1 }),
          getAllReservations({ status: 'paid', pageSize: 1 }),
          getAllReservations({ status: 'picked_up', pageSize: 1 }),
          getAllReservations({ status: 'expired', pageSize: 1 }),
          getAllReservations({ status: 'cancelled', pageSize: 1 })
        ])
        
        this.stats.pending = pending.count || 0
        this.stats.paid = paid.count || 0
        this.stats.pickedUp = pickedUp.count || 0
        this.stats.expired = expired.count || 0
        this.stats.cancelled = cancelled.count || 0

        // Calculate total revenue using SQL aggregation
        const totalRevenue = await getTotalRevenueByStatuses(['paid', 'picked_up'])
        this.stats.totalRevenue = totalRevenue.toFixed(2)
      } catch (err) {
        console.error('Failed to load stats:', err)
      }
    },
    debouncedSearch() {
      if (this.searchTimeout) clearTimeout(this.searchTimeout)
      this.searchTimeout = setTimeout(() => {
        this.currentPage = 1
        this.loadOrders()
      }, 300)
    },
    filterByStatus(status) {
      this.currentStatus = status
      this.currentPage = 1
      this.loadOrders()
    },
    goToPage(page) {
      this.currentPage = page
      this.loadOrders()
    },
    async confirmPayment(order) {
      if (!confirm(`确认将订单 #${order.id.substring(0, 8).toUpperCase()} 标记为已支付？`)) return

      this.actionLoading = order.id
      try {
        // 1. Update reservation status
        await updateReservationStatus(order.id, 'paid')

        // 2. Send payment confirmation email
        try {
          await sendPaymentConfirmationBackend(order.id)
          console.log(`Payment confirmation email sent to ${order.customer_email}`)
        } catch (emailError) {
          console.error('Failed to send payment confirmation email:', emailError)
          // Don't fail the entire operation if email sending fails
        }

        // 3. Refresh data
        await this.loadOrders()
        await this.loadStats()
      } catch (err) {
        console.error('Failed to confirm payment:', err)
        alert('操作失败，请重试')
      } finally {
        this.actionLoading = null
      }
    },
    async cancelOrder(order) {
      if (!confirm(`确认取消订单 #${order.id.substring(0, 8).toUpperCase()}？座位将被释放。`)) return
      
      this.actionLoading = order.id
      try {
        await updateReservationStatus(order.id, 'cancelled')
        await this.loadOrders()
        await this.loadStats()
      } catch (err) {
        console.error('Failed to cancel order:', err)
        alert('操作失败，请重试')
      } finally {
        this.actionLoading = null
      }
    },
    async pickUpTicket(order) {
      if (!confirm(`确认将订单 #${order.id.substring(0, 8).toUpperCase()} 标记为已取票？`)) return
      
      this.actionLoading = order.id
      try {
        await updateReservationStatus(order.id, 'picked_up')
        await this.loadOrders()
        await this.loadStats()
      } catch (err) {
        console.error('Failed to mark as picked up:', err)
        alert('操作失败，请重试')
      } finally {
        this.actionLoading = null
      }
    },
    viewOrder(order) {
      this.selectedOrder = order
    },
    closeModal() {
      this.selectedOrder = null
    },
    getStatusText(status) {
      const map = {
        pending: '待支付',
        paid: '已支付',
        picked_up: '已取票',
        expired: '已过期',
        cancelled: '已取消'
      }
      return map[status] || status
    },
    formatDate(dateStr) {
      if (!dateStr) return ''
      const date = new Date(dateStr)
      return date.toLocaleDateString('zh-CN', { month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' })
    },
    formatDateTime(dateStr) {
      if (!dateStr) return ''
      const date = new Date(dateStr)
      return date.toLocaleString('zh-CN')
    }
  }
}
</script>

<style scoped>
.orders-management {
  color: #fff;
}

.page-header {
  margin-bottom: 24px;
}

.page-header h1 {
  font-size: 28px;
  font-weight: 600;
  margin: 0 0 8px;
}

.subtitle {
  color: rgba(255, 255, 255, 0.5);
  font-size: 14px;
  margin: 0;
}

/* Filters */
.filters-bar {
  display: flex;
  gap: 16px;
  margin-bottom: 24px;
  flex-wrap: wrap;
}

.search-box {
  position: relative;
  flex: 1;
  min-width: 280px;
}

.search-icon {
  position: absolute;
  left: 14px;
  top: 50%;
  transform: translateY(-50%);
  width: 18px;
  height: 18px;
  color: rgba(255, 255, 255, 0.4);
}

.search-box input {
  width: 100%;
  padding: 12px 16px 12px 44px;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
  font-size: 14px;
}

.search-box input::placeholder {
  color: rgba(255, 255, 255, 0.3);
}

.search-box input:focus {
  outline: none;
  border-color: #e94560;
}

.filter-tabs {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.filter-tab {
  padding: 10px 16px;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.03);
  color: rgba(255, 255, 255, 0.6);
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 6px;
}

.filter-tab:hover {
  background: rgba(255, 255, 255, 0.08);
  color: #fff;
}

.filter-tab.active {
  background: rgba(233, 69, 96, 0.15);
  border-color: rgba(233, 69, 96, 0.4);
  color: #e94560;
}

.tab-count {
  font-size: 12px;
  padding: 2px 6px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 10px;
}

.filter-tab.active .tab-count {
  background: rgba(233, 69, 96, 0.3);
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-icon svg {
  width: 24px;
  height: 24px;
}

.stat-card.pending .stat-icon {
  background: rgba(255, 193, 7, 0.15);
  color: #ffc107;
}

.stat-card.paid .stat-icon {
  background: rgba(76, 175, 80, 0.15);
  color: #4caf50;
}

.stat-card.expired .stat-icon {
  background: rgba(244, 67, 54, 0.15);
  color: #f44336;
}

.stat-card.total .stat-icon {
  background: rgba(33, 150, 243, 0.15);
  color: #2196f3;
}

.stat-info {
  display: flex;
  flex-direction: column;
}

.stat-value {
  font-size: 24px;
  font-weight: 600;
}

.stat-label {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.5);
}

/* Orders Table */
.orders-table-container {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  overflow: hidden;
}

.loading-state {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 60px;
  color: rgba(255, 255, 255, 0.5);
}

.spinner {
  width: 24px;
  height: 24px;
  border: 2px solid rgba(255, 255, 255, 0.1);
  border-top-color: #e94560;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.orders-table {
  width: 100%;
  border-collapse: collapse;
}

.orders-table th {
  text-align: left;
  padding: 14px 16px;
  font-size: 13px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.5);
  background: rgba(255, 255, 255, 0.02);
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.orders-table td {
  padding: 14px 16px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.03);
  vertical-align: top;
}

.orders-table tr:hover {
  background: rgba(255, 255, 255, 0.02);
}

.order-id .id-text {
  font-family: monospace;
  font-size: 13px;
  color: #e94560;
}

.customer-info .customer-name {
  font-weight: 500;
  margin-bottom: 4px;
}

.customer-info .customer-contact {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.5);
}

.seats-list {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.seat-tag {
  font-size: 11px;
  padding: 3px 6px;
  background: rgba(255, 255, 255, 0.08);
  border-radius: 4px;
  color: rgba(255, 255, 255, 0.8);
}

.seat-more {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.5);
}

.amount {
  font-weight: 600;
  color: #4caf50;
}

.status-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.status-badge.pending {
  background: rgba(255, 193, 7, 0.15);
  color: #ffc107;
}

.status-badge.paid {
  background: rgba(76, 175, 80, 0.15);
  color: #4caf50;
}

.status-badge.picked_up {
  background: rgba(156, 39, 176, 0.15);
  color: #9c27b0;
}

.status-badge.expired {
  background: rgba(244, 67, 54, 0.15);
  color: #f44336;
}

.status-badge.cancelled {
  background: rgba(158, 158, 158, 0.15);
  color: #9e9e9e;
}

.time-info {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.7);
}

.expires-time {
  font-size: 12px;
  color: rgba(255, 193, 7, 0.8);
  margin-top: 4px;
}

.action-buttons {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.action-btn {
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
  border: none;
  transition: all 0.3s ease;
}

.action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.action-btn.confirm {
  background: rgba(76, 175, 80, 0.15);
  color: #4caf50;
}

.action-btn.confirm:hover:not(:disabled) {
  background: rgba(76, 175, 80, 0.25);
}

.action-btn.cancel {
  background: rgba(244, 67, 54, 0.15);
  color: #f44336;
}

.action-btn.cancel:hover:not(:disabled) {
  background: rgba(244, 67, 54, 0.25);
}

.action-btn.view {
  background: rgba(33, 150, 243, 0.15);
  color: #2196f3;
}

.action-btn.view:hover {
  background: rgba(33, 150, 243, 0.25);
}

.action-btn.pickup {
  background: rgba(156, 39, 176, 0.15);
  color: #9c27b0;
}

.action-btn.pickup:hover:not(:disabled) {
  background: rgba(156, 39, 176, 0.25);
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px;
  color: rgba(255, 255, 255, 0.4);
}

.empty-state svg {
  width: 48px;
  height: 48px;
  margin-bottom: 16px;
}

/* Pagination */
.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
  margin-top: 24px;
}

.page-btn {
  padding: 8px 16px;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.page-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.1);
}

.page-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.page-info {
  color: rgba(255, 255, 255, 0.6);
  font-size: 14px;
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal-content {
  background: #1a1a2e;
  border-radius: 16px;
  width: 100%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 24px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.modal-header h2 {
  font-size: 18px;
  font-weight: 600;
  margin: 0;
}

.close-btn {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  border: none;
  background: rgba(255, 255, 255, 0.05);
  color: rgba(255, 255, 255, 0.6);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
}

.close-btn svg {
  width: 18px;
  height: 18px;
}

.modal-body {
  padding: 24px;
}

.detail-section {
  margin-bottom: 24px;
}

.detail-section:last-child {
  margin-bottom: 0;
}

.detail-section h3 {
  font-size: 14px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.5);
  margin: 0 0 12px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 12px;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.detail-item .label {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.4);
}

.detail-item .value {
  font-size: 14px;
  color: #fff;
  word-break: break-all;
}

.detail-item .value.amount {
  font-size: 18px;
  font-weight: 600;
  color: #4caf50;
}

.seats-detail {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.seat-tag-lg {
  padding: 8px 12px;
  background: rgba(255, 255, 255, 0.08);
  border-radius: 8px;
  font-size: 13px;
}
</style>
