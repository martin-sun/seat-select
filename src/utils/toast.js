import { reactive } from 'vue'

const state = reactive({
    toasts: []
})

let nextId = 0

export const toast = {
    success(message, duration = 3000) {
        this.add(message, 'success', duration)
    },
    error(message, duration = 5000) {
        this.add(message, 'error', duration)
    },
    info(message, duration = 3000) {
        this.add(message, 'info', duration)
    },
    warning(message, duration = 4000) {
        this.add(message, 'warning', duration)
    },
    add(message, type = 'info', duration = 3000) {
        const id = nextId++
        const toast = { id, message, type, duration }
        state.toasts.push(toast)

        if (duration > 0) {
            setTimeout(() => {
                this.remove(id)
            }, duration)
        }
    },
    remove(id) {
        const index = state.toasts.findIndex(t => t.id === id)
        if (index !== -1) {
            state.toasts.splice(index, 1)
        }
    },
    state
}

export default toast
