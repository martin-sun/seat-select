

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
