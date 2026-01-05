<template>
  <Transition name="fade">
    <div v-if="show" class="modal-overlay" @click.self="$emit('cancel')">
      <Transition name="bounce">
        <div v-if="show" class="modal-content">
          <div class="modal-header">
            <h3>{{ title }}</h3>
            <button class="close-btn" @click="$emit('cancel')">&times;</button>
          </div>
          <div class="modal-body">
            <p>{{ message }}</p>
          </div>
          <div class="modal-footer">
            <button class="modal-btn cancel" @click="$emit('cancel')">{{ cancelText }}</button>
            <button class="modal-btn confirm" :class="type" @click="$emit('confirm')">{{ confirmText }}</button>
          </div>
        </div>
      </Transition>
    </div>
  </Transition>
</template>

<script>
export default {
  name: 'ConfirmModal',
  props: {
    show: { type: Boolean, required: true },
    title: { type: String, default: '确认操作' },
    message: { type: String, required: true },
    confirmText: { type: String, default: '确定' },
    cancelText: { type: String, default: '取消' },
    type: { type: String, default: 'primary' } // primary, danger
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
}

.modal-content {
  background: #1a1a2e;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 16px;
  width: 90%;
  max-width: 400px;
  padding: 24px;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.modal-header h3 {
  margin: 0;
  font-size: 18px;
  color: #fff;
}

.close-btn {
  background: none;
  border: none;
  color: rgba(255, 255, 255, 0.5);
  font-size: 24px;
  cursor: pointer;
  transition: color 0.3s;
}

.close-btn:hover {
  color: #fff;
}

.modal-body {
  margin-bottom: 24px;
  color: rgba(255, 255, 255, 0.8);
  font-size: 15px;
  line-height: 1.5;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.modal-btn {
  padding: 10px 20px;
  border-radius: 8px;
  border: none;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.modal-btn.cancel {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
}

.modal-btn.cancel:hover {
  background: rgba(255, 255, 255, 0.15);
}

.modal-btn.confirm.primary {
  background: #2196f3;
  color: #fff;
}

.modal-btn.confirm.primary:hover {
  background: #42a5f5;
}

.modal-btn.confirm.danger {
  background: #e94560;
  color: #fff;
}

.modal-btn.confirm.danger:hover {
  background: #ff4d6d;
}

/* Animations */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

.bounce-enter-active {
  animation: bounce-in 0.4s;
}
.bounce-leave-active {
  animation: bounce-in 0.3s reverse;
}

@keyframes bounce-in {
  0% { transform: scale(0.9); opacity: 0; }
  60% { transform: scale(1.05); }
  100% { transform: scale(1); opacity: 1; }
}
</style>
