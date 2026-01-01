<template>
	<div id="header" class="flex w-full h-11 md:h-14 bg-gradient-to-r from-primary to-primary-light text-white">
		<!-- <div class="back" v-show="showLeft" @click="backClick"> 返回</div> -->
		<slot name='leftView'><div class="w-16 md:w-20 h-full text-center leading-11 md:leading-14 text-sm md:text-base"></div></slot>
		<slot name='titleView'><div class="flex-1 h-full text-center text-base md:text-lg leading-11 md:leading-14">{{titleText}}</div></slot>
		<slot name='rightView'><div class="w-16 md:w-20 h-full text-center pr-2 text-base md:text-lg leading-11 md:leading-14 text-white"></div></slot>
		<slot></slot>
	</div>
</template>

<script>
export default {
  name: '',
  props: {
    showLeft: Number,
    titleText: String,
    rightText: String
  },
  data () {
    return {

    }
  },
  methods: {
  }
}
</script>

<style scoped>
/* Custom line-height utilities for header */
.leading-11 {
  line-height: 2.75rem;
}
.leading-14 {
  line-height: 3.5rem;
}
@media (min-width: 768px) {
  .md\:leading-11 {
    line-height: 2.75rem;
  }
  .md\:leading-14 {
    line-height: 3.5rem;
  }
}
</style>
