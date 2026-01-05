<template>
  <div id="app" class="min-h-screen bg-bg-gray">
    <router-view/>
    <Toast />
  </div>
</template>

<script>
import Toast from '@/components/Toast.vue'

export default {
  name: 'App',
  components: {
    Toast
  }
}
</script>

<style>
/* App-level styles if needed */
</style>
